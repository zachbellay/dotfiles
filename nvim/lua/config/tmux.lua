local M = {}

function M.socket()
  return vim.env.TMUX and vim.split(vim.env.TMUX, ",", { plain = true })[1] or nil
end

function M.select_pane(direction)
  local socket = M.socket()
  local pane = vim.env.TMUX_PANE
  if not socket or not pane or pane == "" then
    return false
  end
  vim.fn.system({ "tmux", "-S", socket, "select-pane", "-t", pane, "-" .. direction })
  return vim.v.shell_error == 0
end

return M
