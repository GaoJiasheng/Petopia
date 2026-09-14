#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if ! command -v cwebp >/dev/null 2>&1; then
  echo "cwebp is required to build runtime yard decor." >&2
  exit 1
fi
for season in spring summer autumn winter; do
  source="$root/assets/art/world/decor/deco_tree_seasonal_${season}.png"
  cwebp -quiet -lossless -z 9 -exact -mt -metadata none \
    "$source" -o "${source%.png}.webp"
done
echo "Built 4 pixel-lossless seasonal tree assets."
