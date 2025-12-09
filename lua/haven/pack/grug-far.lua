---@type lz.n.Spec
return {
  "grug-far.nvim",
  cmd = "GrugFar",
  keys = {
    {
      "<leader>fR",
      function()
        local grug = require("grug-far")
        grug.open({ transient = true })
      end,
      desc = "GrugFar",
      mode = { "n", "v" },
    },
  },
  config = function()
    require("grug-far").setup({
      -- Disable folding.
      folding = { enabled = false },
      -- Don't numerate the result list.
      resultLocation = { showNumberLabel = false },
    })
  end,
}
