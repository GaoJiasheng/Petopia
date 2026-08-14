#!/usr/bin/env python3
"""Remove legacy visitor fragments and rebuild clean breathing strips."""

from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
VISITOR_DIR = ROOT / "assets/art/world/visitors"
SLUGS = ("firefly", "frog", "ghostpuff", "snowhare", "squirrel")
BOTTOM_CLEANUP = {
    "firefly": 230,
    "frog": 160,
    "squirrel": 155,
}
ALPHA_THRESHOLD = 16
SCALE_Y = (1.000, 1.004, 1.007, 1.004, 1.000, 0.997, 0.995, 0.997)
SHIFT_X = (0.000, 0.002, 0.003, 0.002, 0.000, -0.002, -0.003, -0.002)
SHIFT_Y = (0.000, -0.004, -0.006, -0.004, 0.000, 0.003, 0.004, 0.002)


def hard_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.point(lambda value: 255 if value >= ALPHA_THRESHOLD else 0).getbbox()
    if bbox is None:
        raise ValueError("empty visitor image")
    return bbox


def clean_master(slug: str, image: Image.Image) -> Image.Image:
    cutoff = BOTTOM_CLEANUP.get(slug)
    if cutoff is None:
        return image
    cleaned = image.copy()
    cleaned.paste((0, 0, 0, 0), (0, cutoff, image.width, image.height))
    return cleaned


def render_frame(master: Image.Image, index: int) -> Image.Image:
    width, height = master.size
    bbox = hard_bbox(master)
    subject = master.crop(bbox)
    current_fill = max(subject.width / width, subject.height / height)
    base_scale = max(1.0, 0.58 / current_fill)
    rendered = subject.resize(
        (
            max(1, round(subject.width * base_scale)),
            max(1, round(subject.height * base_scale * SCALE_Y[index])),
        ),
        Image.Resampling.LANCZOS,
    )
    center_x = (bbox[0] + bbox[2]) / 2 + SHIFT_X[index] * width
    center_y = (bbox[1] + bbox[3]) / 2 + SHIFT_Y[index] * height
    frame = Image.new("RGBA", master.size, (0, 0, 0, 0))
    frame.alpha_composite(
        rendered,
        (round(center_x - rendered.width / 2), round(center_y - rendered.height / 2)),
    )
    left, top, right, bottom = hard_bbox(frame)
    margins = (left, top, width - right, height - bottom)
    if min(margins) < round(min(width, height) * 0.05):
        raise ValueError(f"unsafe {index=} margins for visitor: {margins}")
    return frame


def rebuild(slug: str) -> None:
    base_path = VISITOR_DIR / f"visitor_{slug}_yard_base.png"
    strip_path = VISITOR_DIR / f"visitor_{slug}_yard.png"
    with Image.open(base_path) as opened:
        master = clean_master(slug, opened.convert("RGBA"))
    master.save(base_path, optimize=True)
    frames = [render_frame(master, index) for index in range(8)]
    strip = Image.new(
        "RGBA",
        (master.width * len(frames), master.height),
        (0, 0, 0, 0),
    )
    for index, frame in enumerate(frames):
        strip.alpha_composite(frame, (index * master.width, 0))
    strip.save(strip_path, optimize=True)


def main() -> int:
    for slug in SLUGS:
        rebuild(slug)
        print(slug)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
