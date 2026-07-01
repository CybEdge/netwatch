#!/usr/bin/env bash
# Router client script for netwatch — prints JSON array to stdout.
# See ~/.config/netwatch/config.yaml and press h in netwatch for setup help.

set -euo pipefail

CONFIG_DIR="${HOME}/.config/netwatch"
MANUAL="${CONFIG_DIR}/router-manual.json"

exec python3 - "${MANUAL}" <<'PY'
import json
import pathlib
import re
import subprocess
import sys

manual_path = pathlib.Path(sys.argv[1])


def add(rows: dict, ip: str, mac: str, name: str) -> None:
    mac = (mac or "").lower()
    if not mac or mac == "failed":
        return
    rows[mac] = {"ip": ip or "?", "mac": mac, "name": name or "?"}


rows: dict[str, dict] = {}

route = subprocess.run(
    ["ip", "route", "show", "default"],
    capture_output=True,
    text=True,
    check=False,
).stdout
match = re.search(r"dev (\S+)", route)
iface = match.group(1) if match else ""

if iface:
    neigh = subprocess.run(
        ["ip", "neigh", "show", "dev", iface],
        capture_output=True,
        text=True,
        check=False,
    ).stdout
    for line in neigh.splitlines():
        parts = line.split()
        if len(parts) >= 5 and parts[0].count(".") == 3:
            add(rows, parts[0], parts[2], "arp-neighbor")

if manual_path.is_file():
    try:
        for item in json.loads(manual_path.read_text()):
            add(rows, item.get("ip", "?"), item.get("mac", ""), item.get("name", "manual"))
    except json.JSONDecodeError as exc:
        print(json.dumps([{"ip": "?", "mac": "?", "name": f"router-manual.json invalid: {exc}"}]))
        sys.exit(0)

print(json.dumps(list(rows.values())))
PY
