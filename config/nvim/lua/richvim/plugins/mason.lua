-- Standalone tools Mason should keep installed (not LSP servers or none-ls sources).
local tools = {
  "tree-sitter-cli", -- compiles parsers for nvim-treesitter (main branch)
}

return {
  "mason-org/mason.nvim",
  dependencies = {
    "mason-org/mason-lspconfig.nvim", -- Bridges Mason with lspconfig
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
      -- Servers are enabled explicitly in plugins/lsp.lua. Without this, every
      -- Mason-installed server is started (e.g. Mason's rubocop/stylua as LSPs).
      automatic_enable = false,
    })

    require("mason-null-ls").setup({
      ensure_installed = {
        "stylua",   -- Lua formatter
        "prettier", -- JS/TS/CSS formatter
        "eslint_d", -- JS linter
      },
      automatic_installation = false,
    })

    local registry = require("mason-registry")
    registry.refresh(function()
      for _, name in ipairs(tools) do
        local pkg = registry.get_package(name)
        if not pkg:is_installed() then pkg:install() end
      end
    end)
  end
}
