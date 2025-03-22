local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
  [[ ____  _      _  __     ___           ]],
  [[|  _ \(_) ___| |_\ \   / (_)_ __ ___  ]],
  [[| |_) | |/ __| '_ \ \ / /| | '_ ` _ \ ]],
  [[|  _ <| | (__| | | \ V / | | | | | | |]],
  [[|_| \_\_|\___|_| |_|\_/  |_|_| |_| |_|]],
  [[                                       ]],
  [[         WOULD YOU LIKE TO PLAY A GAME?]],
}

dashboard.section.buttons.val = {
  dashboard.button("1", "🔍  Launch Global Thermonuclear Search", ":Telescope live_grep<CR>"),
  dashboard.button("2", "📝  Initiate Ruby Protocol Editor", ":enew<CR>"),
  dashboard.button("3", "📂  Access File Grid Matrix", ":Telescope find_files<CR>"),
  dashboard.button("4", "📁  Resume Tactical Session Logs", ":Telescope oldfiles<CR>"),
  dashboard.button("5", "💤  Power Down the System", ":qa<CR>"),
}

dashboard.section.footer.val = "RICHVIM ∙ DEFCON 1 ∙ SYSTEM ONLINE ⚡"

-- Optional styling tweaks
dashboard.opts.opts.noautocmd = true
dashboard.section.header.opts.hl = "Type"
dashboard.section.footer.opts.hl = "Constant"

return {
  setup = function()
    alpha.setup(dashboard.config)
    vim.schedule(function()
      vim.notify("RICHVIM SYSTEM ONLINE — READY TO PLAY A GAME", vim.log.levels.INFO, {
        title = "RichVim",
      })
    end)
  end,
}

