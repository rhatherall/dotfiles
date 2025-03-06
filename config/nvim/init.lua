-- Set leader key early (space as leader)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap Lazy.nvim (ensures Lazy.nvim is installed before anything else)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from the "lua/plugins" directory
require("lazy").setup("plugins")

-- Basic options
vim.opt.number = true        -- Show line numbers
vim.opt.relativenumber = true -- Relative numbers for better navigation
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.shiftwidth = 2        -- Number of spaces for indentation
vim.opt.tabstop = 2           -- Number of spaces per tab
vim.opt.smartindent = true    -- Smart auto-indentation
vim.opt.wrap = false          -- Disable line wrap
vim.opt.termguicolors = true  -- Enable true color support
vim.opt.cursorline = true     -- Highlight the current line
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard

-- Format the current file manually
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format File" })

-- Run diagnostics manually
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show Diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
