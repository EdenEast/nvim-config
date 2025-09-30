-- checking if the NVIM_APPNAME is set to something other than nvim-haven if so when we should run that's init.lua file
if vim.env.NVIM_APPNAME and vim.env.NVIM_APPNAME ~= "nvim-haven" then
  local config_init_file = vim.fs.joinpath(vim.fn.stdpath("config"), "init.lua")
  if vim.uv.fs_stat(config_init_file) and not vim.g.loaded_appname_init then
    vim.g.loaded_appname_init = true
    dofile(config_init_file)
    return
  end
end

require("haven")
