local fmt = string.format

vim.opt_local.foldenable = false

vim.opt_local.spell = true
vim.opt_local.textwidth = 72
vim.opt_local.colorcolumn = [[51,+1]]

local cache_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "gitcommit")

local function search_cache_dir()
  vim.cmd.packadd("fzf-lua")
  require("fzf-lua").files({
    cwd = cache_dir,
    winopts = {
      preview = {
        hidden = false,
      },
    },
  })
end
vim.keymap.set("n", "<localleader>f", function() search_cache_dir() end, { buffer = 0, desc = "Search Cache" })

local function get_last_cache_entry()
  -- Get the last modified file in the cache directory
  local files = vim.fn.globpath(cache_dir, "*", false, true)
  if #files == 0 then return end

  table.sort(files, function(a, b) return vim.fn.getftime(a) > vim.fn.getftime(b) end)
  local latest = files[1]

  -- check if width is greater than height
  -- local width = vim.api.nvim_get_option_value("columns", {})
  -- local height = vim.api.nvim_get_option_value("lines", {})
  local win = vim.api.nvim_get_current_win()
  local width = vim.api.nvim_win_get_width(win)
  local height = vim.api.nvim_win_get_height(win)
  print("width = " .. width .. ", height = " .. height)
  if width / 2 > height then
    -- open in vertical split
    vim.cmd("vsplit " .. latest)
  else
    -- open in horizontal split
    vim.cmd("split " .. latest)
  end
end
get_last_cache_entry()
vim.keymap.set("n", "<localleader>l", function() get_last_cache_entry() end, { buffer = 0, desc = "Last Cache Entry" })

-- Save git commit content to a cache temp file in case there was an issue writing the commit
-- This is handy if the commit failed for what ever reason and the .git/COMMIT_EDITMSG file
-- has been overwritten
-- vim.api.nvim_create_autocmd("BufWritePost", {
--   buffer = vim.api.nvim_get_current_buf(),
--   callback = function()
--     vim.fn.mkdir(cache_dir, "p")
--
--     local datetime = os.date("%Y-%m-%d-%H%M%S")
--     local filepath = vim.fs.joinpath(cache_dir, datetime)
--
--     local lines = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false)
--     local file = io.open(filepath, "w")
--     if not file then
--       error("cound not open file: " .. filepath)
--       return
--     end
--
--     for _, line in ipairs(lines) do
--       file:write(line, "\n")
--     end
--     file:close()
--   end,
-- })
--
--
