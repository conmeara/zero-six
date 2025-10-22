#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXTENSION_DIR="$ROOT_DIR/apps/chrome-extension"
OUTPUT_ARCHIVE="$ROOT_DIR/apps/macos/ZeroSixApp/Resources/ChromeExtension/zero-six-extension.zip"

rm -f "$OUTPUT_ARCHIVE"
cd "$EXTENSION_DIR"
zip -r "$OUTPUT_ARCHIVE" .
