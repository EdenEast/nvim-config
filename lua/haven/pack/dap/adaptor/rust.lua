local dap = require("dap")
local dutils = require("dap.utils")
local util = require("haven.pack.dap.util")

local function rust_crate()
  local metadata_json = vim.fn.system("cargo metadata --format-version 1 --no-deps")
  local metadata = vim.fn.json_decode(metadata_json)
  local target_dir = metadata.target_directory

  local results = {}
  for _, package in ipairs(metadata.packages) do
    for _, target in ipairs(package.targets) do
      if vim.tbl_contains(target.kind, "bin") then table.insert(results, target_dir .. "/debug/" .. target.name) end
    end
  end

  if #results == 1 then return results[1] end
  return util.user_select("Select target:", results)
end

local function lldb_init_commands()
  local rustc_sysroot = vim.fn.system("rustc --print sysroot"):gsub("\n", "")
  assert(vim.v.shell_error == 0, "failed to get rust sysroot using `rustc --print sysroot`: " .. rustc_sysroot)

  local script_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_lookup.py"
  local command_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_commands"
  return {
    ([[!command script import '%s']]):format(script_file),
    ([[command source '%s']]):format(command_file),
  }
end

dap.adapters.lldb_rust = {
  name = "lldb",
  type = "executable",
  attach = {
    pidProperty = "pid",
    pidSelect = "ask",
  },
  command = vim.fn.exepath("lldb-dap"),
  env = util.pass_env({
    LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES",
  }),
  initCommands = lldb_init_commands(),
}

dap.configurations.rust = {
  {
    name = "Debug Crate",
    type = "lldb_rust",
    request = "launch",
    cwd = "${workspaceFolder}",
    stopOnEntry = true,
    program = function()
      local env_bin = vim.fn.environ()["RUST_DEBUG_BINARY"]
      if env_bin then return vim.fs.joinpath(vim.fn.getcwd(), env_bin) end
      return rust_crate()
    end,
    args = function()
      local args = vim.fn.environ()["RUST_DEBUG_ARGS"]
      if args ~= nil then return vim.split(args, " ") end

      local co = coroutine.running()
      vim.ui.input({
        prompt = "Args: ",
        relative = "win",
      }, function(input) coroutine.resume(co, vim.split(input or "", " ")) end)

      return coroutine.yield()
    end,
  },
  {
    -- If you get an "Operation not permitted" error using this, try disabling YAMA:
    --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    name = "Attach",
    type = "lldb",
    request = "attach",
    pid = dutils.pick_process,
    args = {},
  },
}
