---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      -- runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
      diagnostics = {
        -- Don't analyze whole workspace, as it consumes too much CPU and RAM
        workspaceDelay = -1,
      },
      workspace = {
        -- Don't analyze code from submodules
        ignoreSubmodules = true,
        -- Add Neovim's methods for easier code writing
        library = { vim.env.VIMRUNTIME },
      },
      telemetry = { enable = false },
    },
  },
  on_attach = function(client, bufnr) end,
}
