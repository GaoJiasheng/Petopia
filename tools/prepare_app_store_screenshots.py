#!/usr/bin/env python3
"""Prepare the reviewed English App Store screenshot release set."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


SCENES = (
    ("01-garden", "yard"),
    ("02-letters-after-graduation", "onboarding-3"),
    ("03-graduation", "graduation"),
    ("04-postcard", "postcard"),
    ("05-postcard-album", "album-postcards"),
    ("06-pet-compendium", "pet-compendium"),
    ("07-visitor-compendium", "visitor-compendium"),
)

DEVICES = (
    ("iphone-6.9", (1320, 2868)),
    ("ipad-13", (2064, 2752)),
)


def prepare_device(
    source_dir: Path,
    prefix: str,
    output_dir: Path,
    expected_size: tuple[int, int],
) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    for output_name, scene in SCENES:
        source = source_dir / f"{prefix}-{scene}.png"
        if not source.is_file():
            raise FileNotFoundError(f"missing captured scene: {source}")

        with Image.open(source) as image:
            if image.size != expected_size:
                raise ValueError(
                    f"{source}: found {image.size}, expected {expected_size}"
                )
            rgb = image.convert("RGB")
            rgb.save(output_dir / f"{output_name}.png", optimize=True)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Convert reviewed simulator captures into a release screenshot set."
    )
    parser.add_argument(
        "--source-dir",
        type=Path,
        default=Path("/tmp"),
        help="directory containing integration-test captures",
    )
    parser.add_argument(
        "--iphone-source-dir",
        type=Path,
        help="optional iPhone capture directory; defaults to --source-dir",
    )
    parser.add_argument(
        "--ipad-source-dir",
        type=Path,
        help="optional iPad capture directory; defaults to --source-dir",
    )
    parser.add_argument(
        "--iphone-prefix",
        default="petopia-store-en-iphone69",
        help="filename prefix for iPhone captures",
    )
    parser.add_argument(
        "--ipad-prefix",
        default="petopia-store-en-ipad13",
        help="filename prefix for iPad captures",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("docs/app-store/screenshots/release/en-US"),
        help="release-set output directory",
    )
    args = parser.parse_args()

    sources = (
        args.iphone_source_dir or args.source_dir,
        args.ipad_source_dir or args.source_dir,
    )
    prefixes = (args.iphone_prefix, args.ipad_prefix)
    for (device, expected_size), prefix, source_dir in zip(
        DEVICES, prefixes, sources
    ):
        prepare_device(
            source_dir=source_dir,
            prefix=prefix,
            output_dir=args.output / device,
            expected_size=expected_size,
        )

    print(f"Prepared {len(SCENES)} screenshots for each device in {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
