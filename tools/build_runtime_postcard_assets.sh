#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POSE_SOURCE="$ROOT/assets/art/postcards/poses"
STICKER_SOURCE="$ROOT/assets/art/postcards/stickers"
BACKGROUND_SOURCE="$ROOT/assets/art/postcards/backgrounds"
POSE_RUNTIME="$ROOT/assets/runtime/postcards/poses"
STICKER_RUNTIME="$ROOT/assets/runtime/postcards/stickers"
BACKGROUND_RUNTIME="$ROOT/assets/runtime/postcards/backgrounds"

if ! command -v cwebp >/dev/null 2>&1; then
  echo "cwebp is required to build runtime postcard assets." >&2
  exit 1
fi

mkdir -p "$POSE_RUNTIME" "$STICKER_RUNTIME" "$BACKGROUND_RUNTIME"
find "$POSE_RUNTIME" "$STICKER_RUNTIME" \
  -maxdepth 1 -type f -name '*.webp' -delete
find "$BACKGROUND_RUNTIME" -maxdepth 1 -type f -name '*.webp' -delete

convert_lossless() {
  local source="$1"
  local output="$2"
  cwebp -quiet -lossless -z 9 -exact -mt -metadata none "$source" -o "$output"
}

for source in "$POSE_SOURCE"/*_gaze.png; do
  convert_lossless "$source" "$POSE_RUNTIME/$(basename "${source%.png}").webp"
done

for source in "$BACKGROUND_SOURCE"/pc_bg_*.jpg; do
  cwebp -quiet -q 95 -m 6 -mt -metadata none \
    "$source" \
    -o "$BACKGROUND_RUNTIME/$(basename "${source%.jpg}").webp"
done

event_stickers=(
  pc_sticker_heart_postmark
  pc_sticker_straw_hat
  pc_sticker_creased_map
  pc_sticker_drift_bottle
  pc_sticker_leaf_spring
  pc_sticker_wish_star
  pc_sticker_cloud_gap
  pc_sticker_gold_beam
  pc_sticker_warm_kettle
  pc_sticker_signed_leaf
)

for name in "${event_stickers[@]}"; do
  convert_lossless "$STICKER_SOURCE/$name.png" "$STICKER_RUNTIME/$name.webp"
done

for source in "$STICKER_SOURCE"/pc_sticker_traveler_*_var0[1-5]_back.png; do
  convert_lossless \
    "$source" \
    "$STICKER_RUNTIME/$(basename "${source%.png}").webp"
done

pose_count="$(find "$POSE_RUNTIME" -maxdepth 1 -name '*.webp' | wc -l | tr -d ' ')"
sticker_count="$(find "$STICKER_RUNTIME" -maxdepth 1 -name '*.webp' | wc -l | tr -d ' ')"
background_count="$(
  find "$BACKGROUND_RUNTIME" -maxdepth 1 -name '*.webp' | wc -l | tr -d ' '
)"
if [[ "$pose_count" != "12" || "$sticker_count" != "70" || "$background_count" != "40" ]]; then
  echo "Unexpected runtime asset count: poses=$pose_count stickers=$sticker_count backgrounds=$background_count" >&2
  exit 1
fi

echo "Built $pose_count poses, $sticker_count stickers, and $background_count backgrounds."
