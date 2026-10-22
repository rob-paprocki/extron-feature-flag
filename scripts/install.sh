#!/bin/sh
# Install the prebuilt Factory DLLs into GCP, GUI Designer, and Toolbelt.
# Each DLL is the same source rebuilt per app against that app's local
# Extron.Features.Contracts.dll. Nothing shipped is modified.
#
#   sh scripts/install.sh [root/of/Extron/folders]
#
# Default root: ~/Desktop/Extron
set -eu
ROOT="${1:-$HOME/Desktop/Extron}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"

for pair in "GCP:GCP" "GUIDesigner:GUI Designer" "Toolbelt:Toolbelt"; do
  dist="${pair%%:*}"
  app="${pair#*:}"
  src="$REPO/dist/$dist/Extron.Features.Factory.dll"
  dst="$ROOT/$app/Extron.Features.Factory.dll"
  test -f "$src" || { echo "missing $src"; continue; }
  test -d "$ROOT/$app" || { echo "skip $app (no install folder at $ROOT/$app)"; continue; }
  cp -v "$src" "$dst"
done

echo
echo "Done. Launch each app and look for Tools > Feature Flag Control."
echo "GUI Designer places the item under a top-level Debug menu that only"
echo "appears after a license-info change: sign in or out once and look again."
echo
echo "Revert: rm the Extron.Features.Factory.dll from each app folder."
