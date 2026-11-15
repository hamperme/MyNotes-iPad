#!/usr/bin/env bash
# Build a fresh, unsigned device app. Never read or regenerate a signed checkout.
set -euo pipefail
usage() {
  echo 'Usage: package-ipa.sh --output-dir DIR --bundle-id ID --display-name NAME --build-number INTEGER' >&2
  exit 64
}
out='' bundle='' name='' number=''
while [ "$#" -gt 0 ]; do
  [ "$#" -ge 2 ] || usage
  case "$1" in
    --output-dir) out="$2" ;;
    --bundle-id) bundle="$2" ;;
    --display-name) name="$2" ;;
    --build-number) number="$2" ;;
    *) usage ;;
  esac
  shift 2
done
[ -n "$out" ] && [ -n "$bundle" ] && [ -n "$name" ] && [ -n "$number" ] || usage
[[ "$bundle" =~ ^[A-Za-z0-9][A-Za-z0-9.-]*$ ]] || usage
[[ "$number" =~ ^[1-9][0-9]*$ ]] || usage
root="$(cd "$(dirname "$0")/.." && pwd)"
for tool in xcodegen xcodebuild python3 ditto; do command -v "$tool" >/dev/null || exit 69; done
mkdir -p "$out"
out="$(cd "$out" && pwd -P)"
# Do not overwrite a prior deliverable or hide a failed build under old output.
[ ! -e "$out/MyNotes.ipa" ] && [ ! -e "$out/manifest.json" ] || { echo 'Output already exists; choose a new output directory.' >&2; exit 73; }
work="$(mktemp -d "${TMPDIR:-/tmp}/mynotes-ipa.XXXXXX")"
trap 'rm -rf "$work"' EXIT HUP INT TERM
cp "$root/project.yml" "$work/project.yml"
ditto "$root/MyNotes" "$work/MyNotes"
xcodegen generate --spec "$work/project.yml" --project "$work"
xcodebuild -project "$work/MyNotes.xcodeproj" -scheme MyNotes \
  -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
  -jobs 2 -derivedDataPath "$work/DerivedData" \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= DEVELOPMENT_TEAM= \
  COMPILER_INDEX_STORE_ENABLE=NO TARGETED_DEVICE_FAMILY=2 \
  "PRODUCT_BUNDLE_IDENTIFIER=$bundle" "INFOPLIST_KEY_CFBundleDisplayName=$name" \
  MARKETING_VERSION=0.1.0 "CURRENT_PROJECT_VERSION=$number" \
  INFOPLIST_KEY_CFBundleShortVersionString=0.1.0 "INFOPLIST_KEY_CFBundleVersion=$number" build
app="$work/DerivedData/Build/Products/Release-iphoneos/MyNotes.app"
python3 - "$app" "$work/MyNotes.ipa" <<'PY'
from pathlib import Path
import sys, zipfile
app, output = map(Path, sys.argv[1:])
if not (app / 'Info.plist').is_file():
    raise SystemExit('Missing built device app')
with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(app.rglob('*')):
        if path.is_symlink():
            raise SystemExit('Unexpected symlink in device app')
        if path.is_file():
            archive.write(path, 'Payload/MyNotes.app/' + path.relative_to(app).as_posix())
PY
python3 "$root/scripts/verify-ipa.py" "$work/MyNotes.ipa" --bundle-id "$bundle" --build-number "$number" > "$work/manifest.json"
python3 - "$root" "$work/manifest.json" <<'PY'
from pathlib import Path
import hashlib, json, subprocess, sys
root, manifest = map(Path, sys.argv[1:])
data = json.loads(manifest.read_text())
data['source_commit'] = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()
paths = sorted(p for p in (root / 'MyNotes').rglob('*') if p.is_file()) + [root / 'project.yml']
data['source_sha256'] = {p.relative_to(root).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
data['xcode'] = subprocess.check_output(['xcodebuild', '-version'], text=True).strip()
data['xcodegen'] = subprocess.check_output(['xcodegen', '--version'], text=True).strip()
manifest.write_text(json.dumps(data, indent=2) + '\n')
PY
mv "$work/MyNotes.ipa" "$out/MyNotes.ipa"
mv "$work/manifest.json" "$out/manifest.json"
(cd "$out" && shasum -a 256 MyNotes.ipa > MyNotes.ipa.sha256)
printf 'IPA_PACKAGE_PASS: %s\n' "$out/MyNotes.ipa"
printf 'Unsigned arm64 iPad package only; SideStore signing/install/refresh NOT VERIFIED.\n'
