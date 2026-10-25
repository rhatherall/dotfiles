-- Diagnostics (built-in <C-w>d shows the diagnostic under the cursor)
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next Diagnostic" })

-- Telescope for Rails
vim.keymap.set("n", "<leader>rs", ":Telescope rails specs<CR>", { noremap = true, silent = true, desc = "Specs" })
vim.keymap.set("n", "<leader>rc", ":Telescope rails controllers<CR>", { noremap = true, silent = true, desc = "Controllers" })
vim.keymap.set("n", "<leader>rm", ":Telescope rails models<CR>", { noremap = true, silent = true, desc = "Models" })
vim.keymap.set("n", "<leader>rv", ":Telescope rails views<CR>", { noremap = true, silent = true, desc = "Views" })
vim.keymap.set("n", "<leader>ri", ":Telescope rails migrations<CR>", { noremap = true, silent = true, desc = "Migrations" })
vim.keymap.set("n", "<leader>rl", ":Telescope rails libs<CR>", { noremap = true, silent = true, desc = "Libs" })

-- Move selected lines up/down (normal-mode <C-j>/<C-k> are window navigation)
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

-- Normal and Visual mode: Yank to system clipboard with <leader>y
vim.keymap.set("n", "<leader>y", [["+y]], { noremap = true, silent = true })
vim.keymap.set("v", "<leader>y", [["+y]], { noremap = true, silent = true })

-- Normal mode: Yank a full line to clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]], { noremap = true, silent = true })
