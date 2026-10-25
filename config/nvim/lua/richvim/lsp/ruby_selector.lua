local M = {}

local function in_bundle(root, gem)
  local ok, lines = pcall(vim.fn.readfile, root .. "/Gemfile.lock")
  if not ok then return false end
  local pattern = "^%s*" .. vim.pesc(gem) .. "%s*%("
  for _, line in ipairs(lines) do
    if line:match(pattern) then
      return true
    end
  end
  return false
end

local function has_ruby_lsp(root)
  return in_bundle(root, "ruby-lsp") or vim.uv.fs_stat(root .. "/.ruby-lsp") ~= nil
end

local function project_root(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then return nil end
  return vim.fs.root(bufnr, { "Gemfile", ".git" })
end

-- vim.lsp.config root_dir functions receive (bufnr, on_dir)
-- They must call on_dir(root) to start the server (returning a value does nothing)

function M.ruby_lsp_root_dir(bufnr, on_dir)
  local root = project_root(bufnr)
  if root and has_ruby_lsp(root) then
    on_dir(root)
  end
end

function M.solargraph_root_dir(bufnr, on_dir)
  local root = project_root(bufnr)
  if root and not has_ruby_lsp(root) then
    on_dir(root)
  end
end

-- Builds a vim.lsp.config `cmd` that runs the project's bundled copy of `gem`
-- via `bundle exec` when it's in Gemfile.lock, else the globally installed one.
-- (`bundle exec` fails outright when the gem isn't part of the bundle.)
function M.cmd(gem, args)
  return function(dispatchers, config)
    local cmd = vim.list_extend({ gem }, args or {})
    if config.root_dir and in_bundle(config.root_dir, gem) then
      cmd = vim.list_extend({ "bundle", "exec" }, cmd)
    end
    return vim.lsp.rpc.start(cmd, dispatchers, {
      cwd = config.cmd_cwd or config.root_dir,
      env = config.cmd_env,
    })
  end
end

return M
