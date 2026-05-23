return {
  {
    "folke/snacks.nvim",
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
          grep = {
            regex = false,
          },
        },
      },
    },
  },
}
