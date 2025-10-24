---@type lz.n.Spec
return {
  "vim-tmux-navigator",
  before = function() vim.g.tmux_navigator_disable_when_zoomed = 1 end,
  after = function()
    local t = function(key, direction)
      vim.keymap.set(
        "t",
        string.format("<c-%s>", key),
        function() vim.cmd("TmuxNavigate" .. direction) end,
        { desc = "Move focus " .. direction }
      )
    end

    t("h", "Left")
    t("j", "Down")
    t("k", "Up")
    t("l", "Right")
  end,
}
