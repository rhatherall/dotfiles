local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Create a general group for autocmds
local richvim_group = augroup("RichVim", {})

-- Highlight Yanked Text for 200ms
autocmd("TextYankPost", {
  group = richvim_group,
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
  desc = "Highlight yanked text",
})

-- Close Certain Filetypes with `q`
autocmd("FileType", {
  group = richvim_group,
  pattern = { "help", "man", "checkhealth", "qf", "NvimTree", "toggleterm" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true })
  end,
  desc = "Close certain filetypes with 'q'",
})

-- Wrap and Spell-Check Prose
autocmd("FileType", {
  group = richvim_group,
  pattern = { "markdown", "gitcommit" },
  callback = function(args)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.breakindentopt = "list:-1" -- under the list item's text, not its bullet
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_gb"
    -- A paragraph is often one line, so j/k move by screen line. With a count
    -- they move by real lines, which is what relative numbers show.
    for _, key in ipairs({ "j", "k" }) do
      vim.keymap.set({ "n", "x" }, key, function()
        return vim.v.count == 0 and "g" .. key or key
      end, { buffer = args.buf, expr = true })
    end
  end,
  desc = "Wrap and spell-check prose",
})

-- Remove Trailing Whitespace on Save
autocmd("BufWritePre", {
  group = richvim_group,
  pattern = "*",
  callback = function(args)
    if not vim.bo[args.buf].modifiable or vim.bo[args.buf].binary then return end
    local view = vim.fn.winsaveview() -- :s would otherwise jump the cursor
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
  desc = "Remove trailing whitespace on save",
})

-- Open File at Last Cursor Position
autocmd("BufReadPost", {
  group = richvim_group,
  callback = function(args)
    if vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo[args.buf].filetype) then return end
    local row, col = unpack(vim.api.nvim_buf_get_mark(0, '"'))
    if row > 0 and row <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, { row, col })
    end
  end,
  desc = "Open file at last cursor position",
})
