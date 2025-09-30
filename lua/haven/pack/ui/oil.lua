---@type lz.n.Spec
return {
  "oil.nvim",
  keys = {
    { "<leader>=", "<cmd>Oil<cr>", "Oil" },
  },
  cmd = "Oil",
  after = function() require("oil").setup() end,
}
