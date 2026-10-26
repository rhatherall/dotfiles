-- Chooses the Ruby language server per project: ruby-lsp, which needs Ruby 3.0+,
-- or solargraph for older projects so legacy code can still be navigated.
local M = {}

local versions = {} -- project root -> RUBY_VERSION, or false when it can't be run

-- The project's Ruby as asdf resolves it from the project's version files.
local function ruby_version(root)
  if versions[root] == nil then
    local result = vim.system({ "ruby", "-e", "print RUBY_VERSION" }, { cwd = root, text = true }):wait(5000)
    versions[root] = result.code == 0 and result.stdout or false
    if not versions[root] then
      -- Otherwise the language server fails to start with only a log entry
      local reason = vim.split(vim.trim(result.stderr or ""), "\n")[1] or ""
      vim.notify(("Can't run Ruby in %s, so no Ruby LSP: %s"):format(vim.fn.fnamemodify(root, ":~"), reason),
        vim.log.levels.WARN, { title = "Ruby LSP" })
    end
  end
  return versions[root] or nil
end

-- true for Ruby < 3.0, false for 3.0+, nil when the project's Ruby can't run
local function legacy_ruby(root)
  local version = ruby_version(root)
  if version == nil then return nil end
  return vim.version.lt(version, "3.0")
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
  if root and legacy_ruby(root) == false then
    on_dir(root)
  end
end

function M.solargraph_root_dir(bufnr, on_dir)
  local root = project_root(bufnr)
  if root and legacy_ruby(root) then
    on_dir(root)
  end
end

-- Builds a vim.lsp.config `cmd` that starts the server from the project root,
-- so asdf runs it with the project's Ruby rather than Neovim's cwd's.
function M.cmd(cmd)
  return function(dispatchers, config)
    return vim.lsp.rpc.start(cmd, dispatchers, {
      cwd = config.cmd_cwd or config.root_dir,
      env = config.cmd_env,
    })
  end
end

return M
