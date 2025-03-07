return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- Lua LSP
      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          }
        }
      })

      -- Ruby LSP (Solargraph)
      lspconfig.solargraph.setup {
        settings = {
          solargraph = {
            diagnostics = true,
            formatting = false,
            completion = true,
            useBundler = true,
          }
        },
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
        end
      }

      -- Linting with Rubocop
      lspconfig.rubocop.setup {
        cmd = { "rubocop", "--lsp" },
        filetypes = { "ruby" },
      }

      -- StandardRB (alternative to Rubocop)
      lspconfig.standardrb.setup {}

      -- Keybindings for LSP
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Find References" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Info" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
    end
  },

  -- None-LS: Community Fork of Null-LS for Linting & Formatting
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvimtools/none-ls-extras.nvim", -- Adds additional linters & formatters
    },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          -- Formatters
          -- null_ls.builtins.formatting.standardrb,   -- StandardRB for Ruby
          null_ls.builtins.formatting.rubocop,      -- Rubocop for Ruby
          null_ls.builtins.formatting.prettier,     -- Prettier (JS, JSON, etc.)

          -- Linters
          -- null_ls.builtins.diagnostics.standardrb,  -- StandardRB as a linter
          null_ls.builtins.diagnostics.rubocop,     -- Rubocop as a linter

          -- Code Actions
          null_ls.builtins.code_actions.gitsigns,
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            -- Auto-format on save
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ async = false })
              end,
            })
          end
        end
      })
    end
  },
}
