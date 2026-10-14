#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [ ! -d MyNotes.xcodeproj ]; then
  ./scripts/bootstrap.sh
fi
xcodebuild -project MyNotes.xcodeproj \
  -scheme MyNotes \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
