-- Chooses the Ruby language server per project: ruby-lsp, which needs Ruby 3.0+,
-- or solargraph for older projects so legacy code can still be navigated.
local M = {}

local versions = {} -- project root -> RUBY_VERSION, or false when it can't be run
local pending = {}  -- project root -> callbacks waiting for its version check

local function version_checked(root, version, reason)
  versions[root] = version or false
  if not version then
    -- Otherwise the language server fails to start with only a log entry
    vim.notify(("Can't run Ruby in %s, so no Ruby LSP: %s"):format(vim.fn.fnamemodify(root, ":~"), reason),
      vim.log.levels.WARN, { title = "Ruby LSP" })
  end
  local callbacks = pending[root]
  pending[root] = nil
  for _, callback in ipairs(callbacks) do callback(version) end
end

-- Calls back with the project's Ruby as asdf resolves it from the project's
-- version files, or nil when it can't be run. Checked in the background, once
-- per root: through asdf's shim it takes 60-150ms.
local function ruby_version(root, callback)
  if versions[root] ~= nil then return callback(versions[root] or nil) end
  if pending[root] then return table.insert(pending[root], callback) end
  pending[root] = { callback }

  local ok, err = pcall(vim.system, { "ruby", "-e", "print RUBY_VERSION" }, { cwd = root, text = true, timeout = 5000 },
    function(result)
      local reason = vim.split(vim.trim(result.stderr or ""), "\n")[1] or ""
      vim.schedule(function() version_checked(root, result.code == 0 and result.stdout or nil, reason) end)
    end)
  if not ok then version_checked(root, nil, err) end
end

local function project_root(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then return nil end
  return vim.fs.root(bufnr, { "Gemfile", ".git" })
end

-- vim.lsp.config root_dir functions receive (bufnr, on_dir)
-- They must call on_dir(root) to start the server (returning a value does nothing),
-- and may call it later, so the server starts once the version check finishes

-- Starts the server for the buffer's project when `wanted(version)` is true
local function root_dir_for(wanted)
  return function(bufnr, on_dir)
    local root = project_root(bufnr)
    if not root then return end
    ruby_version(root, function(version)
      if version and wanted(version) and vim.api.nvim_buf_is_valid(bufnr) then
        on_dir(root)
      end
    end)
  end
end

M.ruby_lsp_root_dir = root_dir_for(function(version) return not vim.version.lt(version, "3.0") end)
M.solargraph_root_dir = root_dir_for(function(version) return vim.version.lt(version, "3.0") end)

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
