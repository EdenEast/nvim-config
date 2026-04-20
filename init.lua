local appname = vim.env.NVIM_APPNAME
if appname and appname ~= "nvim-haven" then
  -- The mnw wrapper unconditionally injects haven paths into runtimepath/packpath via --cmd
  -- before this file runs. Strip them out so the delegated config gets a clean slate.
  local viminit = vim.env.VIMINIT
  if viminit then
    local mnw_config_dir = viminit:match("source (.+)/init%.lua")
    if mnw_config_dir then
      vim.opt.runtimepath:remove(mnw_config_dir)
      vim.opt.packpath:remove(mnw_config_dir)
    end
    -- Also remove the impure dev path (NV_PATH / FLAKE_ROOT / cwd fallback) that mnw injects
    local impure = vim.env.NV_PATH or vim.env.FLAKE_ROOT or vim.uv.cwd()
    if impure then
      vim.opt.runtimepath:remove(impure)
      vim.opt.runtimepath:remove(impure .. "/after")
    end
  end

  if not vim.g.loaded_appname_init then
    vim.g.loaded_appname_init = true
    local config_init_file = vim.fs.joinpath(vim.fn.stdpath("config"), "init.lua")
    if vim.uv.fs_stat(config_init_file) then dofile(config_init_file) end
  end
  return
end

require("haven")
