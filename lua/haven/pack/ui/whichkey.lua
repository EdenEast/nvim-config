---@type lz.n.Spec
return {
  "which-key.nvim",
  after = function()
    local wk = require("which-key")
    wk.setup({
      plugins = { spelling = true },
    })

    wk.add({
      mode = { "n", "v" },
      { "g", group = "+goto" },
      { "ys", group = "+surround" },
      { "]", group = "+next" },
      { "[", group = "+prev" },
      { "<leader>f", group = "+file/find" },
      { "<leader>g", group = "+git" },
      { "<leader>s", group = "+search" },
      { "<leader>u", group = "+ui" },
    })

    require("haven.util.whichkey").init()
  end,
}
