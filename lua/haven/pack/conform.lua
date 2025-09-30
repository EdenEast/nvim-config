return {
  "conform.nvim",
  event = { "BufWritePre" },
  keys = {
    {
      "<leader>uf",
      function()
        vim.g.autoformat = not vim.g.autoformat
        vim.notify("Autoformat: " .. (vim.g.autoformat and "Enable" or "Disable"), vim.log.levels.INFO)
      end,
      desc = "Toggle Autoformat",
    },
  },
  before = function()
    -- Use conform for gq.
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    vim.g.autoformat = true
  end,
  after = function()
    require("conform").setup({
      notify_on_error = false,
      default_format_opts = {
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        c = { name = "clangd", timeout_ms = 500, lsp_format = "prefer" },
        javascript = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        javascriptreact = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        json = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        jsonc = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        less = { "prettier" },
        lua = { "stylua", lsp_format = "fallback" },
        markdown = { "prettier" },
        nix = { "alejandra", "nixfmt", stop_after_first = true },
        rust = { name = "rust_analyzer", timeout_ms = 500, lsp_format = "prefer" },
        scss = { "prettier" },
        sh = { "shfmt" },
        typescript = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        typescriptreact = { "prettier", name = "dprint", timeout_ms = 500, lsp_format = "fallback" },
        -- For filetypes without a formatter:
        ["_"] = { "trim_whitespace", "trim_newlines" },
      },
      format_on_save = function(bufnr)
        if vim.g.skip_autoformat then
          vim.g.skip_autoformat = false
          return nil
        end

        -- Stop if we disabled auto-formatting.
        if not vim.g.autoformat then return nil end

        return { timeout_ms = 500 }
      end,
    })
  end,
}
