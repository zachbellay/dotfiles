return {
  {
    "lewis6991/satellite.nvim",
    event = "VeryLazy",
    opts = {
      current_only = true,
      winblend = 0,
      zindex = 40,
      width = 2,
      excluded_filetypes = {
        "snacks_dashboard",
        "snacks_layout_box",
        "snacks_picker_input",
        "snacks_picker_list",
      },
      handlers = {
        cursor = {
          enable = true,
          symbols = { "┃" },
        },
        search = {
          enable = true,
        },
        diagnostic = {
          enable = true,
          signs = { "-", "=", "≡" },
          min_severity = vim.diagnostic.severity.HINT,
        },
        gitsigns = {
          enable = true,
          signs = {
            add = "│",
            change = "│",
            delete = "_",
          },
        },
        marks = {
          enable = true,
          show_builtins = false,
          key = "m",
        },
        quickfix = {
          enable = true,
          signs = { "-", "=", "≡" },
        },
      },
    },
  },
}
