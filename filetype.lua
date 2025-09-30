vim.filetype.add({
  filename = {
    ["justfile"] = "just",
    ["Justfile"] = "just",
  },
  extension = {
    ["kdl"] = "kdl",
    ["dhall"] = "dhall",
    ["tl"] = "teal",
  },
  pattern = {
    -- Borrowed from LazyVim. Mark huge files to disable features later.
    [".*"] = function(path, bufnr)
      return vim.bo[bufnr]
          and vim.bo[bufnr].filetype ~= "bigfile"
          and path
          and vim.fn.getfsize(path) > (1024 * 500) -- 500 KB
          and "bigfile"
        or nil
    end,
  },
})
