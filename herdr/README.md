# Herdr

Personal Herdr keybindings, sidebar layout, pane helpers, and Agent Inbox styling.
Runtime sessions, sockets, logs, caches, and plugin binaries are not tracked.

Requires Herdr, Python 3, and the GitHub CLI (`gh`).

## Restore

Run these commands from the dotfiles repository root with Herdr running:

```sh
herdr plugin install douglascorrea/herdr-agent-inbox --ref 78b243279b4da55150b58dc2cc3cffcdc2fd6a04 --yes
herdr plugin install itisbryan/herdr-gh-checks --ref c761b87d2e9dec4c3c5b782386d5e314b96fdee9 --yes

mkdir -p "$HOME/.config/herdr/plugins/config/herdr-agent-inbox"
cp herdr/config.toml herdr/swap-pane.py herdr/toggle-pr-panel.py "$HOME/.config/herdr/"
cp herdr/plugins/herdr-agent-inbox/config.toml herdr/plugins/herdr-agent-inbox/inbox-theme.json "$HOME/.config/herdr/plugins/config/herdr-agent-inbox/"

inbox_plugin_root=$(herdr plugin list --plugin herdr-agent-inbox --json | python3 -c 'import json, sys; print(json.load(sys.stdin)["result"]["plugins"][0]["plugin_root"])')
inbox_patch="$PWD/herdr/plugins/herdr-agent-inbox/inbox-tui.patch"
if git -C "$inbox_plugin_root" apply --check "$inbox_patch"; then
  git -C "$inbox_plugin_root" apply "$inbox_patch"
else
  git -C "$inbox_plugin_root" apply --reverse --check "$inbox_patch"
fi

herdr server reload-config
```

The inbox patch is tied to the pinned upstream revision. Reopen the inbox popup
after applying it. Installing a newer upstream version can overwrite the patch.

## Keybindings

The prefix is `Ctrl+b`.

| Keys | Action |
| --- | --- |
| Prefix + `"` / `%` | Split horizontally / vertically |
| Prefix + `h/j/k/l`, or `Ctrl+h/j/k/l` | Focus a pane |
| Prefix + `a` | Workspace picker |
| Prefix + `w` or `g` | Go to a workspace or pane |
| Prefix + `b` or `Shift+b` | Toggle the sidebar |
| Prefix + `{` / `}` | Swap with the previous / next pane |
| Prefix + `i` or `Shift+i` | Open Agent Inbox |
| Prefix + `m` | Settle the current agent |
| Prefix + `Shift+m` | Mark the current agent unread |
| Prefix + `Alt+m` | Settle finished agents in the workspace |
| Prefix + `p` | Toggle the full-height PR checks panel on the right |

The PR panel helper preserves running terminals and restores their split layout.
The sidebar includes agent titles, runtimes, Git status, and PR/CI status tokens.
Agent Inbox uses the saved terminal theme and custom table styling; automatic tab
renaming and LLM title summarization are disabled.
