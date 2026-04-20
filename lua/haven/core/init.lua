vim.loader.enable()

-- When running as nvim-haven, the standard nvim data paths are not in the packpath, so prepend the
-- default nvim dev pack dir to pick up locally developed plugins from the standard location.
if vim.env.NVIM_APPNAME and vim.env.NVIM_APPNAME ~= "nvim" then
  vim.opt.packpath:prepend(vim.fs.joinpath(os.getenv("HOME"), ".local", "share", "nvim", "site", "pack", "dev"))
end

---Benchmark function by executing the function
---@param label string name of benchmark
---@param f fun() Fucntion to be executed
---@param iter number Number of iterations (default 1000)
_G.bench = function(label, f, iter)
  iter = iter or 1000
  local sum = 0
  for _ = 1, iter do
    local start = vim.loop.hrtime()
    f()
    sum = sum + (vim.loop.hrtime() - start)
  end
  print(label, sum / iter / 1000000)
end

-- Disable built-in plugins that I don't use. This is to reduce startup time
vim
  .iter({
    "gzip",
    "netrwPlugin",
    "tarPlugin",
    "tohtml",
    "tutor",
    "zipPlugin",
  })
  :each(function(v) vim.g["loaded_" .. v] = true end)

local dev_pack_path = vim.fn.stdpath("data") .. "/site"
vim.opt.runtimepath:prepend(dev_pack_path)

require("haven.core.string")

-- require("haven.core.clipboard")
vim.opt.clipboard = { "unnamed", "unnamedplus" }

require("haven.core.autocmds")
require("haven.core.options")
require("haven.core.keymaps")
-- vim.cmd.doautoall("User", "HavenLocalPre")
require("lz.n").load("haven.pack")
require("haven.core.theme").setup()
require("haven.core.statusline").setup()
require("haven.core.winbar").setup()
require("haven.core.marks")
-- vim.cmd.doautoall("User", "HavenLocalPost")

-- Enable the new experimental command-line features.
require("vim._core.ui2").enable({})
