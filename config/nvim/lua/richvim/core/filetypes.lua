local home = vim.fn.expand("~")

vim.filetype.add({
  extension = {
    zsh = "zsh",
  },
  filename = {
    [".zshrc"] = "zsh",
    [".zshenv"] = "zsh",
    [".zprofile"] = "zsh",
  },
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { home .. "/dotfiles/zsh/functions/*" },
  callback = function()
    vim.bo.filetype = "zsh"
  end,
})
