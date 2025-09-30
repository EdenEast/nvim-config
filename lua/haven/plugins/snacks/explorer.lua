local set = vim.keymap.set
set("n", "<leader>E", function() Snacks.explorer.open() end, { desc = "Explorer Filetree" })

-- https://sourcegraph.com/github.com/and-rs/nvim/-/blob/.config/nvim/lua/plugins/explorer.lua?L4-7
return {}
