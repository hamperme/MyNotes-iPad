#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -ne 1 ]; then
  echo 'Usage: ./scripts/check-editor.sh SIMULATOR_UUID (use a dedicated iPad simulator)' >&2
  exit 64
fi
root="$(cd "$(dirname "$0")/.." && pwd)"
build="$(mktemp -d "${TMPDIR:-/tmp}/mynotes-editor-test.XXXXXX")"
printf 'Regression build and results: %s\n' "$build"
# A distinct test bundle/simulator protects personal notes and signing settings.
xcodegen generate --spec "$root/tests/project.yml" --project "$root/tests"
xcodebuild test -project "$root/tests/MyNotesRegression.xcodeproj" \
  -scheme MyNotes -destination "id=$1" -parallel-testing-enabled NO \
  -jobs 2 -derivedDataPath "$build/DerivedData" \
  -resultBundlePath "$build/EditorRegression.xcresult" \
  CODE_SIGNING_ALLOWED=NO COMPILER_INDEX_STORE_ENABLE=NO
