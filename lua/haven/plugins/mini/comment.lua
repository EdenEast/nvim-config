require("mini.comment").setup({
  options = {
    hooks = {
      pre = function() require("ts_context_commentstring.internal").update_commentstring({}) end,
    },
  },
})
