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
    { "<leader>f<", f("resume"), desc = "Resume last fzf command" },

    -- find
    { "<leader>fb", f("buffers", { sort_mru = true, sort_lastunused = true }), desc = "Find Files (Root Dir)" },
    { "<leader>ff", f("files"), desc = "Find Files (Root Dir)" },
    { "<leader>fF", f("git_files"), desc = "Find Files (git-files)" },
    { "<leader>fg", f("live_grep"), desc = "Grep" },
    { "<leader>fg", f("grep_visual"), desc = "Grep", mode = "x" },
    { "<leader>fd", f("diagnostics_document"), desc = "Document Diagnostics" },
    { "<leader>fD", f("diagnostics_workspace"), desc = "Workspace Diagnostics" },
    { "<leader>fh", f("help_tags"), desc = "Help Pages" },
    { "<leader>fs", f("lsp_document_symbols"), desc = "Goto Symbol" },
    { "<leader>fS", f("lsp_live_workspace_symbols"), desc = "Goto Symbol (workspace)" },
    { "<leader>fr", f("resume"), desc = "Resume" },
    { "<leader>fw", f("grep_cword"), desc = "cword" },
    { "<leader>fW", f("grep_cWORD"), desc = "cWORD" },
    { "<leader>fw", f("grep_visual"), mode = "v", desc = "Word" },
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
  before = function()
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function(items, opts, on_choice)
      local ui_select = require("fzf-lua.providers.ui_select")

      -- Register the fzf-lua picker the first time we call select.
      if not ui_select.is_registered() then
        ui_select.register(function(ui_opts)
          if ui_opts.kind == "luasnip" then
            ui_opts.prompt = "Snippet choice: "
            ui_opts.winopts = {
              relative = "cursor",
              height = 0.35,
              width = 0.3,
            }
          else
            ui_opts.winopts = { height = 0.5, width = 0.4 }
          end

          -- Use the kind (if available) to set the previewer's title.
          if ui_opts.kind then ui_opts.winopts.title = string.format(" %s ", ui_opts.kind) end

          return ui_opts
        end)
      end

      -- Don't show the picker if there's nothing to pick.
      if #items > 0 then return vim.ui.select(items, opts, on_choice) end
    end
  end,
}
