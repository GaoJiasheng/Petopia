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


def _profile_for(label: str) -> tuple[float, float, float, float]:
    """Returns min fill, max fill, hard margin, soft bottom margin."""
    if "/actions/" in label:
        return (0.74, 0.82, 0.08, 0.08)
    if "assets/runtime/pets/" in label:
        return (0.68, 0.82, 0.08, 0.08)
    if "assets/runtime/postcards/poses/" in label:
        return (0.62, 0.75, 0.10, 0.10)
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
        "assets/art/world/visitors/*_yard.png",
        "assets/art/world/visitors/*_portrait.png",
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


def main() -> int:
    cutouts = _cutout_paths()
    frames = sum(_audit_cutout(path) for path in cutouts)
    icons = _audit_icons()

    if FAILURES:
        print(f"FAIL: {len(FAILURES)} runtime art issue(s)")
        for failure in FAILURES:
            print(f"  - {failure}")
        return 1

    print(
        f"PASS: {len(cutouts)} cutout files / {frames} frames and "
        f"{icons} opaque app icons"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
