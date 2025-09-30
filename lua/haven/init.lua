local profiler = vim.env.NVIM_PROFILE
if profiler then
  if profiler == "snacks" then
    require("snacks.profiler").startup({ event = "VimEnter" })
  elseif profiler == "trace" then
    vim.api.nvim_create_autocmd("UiEnter", {
      group = vim.api.nvim_create_augroup("startup_profiler_trace", { clear = true }),
      callback = function()
        local profile = require("profile")
        profile.stop()
        vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "profile.json" }, function(filename)
          if filename then
            profile.export(filename)
            vim.notify(string.format("Wrote %s", filename))
          end
        end)
      end,
    })

    vim.cmd.packadd("profile.nvim")
    local profile = require("profile")
    profile.instrument_autocmds()
    profile.start("*")
  end
end

require("haven.core")
