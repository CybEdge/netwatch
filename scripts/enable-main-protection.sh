#!/usr/bin/env bash
# Apply GitHub ruleset so main only accepts changes via reviewed pull requests.
# Requires: gh CLI + gh auth login (repo admin)
set -euo pipefail

REPO="${1:-CybEdge/netwatch}"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is not installed."
  echo "  Fedora/Nobara: sudo dnf install gh"
  echo "  Then: gh auth login"
  echo ""
  echo "Or enable protection manually — see CONTRIBUTING.md"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Not logged in to GitHub. Run: gh auth login"
  exit 1
fi

echo "Applying branch ruleset to ${REPO} (protect main via pull requests)…"

# Repository ruleset — blocks unreviewed direct updates to default branch.
gh api "repos/${REPO}/rulesets" --method POST --input - <<'EOF'
{
  "name": "Protect main",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["~DEFAULT_BRANCH"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": true
      }
    },
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    }
  ]
}
EOF

echo ""
echo "Done. Verify: https://github.com/${REPO}/settings/rules"
echo "Contributors should fork, branch, and open PRs — see CONTRIBUTING.md"
