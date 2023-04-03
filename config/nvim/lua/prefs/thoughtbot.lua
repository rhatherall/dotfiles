vim.opt.encoding = 'utf-8'
-- vim.opt.backspace = 2   " Backspace deletes like most programs in insert mode
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false -- http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
vim.opt.history = 50
vim.opt.ruler = true -- show the cursor position all the time
vim.opt.showcmd = true -- display incomplete commands
vim.opt.incsearch = true -- do incremental searching
vim.opt.laststatus = 2 -- Always display the status line
vim.opt.autowrite = true -- Automatically :write before running commands
vim.opt.modelines = 0 -- Disable modelines as a security precaution
vim.opt.modeline = false

-- Softtabs, 2 spaces
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

-- Use one space, not two, after punctuation.
vim.opt.joinspaces = false

-- Make it obvious where 80 characters is
vim.opt.textwidth = 80
vim.opt.colorcolumn = '+1'

-- Numbers
vim.opt.number = true
vim.opt.numberwidth = 5

-- Treat <li> and <p> tags like the block tags they are
vim.g.html_indent_tags = 'li|p'

-- Open new split panes to right and bottom, which feels more natural
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Autocomplete with dictionary words when spell check is on
vim.opt.complete = 'kspell'

-- Always use vertical diffs
vim.opt.diffopt = 'vertical'
