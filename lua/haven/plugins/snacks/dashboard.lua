-- https://github.com/Praczet/little-taskwarrior.nvim
-- https://github.com/folke/snacks.nvim/discussions/111#discussioncomment-11986334

---@type snacks.dashboard.Config
---@diagnostic disable-next-line: missing-fields
return {
  preset = {
    header = [[
██╗  ██╗ █████╗ ██╗   ██╗███████╗███╗   ██╗
██║  ██║██╔══██╗██║   ██║██╔════╝████╗  ██║
███████║███████║██║   ██║█████╗  ██╔██╗ ██║
██╔══██║██╔══██║╚██╗ ██╔╝██╔══╝  ██║╚██╗██║
██║  ██║██║  ██║ ╚████╔╝ ███████╗██║ ╚████║
╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝
          ]],
    ---@type snacks.dashboard.Item[]
    keys = {
      { icon = " ", key = "s", desc = "Scratch", action = ":lua Snacks.scratch()" },
      { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
      { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
      { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
      { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
      -- { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
      { icon = " ", key = "b", desc = "Browse Repo", action = function() Snacks.gitbrowse() end },
      { icon = " ", key = "q", desc = "Quit", action = ":qa" },
    },
  },
  sections = {
    { section = "header" },
    { pane = 1, icon = " ", title = "Keys", section = "keys", indent = 3, padding = 1 },
    { pane = 1, icon = " ", title = "Projects", section = "projects", indent = 3, padding = 1, limit = 5 },
    { pane = 1, icon = " ", title = "Recent Files", section = "recent_files", indent = 3, padding = 1, limit = 5 },
    {
      pane = 2,
      icon = " ",
      title = "Git Status",
      section = "terminal",
      enabled = function() return Snacks.git.get_root() ~= nil end,
      cmd = "git status --short --branch --renames",
      height = 10,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    },
    {
      pane = 2,
      icon = " ",
      title = "Git Graph",
      section = "terminal",
      enabled = function() return Snacks.git.get_root() ~= nil end,
      cmd = [[echo -e "$(git-graph --style round --color always --wrap 80 0 8 -f 'oneline')"]],
      height = 10,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    },
  },
}
