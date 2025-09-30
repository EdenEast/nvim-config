---@type lz.n.Spec
return {
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
}
