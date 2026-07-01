# Contributing to Netwatch

Thanks for helping improve Netwatch. **`main` is protected** — please do not push commits directly to it. All changes go through a pull request so they can be reviewed first.

## Contributor workflow

1. **Fork** [CybEdge/netwatch](https://github.com/CybEdge/netwatch) on GitHub.
2. **Clone your fork** and create a branch:
   ```bash
   git clone https://github.com/YOUR_USER/netwatch.git
   cd netwatch
   git checkout -b my-feature
   ```
3. **Make your changes.** Keep diffs focused. Match the existing style in `netwatch` (single-file TUI).
4. **Test locally:**
   ```bash
   python3 -m py_compile netwatch
   ./install.sh   # optional — syncs to ~/.local/bin/netwatch
   netwatch
   ```
5. **Commit** with a clear message (what changed and why).
6. **Push** your branch to your fork:
   ```bash
   git push -u origin my-feature
   ```
7. **Open a pull request** against `CybEdge/netwatch` **`main`**. Fill in the PR template.
8. Wait for review. Address feedback on the same branch — the PR updates automatically.

## What we look for

- Small, reviewable PRs (one feature or fix when possible)
- No secrets or personal config (`auth.json`, `secrets.env`, `ui_state.json`, etc.)
- No unrelated drive-by refactors
- Manual test notes in the PR (“tested identify flow”, “tested redact guard”, …)

## Maintainer: enable branch protection (one-time)

Run this once on a machine with [GitHub CLI](https://cli.github.com/) authenticated as the repo owner:

```bash
gh auth login
./scripts/enable-main-protection.sh
```

Or configure manually on GitHub:

1. Open **Settings → Rules → Rulesets → New branch ruleset**
2. **Name:** `Protect main`
3. **Enforcement status:** Active
4. **Bypass list:** your admin account only (optional emergency bypass)
5. **Target branches:** Include default branch (`main`)
6. **Rules:**
   - **Require a pull request before merging** — 1 approving review
   - **Require conversation resolution before merging**
   - **Block force pushes**
   - **Block branch deletion**
7. Save the ruleset

After this, direct pushes to `main` are rejected; you merge via reviewed PRs (including your own, if you use a branch + PR like everyone else).

## Questions

Open a [GitHub issue](https://github.com/CybEdge/netwatch/issues) for bugs, ideas, or questions before large changes.
