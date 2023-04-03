-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Quicker window movement
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- vim-fugitive mappins
vim.keymap.set('n', '<leader>gs', vim.cmd.Git);

-- vim-test mappings
vim.keymap.set('n', '<Leader>t', ':TestFile<CR>', { silent = true })
vim.keymap.set('n', '<Leader>s', ':TestNearest<CR>', { silent = true })
vim.keymap.set('n', '<Leader>l', ':TestLast<CR>', { silent = true })
vim.keymap.set('n', '<Leader>a', ':TestSuite<CR>', { silent = true })
vim.keymap.set('n', '<Leader>gt', ':TestVisit<CR>', { silent = true })

-- Move selected lines
vim.keymap.set('v', 'K', ":m '>-2<CR>gv=gv")
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")

-- Keep cursor where it is when jumping up/down
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Preserve paste
vim.keymap.set('x', '<leader>p', '\"_dP')
