-- vim.opt_local.textwidth = 80
vim.opt_local.concealcursor = "nc"
vim.opt_local.conceallevel = 2
vim.opt_local.formatexpr = ""
vim.opt_local.linebreak = false
vim.opt_local.spell = true
vim.opt_local.spelllang = { "en_us" }

vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.tabstop = 2
vim.opt_local.textwidth = 120

require("markview").setup({
  experimental = { check_rtp = false },
  preview = {
    enable_hybrid_mode = true,
    hybrid_modes = { "n" },
    linewise_hybrid_mode = true,
  },
})

vim.keymap.set("n", "<localleader>p", "<cmd>LivePreview start<cr>", { desc = "Open Live Preview" })
vim.keymap.set("n", "<localleader>m", "<cmd>Markview toggle<cr>", { desc = "Toggle Markview" })
