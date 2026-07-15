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
FAILURES: list[str] = []


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
    bbox = alpha.getbbox()
    if bbox is None:
        FAILURES.append(f"{label}: empty transparent frame")
        return

    width, height = rgba.size
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
        "assets/runtime/pets/*/pet_*_stage?.png",
        "assets/runtime/pets/*/actions/*.png",
        "assets/art/world/visitors/*_yard.png",
        "assets/art/world/visitors/*_portrait.png",
        "assets/art/postcards/poses/*.png",
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

