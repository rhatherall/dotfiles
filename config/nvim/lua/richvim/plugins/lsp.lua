-- ruby-lsp only re-indexes an open file when asked for its outline, and only
-- if the last edit touched a declaration. Neovim doesn't ask, so `gd` can't
-- find methods added since the file was opened, or ruby-lsp-rspec's `let`s
-- (spec files are left out of the workspace index). Ask on attach and after
-- every change; a delay would let later edits hide the one that matters.
local function keep_ruby_index_current(client, bufnr)
  local function request_outline()
    local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
    client:request("textDocument/documentSymbol", params, function() end, bufnr)
  end

  local group = vim.api.nvim_create_augroup("RichVimRubyIndex", { clear = false })
  vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr }) -- from a previous ruby-lsp
  vim.api.nvim_create_autocmd("LspNotify", {
    group = group,
    buffer = bufnr,
    callback = function(args)
      if args.data.client_id == client.id and args.data.method == "textDocument/didChange" then
        request_outline()
      end
    end,
  })
  request_outline()
end

-- Rails runs some YAML through ERB before parsing it (config/database.yml), and
-- a line that is only an ERB tag isn't YAML until then. ERB inside a value
-- (password: <%= ... %>) parses, so only a line starting with one counts.
local function erb_templated(bufnr)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line:match("^%s*<%%") then return true end
  end
  return false
end

return {
  -- LSP Configuration (Neovim 0.11+)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      -- Keep logs sane (your lsp.log was getting huge)
      vim.lsp.log.set_level("ERROR")

      -- Buffer-local LSP keymaps. Neovim provides the rest by default:
      -- K hover, grr references, grn rename, gra code action,
      -- gri implementation, grt type definition
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("RichVimLspAttach", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to Definition" })

          if not client then return end

          -- Solargraph is only for navigating legacy projects; don't let it format
          if client.name == "solargraph" then
            client.server_capabilities.documentFormattingProvider = false
          end

          if client.name == "ruby_lsp" and vim.bo[bufnr].filetype == "ruby" then
            keep_ruby_index_current(client, bufnr)
          end

          if client.name == "yamlls" and erb_templated(bufnr) then
            vim.diagnostic.enable(false, { bufnr = bufnr, ns_id = vim.lsp.diagnostic.get_namespace(client.id, false) })
          end

          -- Suppress benign NO_RESULT_CALLBACK_FOUND from ruby-lsp on eruby buffers
          if client.name == "ruby_lsp" and not client._richvim_error_patched then
            client._richvim_error_patched = true
            local orig_on_error = client._on_error
            client._on_error = function(self, code, err)
              if code == vim.lsp.rpc.client_errors.NO_RESULT_CALLBACK_FOUND then return end
              return orig_on_error(self, code, err)
            end
          end
        end,
      })

      -- Shared by every server: blink.cmp completion capabilities, plus a
      -- normalized position encoding to avoid mixed-client weirdness. Set here
      -- because blink.cmp only sets them itself once it loads, after the first
      -- file's servers have started.
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(
          { general = { positionEncodings = { "utf-16" } } },
          true
        ),
      })

      -- Per-project selector (ruby-lsp if present in Gemfile.lock or .ruby-lsp/ exists; else solargraph)
      local ruby_selector = require("richvim.lsp.ruby_selector")

      -- Lua LSP
      vim.lsp.config("lua_ls", {
        filetypes = { "lua" },
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })
      vim.lsp.enable("lua_ls")

      -- ruby-lsp (Ruby 3.0+): navigation, completion, plus RuboCop/Standard
      -- diagnostics and formatting using the project's own config. Run from the
      -- global gem, not `bundle exec`: it builds its own bundle in .ruby-lsp/
      -- that includes the project's Gemfile.
      vim.lsp.config("ruby_lsp", {
        filetypes = { "ruby", "eruby" },
        root_dir = ruby_selector.ruby_lsp_root_dir,
        cmd = ruby_selector.cmd({ "ruby-lsp" }),
        -- Send each change straight away. With Neovim's default 150ms batching,
        -- ruby-lsp can answer the signature help request blink.cmp makes on `(`
        -- before applying autopairs' `)`, and returns nothing.
        flags = { debounce_text_changes = 0 },
      })
      vim.lsp.enable("ruby_lsp")

      -- Solargraph (Ruby < 3.0): navigation only, for legacy projects
      vim.lsp.config("solargraph", {
        filetypes = { "ruby" },
        root_dir = ruby_selector.solargraph_root_dir,
        cmd = ruby_selector.cmd({ "solargraph", "stdio" }),
        settings = {
          solargraph = {
            diagnostics = false,
            formatting = false,
            completion = true,
          },
        },
      })
      vim.lsp.enable("solargraph")

      -- Python (installed by mason-lspconfig)
      vim.lsp.enable("pyright")

      -- YAML: checks files against the schemas schemastore.org lists for
      -- their names (GitHub workflows, docker-compose and so on). CloudFormation's
      -- short-form functions are custom tags, which it reports as errors unless
      -- declared; cfn-lint checks the templates themselves.
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            customTags = {
              "!And sequence", "!Base64", "!Base64 mapping", "!Cidr sequence", "!Condition",
              "!Equals sequence", "!FindInMap sequence", "!GetAtt", "!GetAtt sequence", "!GetAZs",
              "!If sequence", "!ImportValue", "!ImportValue mapping", "!Join sequence", "!Not sequence",
              "!Or sequence", "!Ref", "!Select sequence", "!Split sequence", "!Sub", "!Sub sequence",
              "!Transform mapping",
            },
          },
        },
      })
      vim.lsp.enable("yamlls")

      -- JavaScript (Stimulus controllers). In an importmap app the packages
      -- aren't on disk, so only imports of the app's own files resolve.
      vim.lsp.enable("ts_ls")
    end,
  },

  -- Formatting: on save and <leader>cf
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function()
          if not require("conform").format() then
            vim.notify("No formatter available for this buffer (see :ConformInfo)", vim.log.levels.WARN, { title = "Format" })
          end
        end,
        desc = "Format File",
      },
    },
    config = function()
      local formatters_by_ft = {
        -- ruby-lsp formats with the project's own RuboCop/Standard config
        ruby = { lsp_format = "prefer" },
        eruby = { "htmlbeautifier" },
      }
      for _, ft in ipairs({
        "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "astro",
        "css", "scss", "less", "html", "json", "jsonc", "yaml", "markdown", "graphql", "handlebars",
      }) do
        formatters_by_ft[ft] = { "prettier" }
      end

      require("conform").setup({
        formatters_by_ft = formatters_by_ft,
        formatters = {
          -- Only for projects that bundle it, run through Bundler
          htmlbeautifier = {
            command = "bundle",
            args = { "exec", "htmlbeautifier" },
            cwd = require("conform.util").root_file({ "Gemfile.lock" }),
            require_cwd = true,
            condition = function(_, ctx)
              local root = vim.fs.root(ctx.buf, { "Gemfile.lock" })
              if not root then return false end
              local ok, lines = pcall(vim.fn.readfile, root .. "/Gemfile.lock")
              if not ok then return false end
              for _, line in ipairs(lines) do
                if line:match("^%s*htmlbeautifier%s*%(") then return true end
              end
              return false
            end,
          },
        },
        default_format_opts = { timeout_ms = 10000 },
        format_on_save = {},
      })
    end,
  },

  -- Linting: ShellCheck for sh and zsh
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      local shellcheck = lint.linters.shellcheck

      -- ShellCheck doesn't support zsh; checking it as bash still catches
      -- most mistakes without flagging every file for a missing shebang
      lint.linters.shellcheck_zsh = vim.tbl_extend("force", shellcheck, {
        args = vim.list_extend({ "--shell=bash" }, vim.deepcopy(shellcheck.args)),
      })
      lint.linters_by_ft = {
        sh = { "shellcheck" },
        zsh = { "shellcheck_zsh" },
      }

      -- cfn-lint only for CloudFormation templates: other YAML and JSON would
      -- fail it. A template that leaves out the optional
      -- AWSTemplateFormatVersion isn't recognised.
      local function cloudformation_template(bufnr)
        if not vim.tbl_contains({ "yaml", "json" }, vim.bo[bufnr].filetype) then return false end
        for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 10, false)) do
          if line:find("AWSTemplateFormatVersion", 1, true) then return true end
        end
        return false
      end

      -- FileType as well as BufReadPost: this plugin loads during the first
      -- buffer's BufReadPost, which can be before its filetype is detected
      vim.api.nvim_create_autocmd({ "BufReadPost", "FileType", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("RichVimLint", { clear = true }),
        callback = function(args)
          lint.try_lint()
          if cloudformation_template(args.buf) then lint.try_lint("cfn_lint") end
        end,
      })
    end,
  },
}
