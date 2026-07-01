#!/usr/bin/env bash
# Example custom probe harness — copy and enable in a new YAML file:
#
# id: my-printer
# probe:
#   type: script
#   path: ~/.config/netwatch/harnesses/examples/example-probe.sh
# stop_on_first_match is per-config; script must print JSON:
# {"matched":true,"device_type":"printer","auto_guess":"HP LaserJet","note":"port 9100"}

set -euo pipefail
ip="${NETWATCH_IP:?}"
mac="${NETWATCH_MAC:-}"

if timeout 0.4 bash -c "echo >/dev/tcp/${ip}/9100" 2>/dev/null; then
  python3 - <<PY
import json
print(json.dumps({
    "matched": True,
    "device_type": "printer?",
    "auto_guess": "Network printer?",
    "note": f"TCP 9100 open on {ip}",
    "confidence": 0.6,
}))
PY
  exit 0
fi

echo '{"matched":false}'
