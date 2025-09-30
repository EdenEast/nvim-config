---@type lz.n.Spec
local spec = {}

local mods = {
  "blink",
  "conform",
  "fzf",
  "overseer",
  "treesitter",
}

for _, mod in ipairs(mods) do
  spec[#spec + 1] = require("haven.mod.editor." .. mod)
end

return spec
