return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewClose",
      "DiffviewOpen",
    },
    keys = {
      {
        "<leader>gM",
        "<cmd>DiffviewOpen main...HEAD<cr>",
        desc = "Diff branch vs main",
      },
      {
        "<leader>gm",
        "<cmd>DiffviewOpen HEAD~1..HEAD<cr>",
        desc = "Diff current commit vs previous",
      },
      {
        "<leader>gq",
        "<cmd>DiffviewClose<cr>",
        desc = "Close diff view",
      },
    },
  },
}
