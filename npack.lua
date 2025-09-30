local async = require("vim._async")
local fs, uv, joinpath = vim.fs, vim.uv, vim.fs.joinpath
local fmt = string.format
local copcall = package.loaded.jit and pcall or require("coxpcall").pcall
local n_threads = 2 * #(uv.cpu_info() or { {} })
vim.g.is_npack_load = true

local is_headless = #vim.api.nvim_list_uis() == 0

local Terminal = {}

Terminal.colors = {
  reset = "\27[0m",
  black = "\27[30m",
  red = "\27[31m",
  green = "\27[32m",
  yellow = "\27[33m",
  blue = "\27[34m",
  magenta = "\27[35m",
  cyan = "\27[36m",
  white = "\27[37m",
  bright_black = "\27[90m",
  bright_red = "\27[91m",
  bright_green = "\27[92m",
  bright_yellow = "\27[93m",
  bright_blue = "\27[94m",
  bright_magenta = "\27[95m",
  bright_cyan = "\27[96m",
  bright_white = "\27[97m",
}

for _, color in ipairs(vim.tbl_keys(Terminal.colors)) do
  Terminal[color] = function(text)
    return not is_headless and text or Terminal.colors[color] .. text .. Terminal.colors.reset
  end
end

---@param name string
---@param data string
function Terminal.prefix(name, data)
  local prefix = string.rep(" ", 30 - #name) .. Terminal.cyan(name) .. " | "
  data = data:gsub("\r\n", "\n")
  data = prefix .. data
  data = data:gsub("(\n)([^\r])", "%1" .. prefix .. "%2")
  data = data:gsub("\r([^\n])", function(nextChar)
    if nextChar:sub(1, #prefix) == prefix then
      return "\r" .. nextChar
    else
      return "\r" .. prefix .. nextChar
    end
  end)
  return data
end

--- @param content string
local function write(content)
  if is_headless then
    io.write(content .. "\n")
  else
    print(content)
  end
end

-- ----------------------------------------------------------------------------

--- Check if a path exists
---@param path string
---@return boolean
local function path_exists(path) return uv.fs_stat(path) ~= nil end

---Convert module format to path format
---@param modname string module name in the format `foo.bar`
---@return string modpath module path in the format `foo/bar`
local function modname_to_path(modname) return joinpath(unpack(vim.split(modname, ".", { plain = true }))) end

---List lua submodules
---@param modname string module root name `foo.bar`
---@return string[] list of submodules in format `foo.bar.baz`
local function list_lua_submodules(modname, files_only)
  files_only = files_only or false
  ---@type string[]
  local modlist = {}
  local modpath = vim.api.nvim_get_runtime_file(joinpath("lua", modname_to_path(modname)), true)
  if #modpath > 0 then
    local dir = modpath[1]
    local handle = uv.fs_scandir(dir)
    while handle do
      local name, ty = uv.fs_scandir_next(handle)
      local path = joinpath(dir, name)
      ty = ty or uv.fs_stat(path).type
      if not name then
        break
      elseif ty == "directory" then
        if not files_only then
          local init_file = joinpath(dir, name, "init.lua")

          if uv.fs_stat(init_file) then
            local module = modname .. "." .. name
            modlist[#modlist + 1] = module
          end
        end
      elseif (ty == "file" or ty == "link") and name ~= "init.lua" and name:sub(-4) == ".lua" then
        local submodule_name = name:sub(1, -5)
        local module = modname .. "." .. submodule_name
        modlist[#modlist + 1] = module
      end
    end
  end
  return modlist
end

local function is_spec_list(spec)
  return #spec > 1 or vim.islist(spec) and #spec > 1 or (#spec == 1 and type(spec[1]) == "table")
end

local function normalize(spec, result)
  if is_spec_list(spec) then
    vim.iter(spec):each(function(sp) normalize(sp, result) end)
  elseif type(spec[1]) == "string" then
    result[spec[1]] = spec
  end
  return result
end

-- Git ------------------------------------------------------------------------

--- @async
--- @param cmd string[]
--- @param cwd? string
--- @return string
local function git_cmd(cmd, cwd)
  -- Use '-c gc.auto=0' to disable `stderr` "Auto packing..." messages
  cmd = vim.list_extend({ "git", "-c", "gc.auto=0" }, cmd)
  local sys_opts = { cwd = cwd, text = true, clear_env = true }
  local out = async.await(3, vim.system, cmd, sys_opts) --- @type vim.SystemCompleted
  async.await(1, vim.schedule)
  if out.code ~= 0 then error(out.stderr) end
  local stdout, stderr = assert(out.stdout), assert(out.stderr)
  if stderr ~= "" then vim.schedule(function() vim.notify(stderr:gsub("\n+$", ""), vim.log.levels.WARN) end) end
  return (stdout:gsub("\n+$", ""))
end

--- @async
--- @param url string
--- @param path string
local function git_clone(url, path)
  local cmd = { "clone", "--quiet", "--origin", "origin" }

  if vim.startswith(url, "file://") then
    cmd[#cmd + 1] = "--no-hardlinks"
  else
    local filter_args = { "--filter=blob:none", "--recurse-submodules", "--also-filter-submodules" }
    vim.list_extend(cmd, filter_args)
  end

  vim.list_extend(cmd, { "--origin", "origin", url, path })
  git_cmd(cmd, uv.cwd())
end

--- @async
--- @param rev string
--- @param path string
local function git_checkout(rev, path)
  git_cmd({ "checkout", "--quiet", rev }, path)
  local doc_dir = vim.fs.joinpath(path, "doc")
  vim.fn.delete(vim.fs.joinpath(doc_dir, "tags"))
  copcall(vim.cmd.helptags, { doc_dir, magic = { file = false } })
end

-- =====================================================================================================================
-- Main section

local dev_pack_path = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "dev")
local root_pack_path = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "haven")
vim.fn.mkdir(root_pack_path, "p")

-- If executed with '--clean' then config path does not exist and will not be able to find module paths
local config_path = vim.fn.stdpath("config")
if not vim.iter(vim.opt.runtimepath:get()):any(function(path) return path == config_path end) then
  vim.opt.runtimepath:prepend(config_path)
end

local plugins = vim
  .iter(list_lua_submodules("haven.plugins"))
  :fold({}, function(acc, mod) return normalize(require(mod), acc) end)

local opt_pins = vim.json.decode(table.concat(vim.fn.readfile("./opt.json"), "\n")).pins
local start_pins = vim.json.decode(table.concat(vim.fn.readfile("./start.json"), "\n")).pins

local function install(args)
  args = args or {}

  local function inner(name, pin, is_opt)
    local path_comp = is_opt and "opt" or "start"
    local path = vim.fs.joinpath(root_pack_path, path_comp, name)

    -- If I have a plugin in the dev path then I want to use that one and dont install from the packpath
    local dev_path = vim.fs.joinpath(dev_pack_path, path_comp, name)
    if path_exists(dev_path) then return end

    if path_exists(path) then
      -- check if the current rev is the one we want
      local current_rev = git_cmd({ "rev-list", "-1", "HEAD" }, path)
      if current_rev == pin.revision then
        -- write(Terminal.yellow("[" ..name .."] "..))
        write(Terminal.prefix(name, Terminal.green("up to date")))
        return
      end

      git_cmd({ "fetch", "--quiet", "--tags", "--force", "--recurse-submodules=yes", "origin" }, path)
      git_checkout(pin.revision, path)
      write(Terminal.prefix(name, fmt("%s -> %s", Terminal.red(current_rev), Terminal.magenta(pin.revision))))
      return
    end

    local url = fmt("https://github.com/%s/%s", pin.repository.owner, pin.repository.repo)
    git_clone(url, path)
    git_checkout(pin.revision, path)
    write(Terminal.prefix(name, fmt("Installed at rev %s", Terminal.magenta(pin.revision))))
  end

  local funs = {}
  vim.iter(start_pins):fold(funs, function(acc, name, pin)
    acc[#acc + 1] = function() inner(name, pin, false) end
    return acc
  end)
  vim.iter(opt_pins):fold(funs, function(acc, name, pin)
    acc[#acc + 1] = function() inner(name, pin, true) end
    return acc
  end)

  async.run(function() async.join(n_threads, funs) end):wait()
end

local function clean(args)
  args = args or {}

  -- List valid results which should not be cleaned
  local valid_pack_paths = vim.tbl_extend(
    "error",
    vim.iter(start_pins):fold({}, function(acc, name, _)
      acc[name] = vim.fs.joinpath(root_pack_path, "start", name)
      return acc
    end),
    vim.iter(opt_pins):fold({}, function(acc, name, _)
      acc[name] = vim.fs.joinpath(root_pack_path, "opt", name)
      return acc
    end)
  )

  local function list_dirs_from_path(path)
    local list = {}
    local handle = uv.fs_scandir(path)
    while handle do
      local name, ty = uv.fs_scandir_next(handle)
      if not name then break end

      local p = fs.joinpath(path, name)
      ty = ty or uv.fs_stat(path).type
      if ty == "directory" then list[name] = p end
    end
    return list
  end

  local function path_to_dev_path(path)
    local name = vim.fs.basename(path)
    local ty = vim.fs.basename(vim.fs.dirname(path))
    return vim.fs.joinpath(dev_pack_path, ty, name)
  end

  local cleanup_list = vim
    .iter(
      vim.tbl_extend(
        "error",
        list_dirs_from_path(fs.joinpath(root_pack_path, "start")),
        list_dirs_from_path(fs.joinpath(root_pack_path, "opt"))
      )
    )
    :filter(function(name, path)
      if not valid_pack_paths[name] then return true end
      if path_exists(path_to_dev_path(path)) then return true end
      return valid_pack_paths[name] ~= path
    end)
    :fold({}, function(acc, name, value)
      acc[name] = value
      return acc
    end)

  for name, dir in pairs(cleanup_list) do
    if not is_headless then
      local confirm = vim.fn.confirm(("Remove %s: '%s'"):format(name, dir), "&Yes\n&No", 2)
      if confirm == 1 then vim.fs.rm(dir, { force = true, recursive = true }) end
    else
      vim.fs.rm(dir, { force = true, recursive = true })
      print(fmt("Removed %s: %s", name, dir))
    end
  end
end

vim.api.nvim_create_user_command("PackInstall", function(opts)
  install(opts.fargs)
  if is_headless then vim.cmd("qa") end
end, {
  nargs = "*",
})

vim.api.nvim_create_user_command("PackClean", function(opts)
  clean(opts.fargs)
  if is_headless then vim.cmd("qa") end
end, {
  nargs = "*",
})
