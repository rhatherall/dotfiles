-- Reload open files when something else changes them, such as Claude Code
-- working in another pane. Neovim only looks for changes after a shell command
-- or when its terminal regains focus, so a file changed while you watch it
-- otherwise stays stale.
--
-- Each file's directory is watched rather than the file: saving by renaming a
-- new file over the old one, as many tools do, ends a watch on the file. It's
-- the real directory, so a file opened through a symlink (~/.zshrc) reloads
-- when its target changes.
--
-- Buffers with unsaved changes are skipped. Checking one asks what to do, which
-- would interrupt typing, and writing it still warns that the file changed.

local watchers = {} -- real directory -> fs_event handle
local buffer_dirs = {} -- buffer -> real directory of its file

local function reload(dir)
  if vim.fn.getcmdwintype() ~= "" then return end -- :checktime fails in the command-line window
  for buf, buf_dir in pairs(buffer_dirs) do
    if buf_dir == dir and vim.api.nvim_buf_is_loaded(buf) and not vim.bo[buf].modified then
      vim.cmd.checktime(buf)
    end
  end
end

local function watch(buf)
  if vim.bo[buf].buftype ~= "" then return end
  local path = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(buf))
  if not path then return end
  local dir = vim.fs.dirname(path)
  buffer_dirs[buf] = dir
  if watchers[dir] then return end

  local handle = assert(vim.uv.new_fs_event())
  local pending = false
  local ok = handle:start(dir, {}, function(err)
    if err then
      handle:close()
      watchers[dir] = nil
    elseif not pending then
      -- Once per burst of changes, such as a git checkout
      pending = true
      vim.defer_fn(function()
        pending = false
        reload(dir)
      end, 100)
    end
  end)
  if ok then watchers[dir] = handle else handle:close() end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufFilePost" }, {
  group = vim.api.nvim_create_augroup("RichVimAutoreload", { clear = true }),
  callback = function(args) watch(args.buf) end,
  desc = "Reload the file when it changes on disk",
})
