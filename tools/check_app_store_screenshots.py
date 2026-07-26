#!/usr/bin/env python3
"""Validate final App Store screenshots before upload."""

from __future__ import annotations

import argparse
from collections import Counter
from pathlib import Path

from PIL import Image
from PIL import ImageStat


SCREENSHOT_SIZES = {
    (1320, 2868): "iPhone 6.9-inch",
    (2868, 1320): "iPhone 6.9-inch",
    (2064, 2752): "iPad 13-inch",
    (2752, 2064): "iPad 13-inch",
}
SUPPORTED_SUFFIXES = {".jpg", ".jpeg", ".png"}


def suspicious_edge_bands(image: Image.Image) -> list[str]:
    """Catch orientation-buffer failures that leave a solid dark edge band."""
    rgb = image.convert("RGB")
    width, height = rgb.size
    band = max(8, min(width, height) // 80)
    regions = {
        "top": (0, 0, width, band),
        "bottom": (0, height - band, width, height),
        "left": (0, 0, band, height),
        "right": (width - band, 0, width, height),
    }
    suspicious: list[str] = []
    for name, box in regions.items():
        stats = ImageStat.Stat(rgb.crop(box))
        mean = sum(stats.mean) / 3
        spread = max(stats.stddev)
        if mean < 8 and spread < 5:
            suspicious.append(name)
    return suspicious


def screenshot_paths(inputs: list[Path]) -> list[Path]:
    paths: set[Path] = set()
    for item in inputs:
        if item.is_dir():
            paths.update(
                path
                for path in item.rglob("*")
                if path.is_file() and path.suffix.lower() in SUPPORTED_SUFFIXES
            )
        elif item.is_file() and item.suffix.lower() in SUPPORTED_SUFFIXES:
            paths.add(item)
        else:
            raise ValueError(f"not a supported screenshot file or directory: {item}")
    return sorted(paths)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Check screenshot dimensions, color mode, and release-set counts."
    )
    parser.add_argument(
        "paths",
        nargs="+",
        type=Path,
        help="PNG/JPEG files or directories containing final screenshots",
    )
    parser.add_argument(
        "--require-release-set",
        action="store_true",
        help="require 6-10 screenshots for both iPhone 6.9-inch and iPad 13-inch",
    )
    args = parser.parse_args()

    try:
        paths = screenshot_paths(args.paths)
    except ValueError as error:
        parser.error(str(error))
    if not paths:
        parser.error("no PNG/JPEG screenshots found")

    failures: list[str] = []
    counts: Counter[str] = Counter()
    for path in paths:
        try:
            with Image.open(path) as image:
                group = SCREENSHOT_SIZES.get(image.size)
                if group is None:
                    expected = ", ".join(
                        f"{width}x{height}"
                        for width, height in SCREENSHOT_SIZES
                    )
                    failures.append(
                        f"{path}: unsupported size {image.width}x{image.height}; "
                        f"expected one of {expected}"
                    )
                    continue
                if image.mode != "RGB":
                    failures.append(
                        f"{path}: color mode is {image.mode}; flatten to opaque RGB"
                    )
                    continue
                dark_bands = suspicious_edge_bands(image)
                if dark_bands:
                    failures.append(
                        f"{path}: solid dark band on {','.join(dark_bands)} edge; "
                        "check simulator orientation and screenshot buffer"
                    )
                    continue
                counts[group] += 1
        except OSError as error:
            failures.append(f"{path}: cannot decode image ({error})")

    if args.require_release_set:
        for group in sorted(set(SCREENSHOT_SIZES.values())):
            count = counts[group]
            if not 6 <= count <= 10:
                failures.append(
                    f"{group}: found {count} valid screenshots; expected 6-10"
                )

    if failures:
        print("FAIL: App Store screenshot audit")
        for failure in failures:
            print(f"- {failure}")
        return 1

    summary = ", ".join(f"{group}: {counts[group]}" for group in sorted(counts))
    print(f"PASS: {len(paths)} opaque RGB screenshots ({summary})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
