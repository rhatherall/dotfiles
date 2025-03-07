return {
  -- Git Commands Inside Neovim
  { "tpope/vim-fugitive" },
  -- GitHub Integration for Fugitive
  { "tpope/vim-rhubarb" },

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

  -- Neogit (Magit-like Git UI)
  {
    "TimUntersberger/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("neogit").setup({ integrations = { diffview = true } })
      vim.keymap.set("n", "<leader>gg", ":Neogit<CR>", { desc = "Open Neogit" })
    end
  },

  -- DiffView
  {
    "sindrets/diffview.nvim",
    config = function()
      vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Open Diff View" })
      vim.keymap.set("n", "<leader>gq", ":DiffviewClose<CR>", { desc = "Close Diff View" })
    end
  },
}
