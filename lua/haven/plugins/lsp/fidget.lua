---@type lz.n.Spec
return {
  "fidget.nvim",
  event = { "BufReadPre", "BufNewFile" },
  after = function() require("fidget").setup({}) end,
}
