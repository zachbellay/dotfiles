return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader><space>",
        function()
          Snacks.picker.files({ cwd = vim.fn.getcwd() })
        end,
        desc = "Find Files (cwd)",
      },
    },
    opts = {
      lazygit = {
        win = {
          keys = {
            nav_l = {
              "<C-l>",
              function()
                if not require("config.tmux").select_pane("R") then
                  return "<C-l>"
                end
                return ""
              end,
              desc = "Go to Right tmux Pane",
              expr = true,
              mode = "t",
            },
          },
        },
      },
      picker = {
        sources = {
          files = {
            hidden = true,
          },
          grep = {
            regex = false,
          },
        },
      },
    },
  },
}
