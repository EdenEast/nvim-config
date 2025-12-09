return {
  "markview.nvim",
  lazy = false,
  after = function()
    require("markview").setup({
      experimental = { check_rtp = false },
      preview = {
        enable_hybrid_mode = true,
        hybrid_modes = { "n" },
        linewise_hybrid_mode = true,
      },
    })
  end,
}
