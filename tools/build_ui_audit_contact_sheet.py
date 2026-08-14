#!/usr/bin/env python3
"""Build labeled contact sheets from full-resolution UI audit captures."""

from __future__ import annotations

import argparse
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def display_name(path: Path) -> str:
    stem = path.stem
    marker = "-ipad13-" if "-ipad13-" in stem else "-ipad11-"
    if marker not in stem:
        marker = "-iphone69-"
    return stem.split(marker, 1)[-1]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--columns", type=int, default=4)
    parser.add_argument("--pattern", default="*.png")
    args = parser.parse_args()

    paths = sorted(args.source.glob(args.pattern), key=lambda path: display_name(path))
    if not paths:
        parser.error(f"no PNG captures found in {args.source}")

    cell_width = 330
    image_height = 440
    label_height = 54
    gutter = 18
    columns = max(1, args.columns)
    rows = math.ceil(len(paths) / columns)
    sheet = Image.new(
        "RGB",
        (
            gutter + columns * (cell_width + gutter),
            gutter + rows * (image_height + label_height + gutter),
        ),
        (248, 244, 235),
    )
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default(size=18)

    for index, path in enumerate(paths):
        row, column = divmod(index, columns)
        cell_x = gutter + column * (cell_width + gutter)
        cell_y = gutter + row * (image_height + label_height + gutter)
        with Image.open(path) as source:
            image = source.convert("RGB")
            image.thumbnail((cell_width, image_height), Image.Resampling.LANCZOS)
            x = cell_x + (cell_width - image.width) // 2
            y = cell_y + (image_height - image.height) // 2
            sheet.paste(image, (x, y))
        draw.rounded_rectangle(
            (cell_x, cell_y, cell_x + cell_width, cell_y + image_height),
            radius=8,
            outline=(202, 187, 166),
            width=2,
        )
        label = display_name(path).replace("-", " ")
        draw.text(
            (cell_x + 6, cell_y + image_height + 10),
            label,
            fill=(79, 65, 56),
            font=font,
        )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(args.output, optimize=True)
    print(f"Wrote {len(paths)} captures to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
