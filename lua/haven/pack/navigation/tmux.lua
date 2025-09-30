---@type lz.n.Spec
return {
  "nvim-tmux-navigation",
  after = function()
    local ntn = require("nvim-tmux-navigation")
    ntn.setup({
      disable_when_zoomed = true, -- defaults to false
    })
    local k = vim.keymap.set
    k("n", "<C-h>", ntn.NvimTmuxNavigateLeft)
    k("n", "<C-j>", ntn.NvimTmuxNavigateDown)
    k("n", "<C-k>", ntn.NvimTmuxNavigateUp)
    k("n", "<C-l>", ntn.NvimTmuxNavigateRight)
  end,
}
