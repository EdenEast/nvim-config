local simple = {
  "bigfile",
  "gitbrowser",
  "input",
  "quickfile",
}

local plugins = {
  "dashboard",
  "explorer",
  "indent",
  "scratch",
  "terminal",
}

local opts = {}
for _, p in ipairs(simple) do
  opts[p] = { enabled = true }
end
for _, p in ipairs(plugins) do
  opts[p] = require("haven.mod.snacks." .. p)
end

---@type lz.n.Spec
return {
  "snacks.nvim",
  after = function() require("snacks").setup(opts) end,
}
