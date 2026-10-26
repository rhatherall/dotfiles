-- <leader>tt/tf/ts/tl use neotest for RSpec and fall back to vim-test for
-- anything else (Minitest, other languages). Uppercase keys always use vim-test.

-- Matches neotest-rspec's own test file check
local function spec_file()
  return vim.endswith(vim.api.nvim_buf_get_name(0), "_spec.rb")
end

local function rspec_project()
  return vim.fn.isdirectory(vim.fn.getcwd() .. "/spec") == 1
end

local last_runner = "neotest"

-- Builds a keymap that runs `neotest_run` when `use_neotest()` is true and the
-- vim-test command otherwise. Requiring neotest or calling the vim-test
-- command loads that plugin, so neither loads until it's used.
local function run_tests(use_neotest, neotest_run, vim_test_cmd)
  return function()
    if use_neotest() then
      last_runner = "neotest"
      neotest_run(require("neotest"))
    else
      last_runner = "vim-test"
      vim.cmd(vim_test_cmd)
    end
  end
end

return {
  -- Neotest: RSpec runs with results beside each test, a summary tree and
  -- output popups. Tests run in the background, so breakpoints can't be used.
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "olimorris/neotest-rspec",
      "nvim-neotest/nvim-nio",
    },
    cmd = "Neotest",
    -- Set in init, not keys: lazy would load neotest before every keypress,
    -- even ones that fall back to vim-test
    init = function()
      local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc }) end
      map("<leader>tt", run_tests(spec_file, function(nt) nt.run.run() end, "TestNearest"), "Run nearest test")
      map("<leader>tf", run_tests(spec_file, function(nt) nt.run.run(vim.fn.expand("%")) end, "TestFile"), "Run test file")
      map("<leader>ts", run_tests(rspec_project, function(nt) nt.run.run(vim.fn.getcwd()) end, "TestSuite"), "Run test suite")
      map("<leader>tl", run_tests(function() return last_runner == "neotest" end, function(nt) nt.run.run_last() end, "TestLast"), "Run last test")
      map("<leader>to", function() require("neotest").output.open() end, "Show spec output")
      map("<leader>tS", function() require("neotest").summary.toggle() end, "Toggle spec summary")
    end,
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rspec"),
        },
      })
    end,
  },

  -- vim-test: runs any framework (Minitest, RSpec, ...) in a terminal tab,
  -- so binding.irb/pry/debugger breakpoints are interactive
  {
    "vim-test/vim-test",
    cmd = { "TestNearest", "TestFile", "TestSuite", "TestLast", "TestVisit" },
    keys = {
      { "<leader>tT", "<cmd>TestNearest<CR>", desc = "Run nearest test in terminal" },
      { "<leader>tF", "<cmd>TestFile<CR>", desc = "Run test file in terminal" },
      { "<leader>tA", "<cmd>TestSuite<CR>", desc = "Run test suite in terminal" },
      { "<leader>tL", "<cmd>TestLast<CR>", desc = "Run last test in terminal" },
    },
  },
}
