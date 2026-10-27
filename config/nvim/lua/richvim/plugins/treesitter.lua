-- Parsers to keep installed. Neovim 0.12 bundles c, lua, markdown, markdown_inline,
-- query, vim and vimdoc, but listing them here keeps them in step with the queries.
local parsers = {
  "ruby", "embedded_template", "html", "css", "javascript", "typescript", "tsx",
  "json", "yaml", "toml", "sql", "bash", "lua", "luadoc", "vim", "vimdoc", "query",
  "markdown", "markdown_inline", "diff", "gitcommit", "git_rebase", "dockerfile",
}

-- Ruby's own block and argument captures don't fit these keys (see
-- queries/ruby/textobjects.scm), so Ruby buffers use the ones added there
local ruby_captures = {
  ["@block.outer"] = "@call_with_block.outer",
  ["@parameter.outer"] = "@argument.outer",
}

local function capture(name)
  return vim.bo.filetype == "ruby" and ruby_captures[name] or name
end

local function textobject(name)
  return function()
    require("nvim-treesitter-textobjects.select").select_textobject(capture(name), "textobjects")
  end
end

local function jump(direction, name)
  return function()
    require("nvim-treesitter-textobjects.move")[direction](capture(name), "textobjects")
  end
end

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

  -- Text objects for functions, classes, blocks and arguments. Ruby files also
  -- have Vim's own am/im (method), aM/iM (class) and ]m/[m.
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    keys = {
      { "af", textobject("@function.outer"), mode = { "x", "o" }, desc = "a function" },
      { "if", textobject("@function.inner"), mode = { "x", "o" }, desc = "inner function" },
      { "ac", textobject("@class.outer"), mode = { "x", "o" }, desc = "a class" },
      { "ic", textobject("@class.inner"), mode = { "x", "o" }, desc = "inner class" },
      -- Not ab/ib, which are Vim's "a ( block"
      { "ad", textobject("@block.outer"), mode = { "x", "o" }, desc = "a block (with its call in Ruby)" },
      { "id", textobject("@block.inner"), mode = { "x", "o" }, desc = "inner block" },
      { "aa", textobject("@parameter.outer"), mode = { "x", "o" }, desc = "an argument" },
      { "ia", textobject("@parameter.inner"), mode = { "x", "o" }, desc = "inner argument" },
      { "]k", jump("goto_next_start", "@block.outer"), mode = { "n", "x", "o" }, desc = "Next block" },
      { "[k", jump("goto_previous_start", "@block.outer"), mode = { "n", "x", "o" }, desc = "Previous block" },
      {
        "<leader>cs",
        function() require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner") end,
        desc = "Swap argument with next",
      },
      {
        "<leader>cS",
        function() require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner") end,
        desc = "Swap argument with previous",
      },
    },
    opts = {
      select = {
        -- Like targets.vim: when the cursor isn't in one, use the next one,
        -- e.g. cia before the first argument
        lookahead = true,
        selection_modes = {
          ["@function.outer"] = "V",
          ["@class.outer"] = "V",
          -- Whole lines, so `it` examples paste cleanly; on a chained call
          -- (`list.map { ... }.join`) this takes the whole line
          ["@call_with_block.outer"] = "V",
        },
        -- So deleting the first argument doesn't leave a space after the (
        include_surrounding_whitespace = function(opts)
          return opts.query_string == "@parameter.outer" or opts.query_string == "@argument.outer"
        end,
      },
    },
  },
}
