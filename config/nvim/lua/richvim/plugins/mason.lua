return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim", -- Bridges Mason with lspconfig
    "jay-babu/mason-null-ls.nvim", -- Optional: for linters/formatters
  },
  config = function()
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    })

    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",   -- Lua LSP (for Neovim)
        "pyright",  -- Python LSP
      },
      automatic_installation = true, -- Auto-install missing LSPs
    })

    require("mason-null-ls").setup({
      ensure_installed = {
        "stylua",   -- Lua formatter
        "prettier", -- JS/TS/CSS formatter
        "eslint_d", -- JS linter
      },
      automatic_installation = true,
    })
  end
}
