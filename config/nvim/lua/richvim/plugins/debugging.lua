return {
  -- Debug Adapter Protocol (DAP) for Neovim
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui", -- UI for DAP
      "nvim-neotest/nvim-nio", -- Required by nvim-dap-ui
      "suketa/nvim-dap-ruby", -- Ruby DAP Adapter
    },
    cmd = {
      "DapToggleBreakpoint", "DapClearBreakpoints", "DapContinue", "DapNew", "DapStepOver", "DapStepInto",
      "DapStepOut", "DapPause", "DapTerminate", "DapDisconnect", "DapRestartFrame", "DapEval", "DapToggleRepl",
      "DapShowLog", "DapSetLogLevel",
    },
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<CR>", desc = "Toggle Breakpoint" },
      { "<leader>dc", "<cmd>DapContinue<CR>", desc = "Continue Debugging" },
      { "<leader>ds", "<cmd>DapStepOver<CR>", desc = "Step Over" },
      { "<leader>di", "<cmd>DapStepInto<CR>", desc = "Step Into" },
      { "<leader>do", "<cmd>DapStepOut<CR>", desc = "Step Out" },
      { "<leader>dr", function() require("dap").restart() end, desc = "Restart Debugging" },
      { "<leader>dt", "<cmd>DapTerminate<CR>", desc = "Stop Debugging" },

      -- ✅ Delphi IDE Debugger Keymaps
      { "<F5>", "<cmd>DapToggleBreakpoint<CR>", desc = "Toggle Breakpoint" },
      { "<F7>", "<cmd>DapStepInto<CR>", desc = "Step Into" },
      { "<F8>", "<cmd>DapStepOver<CR>", desc = "Step Over" },
      { "<S-F8>", "<cmd>DapStepOut<CR>", desc = "Step Out" },
      { "<F9>", "<cmd>DapContinue<CR>", desc = "Run / Continue Execution" },
      { "<C-F2>", "<cmd>DapTerminate<CR>", desc = "Stop Debugging" },
      { "<S-F9>", function() require("dap.ui.widgets").hover() end, desc = "Inspect Variable" },
      { "<C-S-F9>", "<cmd>DapClearBreakpoints<CR>", desc = "Clear All Breakpoints" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup UI
      dapui.setup()

      -- Auto-open and close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Automatically configure Ruby DAP
      require("dap-ruby").setup()
    end
  },
}
