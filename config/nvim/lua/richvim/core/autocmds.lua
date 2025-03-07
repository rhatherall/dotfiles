local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Create a general group for autocmds
local richvim_group = augroup("RichVim", {})

-- Auto-Reload Neovim Config on Save
autocmd("BufWritePost", {
  pattern = { "init.lua", "lua/richvim/**/*.lua" },
  group = richvim_group,
  command = "source <afile>",
  desc = "Auto-reload Neovim config on save",
})

-- Highlight Yanked Text for 200ms
autocmd("TextYankPost", {
  group = richvim_group,
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
  desc = "Highlight yanked text",
})

-- Close Certain Filetypes with `q`
autocmd("FileType", {
  group = richvim_group,
  pattern = { "help", "man", "lspinfo", "qf", "nvimtree", "toggleterm" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true })
  end,
  desc = "Close certain filetypes with 'q'",
})

-- Remove Trailing Whitespace on Save
autocmd("BufWritePre", {
  group = richvim_group,
  pattern = "*",
  command = [[%s/\s\+$//e]],
  desc = "Remove trailing whitespace on save",
})

-- Open File at Last Cursor Position
autocmd("BufReadPost", {
  group = richvim_group,
  callback = function()
    local row, col = unpack(vim.api.nvim_buf_get_mark(0, '"'))
    if row > 0 and row <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, { row, col })
    end
  end,
  desc = "Open file at last cursor position",
})
