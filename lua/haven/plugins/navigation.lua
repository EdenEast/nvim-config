return {
  {
    "nvim-tmux-navigation",
    after = function()
      local ntn = require("nvim-tmux-navigation")
      ntn.setup({
        disable_when_zoomed = true, -- defaults to false
      })
      local k = vim.keymap.set
      k("n", "<C-h>", ntn.NvimTmuxNavigateLeft)
      k("n", "<C-j>", ntn.NvimTmuxNavigateDown)
      k("n", "<C-k>", ntn.NvimTmuxNavigateUp)
      k("n", "<C-l>", ntn.NvimTmuxNavigateRight)
    end,
  },
  {
    "flash.nvim",
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            search = {
              mode = function(str) return "\\<" .. str end,
            },
          })
        end,
        desc = "Flash",
      },
      -- Not sure about this one
      -- {
      --   "S",
      --   mode = { "n", "o", "x" },
      --   function() require("flash").treesitter() end,
      --   desc = "Flash Treesitter",
      -- },
      {
        "r",
        mode = "o",
        function() require("flash").remote() end,
        desc = "Remote Flash",
      },
    },
    after = function()
      require("flash").setup({
        modes = {
          char = { enable = true },
          search = { enable = true },
        },
      })
    end,
  },
}
