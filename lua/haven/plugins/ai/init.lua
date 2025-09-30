---@type lz.n.Spec
local spec = {}

local mods = {
  "codecompanion",
  "copilot",
}

for _, mod in ipairs(mods) do
  spec[#spec + 1] = require("haven.mod.ai." .. mod)
end

return spec
