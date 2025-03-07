return {
  -- Neotest: Flexible Test Runner
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "olimorris/neotest-rspec",       -- RSpec integration
      "nvim-neotest/neotest-vim-test", -- Allows running tests via vim-test
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local neotest = require("neotest")

      neotest.setup({
        adapters = {
          require("neotest-rspec"),
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
