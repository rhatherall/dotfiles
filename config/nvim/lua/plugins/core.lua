return {
  -- One Dark Theme
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("onedark").setup {
        style = "darker" -- Options: 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'
      }
      require("onedark").load()
    end
  },

  -- File Explorer (Nvim-Tree)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
    end
  },

  -- Fuzzy Finder (Telescope)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
      vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live Grep" })
    end
  },

  -- Git Signs (Shows git diff in the sign column)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup {
        signs = {
          add          = { text = "+" },
          change       = { text = "~" },
          delete       = { text = "-" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
        },
        current_line_blame = true, -- Show git blame inline
      }
    end
  },

  -- Git Commands Inside Neovim
  { "tpope/vim-fugitive" },

  -- GitHub Integration for Fugitive
  { "tpope/vim-rhubarb" },

  -- Neogit (Magit-like Git UI)
  {
    "TimUntersberger/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("neogit").setup {
        integrations = {
          diffview = true, -- Enables integration with diffview.nvim (optional)
        }
      }
      vim.keymap.set("n", "<leader>gg", ":Neogit<CR>", { desc = "Open Neogit" })
    end
  },

  -- Optional: DiffView for better diffs
  {
    "sindrets/diffview.nvim",
    config = function()
      vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Open Diff View" })
      vim.keymap.set("n", "<leader>gq", ":DiffviewClose<CR>", { desc = "Close Diff View" })
    end
  },

  -- Lua Language Server (for editing config and general Lua work)
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").lua_ls.setup {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = {
              globals = { "vim" }, -- Prevent "undefined global 'vim'" error
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          }
        }
      }
    end
  },

  -- Treesitter for better Lua highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "ruby", "lua", "vim", "bash", "javascript", "json" },
        highlight = { enable = true },
        indent = { enable = true }
      }
    end
  },

  -- Run Lua code inside Neovim
  { "bfredl/nvim-luadev" },

  -- Debugging helper functions
  { "nvim-lua/plenary.nvim" },

    -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- Ruby LSP (Solargraph)
      lspconfig.solargraph.setup {
        settings = {
          solargraph = {
            diagnostics = true,
            formatting = true,
            completion = true,
          }
        }
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

    -- Completion Engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",    -- LSP source
      "hrsh7th/cmp-buffer",      -- Buffer words completion
      "hrsh7th/cmp-path",        -- Path completion
      "L3MON4D3/LuaSnip",        -- Snippets
      "saadparwaiz1/cmp_luasnip" -- Snippet completion
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- Use LuaSnip for snippets
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept completion
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end,
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- LSP completions
          { name = "buffer" },   -- Buffer words
          { name = "path" },     -- Path completion
          { name = "luasnip" },  -- Snippets
        })
      })
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

  -- Neotest: Flexible Test Runner
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "olimorris/neotest-rspec",  -- RSpec integration
      "nvim-neotest/neotest-vim-test",  -- Allow running tests via vim-test
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local neotest = require("neotest")

      neotest.setup({
        adapters = {
          require("neotest-rspec"),  -- RSpec support
          require("neotest-vim-test")({ allow_file_types = { "ruby", "elixir", "python" } }),
        },
      })

      -- Keybindings for running tests
      vim.keymap.set("n", "<leader>tt", function() neotest.run.run() end, { desc = "Run nearest test" })
      vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run current file tests" })
      vim.keymap.set("n", "<leader>ts", function() neotest.run.run(vim.fn.getcwd()) end, { desc = "Run full test suite" })
      vim.keymap.set("n", "<leader>to", function() neotest.output.open() end, { desc = "Show test output" })
      vim.keymap.set("n", "<leader>tl", function() neotest.summary.toggle() end, { desc = "Toggle test summary" })
    end
  },

  -- Vim-Test: Alternative Test Runner
  {
    "vim-test/vim-test",
    config = function()
      vim.keymap.set("n", "<leader>tT", ":TestNearest<CR>", { desc = "Run nearest test (vim-test)" })
      vim.keymap.set("n", "<leader>tF", ":TestFile<CR>", { desc = "Run current test file (vim-test)" })
      vim.keymap.set("n", "<leader>tA", ":TestSuite<CR>", { desc = "Run full test suite (vim-test)" })
    end
  },
}
