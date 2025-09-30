local function f(builtin, opts)
  return function() require("fzf-lua")[builtin](opts or {}) end
end

---@type lz.n.Spec
return {
  "fzf-lua",
  cmd = "FzfLua",
  keys = {
    { "<leader>,", f("buffers"), desc = "Find in Files (Grep)" },
    { "<leader>/", f("live_grep"), desc = "Grep" },
    { "<leader>:", f("command_history"), desc = "Command History" },
    { "<leader><cr>", f("files"), desc = "Find files (Grep)" },

    -- find
    { "<leader>fb", f("buffers", { sort_mru = true, sort_lastunused = true }), desc = "Find Files (Root Dir)" },
    { "<leader>ff", f("files"), desc = "Find Files (Root Dir)" },
    { "<leader>fg", f("git_files"), desc = "Find Files (git-files)" },

    -- search
    { '<leader>s"', f("registers"), desc = "Registers" },
    { "<leader>sb", f("builtin"), desc = "Builtins" },
    { "<leader>sd", f("diagnostic_document"), desc = "Document Diagnostics" },
    { "<leader>sD", f("diagnostic_workspace"), desc = "Workspace Diagnostics" },
    { "<leader>sg", f("live_grep"), desc = "Grep" },
    { "<leader>sh", f("help_tags"), desc = "Help Pages" },
    { "<leader>ss", f("lsp_document_symbols"), desc = "Goto Symbol" },
    { "<leader>sS", f("lsp_live_workspace_symbols"), desc = "Goto Symbol (workspace)" },
    { "<leader>sR", f("resume"), desc = "Resume" },
    { "<leader>sw", f("grep_cword"), desc = "cword" },
    { "<leader>sW", f("grep_cWORD"), desc = "cWORD" },
    { "<leader>sw", f("grep_visual"), mode = "v", desc = "Word" },
  },
  after = function()
    local actions = require("fzf-lua.actions")
    local icons = require("haven.icons")

    require("fzf-lua").setup({
      { "borderless-full", "hide" },
      fzf_opts = {
        ["--info"] = "default",
      },
      winopts = {
        preview = {
          scrollbar = false,
          layout = "vertical",
          vertical = "up:40%",
        },
      },
      keymap = {
        builtin = {
          true,
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },
        fzf = {
          true,
          ["ctrl-d"] = "preview-page-down",
          ["ctrl-u"] = "preview-page-up",
          ["ctrl-q"] = "select-all+accept",
        },
      },
      defaults = { git_icons = false },
      -- Configuration for specific commands
      files = {
        follow = true,
        winopts = {
          preview = { hidden = true },
        },
      },
      grep = {
        follow = true,
        header_prefix = icons.misc.search .. " ",
        rg_glob_fn = function(query, opts)
          local regex, flags = query:match(string.format("^(.*)%s(.*)$", opts.glob_separator))
          -- Return the original query if there's no separator.
          return (regex or query), flags
        end,
      },
      helptags = {
        actions = {
          -- Open help pages in a vertical split.
          ["enter"] = actions.help_vert,
        },
      },
      lsp = {
        symbols = {
          symbol_icons = icons.symbol_kinds,
        },
        code_actions = {
          winopts = {
            width = 70,
            height = 20,
            relative = "cursor",
            preview = {
              hidden = true,
              vertical = "down:50%",
            },
          },
        },
      },
      diagnostics = {
        -- Remove the dashed line between diagnostic items.
        multiline = 1,
        diag_icons = {
          icons.diagnostics.ERROR,
          icons.diagnostics.WARN,
          icons.diagnostics.INFO,
          icons.diagnostics.HINT,
        },
        actions = {
          ["ctrl-e"] = {
            fn = function(_, opts)
              -- If not filtering by severity, show all diagnostics.
              if opts.severity_only then
                opts.severity_only = nil
              else
                -- Else only show errors.
                opts.severity_only = vim.diagnostic.severity.ERROR
              end
              require("fzf-lua").resume(opts)
            end,
            noclose = true,
            desc = "toggle-all-only-errors",
            header = function(opts) return opts.severity_only and "show all" or "show only errors" end,
          },
        },
      },
      oldfiles = {
        include_current_session = true,
        winopts = {
          preview = { hidden = true },
        },
      },
    })
    vim.g.fzf_lua_loaded = true
  end,
}
