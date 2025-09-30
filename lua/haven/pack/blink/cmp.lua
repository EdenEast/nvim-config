---@type lz.n.Spec
return {
  "blink.cmp",
  event = { "InsertEnter" },
  build = "cargo build --release",
  before = function() require("lz.n").trigger_load("friendly-snippets") end,
  after = function()
    require("blink.cmp").setup({
      completion = {
        accept = {
          -- experimental auto-brackets support
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          enabled = true,
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      keymap = {
        preset = "enter",
        ["<C-y>"] = { "select_and_accept" },
      },
    })

    -- Extend neovim's client capabilities with the completion ones.
    vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(nil, true) })
  end,
}
