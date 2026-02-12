return {
  -- LSP Configuration (Neovim 0.11+)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Keep logs sane (your lsp.log was getting huge)
      vim.lsp.set_log_level("ERROR")

      -- Buffer-local LSP keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("RichVimLspAttach", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local opts = { buffer = bufnr }

          vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
          vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Find References" }))
          vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Info" }))
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))

          if not client then return end

          -- Let none-ls own formatting
          if client.name == "solargraph" then
            client.server_capabilities.documentFormattingProvider = false
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

      -- Normalize position encoding to avoid mixed-client weirdness
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.general = capabilities.general or {}
      capabilities.general.positionEncodings = { "utf-16" }

      -- Per-project selector (ruby-lsp if present in Gemfile.lock or .ruby-lsp/ exists; else solargraph)
      local ruby_selector = require("richvim.lsp.ruby_selector")

      -- Lua LSP
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
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

      -- ruby-lsp (modern projects)
      vim.lsp.config("ruby_lsp", {
        capabilities = capabilities,
        filetypes = { "ruby", "eruby" },
        root_dir = ruby_selector.ruby_lsp_root_dir,
        cmd = { "bundle", "exec", "ruby-lsp" },
      })
      vim.lsp.enable("ruby_lsp")

      -- Solargraph (legacy projects)
      vim.lsp.config("solargraph", {
        capabilities = capabilities,
        filetypes = { "ruby" },
        root_dir = ruby_selector.solargraph_root_dir,
        cmd = { "bundle", "exec", "solargraph", "stdio" },
        settings = {
          solargraph = {
            diagnostics = true,
            formatting = false,
            completion = true,
            useBundler = true,
          },
        },
      })
      vim.lsp.enable("solargraph")

      -- IMPORTANT:
      -- Do NOT also enable rubocop / standardrb as LSP servers if you're using none-ls for rubocop.
      -- That was a big source of hangs and encoding mismatch in your earlier :LspInfo.
    end,
  },

  -- None-LS (RuboCop diagnostics + formatting + format-on-save)
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvimtools/none-ls-extras.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local null_ls = require("null-ls")
      local shellcheck = require("richvim.diagnostics.shellcheck")

      null_ls.setup({
        sources = {
          -- RuboCop formatting (Bundler)
          null_ls.builtins.formatting.rubocop.with({
            command = "bundle",
            args = { "exec", "rubocop", "--autocorrect-all", "-f", "quiet", "--stderr", "--stdin", "$FILENAME" },
          }),

          -- RuboCop diagnostics (Bundler)
          null_ls.builtins.diagnostics.rubocop.with({
            command = "bundle",
            args = { "exec", "rubocop", "--format", "json", "--force-exclusion", "--stdin", "$FILENAME" },
          }),

          -- htmlbeautifier for ERB (Bundler, only when gem is available)
          null_ls.builtins.formatting.htmlbeautifier.with({
            command = "bundle",
            args = { "exec", "htmlbeautifier", "$FILENAME" },
            runtime_condition = function(params)
              local lock = vim.fs.root(params.bufnr, { "Gemfile.lock" })
              if not lock then return false end
              local ok, lines = pcall(vim.fn.readfile, lock .. "/Gemfile.lock")
              if not ok then return false end
              for _, line in ipairs(lines) do
                if line:match("^%s*htmlbeautifier%s*%(") then return true end
              end
              return false
            end,
          }),

          -- Other
          null_ls.builtins.formatting.prettier,
          shellcheck,
          null_ls.builtins.code_actions.gitsigns,
        },
      })

      -- Format on save via null-ls only
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("RichVimFormatOnSave", { clear = true }),
        callback = function(args)
          vim.lsp.buf.format({
            bufnr = args.buf,
            async = false,
            name = "null-ls",
            timeout_ms = 10000,
          })
        end,
      })
    end,
  },
}
