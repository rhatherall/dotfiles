-- Timewarrior integration for RichVim
--
-- Thin async wrappers around the `timew` CLI so you can start, stop and
-- inspect time tracking without leaving Neovim. Results surface through
-- vim.notify. Intervals started without explicit tags are tagged with the
-- current project name (git root, else cwd basename).

-- Run `timew` with the given args, reporting stdout/stderr via a notification.
local function timew(args, opts)
  opts = opts or {}
  local cmd = vim.list_extend({ "timew" }, args)
  vim.system(cmd, { text = true }, vim.schedule_wrap(function(result)
    local output = vim.trim((result.stdout or "") .. (result.stderr or ""))
    if result.code ~= 0 then
      vim.notify(output ~= "" and output or "timew failed", vim.log.levels.ERROR, { title = "Timewarrior" })
    elseif not opts.silent then
      vim.notify(output ~= "" and output or "OK", vim.log.levels.INFO, { title = "Timewarrior" })
    end
  end))
end

-- Best-effort project name to use as a default tag.
local function project_tag()
  local root = vim.fs.root(0, ".git")
  local dir = root or vim.uv.cwd()
  return vim.fn.fnamemodify(dir, ":t")
end

vim.api.nvim_create_user_command("TimewStart", function(o)
  local tags = o.args ~= "" and o.args or project_tag()
  timew(vim.list_extend({ "start" }, vim.split(tags, " ", { trimempty = true })))
end, { nargs = "*", desc = "Start Timewarrior tracking (defaults to project name)" })

vim.api.nvim_create_user_command("TimewStop", function()
  timew({ "stop" })
end, { desc = "Stop Timewarrior tracking" })

vim.api.nvim_create_user_command("TimewContinue", function()
  timew({ "continue" })
end, { desc = "Resume the last Timewarrior interval" })

vim.api.nvim_create_user_command("TimewStatus", function()
  timew({}) -- bare `timew` prints the active interval
end, { desc = "Show the active Timewarrior interval" })

vim.api.nvim_create_user_command("TimewSummary", function(o)
  timew({ "summary", o.args ~= "" and o.args or ":day" })
end, { nargs = "?", desc = "Show a Timewarrior summary (default :day)" })

-- Keybindings under the <leader>w ("warrior") namespace
vim.keymap.set("n", "<leader>ws", "<cmd>TimewStart<cr>", { desc = "Timew: start (project)" })
vim.keymap.set("n", "<leader>wS", function()
  vim.ui.input({ prompt = "Timew tags: " }, function(input)
    if input and input ~= "" then
      vim.cmd("TimewStart " .. input)
    end
  end)
end, { desc = "Timew: start with tags" })
vim.keymap.set("n", "<leader>wx", "<cmd>TimewStop<cr>", { desc = "Timew: stop" })
vim.keymap.set("n", "<leader>wc", "<cmd>TimewContinue<cr>", { desc = "Timew: continue" })
vim.keymap.set("n", "<leader>ww", "<cmd>TimewStatus<cr>", { desc = "Timew: status" })
vim.keymap.set("n", "<leader>wd", "<cmd>TimewSummary<cr>", { desc = "Timew: day summary" })
