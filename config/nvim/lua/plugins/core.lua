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

  -- Fuzzy Finder (Telescope)
  {
    "sato-s/telescope-rails.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("rails")
    end,
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
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
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

  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    build = "make install_jsregexp",
    config = function()
      require("luasnip").config.setup({ enable_autosnippets = true })
      require("luasnip.loaders.from_vscode").lazy_load() -- Load VSCode-style snippets
      require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
    end,
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

  -- Debug Adapter Protocol (DAP) for Neovim
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui", -- UI for DAP
      "suketa/nvim-dap-ruby", -- Ruby DAP Adapter
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup UI
      dapui.setup()

      -- Auto-open and close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Automatically configure Ruby DAP
      require("dap-ruby").setup()

      -- Keybindings for debugging
      vim.keymap.set("n", "<leader>db", ":DapToggleBreakpoint<CR>", { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", ":DapContinue<CR>", { desc = "Continue Debugging" })
      vim.keymap.set("n", "<leader>ds", ":DapStepOver<CR>", { desc = "Step Over" })
      vim.keymap.set("n", "<leader>di", ":DapStepInto<CR>", { desc = "Step Into" })
      vim.keymap.set("n", "<leader>do", ":DapStepOut<CR>", { desc = "Step Out" })
      vim.keymap.set("n", "<leader>dr", ":DapRestart<CR>", { desc = "Restart Debugging" })
      vim.keymap.set("n", "<leader>dt", ":DapTerminate<CR>", { desc = "Stop Debugging" })

      -- ✅ Delphi IDE Debugger Keymaps
      vim.keymap.set("n", "<F5>", ":DapToggleBreakpoint<CR>", { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<F7>", ":DapStepInto<CR>", { desc = "Step Into" })
      vim.keymap.set("n", "<F8>", ":DapStepOver<CR>", { desc = "Step Over" })
      vim.keymap.set("n", "<S-F8>", ":DapStepOut<CR>", { desc = "Step Out" })
      vim.keymap.set("n", "<F9>", ":DapContinue<CR>", { desc = "Run / Continue Execution" })
      vim.keymap.set("n", "<C-F2>", ":DapTerminate<CR>", { desc = "Stop Debugging" })
      vim.keymap.set("n", "<S-F9>", ":lua require('dap.ui.widgets').hover()<CR>", { desc = "Inspect Variable" })
      vim.keymap.set("n", "<C-S-F9>", ":DapClearBreakpoints<CR>", { desc = "Clear All Breakpoints" })
    end
  },

  {
    "tpope/vim-rails",
    event = "VeryLazy",
  },
}
