return {
  -- Claude Code's IDE connection: Claude sees the open file and selection, and
  -- edits it asks about open here as diffs. Claude runs in its own terminal,
  -- so this plugin opens none.
  {
    "coder/claudecode.nvim",
    -- /ide only finds Neovim once the server is running, but it needn't
    -- delay the first screen
    event = "VeryLazy",
    keys = {
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", desc = "Add file to Claude" },
      -- Not select mode: LuaSnip placeholders use it, where <Space> is typed text
      { "<leader>as", "<cmd>ClaudeCodeSend<CR>", mode = "x", desc = "Send selection to Claude" },
      { "<leader>as", "<cmd>ClaudeCodeTreeAdd<CR>", ft = "NvimTree", desc = "Add file to Claude" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", desc = "Accept Claude's diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>", desc = "Reject Claude's diff" },
    },
    opts = {
      terminal = { provider = "none" },
    },
  },
}
