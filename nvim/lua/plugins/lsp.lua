return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        vtsls = {
          cmd_env = {
            NODE_OPTIONS = "--max-old-space-size=8192",
          },
          settings = {
            typescript = {
              tsserver = {
                maxTsServerMemory = 8192,
                nodePath = vim.fn.exepath("node"),
              },
            },
          },
        },
      },
    },
  },
}
