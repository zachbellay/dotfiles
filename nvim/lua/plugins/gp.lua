return {
  {
    "Robitx/gp.nvim",
    keys = {
      { "<leader>aa", "<cmd>GpChatNew<cr>", desc = "AI Chat" },
      { "<leader>as", "<cmd>GpSelectAgent<cr>", desc = "AI Select Agent" },
      { "<leader>at", "<cmd>GpChatToggle<cr>", desc = "AI Chat Toggle" },
      { "<leader>k", ":<C-u>'<,'>GpRewrite<cr>", mode = "v", desc = "AI Rewrite Selection" },
    },
    config = function()
      local openai_api_key = os.getenv("OPENAI_API_KEY")
      if openai_api_key == nil and vim.uv.os_uname().sysname == "Darwin" then
        openai_api_key = { "security", "find-generic-password", "-s", "nvim-openai-api-key", "-w" }
      end

      require("gp").setup({
        openai_api_key = openai_api_key,
        default_command_agent = "CodeGPT5.5",
        default_chat_agent = "ChatGPT5.5",
        agents = {
          {
            name = "CodeGPT5.5",
            provider = "openai",
            chat = false,
            command = true,
            model = { model = "gpt-5.5" },
            system_prompt = require("gp.defaults").code_system_prompt,
          },
          {
            name = "ChatGPT5.5",
            provider = "openai",
            chat = true,
            command = false,
            model = { model = "gpt-5.5" },
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
        },
      })

      vim.api.nvim_create_user_command("GpAgentSelect", function()
        vim.cmd.GpSelectAgent()
      end, { desc = "Alias for GpSelectAgent" })
    end,
  },
}
