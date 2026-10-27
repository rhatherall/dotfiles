-- The branch HEAD started from: whichever of main, master and develop it has
-- the fewest commits beyond, so a git flow feature branch is compared with
-- develop, not main. Remote branches come first: a local main counts commits
-- that haven't been pushed as part of the base.
local function branch_base()
  local function git(...)
    local result = vim.system({ "git", ... }, { text = true }):wait()
    return result.code == 0 and vim.trim(result.stdout) or nil
  end

  local candidates = {}
  for _, prefix in ipairs({ "origin/", "" }) do
    for _, name in ipairs({ "main", "master", "develop" }) do
      if git("rev-parse", "--verify", "--quiet", prefix .. name) then
        table.insert(candidates, prefix .. name)
      end
    end
    if #candidates > 0 then break end
  end

  local base, fewest
  for _, ref in ipairs(candidates) do
    local ahead = tonumber(git("rev-list", "--count", ref .. "..HEAD"))
    if ahead and (not fewest or ahead < fewest) then
      base, fewest = ref, ahead
    end
  end
  return base
end

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
          vim.keymap.set({ "o", "x" }, "ih", gitsigns.select_hunk, { buffer = bufnr, desc = "inner hunk" })
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
      {
        "<leader>gD",
        function()
          local base = branch_base()
          if not base then
            vim.notify("No develop, main or master branch to compare with", vim.log.levels.WARN, { title = "Diffview" })
            return
          end
          -- --imply-local: the right side is the files on disk, uncommitted
          -- changes included, and they can be edited with LSP as usual.
          -- Diffview never lists untracked files against a commit; <leader>gd
          -- shows them
          vim.cmd("DiffviewOpen " .. base .. "...HEAD --imply-local")
        end,
        desc = "Diff branch against its base",
      },
      { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Close Diff View" },
    },
  },
}
