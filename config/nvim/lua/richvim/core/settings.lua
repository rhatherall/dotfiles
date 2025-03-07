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
vim.opt.splitright = true  -- Open vertical splits to the left
vim.opt.splitbelow = true   -- Open horizontal splits below

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
