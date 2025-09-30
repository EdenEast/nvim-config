local set = vim.keymap.set

set({ "n", "t" }, "<c-space>", function() Snacks.terminal.toggle() end, { desc = "Toggle Term" })

---@type snacks.terminal.Config
---@diagnostic disable-next-line: missing-fields
return {}
