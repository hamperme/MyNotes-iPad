#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v xcodegen >/dev/null 2>&1; then
  echo '缺少 XcodeGen。Mac 上运行：brew install xcodegen' >&2
  exit 1
fi
xcodegen generate --spec project.yml
printf '\n已生成 MyNotes.xcodeproj，请用 Xcode 打开并设置 Signing Team。\n'
