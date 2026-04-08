local M = {}

--- Walk up the tree from the node under the cursor to find a `binding` node
--- that satisfies an optional predicate.
--- @param pred? fun(node: TSNode): boolean
--- @return TSNode|nil
local function find_binding(pred)
  local node = vim.treesitter.get_node()
  while node do
    if node:type() == "binding" then
      if not pred or pred(node) then return node end
    end
    node = node:parent()
  end
  return nil
end

--- Collect the text of non-`.` children of an `attrpath` node.
--- @param attrpath_node TSNode
--- @return string[]
local function get_attrpath_parts(attrpath_node)
  local parts = {}
  for child in attrpath_node:iter_children() do
    if child:type() ~= "." then table.insert(parts, vim.treesitter.get_node_text(child, 0)) end
  end
  return parts
end

--- Get leading whitespace from the first line of a binding node.
--- @param binding TSNode
--- @return string
local function get_indent(binding)
  local row = binding:range()
  local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
  return line:match("^(%s*)") or ""
end

--- Build replacement lines for a split operation.
--- @param indent string
--- @param outer_path string  e.g. "services.nginx"
--- @param last_part string   e.g. "enable"
--- @param value_text string  possibly multiline
--- @return string[]
local function build_split_lines(indent, outer_path, last_part, value_text)
  local inner_indent = indent .. "  "
  local value_lines = vim.split(value_text, "\n", { plain = true })

  if #value_lines == 1 then
    return {
      indent .. outer_path .. " = {",
      inner_indent .. last_part .. " = " .. value_text .. ";",
      indent .. "};",
    }
  else
    -- Multi-line value: indent each line of the value by inner_indent
    local lines = { indent .. outer_path .. " = {" }
    local first_val_line = inner_indent .. last_part .. " = " .. value_lines[1]
    table.insert(lines, first_val_line)
    for i = 2, #value_lines do
      table.insert(lines, inner_indent .. value_lines[i])
    end
    -- Add semicolon to last value line
    lines[#lines] = lines[#lines] .. ";"
    table.insert(lines, indent .. "};")
    return lines
  end
end

--- Split a dotted attribute set path binding one level, e.g.
---   services.nginx.enable = true;
--- becomes:
---   services.nginx = {
---     enable = true;
---   };
function M.split()
  local binding = find_binding()
  if not binding then
    vim.notify("No binding under cursor", vim.log.levels.INFO)
    return
  end

  local attrpath_node = binding:child(0)
  if not attrpath_node or attrpath_node:type() ~= "attrpath" then
    vim.notify("No attrpath found", vim.log.levels.INFO)
    return
  end

  local parts = get_attrpath_parts(attrpath_node)
  if #parts <= 1 then
    vim.notify("Nothing to split: attrpath has only one component", vim.log.levels.INFO)
    return
  end

  local value_node = binding:child(2)
  if not value_node then
    vim.notify("No value node found in binding", vim.log.levels.INFO)
    return
  end

  local value_text = vim.treesitter.get_node_text(value_node, 0)
  local indent = get_indent(binding)

  -- outer_path = all but last part; last_part = last
  local outer_path = table.concat(parts, ".", 1, #parts - 1)
  local last_part = parts[#parts]

  local new_lines = build_split_lines(indent, outer_path, last_part, value_text)

  local start_row, _, end_row, _ = binding:range()
  vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, new_lines)
end

--- Join a nested attrset binding into flat dotted attrpath bindings, e.g.
---   services.nginx = {
---     enable = true;
---     user = "nginx";
---   };
--- becomes:
---   services.nginx.enable = true;
---   services.nginx.user = "nginx";
function M.join()
  local binding = find_binding(function(n)
    local val = n:child(2)
    return val ~= nil and (val:type() == "attrset_expression" or val:type() == "rec_attrset_expression")
  end)
  if not binding then
    vim.notify("No attrset binding under cursor", vim.log.levels.INFO)
    return
  end

  local outer_attrpath = binding:child(0)
  local outer_parts = get_attrpath_parts(outer_attrpath)
  local outer_prefix = table.concat(outer_parts, ".")

  local attrset_node = binding:child(2)
  local indent = get_indent(binding)

  -- Collect inner bindings (grammar wraps them in a binding_set node)
  local inner_bindings = {}
  local binding_set = nil
  for child in attrset_node:iter_children() do
    if child:type() == "binding_set" then
      binding_set = child
      break
    end
  end
  local search_node = binding_set or attrset_node
  for child in search_node:iter_children() do
    if child:type() == "binding" then table.insert(inner_bindings, child) end
  end

  if #inner_bindings == 0 then
    vim.notify("Attrset is empty, nothing to join", vim.log.levels.INFO)
    return
  end

  local new_lines = {}
  for _, inner in ipairs(inner_bindings) do
    local inner_attrpath = inner:child(0)
    local inner_parts = get_attrpath_parts(inner_attrpath)
    local inner_path = table.concat(inner_parts, ".")
    local full_path = outer_prefix .. "." .. inner_path

    local val_node = inner:child(2)
    local val_text = vim.treesitter.get_node_text(val_node, 0)
    local val_lines = vim.split(val_text, "\n", { plain = true })

    if #val_lines == 1 then
      table.insert(new_lines, indent .. full_path .. " = " .. val_text .. ";")
    else
      -- Multi-line value: keep relative indentation
      -- Determine the inner binding's own indent to compute offset
      local inner_row = inner:range()
      local inner_line = vim.api.nvim_buf_get_lines(0, inner_row, inner_row + 1, false)[1] or ""
      local inner_own_indent = inner_line:match("^(%s*)") or ""
      local extra = #inner_own_indent

      table.insert(new_lines, indent .. full_path .. " = " .. val_lines[1])
      for i = 2, #val_lines do
        local stripped = val_lines[i]:sub(extra + 1) -- remove inner binding's indent level
        table.insert(new_lines, indent .. stripped)
      end
      -- Ensure semicolon on last line
      new_lines[#new_lines] = new_lines[#new_lines] .. ";"
    end
  end

  local start_row, _, end_row, _ = binding:range()
  vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, new_lines)
end

return M
