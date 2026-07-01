#!/usr/bin/env bash
# Install netwatch from a git clone into ~/.local/bin and ~/.config/netwatch
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
CFG_DIR="${HOME}/.config/netwatch"
SHARE="${REPO}/share"

if [[ ! -x "${REPO}/netwatch" ]]; then
  echo "Missing ${REPO}/netwatch — run from repository root." >&2
  exit 1
fi

mkdir -p "${BIN_DIR}" "${CFG_DIR}" "${CFG_DIR}/harnesses"

install -m 755 "${REPO}/netwatch" "${BIN_DIR}/netwatch"

install -m 755 "${SHARE}/router-clients.sh" "${CFG_DIR}/router-clients.sh"
install -m 755 "${SHARE}/router-block.sh" "${CFG_DIR}/router-block.sh"
install -m 644 "${SHARE}/sudoers-netwatch.example" "${CFG_DIR}/sudoers-netwatch.example"
install -m 755 "${SHARE}/install-cron.sh" "${CFG_DIR}/install-cron.sh"

if [[ ! -f "${CFG_DIR}/config.yaml" ]]; then
  install -m 644 "${SHARE}/config.yaml.example" "${CFG_DIR}/config.yaml"
  echo "→ Installed default config: ${CFG_DIR}/config.yaml"
else
  echo "→ Kept existing config: ${CFG_DIR}/config.yaml"
fi

install -m 644 "${SHARE}/router-manual.json.example" "${CFG_DIR}/router-manual.json.example"
install -m 644 "${SHARE}/secrets.env.example" "${CFG_DIR}/secrets.env.example"

# Harnesses: add missing files only (never overwrite user edits)
for f in "${SHARE}/harnesses/"*.yaml; do
  base="$(basename "$f")"
  if [[ ! -f "${CFG_DIR}/harnesses/${base}" ]]; then
    install -m 644 "$f" "${CFG_DIR}/harnesses/${base}"
  fi
done
mkdir -p "${CFG_DIR}/harnesses/examples"
if [[ ! -f "${CFG_DIR}/harnesses/examples/example-probe.sh" ]]; then
  install -m 755 "${SHARE}/harnesses/examples/example-probe.sh" \
    "${CFG_DIR}/harnesses/examples/example-probe.sh"
fi

# Empty runtime state (never ship personal LAN data)
touch "${CFG_DIR}/check.log" 2>/dev/null || true
for empty in blocked_devices.json trusted_peers.json known_devices.json router-manual.json; do
  if [[ ! -f "${CFG_DIR}/${empty}" ]]; then
    if [[ "$empty" == *.json ]]; then
      [[ "$empty" == "router-manual.json" ]] && echo "[]" > "${CFG_DIR}/${empty}" || echo "{}" > "${CFG_DIR}/${empty}"
    fi
  fi
done
if [[ ! -f "${CFG_DIR}/alert_state.json" ]]; then
  echo '{"notified_macs": {}}' > "${CFG_DIR}/alert_state.json"
fi

if ! command -v python3 >/dev/null; then
  echo "Warning: python3 not found." >&2
elif ! python3 -c "import yaml" 2>/dev/null; then
  echo "Install PyYAML: sudo dnf install python3-pyyaml   (or apt install python3-yaml)" >&2
fi

echo ""
echo "Netwatch installed → ${BIN_DIR}/netwatch"
echo ""
echo "Next steps:"
echo "  1. netwatch --configure    # router username & password (optional SMTP)"
echo "  2. netwatch --setup        # one-time sudo for quarantine + listener names"
echo "  3. netwatch                # dashboard"
echo ""
echo "Optional: ${CFG_DIR}/install-cron.sh  for periodic --check alerts"
