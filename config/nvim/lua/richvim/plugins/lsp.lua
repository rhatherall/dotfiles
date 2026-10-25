return {
  -- LSP Configuration (Neovim 0.11+)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
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

      -- Shared by every server: nvim-cmp completion capabilities, plus a
      -- normalized position encoding to avoid mixed-client weirdness
      vim.lsp.config("*", {
        capabilities = vim.tbl_deep_extend(
          "force",
          vim.lsp.protocol.make_client_capabilities(),
          require("cmp_nvim_lsp").default_capabilities(),
          { general = { positionEncodings = { "utf-16" } } }
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

      -- ruby-lsp (modern projects)
      vim.lsp.config("ruby_lsp", {
        filetypes = { "ruby", "eruby" },
        root_dir = ruby_selector.ruby_lsp_root_dir,
        cmd = ruby_selector.cmd("ruby-lsp"),
      })
      vim.lsp.enable("ruby_lsp")

      -- Solargraph (legacy projects)
      vim.lsp.config("solargraph", {
        filetypes = { "ruby" },
        root_dir = ruby_selector.solargraph_root_dir,
        cmd = ruby_selector.cmd("solargraph", { "stdio" }),
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

      -- Python (installed by mason-lspconfig)
      vim.lsp.enable("pyright")

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

      -- Format via null-ls only, both on save and on demand
      local function format(bufnr)
        vim.lsp.buf.format({
          bufnr = bufnr,
          async = false,
          name = "null-ls",
          timeout_ms = 10000,
        })
      end

      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("RichVimFormatOnSave", { clear = true }),
        callback = function(args) format(args.buf) end,
      })
      vim.keymap.set("n", "<leader>cf", function() format(0) end, { desc = "Format File" })
    end,
  },
}
