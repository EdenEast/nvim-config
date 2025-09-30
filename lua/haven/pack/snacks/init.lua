---@type lz.n.Spec
return {
  "snacks.nvim",
  after = function()
    require("snacks").setup({
      bigfile = { enabled = true },
      gitbrowser = { enabled = true },
      input = { enabled = true },
      quickfile = { enabled = true },
      dashboard = require("haven.plugins.snacks.dashboard"),
      explorer = require("haven.plugins.snacks.explorer"),
      indent = require("haven.plugins.snacks.indent"),
      scratch = require("haven.plugins.snacks.scratch"),
      terminal = require("haven.plugins.snacks.terminal"),
    })
  end,
}
