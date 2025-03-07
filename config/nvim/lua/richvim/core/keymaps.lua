-- Format the current file manually
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format File" })

-- Run diagnostics manually
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show Diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- Telescope for Rails
vim.keymap.set("n", "<leader>rs", ":Telescope rails specs<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rc", ":Telescope rails controllers<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rm", ":Telescope rails models<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rv", ":Telescope rails views<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ri", ":Telescope rails migrations<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rl", ":Telescope rails libs<CR>", { noremap = true, silent = true })

-- Move lines up/down
vim.keymap.set("n", "<C-j>", ":m .+1<CR>==", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", ":m .-2<CR>==", { noremap = true, silent = true })
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- Better Indentation in Visual mode
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- Better Window Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })

-- Keep cursor in place when joining lines
vim.keymap.set("n", "J", "mzJ`z", { noremap = true, silent = true })

-- Keep cursor in the middle when scrolling pages
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- Keep cursor in the middle when searching
vim.keymap.set("n", "n", "nzzzv", { noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true, silent = true })
