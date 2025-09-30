---@type lz.n.Spec
return {
  "blink.pairs",
  event = { "InsertEnter" },
  build = "cargo build --release",
  after = function() require("blink-pairs").setup({ mappings = { enabled = true } }) end,
}
