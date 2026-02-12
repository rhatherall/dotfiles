local M = {}

local function has_ruby_lsp(root)
  local lock = root .. "/Gemfile.lock"
  local ok, lines = pcall(vim.fn.readfile, lock)
  if ok then
    for _, line in ipairs(lines) do
      if line:match("^%s*ruby%-lsp%s*%(") then
        return true
      end
    end
  end
  return vim.uv.fs_stat(root .. "/.ruby-lsp") ~= nil
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

return M
