local cache_path = vim.fs.joinpath(vim.fn.stdpath("cache"), "theme")

local function copy(t)
  local r = {}
  for k, v in pairs(t) do
    r[k] = v
  end
  return r
end

local Theme = {
  name = "nightfox",
  transparent = {
    enabled = false,
    cache = {},
    groups = {
      "Normal",
      "NormalNC",
    },
  },
}

function Theme.setup()
  vim.opt.termguicolors = true
  Theme.load_cache()
  Theme.set() -- Set it the first time so we dont trigger the colorscheme autocmd and write to the cache
  if not vim.g.colors_name then vim.g.colors_name = "default" end
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("eden_theme_handler", { clear = true }),
    callback = function() require("haven.core.theme").hook() end,
  })
end

function Theme.hook()
  if vim.g.colors_name then Theme.name = vim.g.colors_name end
  if Theme.transparent.enabled then Theme.clear() end
  Theme.write_cache()
end

function Theme.load_cache()
  local exists, lines = pcall(vim.fn.readfile, cache_path)
  if exists then
    Theme.name = lines[1]
    Theme.transparent.enabled = lines[2] == "true"
  end
end

function Theme.write_cache()
  local name = vim.g.colors_name or "default"
  local transparent_enabled = Theme.transparent.enabled or false
  vim.fn.writefile({ name, tostring(transparent_enabled) }, cache_path)
end

function Theme.clear()
  for _, group in ipairs(Theme.transparent.groups) do
    local hl = vim.api.nvim_get_hl(0, { name = group })
    Theme.transparent.cache[group] = copy(hl)
    if hl.bg then hl.bg = "NONE" end
    vim.api.nvim_set_hl(0, group, hl)
  end
end

function Theme.restore()
  for _, group in ipairs(Theme.transparent.groups) do
    local hl = Theme.transparent.cache[group]
    if hl then vim.api.nvim_set_hl(0, group, hl) end
  end
end

---@param value boolean?
function Theme.toggle(value)
  local enabled = value == nil and not Theme.transparent.enabled or value or false

  if enabled then
    Theme.clear()
  else
    Theme.restore()
  end

  Theme.transparent.enabled = enabled
  Theme.write_cache()
end

---@param scheme string?
function Theme.set(scheme)
  scheme = scheme or Theme.name
  pcall(vim.cmd.colorscheme, scheme)
end

return Theme
