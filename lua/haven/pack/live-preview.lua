return {
  "live-preview.nvim",
  ft = { "markdown", "asciidoc" },
  cmd = { "LivePreview" },
  after = function() require("livepreview.config").set() end,
}
