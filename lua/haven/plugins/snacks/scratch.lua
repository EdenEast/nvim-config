vim.keymap.set("n", "<leader>us", function() Snacks.scratch() end, { desc = "Scratch Buffer" })

---@type snacks.scratch.Config
---@diagnostic disable-next-line: missing-fields
return {
  win = {
    style = "split",
  },
  win_by_ft = {
    lua = {
      keys = {
        ["source"] = {
          "<cr>",
          function(self)
            local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
            Snacks.debug.run({ buf = self.buf, name = name })
          end,
          desc = "Source buffer",
          mode = { "n", "x" },
        },
        ["line"] = {
          "<localLeader><cr>",
          function(self) vim.cmd.lua(vim.api.nvim_get_current_line()) end,
          desc = "Source link",
          mode = { "n", "x" },
        },
      },
    },
  },
}
