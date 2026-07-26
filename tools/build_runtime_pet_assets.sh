#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PET_RUNTIME="$ROOT/assets/runtime/pets"

if ! command -v cwebp >/dev/null 2>&1; then
  echo "cwebp is required to build runtime pet assets." >&2
  exit 1
fi

convert_lossless() {
  local source="$1"
  local output="${source%.png}.webp"
  cwebp -quiet -lossless -z 9 -exact -mt -metadata none "$source" -o "$output"
}

count=0
while IFS= read -r source; do
  convert_lossless "$source"
  count=$((count + 1))
done < <(
  find "$PET_RUNTIME" -mindepth 2 -maxdepth 3 \
    -type f \( -name 'pet_*_stage?.png' -o -path '*/actions/*.png' \) \
    -print | sort
)

if [[ "$count" != "288" ]]; then
  echo "Unexpected pet source count: $count (expected 288)." >&2
  exit 1
fi

webp_count="$(
  find "$PET_RUNTIME" -mindepth 2 -maxdepth 3 \
    -type f \( -name 'pet_*_stage?.webp' -o -path '*/actions/*.webp' \) |
    wc -l | tr -d ' '
)"
if [[ "$webp_count" != "288" ]]; then
  echo "Unexpected pet WebP count: $webp_count (expected 288)." >&2
  exit 1
fi

echo "Built $webp_count pixel-lossless pet WebP assets."
