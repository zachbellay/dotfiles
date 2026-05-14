return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete buffer" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        mode = "buffers",
        separator_style = "slant",
        show_buffer_close_icons = true,
        show_close_icon = false,
        always_show_bufferline = true,
      },
    },
  },
}
