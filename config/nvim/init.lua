-- Set leader key early (space as leader)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Require core settings first
require("richvim.core.bootstrap") -- Load Lazy.nvim bootstrap
require("richvim.core.settings") -- General settings (options, UI tweaks)
require("richvim.core.keymaps")  -- Keybindings
require("richvim.core.autocmds") -- Auto commands
require("richvim.core.filetypes") -- File type configurations

-- Load plugins
require("lazy").setup("richvim.plugins", {
  rocks = {
    enabled = false,
  }
})
-- require("richvim.plugin_config") -- Plugin configurations
