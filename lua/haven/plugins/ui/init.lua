---@type lz.n.Spec
local spec = {}

local mods = {
  "bufferline",
  "oil",
  "quicker",
  "whichkey",
}

for _, mod in ipairs(mods) do
  spec[#spec + 1] = require("haven.mod.ui." .. mod)
end

return spec
