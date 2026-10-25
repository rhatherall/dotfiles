-- Parsers to keep installed. Neovim 0.12 bundles c, lua, markdown, markdown_inline,
-- query, vim and vimdoc, but listing them here keeps them in step with the queries.
local parsers = {
  "ruby", "embedded_template", "html", "css", "javascript", "typescript", "tsx",
  "json", "yaml", "toml", "sql", "bash", "lua", "luadoc", "vim", "vimdoc", "query",
  "markdown", "markdown_inline", "diff", "gitcommit", "git_rebase", "dockerfile",
}

return {
  -- Treesitter: Better Syntax Highlighting & Indentation
  --
  -- Uses the `main` branch rewrite; the old `master` branch is archived and breaks
  -- on Neovim 0.12. Parsers are compiled with the `tree-sitter` CLI, which Mason
  -- installs (see plugins/mason.lua).
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- does not support lazy-loading
    dependencies = { "mason-org/mason.nvim" }, -- puts tree-sitter CLI on PATH first
    build = ":TSUpdate",
    config = function()
      if vim.fn.executable("tree-sitter") == 1 then
        require("nvim-treesitter").install(parsers) -- async; no-op when already installed
      else
        vim.notify(
          "tree-sitter CLI not found; parsers will install once Mason has fetched it (or `brew install tree-sitter-cli`)",
          vim.log.levels.WARN,
          { title = "nvim-treesitter" }
        )
      end

      -- Highlighting/indent are no longer module-driven: start them per buffer
      -- for any filetype that has a parser available.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("RichVimTreesitter", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang or not vim.treesitter.language.add(lang) then return end

          vim.treesitter.start(args.buf, lang)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
