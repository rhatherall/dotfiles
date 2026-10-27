-- Standalone tools Mason should keep installed (LSP servers are listed below).
local tools = {
  "tree-sitter-cli", -- compiles parsers for nvim-treesitter (main branch)
  "prettier",        -- conform.nvim: JS/TS/CSS/JSON/YAML/Markdown formatting
  "shellcheck",      -- nvim-lint: sh/zsh diagnostics
  "cfn-lint",        -- nvim-lint: CloudFormation templates
}

return {
  "mason-org/mason.nvim",
  dependencies = {
    "mason-org/mason-lspconfig.nvim", -- Bridges Mason with lspconfig
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
        "yamlls",   -- YAML LSP
        "ts_ls",    -- JavaScript/TypeScript LSP
      },
      -- Servers are enabled explicitly in plugins/lsp.lua. Without this, every
      -- Mason-installed server is started (e.g. Mason's rubocop/stylua as LSPs).
      automatic_enable = false,
    })

    -- After startup: loading the registry takes a few milliseconds
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        local registry = require("mason-registry")
        registry.refresh(function()
          for _, name in ipairs(tools) do
            local pkg = registry.get_package(name)
            if not pkg:is_installed() then pkg:install() end
          end
        end)
      end,
    })
  end
}
