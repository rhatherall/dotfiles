return {
  -- One Dark Theme
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("onedark").setup { style = "darker" }
      require("onedark").load()
    end
  },

  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- for icons
    config = function()
      require("richvim.core.dashboard").setup()
    end,
  },

  {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
      require("notify").setup({
        background_colour = "#000000",
        stages = "fade_in_slide_out",
      })
    end,
  },

  -- File Explorer (Nvim-Tree)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFile", "NvimTreeFindFileToggle" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle File Explorer" },
    },
    init = function()
      -- `nvim <dir>` should open the tree rather than netrw's listing
      if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
        require("nvim-tree")
      end
    end,
    config = function()
      require("nvim-tree").setup({})
    end
  },

  -- Fuzzy Finder (Telescope)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sato-s/telescope-rails.nvim", -- :Telescope rails (<leader>r maps in core/keymaps.lua)
      -- Compiled sorter; Telescope's own is Lua and slows on long result lists
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope resume<CR>", desc = "Resume Last Search" },
      -- A charwise selection in visual mode, otherwise the word under the cursor
      { "<leader>fw", function() require("telescope.builtin").grep_string() end, mode = { "n", "x" }, desc = "Grep Word" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Workspace Symbols" },
    },
    config = function()
      require("telescope").setup({})
      require("telescope").load_extension("rails")
      -- Without the compiled library (a failed build), keep Telescope's own sorter
      if not pcall(require("telescope").load_extension, "fzf") then
        vim.notify("telescope-fzf-native isn't built; run :Lazy build telescope-fzf-native.nvim", vim.log.levels.WARN, { title = "Telescope" })
      end
    end
  },

  -- Search and Replace
  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = "Spectre",
    keys = {
      { '<leader>sr', function() require("spectre").open() end, desc = "Search & Replace (Spectre)" },
    },
    config = function()
      require('spectre').setup()
    end,
  },
}
