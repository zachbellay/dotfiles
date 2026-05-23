-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local tmux = require("config.tmux")

local function navigate(wincmd, tmux_direction)
  local current = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(wincmd)
  if vim.api.nvim_get_current_win() == current then
    tmux.select_pane(tmux_direction)
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
  tmux.select_pane("l")
end, { silent = true, desc = "Navigate to previous tmux pane" })

vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied path: " .. path)
end, { desc = "Copy current file path" })

vim.keymap.set("n", "<leader>gR", function()
  require("config.git").open_pr_for_current_line()
end, { desc = "Open PR that introduced line" })

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })

vim.keymap.set("n", "<leader>bc", "<cmd>enew<cr>", { desc = "Create Buffer" })

vim.keymap.set("n", "<leader>bd", function()
  local buf = vim.api.nvim_get_current_buf()
  local listed = vim.tbl_filter(function(buffer)
    return vim.bo[buffer].buflisted
  end, vim.api.nvim_list_bufs())

  if #listed > 1 then
    Snacks.bufdelete(buf)
    return
  end

  if vim.bo[buf].modified then
    local name = vim.api.nvim_buf_get_name(buf)
    local label = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
    local choice = vim.fn.confirm("Save changes to " .. label .. "?", "&Save\n&Discard\n&Cancel", 1)

    if choice == 0 or choice == 3 then
      return
    end

    if choice == 1 then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd.write()
      end)
    end
  end

  local empty = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_win_set_buf(0, empty)

  local ok, err = pcall(vim.api.nvim_buf_delete, buf, { force = true })
  if not ok then
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_buf_delete(empty, { force = true })
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Delete Buffer" })
