local fs = vim.fs
local uv = vim.uv
local M = {}

---Convert module format to path format
---@param modname string module name in the format `foo.bar`
---@return string modpath module path in the format `foo/bar`
function M.modname_to_path(modname) return fs.joinpath(unpack(vim.split(modname, ".", { plain = true }))) end

---List lua submodules
---@param modname string module root name `foo.bar`
---@param cb fun(module: string)|nil
---@return string[] list of submodules in format `foo.bar.baz`
function M.list_lua_submodules(modname, cb)
  ---@type string[]
  local modlist = {}
  local modpath = vim.api.nvim_get_runtime_file(fs.joinpath("lua", M.modname_to_path(modname)), true)
  if #modpath > 0 then
    local dir = modpath[1]
    local handle = uv.fs_scandir(dir)
    while handle do
      local name, ty = uv.fs_scandir_next(handle)
      local path = fs.joinpath(dir, name)
      ty = ty or uv.fs_stat(path).type
      if not name then
        break
      elseif (ty == "file" or ty == "link") and name ~= "init.lua" and name:sub(-4) == ".lua" then
        local submodule_name = name:sub(1, -5)
        local module = modname .. "." .. submodule_name
        modlist[#modlist + 1] = module
        if cb then cb(module) end
      end
    end
  end
  return modlist
end

local enabled_lsp_servers = {}
function M.enable_lsp(server)
  if enabled_lsp_servers[server] then return end

  enabled_lsp_servers[server] = true
  vim.lsp.enable(server)
  -- As lsp's attach on filetype the filetype autocmd has already happened. As we just enabled the lsp server
  -- the filetype autocmd needs to be retriggered.
  vim.schedule(function() vim.cmd.doautocmd("FileType") end)
end

local loaded_list = {}
---Trigger load if plugin has not been loaded by lz.n
---@generic T
---@param module string lua module to be required
---@param plugin_name string plugin to be loaded by lz.n
---@return T
function M.require_or_trigger_load(module, plugin_name)
  if not loaded_list[plugin_name] then
    require("lz.n").trigger_load(plugin_name)
    loaded_list[plugin_name] = true
  end
  return require(module)
end

return M
