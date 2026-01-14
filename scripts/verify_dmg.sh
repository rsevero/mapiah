#!/usr/bin/env bash
set -euo pipefail

DMG_PATH="${1:?Usage: verify_dmg.sh path/to/Mapiah.dmg}"

MOUNT_POINT=""
cleanup() {
  if [[ -n "${MOUNT_POINT}" ]]; then
    hdiutil detach "${MOUNT_POINT}" -quiet || true
  fi
}
trap cleanup EXIT

echo "== Verify DMG file integrity =="
hdiutil verify "${DMG_PATH}"

echo "== Mount DMG =="
ATTACH_OUT="$(hdiutil attach -nobrowse -readonly "${DMG_PATH}")"
MOUNT_POINT="$(echo "${ATTACH_OUT}" | awk '/\/Volumes\// {print $3; exit}')"
echo "Mounted at: ${MOUNT_POINT}"

APP="${MOUNT_POINT}/mapiah.app"
test -d "${APP}"

echo "== Check /Applications link exists =="
test -L "${MOUNT_POINT}/Applications" || test -e "${MOUNT_POINT}/Applications"

echo "== Validate Info.plist =="
plutil -lint "${APP}/Contents/Info.plist"
BID="$(defaults read "${APP}/Contents/Info" CFBundleIdentifier)"
EXE="$(defaults read "${APP}/Contents/Info" CFBundleExecutable)"
echo "CFBundleIdentifier=${BID}"
echo "CFBundleExecutable=${EXE}"

echo "== Bundle structure (diagnostic) =="
ls -la "${APP}/Contents" || true
ls -la "${APP}/Contents/Resources" || true

echo "== Check app icon resources exist inside the app bundle =="
# On macOS, apps may use either an .icns (CFBundleIconFile) or an asset catalog (Assets.car).
if ! ls "${APP}/Contents/Resources/"*.icns >/dev/null 2>&1 && [[ ! -f "${APP}/Contents/Resources/Assets.car" ]]; then
  echo "ERROR: No icon resources found in ${APP}/Contents/Resources (expected *.icns or Assets.car)."
  exit 1
fi

echo "== Check DMG volume icon (optional) =="
if [[ -f "${MOUNT_POINT}/.VolumeIcon.icns" ]]; then
  echo "Found .VolumeIcon.icns"
else
  echo "Note: .VolumeIcon.icns not found (may still be OK depending on appdmg behavior)."
fi

echo "== Gatekeeper / codesign info (diagnostic) =="
codesign --display --verbose=4 "${APP}" || true
spctl -a -t exec -vv "${APP}" || true

echo "== Optional smoke launch (5s) =="
BIN="${APP}/Contents/MacOS/${EXE}"
if [[ -x "${BIN}" ]]; then
  rm -f /tmp/mapiah_smoke.log /tmp/mapiah_smoke_pid || true
  ( "${BIN}" >/tmp/mapiah_smoke.log 2>&1 & echo $! > /tmp/mapiah_smoke_pid ) || true
  sleep 5
  kill "$(cat /tmp/mapiah_smoke_pid)" >/dev/null 2>&1 || true
  echo "--- smoke log (tail) ---"
  tail -n 120 /tmp/mapiah_smoke.log || true
fi

echo "DMG verification OK"
