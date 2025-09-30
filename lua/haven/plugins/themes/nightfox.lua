---@type lz.n.Spec
return {
  "nightfox.nvim",
  colorscheme = { "nightfox", "terafox", "dayfox" },
  after = function()
    require("nightfox").setup({
      options = {
        module_default = false,
        modules = {
          alpha = true,
          cmp = true,
          dap_ui = true,
          diagnostic = true,
          gitgutter = true,
          gitsigns = true,
          illuminate = true,
          leap = true,
          lsp_semantic_tokens = true,
          lsp_trouble = true,
          mini = true,
          neogit = true,
          neotree = true,
          notify = true,
          nvimtree = true,
          telescope = true,
          treesitter = true,
          whichkey = true,

          native_lsp = {
            enable = true,
            background = false,
          },
        },
      },
      specs = {
        all = {
          syntax = {
            operator = "orange",
          },
        },
      },
      groups = {
        all = {
          TelescopeBorder = { fg = "bg4" },
          TelescopeTitle = { fg = "fg2", bg = "bg4" },

          CmpItemKindFunction = { fg = "palette.pink" },
          CmpItemKindMethod = { fg = "palette.pink" },
          CmpWindowBorder = { fg = "bg0", bg = "bg0" },
        },
      },
    })
  end,
}
