return {
  -- Keybinding Helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        spec = {
          { "<leader>c", group = "Code" },
          { "<leader>d", group = "Debug" },
          { "<leader>f", group = "Find" },
          { "<leader>g", group = "Git" },
          { "<leader>r", group = "Rails" },
          { "<leader>s", group = "Search" },
          { "<leader>t", group = "Test" },
          { "<leader>w", group = "Timewarrior" },
        },
      })
    end,
  },

  -- Vim-Rails: Rails Project Navigation
  {
    "tpope/vim-rails",
    event = "VeryLazy",
  },
}
