local M = {
  is_initialized = false,
  queue = {},
}

function M.init()
  M.is_initialized = true
  for _, q in ipairs(M.queue) do
    require("which-key").add(q.mappings, q.opts)
  end
end

--- Add mappings to which-key
---@param mappings wk.Spec
---@param opts? wk.Parse
function M.add(mappings, opts)
  if M.is_initialized then
    require("which-key").add(mappings, opts or {})
  else
    M.queue[#M.queue + 1] = {
      mappings = mappings,
      opts = opts or {},
    }
  end
end

return M
