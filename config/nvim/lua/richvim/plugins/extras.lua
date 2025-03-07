return {
  -- Keybinding Helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Vim-Rails: Rails Project Navigation
  {
    "tpope/vim-rails",
    event = "VeryLazy",
  },
}
