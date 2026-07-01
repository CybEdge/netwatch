# Netwatch

Cyberpunk terminal dashboard for **your** home network — defensive monitoring, device identification, host exposure, and manual quarantine. Built for Linux (Fedora/Nobara, KDE Plasma friendly).

No cloud. No auto-install of packages or sudo rules without your consent. Secrets stay under `~/.config/netwatch/` only — **never in this git repo**:

| File | In git? |
|------|---------|
| `auth.json` (hashed local login) | **No** — gitignored |
| `secrets.env` (router/SMTP) | **No** — gitignored |
| `known_devices.json`, `router-manual.json`, … | **No** — gitignored |
| `share/*.example` | Yes — empty templates only |

## Features

- **LAN dashboard** — ARP neighbors, Tailscale peers, router client list, outbound/inbound flows
- **House scan** — ping sweep + mDNS (+ optional nmap)
- **Identify mode** — label devices, YAML probe harnesses, OUI vendor lookup
- **Host exposure** — who connects *to this PC*, bridges/tunnels, live listener resolution via `ss`/`lsof`
- **Quarantine** — manual block unknown devices (nftables/firewalld + optional router MAC deny)
- **Options UI** — toggle settings, rebind keys, consent gates before installing optional tools

## Requirements

| Required | Optional |
|----------|----------|
| Python 3.10+ | `avahi-tools` (mDNS scan/identify) |
| `python3-pyyaml` | `nmap` (faster house scan) |
| `ip` (iproute) | `tailscale` CLI |
| | `firewalld` or `nftables` (quarantine) |
| | `notify-send` (desktop alerts from `--check`) |

## Local login (first run)

The first time you run `netwatch`, you choose a **local username and password** for the dashboard on this PC. The password is stored as a **PBKDF2-SHA256 hash** in `~/.config/netwatch/auth.json` (mode `600`) — never plaintext.

**There is no password recovery.** If you forget your login, it is lost forever. Your only option is to create a new user, which **erases all local netwatch data** (labels, blocks, secrets, alert history):

```bash
netwatch --new-user   # double confirmation — destructive, no undo
```

Disable local login in `config.yaml`: `auth.enabled: false`

**Router credentials** (for whole-house block) are separate — stored in `secrets.env` via `netwatch --configure` because the router API requires the real password. Those are also chmod `600` and git-ignored, but cannot be one-way hashed.

## Quick start

```bash
git clone https://github.com/YOUR_USER/netwatch.git
cd netwatch
./install.sh

# 1) Router username & password (stored locally, chmod 600)
netwatch --configure

# 2) One-time sudo setup for quarantine + root-owned process names
netwatch --setup

# 3) Dashboard
netwatch
```

Press **H** in the dashboard for the full key map.

## Commands

| Command | Purpose |
|---------|---------|
| `netwatch` | Interactive TUI |
| `netwatch --configure` | Router username/password; optional SMTP for email alerts |
| `netwatch --setup` | `--configure` if needed + passwordless sudo for firewall/tools |
| `netwatch --check` | Non-interactive scan + alerts (cron-friendly) |
| `netwatch --restore-blocks` | Re-apply quarantine rules after reboot |
| `netwatch --dig-listeners` | List LAN listeners with process names |
| `netwatch --dig-port 443` | Deep lookup for one port |

Optional cron (every 2 hours):

```bash
~/.config/netwatch/install-cron.sh
```

## Configuration

After `install.sh`, files live under `~/.config/netwatch/`:

| File | Purpose |
|------|---------|
| `config.yaml` | Feature toggles, scan methods, keybindings |
| `secrets.env` | Router & SMTP credentials (from `--configure`; must be usable by router API) |
| `auth.json` | **Local dashboard login** (hashed password, first-run setup) |
| `known_devices.json` | MAC labels & probe cache (runtime) |
| `router-manual.json` | Extra device names for router panel |
| `harnesses/` | YAML device probes (extend without code changes) |

Router admin URL is **auto-detected** from your default gateway when left empty in config.

Copy `router-manual.json.example` when adding static names:

```bash
cp ~/.config/netwatch/router-manual.json.example ~/.config/netwatch/router-manual.json
```

## Security notes

- Quarantine runs **only** when you press **B** — never from cron alone.
- Package install (`dnf`) and sudoers install require explicit **Y** in the TUI consent dialog.
- Do not commit `secrets.env`, `known_devices.json`, or `router-manual.json`.
- Review `share/sudoers-netwatch.example` before `--setup`.

## Project layout

```
netwatch/
├── netwatch              # Main Python TUI (single file)
├── install.sh            # Install to ~/.local/bin + ~/.config/netwatch
├── share/
│   ├── config.yaml.example
│   ├── secrets.env.example
│   ├── harnesses/        # Default probe harnesses
│   ├── router-clients.sh
│   └── ...
├── README.md
└── LICENSE
```

## License

MIT — see [LICENSE](LICENSE).
