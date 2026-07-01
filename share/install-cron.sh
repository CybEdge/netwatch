#!/usr/bin/env bash
# Install netwatch LAN check every 2 hours (unknown device alerts).
set -euo pipefail

NETWATCH="${HOME}/.local/bin/netwatch"
LOG_DIR="${HOME}/.config/netwatch"
CRON_LINE="0 */2 * * * ${NETWATCH} --check >>${LOG_DIR}/check.log 2>&1"

if [[ ! -x "$NETWATCH" ]]; then
  echo "Missing netwatch at $NETWATCH" >&2
  exit 1
fi

mkdir -p "$LOG_DIR"
touch "${LOG_DIR}/check.log"

existing="$(crontab -l 2>/dev/null || true)"
if echo "$existing" | grep -Fq "netwatch --check"; then
  echo "Cron entry already installed."
else
  (echo "$existing"; echo "$CRON_LINE") | crontab -
  echo "Installed: $CRON_LINE"
fi

echo ""
echo "IMPORTANT — run once before first block:"
echo "  netwatch --setup"
echo ""
echo "Next steps:"
echo "  1. Test now:  netwatch --check"
echo "  2. Email:     edit ~/.config/netwatch/config.yaml → notifications.email"
echo "                export NETWATCH_SMTP_USER / NETWATCH_SMTP_PASS"
echo "  3. Blocking:  sudo visudo -f /etc/sudoers.d/netwatch  (see sudoers-netwatch.example)"
echo "  4. Log tail:  tail -f ~/.config/netwatch/check.log"
