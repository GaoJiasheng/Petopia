#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
master_dir="$root/assets/art/world/exports_1290/themes"
output_dir="$root/assets/art/world/themes"
wide_master_dir="$root/assets/art/world/themes/wide"
wide_output_dir="$root/assets/runtime/yard/themes/wide"

if ! command -v cwebp >/dev/null 2>&1; then
  echo "cwebp is required to build runtime yard themes." >&2
  exit 1
fi

slugs=(
  autumnjam
  bambootea
  candybake
  fourseasons
  meadow
  moongreen
  mossrain
  sakura
  seaside
  snowhut
  starcamp
  wheatkite
)

mkdir -p "$wide_output_dir"

for slug in "${slugs[@]}"; do
  master="$master_dir/yard_theme_${slug}_bg_1290x2796.png"
  output="$output_dir/yard_theme_${slug}_bg.webp"
  if [[ ! -f "$master" ]]; then
    echo "Missing yard theme master: $master" >&2
    exit 1
  fi
  cwebp -quiet -q 90 -m 6 -mt "$master" -o "$output"

  wide_master="$wide_master_dir/yard_theme_${slug}_bg_wide.jpg"
  wide_output="$wide_output_dir/yard_theme_${slug}_bg_wide.webp"
  if [[ ! -f "$wide_master" ]]; then
    echo "Missing wide yard theme master: $wide_master" >&2
    exit 1
  fi
  cwebp -quiet -q 95 -m 6 -mt -metadata none \
    "$wide_master" -o "$wide_output"
done

echo "Built ${#slugs[@]} portrait and wide runtime yard themes."
