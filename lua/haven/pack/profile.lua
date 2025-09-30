return {
  "vim-startuptime",
  src = "dstein64/vim-startuptime",
  cmd = "StartupTime",
  -- before = function()
  --   if vim.env.NVIM_APPNAME ~= "nvim" then vim.g.startuptime_exe_path = vim.env.NVIM_APPNAME end
  -- end,
}
