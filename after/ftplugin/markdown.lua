-- vim.opt_local.textwidth = 80
vim.opt_local.linebreak = false
vim.opt_local.spell = true
vim.opt_local.formatexpr = ""
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = "nc"

vim.keymap.set("n", "<localleader>p", "<cmd>LivePreview start<cr>", { desc = "Open Live Preview" })
