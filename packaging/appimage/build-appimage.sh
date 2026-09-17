#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s /path/to/teleroboxer-runtime [output-directory]\n' "$0"
}

if [[ $# -lt 1 || $# -gt 2 ]]; then usage >&2; exit 2; fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME="$(realpath -- "$1")"
OUTPUT_DIR="$(realpath -m -- "${2:-$SCRIPT_DIR/dist}")"
APPDIR="$OUTPUT_DIR/Teleroboxer.AppDir"
APPIMAGE="$OUTPUT_DIR/Teleroboxer-Recomp-x86_64.AppImage"
APPIMAGETOOL="${APPIMAGETOOL:-$(command -v appimagetool || true)}"
LINUXDEPLOY="${LINUXDEPLOY:-$(command -v linuxdeploy || true)}"

[[ -f "$RUNTIME" && -x "$RUNTIME" ]] || { printf 'Runtime is missing or not executable: %s\n' "$RUNTIME" >&2; exit 1; }
file "$RUNTIME" | grep -q 'ELF 64-bit.*x86-64' || { printf 'Runtime must be an x86_64 Linux ELF executable: %s\n' "$RUNTIME" >&2; exit 1; }
[[ -n "$APPIMAGETOOL" && -x "$APPIMAGETOOL" ]] || { printf 'appimagetool was not found. Set APPIMAGETOOL=/path/to/appimagetool.\n' >&2; exit 1; }
[[ -n "$LINUXDEPLOY" && -x "$LINUXDEPLOY" ]] || { printf 'linuxdeploy was not found. Set LINUXDEPLOY=/path/to/linuxdeploy.\n' >&2; exit 1; }

mkdir -p -- "$OUTPUT_DIR"
rm -rf -- "$APPDIR"
mkdir -p -- "$APPDIR/usr/bin" "$APPDIR/usr/share/applications" "$APPDIR/usr/share/icons/hicolor/scalable/apps"
install -m 0755 "$RUNTIME" "$APPDIR/usr/bin/teleroboxer-recomp"
install -m 0755 "$SCRIPT_DIR/AppRun" "$APPDIR/AppRun"
install -m 0644 "$SCRIPT_DIR/teleroboxer-recomp.desktop" "$APPDIR/teleroboxer-recomp.desktop"
install -m 0644 "$SCRIPT_DIR/teleroboxer-recomp.desktop" "$APPDIR/usr/share/applications/teleroboxer-recomp.desktop"
install -m 0644 "$SCRIPT_DIR/teleroboxer-recomp.svg" "$APPDIR/teleroboxer-recomp.svg"
install -m 0644 "$SCRIPT_DIR/teleroboxer-recomp.svg" "$APPDIR/usr/share/icons/hicolor/scalable/apps/teleroboxer-recomp.svg"

# Collect the runtime's shared-library dependencies before turning the staged
# AppDir into an AppImage. This is what makes the package portable to SteamOS.
"$LINUXDEPLOY" --appdir "$APPDIR" --executable "$APPDIR/usr/bin/teleroboxer-recomp"
ARCH=x86_64 "$APPIMAGETOOL" "$APPDIR" "$APPIMAGE"
printf 'Created %s\n' "$APPIMAGE"
