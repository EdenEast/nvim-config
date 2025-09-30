local M = {}
local defaults = {
  width = 0.4,
  timer = true,
  autoscroll = true,
  buf = nil,
  win = nil,
}

local function get_winopts(opts)
  local ui = vim.api.nvim_list_uis()[1]
  return {
    width = math.floor(ui.width * opts.width),
    split = "right",
  }
end

local function update_message_buffer(opts)
  return function()
    opts = opts and vim.tbl_deep_extend("force", opts, defaults) or defaults
    if not M.buf then return end

    local messages = vim.api.nvim_cmd({ cmd = "messages" }, { output = true })
    if not messages then return end

    local lines = vim.split(messages, "\n")
    local current_lines = vim.api.nvim_buf_get_lines(M.buf, 0, -1, false)
    if #current_lines == #lines then return end

    vim.api.nvim_set_option_value("modifiable", true, { buf = M.buf })
    vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
    if opts.timer then vim.api.nvim_set_option_value("modifiable", false, { buf = M.buf }) end

    -- Autoscroll
    if opts.autoscroll and M.win then vim.api.nvim_win_set_cursor(M.win, { #lines, 0 }) end
  end
end

local function create_buffer(opts)
  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("filetype", "message", { buf = buf })
  vim.api.nvim_set_option_value("buflisted", false, { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })

  vim.keymap.set("n", "<localleader>r", update_message_buffer(opts), { desc = "Reload messages", buffer = buf })
  vim.keymap.set("n", "q", M.close, { buffer = buf })

  return buf
end

function M.open(opts)
  opts = opts and vim.tbl_deep_extend("force", opts, defaults) or defaults

  if not M.buf then M.buf = create_buffer(opts) end
  local update_fn = update_message_buffer(opts)
  update_fn()

  if opts.timer then
    local timer = assert(vim.loop.new_timer())
    local function close_timer()
      timer:stop()
      timer:close()
    end

    timer:start(1000, 500, vim.schedule_wrap(update_fn))
    vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
      buffer = M.buf,
      callback = function() close_timer() end,
    })
  end

  local winopts = get_winopts(opts)
  M.win = vim.api.nvim_open_win(M.buf, false, winopts)
  vim.api.nvim_win_set_buf(M.win, M.buf)
  vim.api.nvim_set_option_value("number", false, { win = M.win })
end

function M.close()
  vim.api.nvim_buf_delete(M.buf, { unload = true })
  M.buf = nil
  M.win = nil
end

function M.toggle()
  if M.win then
    M.close()
  else
    M.open()
  end
end

return M
