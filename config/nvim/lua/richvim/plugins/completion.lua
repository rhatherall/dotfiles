-- Expands a LuaSnip snippet whose trigger is before the cursor
local function expand_snippet()
  local luasnip = require("luasnip")
  if not luasnip.expandable() then return end
  vim.schedule(luasnip.expand)
  return true
end

return {
  -- Completion Engine
  {
    "saghen/blink.cmp",
    version = "1.*", -- release tags ship a prebuilt Rust fuzzy matcher; main is v2, with breaking changes
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = {
      keymap = {
        -- C-space menu/docs, C-n/C-p select, C-y accept, C-e close, C-k signature
        preset = "default",
        -- Enter only accepts an item you've selected; otherwise it's a newline
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", expand_snippet, "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = true } },
        documentation = { auto_show = true },
      },
      signature = { enabled = true },
      snippets = { preset = "luasnip" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },

  {
    "L3MON4D3/LuaSnip",
    lazy = true, -- loaded by blink.cmp
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "v2.*",
    build = "make install_jsregexp",
    config = function()
      require("luasnip").config.setup({ enable_autosnippets = true })
      -- lazy_load: each filetype's snippets are read when a buffer of that type opens
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load({ paths = { "~/.config/nvim/snippets" } })
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = "~/.config/nvim/snippets/yaml",
        include = { "yaml", "json" }
      })
    end,
  },
}
