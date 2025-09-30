return {
  "mini.nvim",
  after = function()
    require("haven.pack.mini.ai")
    require("haven.pack.mini.comment")
    require("haven.pack.mini.files")
  end,
}
