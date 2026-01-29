#!/usr/bin/env bash
set -euo pipefail

# Usage: gen_and_copy_flathub.sh [MANIFEST] [TARGET]
# Default MANIFEST: packaging/linux/flatpak/built-on-flathub/io.github.rsevero.mapiah/flatpak-flutter.yml
# Default TARGET: ~/devel/io.github.rsevero.mapiah

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST_REL=${1:-.tools/flatpak-flutter/io.github.rsevero.mapiah/flatpak-flutter.yml}
MANIFEST="$ROOT_DIR/$MANIFEST_REL"
TARGET=${2:-$HOME/devel/io.github.rsevero.mapiah}
FLATPAK_FLUTTER="$ROOT_DIR/.tools/flatpak-flutter/flatpak-flutter.py"
PUBSPEC="$ROOT_DIR/pubspec.yaml"
METAINFO="$ROOT_DIR/packaging/linux/io.github.rsevero.mapiah.metainfo.xml"
SOURCE_MANIFEST="$ROOT_DIR/packaging/linux/flatpak/built-on-flathub/io.github.rsevero.mapiah/flatpak-flutter.yml"

echo "Manifest: $MANIFEST"
echo "Generator: $FLATPAK_FLUTTER"
echo "Target repo: $TARGET"

# Optionally activate virtualenv if present
if [ -f "$ROOT_DIR/.venv/bin/activate" ]; then
  echo "Activating .venv"
  # shellcheck source=/dev/null
  source "$ROOT_DIR/.venv/bin/activate"
fi

# Recreate .tools (not tracked in git)
TOOLS_DIR="$ROOT_DIR/.tools"
FLATPAK_FLUTTER_DIR="$TOOLS_DIR/flatpak-flutter"
FLATPAK_BUILDER_TOOLS_DIR="$TOOLS_DIR/flatpak-builder-tools"

rm -rf "$TOOLS_DIR"
mkdir -p "$TOOLS_DIR"

git clone --depth 1 https://github.com/TheAppgineer/flatpak-flutter.git "$FLATPAK_FLUTTER_DIR"
git clone --depth 1 https://github.com/flatpak/flatpak-builder-tools.git "$FLATPAK_BUILDER_TOOLS_DIR"

mkdir -p "$FLATPAK_FLUTTER_DIR/io.github.rsevero.mapiah"

FLATPAK_FLUTTER="$FLATPAK_FLUTTER_DIR/flatpak-flutter.py"
MANIFEST="$ROOT_DIR/$MANIFEST_REL"

# Sync manifest into .tools before any processing
if [ -f "$SOURCE_MANIFEST" ]; then
  mkdir -p "$(dirname "$MANIFEST")"
  cp -f "$SOURCE_MANIFEST" "$MANIFEST"
else
  echo "Source manifest not found: $SOURCE_MANIFEST" >&2
  exit 1
fi

# Ensure git sources with tag also include commit in the input manifest.
export MANIFEST
python3 - <<'PY'
import os
import subprocess
import sys

manifest_path = os.environ.get('MANIFEST')
if not manifest_path:
  print('Missing MANIFEST env var', file=sys.stderr)
  sys.exit(1)

try:
  import yaml  # type: ignore
except Exception as exc:
  print(f'PyYAML not available: {exc}', file=sys.stderr)
  sys.exit(1)

with open(manifest_path, 'r', encoding='utf-8') as f:
  manifest = yaml.safe_load(f)

changed = False

def resolve_tag_commit(url: str, tag: str) -> str:
  try:
    result = subprocess.run(
      ['git', 'ls-remote', '--tags', url, f'refs/tags/{tag}', f'refs/tags/{tag}^{{}}'],
      check=True,
      stdout=subprocess.PIPE,
      stderr=subprocess.PIPE,
      text=True,
    )
  except subprocess.CalledProcessError as exc:
    raise RuntimeError(exc.stderr.strip() or exc.stdout.strip() or str(exc))

  peeled = None
  direct = None
  for line in result.stdout.strip().splitlines():
    if not line.strip():
      continue
    sha, ref = line.split('\t', 1)
    if ref.endswith('^{}'):
      peeled = sha
    elif ref.endswith(f'refs/tags/{tag}'):
      direct = sha
  return peeled or direct or ''


for module in manifest.get('modules', []) or []:
  for source in module.get('sources', []) or []:
    if not isinstance(source, dict):
      continue
    if source.get('type') != 'git':
      continue
    tag = source.get('tag')
    commit = source.get('commit')
    url = source.get('url')
    if tag and not commit:
      if not url:
        print(f"Missing url for tagged git source in module {module.get('name')}", file=sys.stderr)
        sys.exit(1)
      resolved = resolve_tag_commit(url, tag)
      if not resolved:
        print(f"Failed to resolve commit for {url} tag {tag}", file=sys.stderr)
        sys.exit(1)
      source['commit'] = resolved
      changed = True

if changed:
  with open(manifest_path, 'w', encoding='utf-8') as f:
    yaml.safe_dump(manifest, f, sort_keys=False)
PY

# Run the generator
if [ ! -x "$FLATPAK_FLUTTER" ] && [ -f "$FLATPAK_FLUTTER" ]; then
  echo "Running generator with python"
  python3 "$FLATPAK_FLUTTER" "$MANIFEST"
else
  "$FLATPAK_FLUTTER" "$MANIFEST"
fi

# Determine app id from manifest (first 'id:' occurrence)
APP_ID=$(grep -m1 '^id:' "$MANIFEST" | awk '{print $2}' || true)
if [ -z "$APP_ID" ]; then
  echo "Failed to determine app id from manifest ($MANIFEST)" >&2
  exit 1
fi

GENERATED_YML="$ROOT_DIR/${APP_ID}.yml"
if [ ! -f "$GENERATED_YML" ]; then
  # fallback: generated in .tools folder
  GENERATED_YML="$ROOT_DIR/.tools/flatpak-flutter/${APP_ID}.yml"
fi

if [ ! -f "$GENERATED_YML" ]; then
  echo "Generated manifest not found: ${APP_ID}.yml" >&2
  echo "List of *.yml files in project root:"
  ls -1 "$ROOT_DIR"/*.yml || true
  exit 1
fi

# No post-processing of generated modules here; rely on flatpak-flutter output.

# Prepare target directories — clean existing contents first (preserve .git)
if [ -d "$TARGET" ]; then
  echo "Cleaning target directory $TARGET (preserving .git/.gitignore if present)"
  if [ -d "$TARGET/.git" ]; then
    find "$TARGET" -mindepth 1 -maxdepth 1 ! -name .git ! -name .gitignore -exec rm -rf {} +
  else
    find "$TARGET" -mindepth 1 -maxdepth 1 ! -name .gitignore -exec rm -rf {} +
  fi
fi
mkdir -p "$TARGET"
mkdir -p "$TARGET/generated/modules"
mkdir -p "$TARGET/generated/sources"
mkdir -p "$TARGET/generated/patches"

# Copy files
echo "Copying $GENERATED_YML -> $TARGET/"
cp -f "$GENERATED_YML" "$TARGET/"

# Copy generated modules/sources if present
if [ -d "$ROOT_DIR/generated/modules" ]; then
  echo "Copying generated/modules -> $TARGET/generated/modules"
  cp -r --remove-destination "$ROOT_DIR/generated/modules/"* "$TARGET/generated/modules/" || true
fi
if [ -d "$ROOT_DIR/generated/sources" ]; then
  echo "Copying generated/sources -> $TARGET/generated/sources"
  cp -r --remove-destination "$ROOT_DIR/generated/sources/"* "$TARGET/generated/sources/" || true
fi
if [ -d "$ROOT_DIR/generated/patches" ]; then
  echo "Copying generated/patches -> $TARGET/generated/patches"
  cp -r --remove-destination "$ROOT_DIR/generated/patches/"* "$TARGET/generated/patches/" || true
fi

# Copy packaging files referenced commonly
PKG_DIR="$ROOT_DIR/packaging/linux"
if [ -f "$PKG_DIR/io.github.rsevero.mapiah.metainfo.xml" ]; then
  cp -f "$PKG_DIR/io.github.rsevero.mapiah.metainfo.xml" "$TARGET/"
fi
if [ -f "$PKG_DIR/io.github.rsevero.mapiah.desktop" ]; then
  cp -f "$PKG_DIR/io.github.rsevero.mapiah.desktop" "$TARGET/"
fi

# Copy icons if present
ICON_DIR="$ROOT_DIR/assets/icons"
if [ -d "$ICON_DIR" ]; then
  cp -f "$ICON_DIR"/m-* "$TARGET/" || true
fi

# If the generator created a .tools/flatpak-flutter/<app>/io.github...yml copy it too
if [ -f "$ROOT_DIR/.tools/flatpak-flutter/${APP_ID}/io.github.rsevero.mapiah.yml" ]; then
  cp -f "$ROOT_DIR/.tools/flatpak-flutter/${APP_ID}/io.github.rsevero.mapiah.yml" "$TARGET/"
fi

echo "Done. Files copied to $TARGET"
ls -l "$TARGET" | sed -n '1,200p'

# Cleanup tools directory
rm -rf "$TOOLS_DIR"
# Cleanup generated directory
rm -rf "$ROOT_DIR/generated"

# Cleanup flatpak-builder temp directory if present
if [ -d "$ROOT_DIR/.flatpak-builder" ]; then
  echo "Removing .flatpak-builder temp directory"
  rm -rf "$ROOT_DIR/.flatpak-builder"
fi
