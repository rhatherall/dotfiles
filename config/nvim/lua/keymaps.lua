-- Format the current file manually
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format File" })

-- Run diagnostics manually
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show Diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- Telescope for Rails
vim.api.nvim_set_keymap("n", "<leader>rs", ":Telescope rails specs<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>rc", ":Telescope rails controllers<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>rm", ":Telescope rails models<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>rv", ":Telescope rails views<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ri", ":Telescope rails migrations<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>rl", ":Telescope rails libs<CR>", { noremap = true, silent = true })
