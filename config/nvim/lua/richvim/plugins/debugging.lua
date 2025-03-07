return {
  -- Debug Adapter Protocol (DAP) for Neovim
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui", -- UI for DAP
      "suketa/nvim-dap-ruby", -- Ruby DAP Adapter
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

      -- Keybindings for debugging
      vim.keymap.set("n", "<leader>db", ":DapToggleBreakpoint<CR>", { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", ":DapContinue<CR>", { desc = "Continue Debugging" })
      vim.keymap.set("n", "<leader>ds", ":DapStepOver<CR>", { desc = "Step Over" })
      vim.keymap.set("n", "<leader>di", ":DapStepInto<CR>", { desc = "Step Into" })
      vim.keymap.set("n", "<leader>do", ":DapStepOut<CR>", { desc = "Step Out" })
      vim.keymap.set("n", "<leader>dr", ":DapRestart<CR>", { desc = "Restart Debugging" })
      vim.keymap.set("n", "<leader>dt", ":DapTerminate<CR>", { desc = "Stop Debugging" })

      -- ✅ Delphi IDE Debugger Keymaps
      vim.keymap.set("n", "<F5>", ":DapToggleBreakpoint<CR>", { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<F7>", ":DapStepInto<CR>", { desc = "Step Into" })
      vim.keymap.set("n", "<F8>", ":DapStepOver<CR>", { desc = "Step Over" })
      vim.keymap.set("n", "<S-F8>", ":DapStepOut<CR>", { desc = "Step Out" })
      vim.keymap.set("n", "<F9>", ":DapContinue<CR>", { desc = "Run / Continue Execution" })
      vim.keymap.set("n", "<C-F2>", ":DapTerminate<CR>", { desc = "Stop Debugging" })
      vim.keymap.set("n", "<S-F9>", ":lua require('dap.ui.widgets').hover()<CR>", { desc = "Inspect Variable" })
      vim.keymap.set("n", "<C-S-F9>", ":DapClearBreakpoints<CR>", { desc = "Clear All Breakpoints" })
    end
  },
}
