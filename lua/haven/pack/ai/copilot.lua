return {
  "copilot.lua",
  event = "InsertEnter",
  after = function()
    require("copilot").setup({
      -- The panel is useless.
      panel = { enabled = false },
      suggestion = {
        hide_during_completion = false,
        keymap = {
          accept = "<C-j>",
          accept_word = "<M-w>",
          accept_line = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-/>",
        },
      },
      filetypes = {
        markdown = true,
        yaml = true,
      },
      server_opts_overrides = {
        settings = {
          telemetry = {
            telemetryLevel = "off",
          },
        },
      },
    })
  end,
}
