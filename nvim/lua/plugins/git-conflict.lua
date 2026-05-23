local function find_conflict()
  local cursor = vim.api.nvim_win_get_cursor(0)[1] - 1
  local line_count = vim.api.nvim_buf_line_count(0)
  local start_line
  local middle_line
  local base_line
  local finish_line

  for line = cursor, 0, -1 do
    if vim.api.nvim_buf_get_lines(0, line, line + 1, false)[1]:match("^<<<<<<<") then
      start_line = line
      break
    end
  end

  if not start_line then
    return nil
  end

  for line = start_line + 1, line_count - 1 do
    local text = vim.api.nvim_buf_get_lines(0, line, line + 1, false)[1]

    if text:match("^|||||||") then
      base_line = line
    elseif text:match("^=======") then
      middle_line = line
    elseif text:match("^>>>>>>>") then
      finish_line = line
      break
    end
  end

  if not middle_line or not finish_line or cursor > finish_line then
    return nil
  end

  return {
    start_line = start_line,
    base_line = base_line,
    middle_line = middle_line,
    finish_line = finish_line,
  }
end

local function choose_conflict(side)
  local conflict = find_conflict()

  if not conflict then
    vim.notify("No conflict block under cursor", vim.log.levels.WARN)
    return
  end

  local ours_end = conflict.base_line or conflict.middle_line
  local ours = vim.api.nvim_buf_get_lines(0, conflict.start_line + 1, ours_end, false)
  local theirs = vim.api.nvim_buf_get_lines(0, conflict.middle_line + 1, conflict.finish_line, false)
  local replacement = {}

  if side == "ours" then
    replacement = ours
  elseif side == "theirs" then
    replacement = theirs
  elseif side == "both" then
    replacement = vim.list_extend(ours, theirs)
  end

  vim.api.nvim_buf_set_lines(0, conflict.start_line, conflict.finish_line + 1, false, replacement)
end

local function jump_conflict(direction)
  local cursor = vim.api.nvim_win_get_cursor(0)[1] - 1
  local line_count = vim.api.nvim_buf_line_count(0)
  local start_line = direction == "next" and cursor + 1 or cursor - 1
  local stop_line = direction == "next" and line_count - 1 or 0
  local step = direction == "next" and 1 or -1

  for line = start_line, stop_line, step do
    if vim.api.nvim_buf_get_lines(0, line, line + 1, false)[1]:match("^<<<<<<<") then
      vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
      return
    end
  end
end

return {
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    lazy = false,
    keys = {
      { "co", function() choose_conflict("ours") end, desc = "Git Conflict: Choose Ours" },
      { "ct", function() choose_conflict("theirs") end, desc = "Git Conflict: Choose Theirs" },
      { "cb", function() choose_conflict("both") end, desc = "Git Conflict: Choose Both" },
      { "c0", function() choose_conflict("none") end, desc = "Git Conflict: Choose None" },
      { "[x", function() jump_conflict("previous") end, desc = "Git Conflict: Previous Conflict" },
      { "]x", function() jump_conflict("next") end, desc = "Git Conflict: Next Conflict" },
      { "<leader>xg", "<cmd>GitConflictListQf<cr>", desc = "Git Conflict: Quickfix List" },
    },
    opts = {
      default_mappings = false,
    },
    config = function(_, opts)
      require("git-conflict").setup(opts)
    end,
  },
}
