#!/usr/bin/env python3
"""Rebuild avian visitor strips from their complete, approved yard masters.

The masters are the anatomy source of truth. Each output keeps the full bird
inside the original square canvas and adds only a restrained breathing/bobbing
cycle, so animation derivation cannot crop a head, beak, crest, wing, or feet.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
VISITOR_DIR = ROOT / "assets/art/world/visitors"
AVIAN_SLUGS = ("sparrow", "pigeon", "crow", "egret", "owl")
FRAME_COUNT = 8
ALPHA_THRESHOLD = 24
MIN_MARGIN = 0.12
TARGET_FILL = 0.64

# A slow closed cycle. Values are fractions of the source canvas so the same
# motion reads consistently on 200 px and 400 px visitor masters.
SCALE_Y = (1.000, 1.004, 1.008, 1.004, 1.000, 0.996, 0.998, 1.000)
SHIFT_X = (0.000, 0.002, 0.003, 0.002, 0.000, -0.002, -0.003, -0.002)
SHIFT_Y = (0.000, -0.003, -0.005, -0.003, 0.000, 0.002, 0.003, 0.002)
ANGLE = (0.00, 0.10, 0.16, 0.10, 0.00, -0.08, -0.12, -0.06)


def _hard_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.point(lambda value: 255 if value >= ALPHA_THRESHOLD else 0).getbbox()
    if bbox is None:
        raise ValueError("empty visitor master")
    return bbox


def _render_frame(source: Image.Image, index: int) -> Image.Image:
    width, height = source.size
    bbox = _hard_bbox(source)
    padding = max(4, round(min(width, height) * 0.025))
    crop_box = (
        max(0, bbox[0] - padding),
        max(0, bbox[1] - padding),
        min(width, bbox[2] + padding),
        min(height, bbox[3] + padding),
    )
    subject = source.crop(crop_box)

    bbox_width = bbox[2] - bbox[0]
    bbox_height = bbox[3] - bbox[1]
    current_fill = max(bbox_width, bbox_height) / max(width, height)
    base_scale = max(1.0, TARGET_FILL / current_fill)
    scale_y = SCALE_Y[index]
    rendered = subject.resize(
        (
            max(1, round(subject.width * base_scale)),
            max(1, round(subject.height * base_scale * scale_y)),
        ),
        Image.Resampling.LANCZOS,
    )
    rendered = rendered.rotate(
        ANGLE[index],
        resample=Image.Resampling.BICUBIC,
        expand=True,
    )

    center_x = (crop_box[0] + crop_box[2]) / 2
    center_y = (crop_box[1] + crop_box[3]) / 2
    center_x += SHIFT_X[index] * width
    center_y += SHIFT_Y[index] * height
    x = round(center_x - rendered.width / 2)
    y = round(center_y - rendered.height / 2)

    frame = Image.new("RGBA", source.size, (0, 0, 0, 0))
    frame.alpha_composite(rendered, (x, y))
    return frame


def _assert_safe(frame: Image.Image, label: str) -> None:
    left, top, right, bottom = _hard_bbox(frame)
    width, height = frame.size
    side_top_margin = min(left, top, width - right) / min(width, height)
    bottom_margin = (height - bottom) / height
    if side_top_margin < MIN_MARGIN:
        raise ValueError(
            f"{label}: top/side margin {side_top_margin:.3f} below {MIN_MARGIN:.2f}"
        )
    if bottom_margin < 0.04:
        raise ValueError(f"{label}: bottom margin {bottom_margin:.3f} below 0.04")


def rebuild(slug: str) -> Path:
    master_path = VISITOR_DIR / f"visitor_{slug}_yard_base.png"
    output_path = VISITOR_DIR / f"visitor_{slug}_yard.png"
    with Image.open(master_path) as opened:
        source = opened.convert("RGBA")
    frames = [_render_frame(source, index) for index in range(FRAME_COUNT)]
    for index, frame in enumerate(frames):
        _assert_safe(frame, f"{slug} frame {index}")

    strip = Image.new(
        "RGBA",
        (source.width * FRAME_COUNT, source.height),
        (0, 0, 0, 0),
    )
    for index, frame in enumerate(frames):
        strip.alpha_composite(frame, (index * source.width, 0))
    strip.save(output_path, optimize=True)
    return output_path


def main() -> int:
    for slug in AVIAN_SLUGS:
        output = rebuild(slug)
        print(output.relative_to(ROOT))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
