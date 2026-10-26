return {
  -- Git Commands Inside Neovim
  { "tpope/vim-fugitive" },
  -- GitHub Integration for Fugitive
  { "tpope/vim-rhubarb" },

  -- Git Signs (Shows git diff in the sign column)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
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
        on_attach = function(bufnr)
          local gitsigns = require("gitsigns")
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
          end

          map("]h", function() gitsigns.nav_hunk("next") end, "Next Hunk")
          map("[h", function() gitsigns.nav_hunk("prev") end, "Previous Hunk")
          map("<leader>gs", gitsigns.stage_hunk, "Stage Hunk")
          map("<leader>gr", gitsigns.reset_hunk, "Reset Hunk")
          map("<leader>gp", gitsigns.preview_hunk, "Preview Hunk")
          map("<leader>gb", gitsigns.blame_line, "Blame Line")
        end,
      }
    end
  },

  -- Neogit (Magit-like Git UI)
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>", desc = "Open Neogit" },
    },
    config = function()
      require("neogit").setup({ integrations = { diffview = true } })
    end
  },

  -- DiffView
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewRefresh", "DiffviewLog" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Open Diff View" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Close Diff View" },
    },
  },
}
