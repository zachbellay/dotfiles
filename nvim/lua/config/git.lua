local M = {}

local function systemlist(args)
  local output = vim.fn.systemlist(args)
  return output, vim.v.shell_error
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Git Line PR" })
end

local function open_url(url)
  if vim.ui and vim.ui.open then
    vim.ui.open(url)
    return
  end

  vim.fn.jobstart({ "open", url }, { detach = true })
end

local function parse_github_remote(remote)
  local host, owner, repo = remote:match("^git@([^:]+):([^/]+)/(.+)$")
  if not host then
    host, owner, repo = remote:match("^https://([^/]+)/([^/]+)/(.+)$")
  end
  if not host then
    host, owner, repo = remote:match("^ssh://git@([^/]+)/([^/]+)/(.+)$")
  end
  if not host or not owner or not repo then
    return nil
  end

  repo = repo:gsub("%.git$", "")
  return {
    host = host,
    owner = owner,
    repo = repo,
    base_url = "https://" .. host .. "/" .. owner .. "/" .. repo,
  }
end

local function get_current_file()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    notify("Current buffer has no file path", vim.log.levels.WARN)
    return nil
  end
  return vim.fn.fnamemodify(path, ":p")
end

local function get_git_root(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  local output, code = systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
  if code ~= 0 or not output[1] then
    notify("Current file is not inside a git repository", vim.log.levels.WARN)
    return nil
  end
  return output[1]
end

local function get_blame_commit(root, relative_path, line)
  local output, code = systemlist({
    "git",
    "-C",
    root,
    "blame",
    "-L",
    line .. "," .. line,
    "--porcelain",
    "--",
    relative_path,
  })
  if code ~= 0 or not output[1] then
    notify("Could not blame current line", vim.log.levels.ERROR)
    return nil
  end

  local commit = output[1]:match("^([0-9a-f]+)%s")
  if not commit or commit:match("^0+$") then
    notify("Current line is uncommitted, so no introducing PR exists", vim.log.levels.WARN)
    return nil
  end
  return commit
end

local function get_github_repo(root)
  local output, code = systemlist({ "git", "-C", root, "remote", "get-url", "origin" })
  if code ~= 0 or not output[1] then
    notify("Could not read origin remote", vim.log.levels.ERROR)
    return nil
  end

  local repo = parse_github_remote(output[1])
  if not repo then
    notify("Origin remote is not a supported GitHub URL", vim.log.levels.ERROR)
    return nil
  end
  return repo
end

local function get_associated_pr_url(repo, commit)
  if vim.fn.executable("gh") ~= 1 then
    return nil
  end

  local args = {
    "gh",
    "api",
    "-H",
    "Accept: application/vnd.github+json",
    "repos/" .. repo.owner .. "/" .. repo.repo .. "/commits/" .. commit .. "/pulls",
    "--jq",
    ".[0].html_url // empty",
  }
  if repo.host ~= "github.com" then
    table.insert(args, 3, repo.host)
    table.insert(args, 3, "--hostname")
  end

  local output, code = systemlist(args)
  if code ~= 0 or not output[1] or output[1] == "" then
    return nil
  end
  return output[1]
end

function M.open_pr_for_current_line()
  local path = get_current_file()
  if not path then
    return
  end

  local root = get_git_root(path)
  if not root then
    return
  end

  local root_prefix = root:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") .. "/"
  local relative_path = path:gsub("^" .. root_prefix, "")

  local line = vim.api.nvim_win_get_cursor(0)[1]
  local commit = get_blame_commit(root, relative_path, line)
  if not commit then
    return
  end

  local repo = get_github_repo(root)
  if not repo then
    return
  end

  local url = get_associated_pr_url(repo, commit)
  if url then
    open_url(url)
    notify("Opened PR for " .. commit:sub(1, 12))
    return
  end

  open_url(repo.base_url .. "/commit/" .. commit)
  notify("No associated PR found; opened commit " .. commit:sub(1, 12), vim.log.levels.WARN)
end

return M
