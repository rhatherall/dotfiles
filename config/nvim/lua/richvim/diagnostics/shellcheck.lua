local helpers = require("null-ls.helpers")
local methods = require("null-ls.methods")

return helpers.make_builtin({
  name = "shellcheck",
  meta = {
    url = "https://www.shellcheck.net",
    description = "Finds bugs and style issues in shell scripts.",
  },
  method = methods.internal.DIAGNOSTICS,
  filetypes = { "sh", "zsh" },
  generator_opts = {
    command = "shellcheck",
    args = { "--format=json1", "-" },
    to_stdin = true,
    from_stderr = false,
    format = "json",
    check_exit_code = function(code)
      return code <= 1
    end,
    on_output = function(params)
      local diagnostics = {}
      for _, result in ipairs(params.output.comments or {}) do
        table.insert(diagnostics, {
          row = result.line,
          col = result.column,
          end_col = result.endColumn,
          message = result.message,
          severity = ({
            error = 1,
            warning = 2,
            info = 3,
            style = 4,
          })[result.level] or 3,
          source = "shellcheck",
        })
      end
      return diagnostics
    end,
  },
  factory = helpers.generator_factory,
})
