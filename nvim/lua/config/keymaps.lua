-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function tmux_socket()
  return vim.env.TMUX and vim.split(vim.env.TMUX, ",", { plain = true })[1] or nil
end

local function tmux_select_pane(direction)
  local socket = tmux_socket()
  local pane = vim.env.TMUX_PANE
  if not socket or not pane or pane == "" then
    return
  end
  vim.fn.system({ "tmux", "-S", socket, "select-pane", "-t", pane, "-" .. direction })
end

local function navigate(wincmd, tmux_direction)
  local current = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(wincmd)
  if vim.api.nvim_get_current_win() == current then
    tmux_select_pane(tmux_direction)
  end
end

local maps = {
  h = { "h", "L" },
  j = { "j", "D" },
  k = { "k", "U" },
  l = { "l", "R" },
}

for key, directions in pairs(maps) do
  vim.keymap.set("n", "<C-" .. key .. ">", function()
    navigate(directions[1], directions[2])
  end, { silent = true, desc = "Navigate " .. key .. " across Neovim and tmux panes" })
end

vim.keymap.set("n", "<C-Bslash>", function()
  tmux_select_pane("l")
end, { silent = true, desc = "Navigate to previous tmux pane" })
