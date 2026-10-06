"""Swap the active Herdr pane with the previous or next pane in its tab."""

import argparse
import json
import os
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("direction", choices=("previous", "next"))
    args = parser.parse_args()

    herdr = os.environ.get("HERDR_BIN_PATH", "herdr")
    source = os.environ["HERDR_ACTIVE_PANE_ID"]
    response = subprocess.check_output(
        [herdr, "pane", "layout", "--pane", source], text=True, timeout=10
    )
    layout = json.loads(response)["result"]["layout"]
    panes = [pane["pane_id"] for pane in layout["panes"]]
    if len(panes) < 2:
        return

    offset = 1
    if args.direction == "previous":
        offset = -1
    target = panes[(panes.index(source) + offset) % len(panes)]
    subprocess.run(
        [herdr, "pane", "swap", "--source-pane", source, "--target-pane", target],
        check=True,
        timeout=10,
    )


if __name__ == "__main__":
    main()
