local map = vim.keymap.set
local fmt = string.format

vim.g.mapleader = vim.g.mapleader or " "
vim.g.maplocalleader = vim.g.maplocalleader or ","

-- Switch to the preveous buffer in the window
map("n", "<leader><leader>", [[<c-^>\"zz]], { desc = "Prev buffer" })

-- Movement -------------------------------------------------------------------

-- Better up / down
--
-- Move by 'display lines' instead of 'logical lines'. If v:count is provided
-- it will jump by logical lines. If v:count is greater than 5 it will create
-- a jump list entry.
map({ "n", "x" }, "j", [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj']], { expr = true, silent = true })
map({ "n", "x" }, "k", [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk']], { expr = true, silent = true })

-- This helps when using colemak's nav cluster
map("n", "<left>", "gh", { remap = true })
map("n", "<down>", "gj", { remap = true })
map("n", "<up>", "gk", { remap = true })
map("n", "<righh>", "gl", { remap = true })

-- Quickly go to the end of the line while in insert mode.
map({ "i", "c" }, "<C-h>", "<C-o>I", { desc = "Go to the beginning of the line" })
map({ "i", "c" }, "<C-l>", "<C-o>A", { desc = "Go to the end of the line" })

-- Move buffers
map("n", "[b", "<cmd>bprevious<cr>", { silent = true, desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { silent = true, desc = "Next buffer" })

-- Move quickfix
map("n", "[q", "<cmd>cprev<cr>", { silent = true, desc = "Prev quickfix" })
map("n", "]q", "<cmd>cnext<cr>", { silent = true, desc = "Next quickfix" })

-- Move tabs
map("n", "[t", "<cmd>tabprev<cr>", { silent = true, desc = "Prev tab" })
map("n", "]t", "<cmd>tabnext<cr>", { silent = true, desc = "Next tab" })

-- Window movement ------------------------------------------------------------

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Move to the left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Move to the bottom window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Move to the top window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Move to the right window", remap = true })

-- -- Resize window using <ctrl> arrow keys
-- map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
-- map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
-- map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
-- map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- -- Move Lines
-- map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
-- map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
-- map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
-- map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
-- map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
-- map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Windows
map("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

-- Search ---------------------------------------------------------------------

-- Better n / N
--
-- Make sure that n searches forward regardless of '/', '?', '#', or '?'.
-- Search results are centered with `zzzv`.
-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map({ "n", "x", "o" }, "n", [[(v:searchforward ? 'n' : 'N') . 'zzzv']], { expr = true, desc = "Next search result" })
map({ "n", "x", "o" }, "N", [[(v:searchforward ? 'N' : 'n') . 'zzzv']], { expr = true, desc = "Prev search result" })

-- Macros and registers -------------------------------------------------------

-- Replay last marco. The normal use case for this would be `qq` to record a
-- macro and then `Q` to quickly replay it (if `q` was the last used macro).
map("n", "Q", "@@")

-- Execute "@" macro over visual line selections
map("x", "Q", [[:'<,'>:normal @@<CR>]])

-- Terminals ------------------------------------------------------------------

-- Exit terminal mode to normal mode
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })

-- Move windows in therminal
map("t", "<C-h>", "<c-\\><c-n><c-w>h", { desc = "Go to left window" })
map("t", "<C-j>", "<c-\\><c-n><c-w>j", { desc = "Go to lower window" })
map("t", "<C-k>", "<c-\\><c-n><c-w>k", { desc = "Go to upper window" })
map("t", "<C-l>", "<c-\\><c-n><c-w>l", { desc = "Go to right window" })

-------------------------------------------------------------------------------

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Map Y to be the same as D and C
map({ "n", "x" }, "Y", "yg_")

-- Make U opposite to u.
map("n", "U", "<C-r>", { desc = "Redo" })

-- Keep selection when indent/outdent
map("x", ">", ">gv")
map("x", "<", "<gv")

-- Visual select last pasted value
map("n", "gp", "`[v`]", { desc = "Select last paste" })

-- Clone paragraph
map("n", "cp", [[vap:t'><cr>(j]])

-- Quickly go to the end of the line while in insert mode.
map({ "i", "c" }, "<C-h>", "<C-o>I", { desc = "Go to the beginning of the line" })
map({ "i", "c" }, "<C-l>", "<C-o>A", { desc = "Go to the end of the line" })

map("n", "gQ", "mzgggqG`z<cmd>delmarks z<cr>zz", { desc = "Format buffer" })

-- Redirect change operation to blackhole register
map({ "n", "x" }, "c", [["_c]])
map({ "n", "x" }, "C", [["_C]])

-- Pipe all blank line deletions to the blackhole register
map("n", "dd", function()
  if vim.api.nvim_get_current_line():match("^%s*$") then
    return '"_dd'
  else
    return "dd"
  end
end, { expr = true, silent = true })

-- Execute last command
map("n", [[\]], ":<c-u><up><cr>")

-- Search for word under cursor
map({ "n", "x" }, "gw", "*N", { desc = "Search word under cursor" })

-- Increment/decrement
map("n", "+", "<C-a>")
map("n", "-", "<C-x>")
map("v", "+", "g<C-a>")
map("v", "-", "g<C-x>")

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Read the current line and execute that line in your $SHELL. Thte reuslting
-- output will replace the curent line that was being executed.
map("n", "<leader>X", [[!!$SHELL <cr>]])

map("n", "<leader>ui", "<cmd>Inspect<cr>", { desc = "Inspect" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })

-- Escape and save changes.
map({ "s", "i", "n", "v" }, "<C-s>", "<esc>:w<cr>", { desc = "Exit insert mode and save changes" })
map({ "s", "i", "n", "v" }, "<C-S-s>", function()
  vim.g.skip_formatting = true
  return "<esc>:w<cr>"
end, { desc = "Exit insert mode and save changes (without formatting)", expr = true })

map("n", "<F2>", function() vim.cmd("write | luafile %") end, { desc = "Execute file" })
map("n", "<leader><cr>", "<cmd>messages<cr>", { desc = "Messages" })
