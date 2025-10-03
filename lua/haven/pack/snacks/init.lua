---@type lz.n.Spec
return {
  "snacks.nvim",
  after = function()
    require("snacks").setup({
      bigfile = { enabled = true },
      gitbrowser = { enabled = true },
      input = { enabled = true },
      quickfile = { enabled = true },
      dashboard = require("haven.pack.snacks.dashboard"),
      explorer = require("haven.pack.snacks.explorer"),
      indent = require("haven.pack.snacks.indent"),
      scratch = require("haven.pack.snacks.scratch"),
      terminal = require("haven.pack.snacks.terminal"),
    })
  end,
}
