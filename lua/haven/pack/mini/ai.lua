local ai = require("mini.ai")

local opts = {
  n_lines = 500,
  custom_textobjects = {
    o = ai.gen_spec.treesitter({ -- code block
      a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    }),
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
    d = { "%f[%d]%d+" }, -- digits
    e = { -- Word with case
      { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
      "^().*()$",
    },
    -- i = LazyVim.mini.ai_indent, -- indent TODO: https://sourcegraph.com/github.com/LazyVim/LazyVim@dc8a3a139e9986292e99b75e530fc3d9168fc001/-/blob/lua/lazyvim/util/mini.lua?L4-40
    u = ai.gen_spec.function_call(), -- u for "Usage"
    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
  },
}

ai.setup(opts)

local objects = {
  { " ", desc = "whitespace" },
  { '"', desc = '" string' },
  { "'", desc = "' string" },
  { "(", desc = "() block" },
  { ")", desc = "() block with ws" },
  { "<", desc = "<> block" },
  { ">", desc = "<> block with ws" },
  { "?", desc = "user prompt" },
  { "U", desc = "use/call without dot" },
  { "[", desc = "[] block" },
  { "]", desc = "[] block with ws" },
  { "_", desc = "underscore" },
  { "`", desc = "` string" },
  { "a", desc = "argument" },
  { "b", desc = ")]} block" },
  { "d", desc = "digit(s)" },
  { "e", desc = "CamelCase / snake_case" },
  { "f", desc = "function" },
  { "o", desc = "block, conditional, loop" },
  { "q", desc = "quote `\"'" },
  { "t", desc = "tag" },
  { "u", desc = "use/call" },
  { "{", desc = "{} block" },
  { "}", desc = "{} with ws" },
}

local ret = { mode = { "o", "x" } }
---@type table<string, string>
local mappings = vim.tbl_extend("force", {}, {
  around = "a",
  inside = "i",
  around_next = "an",
  inside_next = "in",
  around_last = "al",
  inside_last = "il",
}, opts.mappings or {})
mappings.goto_left = nil
mappings.goto_right = nil

for name, prefix in pairs(mappings) do
  name = name:gsub("^around_", ""):gsub("^inside_", "")
  ret[#ret + 1] = { prefix, group = name }
  for _, obj in ipairs(objects) do
    local desc = obj.desc
    if prefix:sub(1, 1) == "i" then desc = desc:gsub(" with ws", "") end
    ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
  end
end

require("haven.util.whichkey").add(ret, { notify = false })
