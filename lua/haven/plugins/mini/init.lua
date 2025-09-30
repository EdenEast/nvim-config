return {
  {
    "mini.nvim",
    after = function()
      require("haven.mod.mini.ai")
      require("haven.mod.mini.comment")
      require("haven.mod.mini.files")
    end,
  },
}
