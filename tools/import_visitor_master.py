#!/usr/bin/env python3
"""Build complete visitor masters, portraits, and safe eight-frame strips."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE_DIR = ROOT / "tmp/imagegen/postcard-pose-redo/alpha"
DEFAULT_OUTPUT_DIR = ROOT / "assets/art/world/visitors"
FRAME_COUNT = 8
ALPHA_THRESHOLD = 16
BASE_SIZES = {
    "butterfly": 200,
    "rainbowshade": 300,
    "fox": 400,
    "emberlight": 200,
    "egret": 400,
    "deer": 400,
    "tanuki": 300,
}
SCALE = (1.000, 1.004, 1.007, 1.004, 1.000, 0.997, 0.995, 0.997)
SHIFT_X = (0.000, 0.002, 0.003, 0.002, 0.000, -0.002, -0.003, -0.002)
SHIFT_Y = (0.000, -0.004, -0.006, -0.004, 0.000, 0.003, 0.004, 0.002)
ANGLE = (0.0, 0.12, 0.18, 0.10, 0.0, -0.08, -0.14, -0.06)


def hard_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.point(lambda value: 255 if value >= ALPHA_THRESHOLD else 0).getbbox()
    if bbox is None:
        raise ValueError("visitor image has no visible subject")
    return bbox


def fit_subject(
    source: Image.Image,
    size: int,
    fill: float,
    baseline: float | None,
) -> Image.Image:
    bbox = hard_bbox(source)
    padding = max(4, round(max(bbox[2] - bbox[0], bbox[3] - bbox[1]) * 0.02))
    crop = source.crop(
        (
            max(0, bbox[0] - padding),
            max(0, bbox[1] - padding),
            min(source.width, bbox[2] + padding),
            min(source.height, bbox[3] + padding),
        )
    )
    scale = min(size * fill / crop.width, size * fill / crop.height)
    subject = crop.resize(
        (max(1, round(crop.width * scale)), max(1, round(crop.height * scale))),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    x = (size - subject.width) // 2
    if baseline is None:
        y = (size - subject.height) // 2
    else:
        y = round(size * baseline - subject.height)
    canvas.alpha_composite(subject, (x, y))
    assert_safe(canvas, "fitted visitor")
    return canvas


def animate(master: Image.Image, index: int) -> Image.Image:
    size = master.width
    bbox = hard_bbox(master)
    subject = master.crop(bbox)
    factor = SCALE[index]
    rendered = subject.resize(
        (
            max(1, round(subject.width * factor)),
            max(1, round(subject.height * factor)),
        ),
        Image.Resampling.LANCZOS,
    ).rotate(ANGLE[index], resample=Image.Resampling.BICUBIC, expand=True)
    center_x = (bbox[0] + bbox[2]) / 2 + SHIFT_X[index] * size
    center_y = (bbox[1] + bbox[3]) / 2 + SHIFT_Y[index] * size
    frame = Image.new("RGBA", master.size, (0, 0, 0, 0))
    frame.alpha_composite(
        rendered,
        (round(center_x - rendered.width / 2), round(center_y - rendered.height / 2)),
    )
    assert_safe(frame, f"animation frame {index}")
    return frame


def assert_safe(image: Image.Image, label: str) -> None:
    left, top, right, bottom = hard_bbox(image)
    width, height = image.size
    margins = (left, top, width - right, height - bottom)
    if min(margins[:3]) < round(min(width, height) * 0.10):
        raise ValueError(f"{label} has unsafe top/side margins: {margins}")
    if margins[3] < round(height * 0.05):
        raise ValueError(f"{label} has unsafe bottom margin: {margins}")


def build(slug: str, source_dir: Path, output_dir: Path) -> None:
    source_path = source_dir / f"{slug}_alpha.png"
    with Image.open(source_path) as opened:
        source = opened.convert("RGBA")
    source_bbox = hard_bbox(source)
    source_margins = (
        source_bbox[0],
        source_bbox[1],
        source.width - source_bbox[2],
        source.height - source_bbox[3],
    )
    if min(source_margins) < 8:
        raise ValueError(f"{slug} source touches the canvas edge: {source_margins}")

    base_size = BASE_SIZES[slug]
    base = fit_subject(source, base_size, fill=0.70, baseline=0.86)
    portrait = fit_subject(source, 400, fill=0.74, baseline=None)
    frames = [animate(base, index) for index in range(FRAME_COUNT)]
    strip = Image.new("RGBA", (base_size * FRAME_COUNT, base_size), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        strip.alpha_composite(frame, (index * base_size, 0))

    output_dir.mkdir(parents=True, exist_ok=True)
    base.save(output_dir / f"visitor_{slug}_yard_base.png", optimize=True)
    portrait.save(output_dir / f"visitor_{slug}_portrait.png", optimize=True)
    strip.save(output_dir / f"visitor_{slug}_yard.png", optimize=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("slugs", nargs="*")
    parser.add_argument("--source-dir", type=Path, default=DEFAULT_SOURCE_DIR)
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR)
    args = parser.parse_args()
    slugs = args.slugs or list(BASE_SIZES)
    for slug in slugs:
        if slug not in BASE_SIZES:
            raise ValueError(f"unknown visitor slug: {slug}")
        build(slug, args.source_dir, args.output_dir)
        print(slug)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
