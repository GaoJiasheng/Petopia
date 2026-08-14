#!/usr/bin/env python3
"""Release-facing raster audit for every cutout that can appear in the app."""

from __future__ import annotations

import json
import math
from pathlib import Path
from typing import Iterable

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
ALPHA_THRESHOLD = 48
SOFT_ALPHA_THRESHOLD = 8
FAILURES: list[str] = []
AVIAN_VISITORS = ("sparrow", "pigeon", "crow", "egret", "owl")
MIN_VISITOR_SILHOUETTE_IOU = 0.90
MIN_AVIAN_SILHOUETTE_IOU = 0.93
DECOR_FOOTER_GUARDS = (
    "deco_flowerbox_wild.png",
    "deco_mushroom_stool.png",
)


def _profile_for(label: str) -> tuple[float, float, float, float]:
    """Returns min fill, max fill, hard margin, soft bottom margin."""
    if "pets/action_props/" in label:
        return (0.75, 0.91, 0.05, 0.08)
    if "postcards/weather/" in label:
        return (0.78, 0.88, 0.07, 0.07)
    if label.endswith(("deco_scarecrow_postman.png", "deco_star_vane.png")):
        return (0.52, 0.82, 0.05, 0.08)
    if "/actions/" in label:
        return (0.74, 0.82, 0.08, 0.08)
    if "assets/runtime/pets/" in label:
        return (0.68, 0.82, 0.08, 0.08)
    if "postcards/poses/" in label:
        return (0.62, 0.75, 0.10, 0.10)
    if label.endswith("_yard_base.png"):
        return (0.50, 0.78, 0.10, 0.04)
    if label.endswith("_yard.png") or "_yard.png#" in label:
        return (0.56, 0.78, 0.10, 0.04)
    if label.endswith("_portrait.png"):
        return (0.60, 0.74, 0.12, 0.10)
    return (0.0, 1.0, 0.0, 0.0)


def _threshold_bbox(alpha: Image.Image, threshold: int) -> tuple[int, int, int, int] | None:
    return alpha.point(lambda value: 255 if value >= threshold else 0).getbbox()


def _longest_run(values: Iterable[int]) -> int:
    longest = current = 0
    for value in values:
        if value >= ALPHA_THRESHOLD:
            current += 1
            longest = max(longest, current)
        else:
            current = 0
    return longest


def _frame_failures(image: Image.Image, label: str) -> None:
    rgba = image.convert("RGBA")
    alpha = rgba.getchannel("A")
    bbox = _threshold_bbox(alpha, ALPHA_THRESHOLD)
    if bbox is None:
        FAILURES.append(f"{label}: empty transparent frame")
        return

    width, height = rgba.size
    min_fill, max_fill, min_margin, min_soft_bottom = _profile_for(label)
    fill = max(bbox[2] - bbox[0], bbox[3] - bbox[1]) / max(width, height)
    hard_margin = min(bbox[0], bbox[1], width - bbox[2]) / min(width, height)
    if not min_fill <= fill <= max_fill:
        FAILURES.append(
            f"{label}: subject fill {fill:.3f} outside "
            f"{min_fill:.2f}-{max_fill:.2f}"
        )
    if hard_margin < min_margin:
        FAILURES.append(
            f"{label}: top/side margin {hard_margin:.3f} below {min_margin:.2f}"
        )
    soft_bbox = _threshold_bbox(alpha, SOFT_ALPHA_THRESHOLD)
    if soft_bbox is not None:
        soft_bottom = (height - soft_bbox[3]) / height
        if soft_bottom < min_soft_bottom:
            FAILURES.append(
                f"{label}: soft shadow bottom margin {soft_bottom:.3f} "
                f"below {min_soft_bottom:.2f}"
            )

    pixels = alpha.load()
    threshold = max(8, int(min(width, height) * 0.015))
    edges = {
        "top": _longest_run(pixels[x, 0] for x in range(width)),
        "left": _longest_run(pixels[0, y] for y in range(height)),
        "right": _longest_run(pixels[width - 1, y] for y in range(height)),
    }
    clipped = [name for name, run in edges.items() if run >= threshold]
    if clipped:
        FAILURES.append(
            f"{label}: opaque subject reaches {','.join(clipped)} edge "
            f"(run={max(edges[name] for name in clipped)}px)"
        )

    is_postcard_pose = "postcards/poses/" in label
    is_visitor_master = label.endswith("_yard_base.png")
    if is_postcard_pose or is_visitor_master:
        bbox_width = bbox[2] - bbox[0]
        bbox_height = bbox[3] - bbox[1]
        bbox_edges = {
            "top": _longest_run(
                pixels[x, bbox[1]] for x in range(bbox[0], bbox[2])
            ),
            "left": _longest_run(
                pixels[bbox[0], y] for y in range(bbox[1], bbox[3])
            ),
            "right": _longest_run(
                pixels[bbox[2] - 1, y] for y in range(bbox[1], bbox[3])
            ),
        }
        suspicious = [
            name
            for name, run in bbox_edges.items()
            if run
            >= max(
                18,
                round(
                    (bbox_width if name == "top" else bbox_height)
                    * (0.30 if is_postcard_pose else 0.35)
                ),
            )
        ]
        if suspicious:
            FAILURES.append(
                f"{label}: subject silhouette has a suspicious straight "
                f"{','.join(suspicious)} cut"
            )

    is_new_rendered_ui = (
        "pets/action_props/" in label or "postcards/weather/" in label
    )
    if is_postcard_pose or is_new_rendered_ui:
        colors = {
            (red // 8, green // 8, blue // 8)
            for red, green, blue, alpha_value in rgba.getdata()
            if alpha_value >= ALPHA_THRESHOLD
        }
        if len(colors) < 80:
            FAILURES.append(
                f"{label}: only {len(colors)} quantized colors; "
                "possible flat geometric placeholder"
            )


def _audit_cutout(path: Path) -> int:
    with Image.open(path) as source:
        image = source.convert("RGBA")
        width, height = image.size
        if width >= height * 2 and width % height == 0:
            frame_count = width // height
            for index in range(frame_count):
                frame = image.crop((index * height, 0, (index + 1) * height, height))
                _frame_failures(frame, f"{path.relative_to(ROOT)}#{index}")
            return frame_count
        _frame_failures(image, str(path.relative_to(ROOT)))
        return 1


def _cutout_paths() -> list[Path]:
    patterns = (
        "assets/runtime/pets/*/pet_*_stage?.webp",
        "assets/runtime/pets/*/actions/*.webp",
        "assets/runtime/postcards/poses/*.webp",
        "assets/art/postcards/poses/*.png",
        "assets/art/postcards/weather/*.png",
        "assets/art/pets/action_props/*.png",
        "assets/art/world/visitors/*_yard.png",
        "assets/art/world/visitors/*_yard_base.png",
        "assets/art/world/visitors/*_portrait.png",
        "assets/art/world/decor/deco_scarecrow_postman.png",
        "assets/art/world/decor/deco_star_vane.png",
    )
    paths: set[Path] = set()
    for pattern in patterns:
        paths.update(ROOT.glob(pattern))
    return sorted(paths)


def _audit_icons() -> int:
    icon_dir = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    contents = json.loads((icon_dir / "Contents.json").read_text())
    checked = 0
    for item in contents["images"]:
        filename = item.get("filename")
        if not filename:
            continue
        path = icon_dir / filename
        if not path.exists():
            FAILURES.append(f"missing app icon: {path.relative_to(ROOT)}")
            continue
        logical = float(item["size"].split("x", 1)[0])
        scale = float(item["scale"].removesuffix("x"))
        expected = int(math.ceil(logical * scale))
        with Image.open(path) as image:
            if image.size != (expected, expected):
                FAILURES.append(
                    f"{path.relative_to(ROOT)}: {image.size}, expected {expected}x{expected}"
                )
            if "A" in image.getbands() or "transparency" in image.info:
                FAILURES.append(f"{path.relative_to(ROOT)}: app icon has transparency")
        checked += 1
    return checked


def _audit_decor_footer_fragments() -> int:
    """Reject separated footer bands left behind by generated decor sheets."""
    decor_dir = ROOT / "assets/art/world/decor"
    checked = 0
    for filename in DECOR_FOOTER_GUARDS:
        path = decor_dir / filename
        with Image.open(path) as opened:
            alpha = opened.convert("RGBA").getchannel("A")
        occupied = [
            any(
                value >= ALPHA_THRESHOLD
                for value in alpha.crop((0, y, alpha.width, y + 1)).getdata()
            )
            for y in range(alpha.height)
        ]
        bands: list[tuple[int, int]] = []
        start: int | None = None
        for y, has_art in enumerate((*occupied, False)):
            if has_art and start is None:
                start = y
            elif not has_art and start is not None:
                bands.append((start, y))
                start = None
        if len(bands) != 1:
            FAILURES.append(
                f"{path.relative_to(ROOT)}: detached vertical art bands {bands}; "
                "possible footer fragment"
            )
        checked += 1
    return checked


def _normalized_alpha_mask(image: Image.Image) -> Image.Image:
    alpha = image.convert("RGBA").getchannel("A")
    mask = alpha.point(lambda value: 255 if value >= ALPHA_THRESHOLD else 0)
    bbox = mask.getbbox()
    if bbox is None:
        return Image.new("L", (128, 128), 0)
    return mask.crop(bbox).resize((128, 128), Image.Resampling.NEAREST)


def _mask_iou(first: Image.Image, second: Image.Image) -> float:
    first_pixels = first.getdata()
    second_pixels = second.getdata()
    intersection = 0
    union = 0
    for left, right in zip(first_pixels, second_pixels):
        left_on = left > 0
        right_on = right > 0
        if left_on and right_on:
            intersection += 1
        if left_on or right_on:
            union += 1
    return intersection / union if union else 0.0


def _audit_visitor_fidelity() -> int:
    checked = 0
    visitor_dir = ROOT / "assets/art/world/visitors"
    for base_path in sorted(visitor_dir.glob("visitor_*_yard_base.png")):
        slug = base_path.stem.removeprefix("visitor_").removesuffix("_yard_base")
        strip_path = visitor_dir / f"visitor_{slug}_yard.png"
        with Image.open(base_path) as opened:
            reference = _normalized_alpha_mask(opened)
        with Image.open(strip_path) as opened:
            strip = opened.convert("RGBA")
        frame_width = strip.width // 8
        for index in range(8):
            frame = strip.crop(
                (index * frame_width, 0, (index + 1) * frame_width, strip.height)
            )
            similarity = _mask_iou(reference, _normalized_alpha_mask(frame))
            threshold = (
                MIN_AVIAN_SILHOUETTE_IOU
                if slug in AVIAN_VISITORS
                else MIN_VISITOR_SILHOUETTE_IOU
            )
            if similarity < threshold:
                FAILURES.append(
                    f"{strip_path.relative_to(ROOT)}#{index}: normalized silhouette "
                    f"IoU {similarity:.3f} below {threshold:.2f}; "
                    "anatomy may be cropped or covered by a placeholder layer"
                )
            checked += 1
    return checked


def main() -> int:
    cutouts = _cutout_paths()
    frames = sum(_audit_cutout(path) for path in cutouts)
    visitor_frames = _audit_visitor_fidelity()
    decor_guards = _audit_decor_footer_fragments()
    icons = _audit_icons()

    if FAILURES:
        print(f"FAIL: {len(FAILURES)} runtime art issue(s)")
        for failure in FAILURES:
            print(f"  - {failure}")
        return 1

    print(
        f"PASS: {len(cutouts)} cutout files / {frames} frames and "
        f"{icons} opaque app icons; {visitor_frames} visitor frames match "
        f"their complete masters; {decor_guards} decor footer guards pass"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
