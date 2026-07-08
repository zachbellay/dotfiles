return {
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    build = false,
    opts = {
      processor = "magick_cli",
    },
    ft = { "markdown", "vimwiki", "quarto", "telekasten", "rmd", "pandoc" },
  },
}
