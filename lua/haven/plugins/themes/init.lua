---@type lz.n.Spec
local spec = {}

local mods = {
  "catppuccin",
  "chroma",
  "nightfox",
}

for _, mod in ipairs(mods) do
  spec[#spec + 1] = require("haven.mod.themes." .. mod)
end

return spec
