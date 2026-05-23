return {
  {
    "christoomey/vim-tmux-navigator",
    init = function()
      vim.g.tmux_navigator_no_mappings = 1

      if vim.env.TMUX and (not vim.env.TMUX_PANE or vim.env.TMUX_PANE == "") then
        vim.env.TMUX_PANE = vim.fn.system("tmux display-message -p '#{pane_id}'"):gsub("%s+$", "")
      end
    end,
    lazy = false,
  },
}
