local function augroup(name, clear)
  return vim.api.nvim_create_augroup("haven/" .. name, { clear = clear ~= nil and clear or true })
end

local using_relative_line_numbers = false
local using_cursorline_only_normal = false

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("big_file"),
  desc = "Disable features in big files",
  pattern = "bigfile",
  callback = function(args)
    vim.schedule(function() vim.bo[args.buf].syntax = vim.filetype.match({ buf = args.buf }) or "" end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  desc = "Close with <q>",
  pattern = {
    "git",
    "help",
    "man",
    "qf",
    "scratch",
    "startuptime",
  },
  callback = function(args) vim.keymap.set("n", "q", "<cmd>quit<cr>", { buffer = args.buf }) end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  desc = "Check for file changes when window focus, more eager than 'autoread'",
  command = "checktime",
})

vim.api.nvim_create_autocmd("CmdwinEnter", {
  group = augroup("execute_cmd_and_stay"),
  desc = "Execute command and stay in the command-line window",
  callback = function(args) vim.keymap.set({ "n", "i" }, "<S-CR>", "<cr>q:", { buffer = args.buf }) end,
})

local group_trailing_whitespace = augroup("trailing_whitespace")
vim.api.nvim_create_autocmd({ "BufWinEnter", "InsertEnter" }, {
  group = group_trailing_whitespace,
  desc = "Match trailing whiltespace when in normal mode",
  command = "match Error /\\s\\+%#@<!$/",
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  group = group_trailing_whitespace,
  desc = "Unmatch trailing whitespace when in insert mode",
  command = "match Error /\\s\\+$/",
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_location"),
  desc = "Go to the last location when opening a buffer",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then vim.cmd('normal! g`"zz') end
  end,
})

-- set cursorline only in the current pane
local group_cursor_line = augroup("cursor_line")
vim.api.nvim_create_autocmd({ "WinEnter", "InsertLeave" }, {
  group = group_cursor_line,
  desc = "Enable cursorline when entering window",
  callback = function() vim.wo.cursorline = true end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "InsertEnter" }, {
  group = group_cursor_line,
  desc = "Disable cursorline when leaving window",
  callback = function() vim.wo.cursorline = false end,
})

if using_relative_line_numbers then
  local line_numbers_group = vim.api.nvim_create_augroup("toggle_line_numbers", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" }, {
    group = line_numbers_group,
    desc = "Toggle relative line numbers on",
    callback = function()
      if vim.wo.nu and not vim.startswith(vim.api.nvim_get_mode().mode, "i") then vim.wo.relativenumber = true end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" }, {
    group = line_numbers_group,
    desc = "Toggle relative line numbers off",
    callback = function(args)
      if vim.wo.nu then vim.wo.relativenumber = false end

      -- Redraw here to avoid having to first write something for the line numbers to update.
      if args.event == "CmdlineEnter" then
        if not vim.tbl_contains({ "@", "-" }, vim.v.event.cmdtype) then vim.cmd.redraw() end
      end
    end,
  })
end

vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  desc = "Resize splits if window got resized",
  callback = function() vim.cmd("tabdo wincmd =") end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("treesitter_folding"),
  desc = "Enable Treesitter folding",
  callback = function(args)
    local bufnr = args.buf
    -- Enable Treesitter folding when not in huge files and when Treesitter is working.
    if vim.bo[bufnr].filetype ~= "bigfile" and pcall(vim.treesitter.start, bufnr) then
      vim.api.nvim_buf_call(bufnr, function()
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.cmd.normal("zx")
      end)
    else
      -- Else just fallback to using indentation.
      vim.wo[0][0].foldmethod = "indent"
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank_highlight"),
  desc = "Highlight on yank",
  callback = function() vim.hl.on_yank() end,
})
