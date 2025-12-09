---@diagnostic disable: missing-fields
local arrows = require("haven.icons").arrows

-- Set up icons.
local icons = {
  Stopped = { "", "DiagnosticWarn", "DapStoppedLine" },
  Breakpoint = "",
  BreakpointCondition = "",
  BreakpointRejected = { "", "DiagnosticError" },
  LogPoint = arrows.right,
}
for name, sign in pairs(icons) do
  sign = type(sign) == "table" and sign or { sign }
  vim.fn.sign_define("Dap" .. name, {
    -- stylua: ignore
    text = sign[1] --[[@as string]] .. ' ',
    texthl = sign[2] or "DiagnosticInfo",
    linehl = sign[3],
    numhl = sign[3],
  })
end

---@type lz.n.Spec
return {
  {
    "nvim-dap",
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dB", "<cmd>Fzflua dap_breakpoints<cr>", desc = "List Breakpoints" },
      {
        "<leader>dc",
        function() require("dap").set_condition({ vim.fn.input("Condition: ") }) end,
        desc = "Breakpoint Condition",
      },
      { "<leader>dk", function() require("dap").down() end, desc = "Move Up" },
      { "<leader>dj", function() require("dap").down() end, desc = "Move Down" },
      { "<leader>dd", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>dr", function() require("dap").disconnect({ restart = true }) end, desc = "Restart" },
      { "<leader>dr", function() require("dap").disconnect() end, desc = "Disconnect" },
      { "<F5>", function() require("dap").continue() end, desc = "Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Step Out" },
    },
    before = function()
      local lz = require("lz.n")
      lz.trigger_load("overseer.nvim")
    end,
    after = function()
      local lz = require("lz.n")
      lz.trigger_load("nvim-dap-virtual-text")
      lz.trigger_load("nvim-dap-view")
      local dap = require("dap")
      local dv = require("dap-view")

      -- Automatically open the UI when a new debug session is created.
      dap.listeners.before.attach["dap-view-config"] = function() dv.open() end
      dap.listeners.before.launch["dap-view-config"] = function() dv.open() end
      dap.listeners.before.event_terminated["dap-view-config"] = function() dv.close() end
      dap.listeners.before.event_exited["dap-view-config"] = function() dv.close() end

      -- Use overseer for running preLaunchTask and postDebugTask.
      require("overseer").patch_dap(true)
      require("dap.ext.vscode").json_decode = require("overseer.json").decode

      -- Load language / adaptor configurations
      for _, mod in ipairs({
        -- "c",
        -- "lua",
        "rust",
      }) do
        require("haven.pack.dap.adaptor." .. mod)
      end
    end,
  },

  {
    "one-small-step-for-vimkind",
    keys = {
      { "<leader>dl", function() require("osv").launch({ port = 8086 }) end, desc = "Launch Lua adaptor" },
    },
    before = function() require("lz.n").trigger_load("nvim-dap") end,
  },

  {
    "nvim-dap-view",
    lazy = true,
    after = function()
      require("dap-view").setup({
        winbar = {
          sections = { "scopes", "breakpoints", "threads", "exceptions", "repl", "console" },
          default_section = "scopes",
        },
        windows = { height = 18 },
        -- When jumping through the call stack, try to switch to the buffer if already open in
        -- a window, else use the last window to open the buffer.
        switchbuf = "usetab,uselast",
      })
    end,
  },

  {
    "nvim-dap-virtual-text",
    lazy = true,
    after = function()
      require("nvim-dap-virtual-text").setup({
        virt_text_pos = "eol",
      })
    end,
  },
}
