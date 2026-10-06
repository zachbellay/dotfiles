"""Toggle a full-height GH Checks pane alongside the current tab's layout."""

import argparse
import fcntl
import json
import os
from pathlib import Path
import socket


SOCKET = os.environ.get("HERDR_SOCKET_PATH") or os.path.expanduser(
    "~/.config/herdr/herdr.sock"
)
MARKER = "gh_checks_toggle"


def request(method, **params):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
        connection.settimeout(30)
        connection.connect(SOCKET)
        payload = {"id": "pr-panel-toggle", "method": method, "params": params}
        connection.sendall((json.dumps(payload) + "\n").encode())
        with connection.makefile("rb") as stream:
            response = json.loads(stream.readline())
    if "error" in response:
        raise RuntimeError(str(response["error"]))
    return response["result"]


def leaves(node):
    if node["type"] == "pane":
        return [node["pane_id"]]
    return leaves(node["first"]) + leaves(node["second"])


def move(pane_id, destination):
    result = request("pane.move", pane_id=pane_id,
                     destination=destination, focus=False)["move_result"]
    if not result["changed"]:
        raise RuntimeError("Could not move pane: " + str(result.get("reason")))
    if result["pane"]["pane_id"] != pane_id:
        raise RuntimeError("Unexpected pane identity change")


def stage(pane_ids):
    # Moving a live terminal preserves its process and pane ID. Each temporary
    # tab is removed automatically when its pane is returned to the main tab.
    for pane_id in pane_ids:
        move(pane_id, {"type": "new_tab", "label": "PR panel layout"})


def restore(node, tab_id):
    if node["type"] == "pane":
        return
    move(leaves(node["second"])[0], {
        "type": "tab", "tab_id": tab_id,
        "target_pane_id": leaves(node["first"])[0],
        "split": node["direction"], "ratio": node["ratio"],
    })
    restore(node["first"], tab_id)
    restore(node["second"], tab_id)


def toggle(pane_id, background=False):
    snapshot = request("session.snapshot")["snapshot"]
    if not pane_id:
        pane_id = snapshot["focused_pane_id"]
    source = request("pane.get", pane_id=pane_id)["pane"]
    tab_id = source["tab_id"]
    workspace_id = source["workspace_id"]
    for pane in snapshot["panes"]:
        tokens = pane.get("tokens", {})
        if pane["tab_id"] == tab_id and tokens.get(MARKER) == "1":
            request("plugin.pane.close", pane_id=pane["pane_id"])
            return_id = tokens.get("gh_checks_return")
            live_ids = {item["pane_id"] for item in snapshot["panes"]}
            if not background and pane_id == pane["pane_id"] and return_id in live_ids:
                request("pane.focus", pane_id=return_id)
            return {"status": "closed", "pane_id": pane["pane_id"]}

    layout = request("layout.export", pane_id=pane_id)["layout"]
    original = layout["root"]
    original_ids = leaves(original)
    anchor = original_ids[0]
    others = original_ids[1:]
    cwd = source.get("foreground_cwd") or source["cwd"]
    # Herdr-managed worktrees are authoritative when the pane's process CWD
    # does not reflect the checkout (for example, an agent launched at home).
    for workspace in snapshot["workspaces"]:
        if workspace["workspace_id"] == workspace_id:
            worktree = workspace.get("worktree") or {}
            cwd = worktree.get("checkout_path") or cwd
            break
    if layout["zoomed"]:
        request("pane.zoom", pane_id=pane_id, mode="off")
    panel_id = None
    try:
        stage(others)
        result = request("plugin.pane.open", plugin_id="herdr-gh-checks",
                         entrypoint="panel", placement="split", direction="right",
                         target_pane_id=anchor,
                         cwd=cwd, env={"CI_CWD": cwd}, focus=False)
        panel_id = result["plugin_pane"]["pane"]["pane_id"]
        request("pane.report_metadata", pane_id=panel_id, source="pr-panel-toggle",
                tokens={MARKER: "1", "gh_checks_return": pane_id})
        request("layout.set_split_ratio", tab_id=tab_id, path=[], ratio=0.68)
        restore(original, tab_id)
    except Exception:
        # Rebuild from live terminals after a failed operation; never close or
        # restart an existing agent as part of changing the layout.
        if panel_id:
            request("plugin.pane.close", pane_id=panel_id)
        stage(others)
        restore(original, tab_id)
        if layout["zoomed"]:
            request("pane.zoom", pane_id=pane_id, mode="on")
        raise
    finally:
        if not background:
            request("pane.focus", pane_id=pane_id)
    return {"status": "opened", "pane_id": panel_id}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pane")
    parser.add_argument("--no-focus", action="store_true")
    args = parser.parse_args()
    pane_id = args.pane or os.environ.get("HERDR_ACTIVE_PANE_ID")
    lock_dir = Path(SOCKET).parent / "pr-panel-state"
    lock_dir.mkdir(mode=0o700, exist_ok=True)
    with (lock_dir / "toggle.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        print(json.dumps(toggle(pane_id, args.no_focus)))


if __name__ == "__main__":
    main()
