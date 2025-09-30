return {
  "chroma.nvim",
  colorscheme = { "chroma" },
  after = function()
    require("chroma").setup({
      plugins = {
        telescope = {
          style = "borderless",
        },
      },
    })
  end,
}
