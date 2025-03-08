return {
  -- Treesitter: Better Syntax Highlighting & Indentation
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "ruby", "lua", "vim", "bash", "javascript", "json", "yaml" },
        highlight = { enable = true },
        indent = { enable = true }
      }
    end
  },
}
