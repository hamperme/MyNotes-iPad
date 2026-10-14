#!/usr/bin/env bash
# Idempotent seeding: use only if milestone issues are missing.
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v gh >/dev/null 2>&1; then
  echo '请先安装并登录 GitHub CLI：brew install gh && gh auth login' >&2
  exit 1
fi
repo="${1:-hamperme/MyNotes-iPad}"
for f in backlog/*.md; do
  title="$(sed -n '1{s/^# //;p;}' "$f")"
  if gh issue list -R "$repo" --state all --limit 200 --json title --jq '.[].title' | grep -Fxq "$title"; then
    printf 'Skip existing: %s\n' "$title"
  else
    gh issue create -R "$repo" --title "$title" --body-file "$f"
  fi
done
