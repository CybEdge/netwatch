#!/usr/bin/env bash
# Optional hook — netwatch handles ZTE router blocks in Python automatically.
# This script logs actions only (customize if your ISP router needs extra steps).

set -euo pipefail
ACTION="${1:-${NETWATCH_ACTION:-block}}"
MAC="${2:-${NETWATCH_MAC:-unknown}}"
IP="${3:-${NETWATCH_IP:-unknown}}"
LOG="${HOME}/.config/netwatch/router-block.log"
mkdir -p "$(dirname "$LOG")"
echo "$(date -Iseconds) action=$ACTION mac=$MAC ip=$IP" >>"$LOG"
exit 0
