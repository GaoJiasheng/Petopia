#!/usr/bin/env python3
"""Build and validate the v1.1 hand-painted support gift animation strips."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import tempfile
from collections import deque
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ART_DIR = ROOT / "assets/art/support-open"
SOURCE_DIR = ART_DIR / "source"
QA_DIR = ROOT / "assets/art/qa/support-open"
FRAME_SIZE = 512
FRAME_COUNT = 8
SUBJECT_LONG_EDGE = 410
MIN_MARGIN = 51
ALPHA_THRESHOLD = 8


@dataclass(frozen=True)
class AssetSpec:
    slug: str
    source: Path
    static: Path
    matte: str

    @property
    def output(self) -> Path:
        return ART_DIR / f"support_open_{self.slug}.webp"


SPECS = (
    AssetSpec(
        slug="treat",
        source=SOURCE_DIR / "support_open_treat_source.png",
        static=ROOT / "assets/runtime/support/support_treat.webp",
        matte="alpha",
    ),
    AssetSpec(
        slug="lantern",
        source=SOURCE_DIR / "support_open_lantern_source.png",
        static=ROOT / "assets/runtime/support/support_lantern.webp",
        matte="checker_lantern",
    ),
    AssetSpec(
        slug="bouquet",
        source=SOURCE_DIR / "support_open_bouquet_source.png",
        static=ROOT / "assets/runtime/support/support_bouquet.webp",
        matte="checker",
    ),
)


def _remove_green_matte(image: Image.Image) -> Image.Image:
    """Turn the generated chroma matte into alpha without touching painted greens."""
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    rgb = rgba[:, :, :3]
    red = rgb[:, :, 0].astype(np.int16)
    green = rgb[:, :, 1].astype(np.int16)
    blue = rgb[:, :, 2].astype(np.int16)

    # The generated matte is a narrow cluster near vivid green. Painted leaves
    # are darker and contain materially more red/blue, so this deliberately
    # conservative key retains their watercolor edges.
    matte = (
        (green >= 205)
        & ((green - red) >= 105)
        & ((green - blue) >= 105)
        & (red <= 105)
        & (blue <= 105)
    )
    rgba[:, :, 3] = np.where(matte, 0, 255).astype(np.uint8)
    rgba[matte, :3] = 0
    return Image.fromarray(rgba, mode="RGBA")


def _remove_checker_matte(
    image: Image.Image, *, neutral_floor: int = 220, max_spread: int = 14
) -> Image.Image:
    """Remove the neutral preview checker while retaining cream paint and glow."""
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    rgb = rgba[:, :, :3].astype(np.int16)
    darkest = rgb.min(axis=2)
    spread = rgb.max(axis=2) - darkest
    matte = (darkest >= neutral_floor) & (spread <= max_spread)
    rgba[:, :, 3] = np.where(matte, 0, 255).astype(np.uint8)
    rgba[matte, :3] = 0
    return Image.fromarray(rgba, mode="RGBA")


def _remove_edge_fragments(image: Image.Image) -> Image.Image:
    """Drop small neighboring-frame components that touch a split gutter."""
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    visible = rgba[:, :, 3] > ALPHA_THRESHOLD
    total = int(visible.sum())
    visited = np.zeros(visible.shape, dtype=bool)
    seeds = np.argwhere(
        visible
        & np.pad(
            np.ones((visible.shape[0], 3), dtype=bool),
            ((0, 0), (0, visible.shape[1] - 3)),
        )
    )
    seeds = np.concatenate(
        (
            seeds,
            np.argwhere(
                visible
                & np.pad(
                    np.ones((visible.shape[0], 3), dtype=bool),
                    ((0, 0), (visible.shape[1] - 3, 0)),
                )
            ),
        )
    )
    for seed_y, seed_x in seeds:
        if visited[seed_y, seed_x]:
            continue
        queue = deque([(int(seed_y), int(seed_x))])
        visited[seed_y, seed_x] = True
        component: list[tuple[int, int]] = []
        while queue:
            y, x = queue.popleft()
            component.append((y, x))
            for next_y, next_x in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                if (
                    0 <= next_y < visible.shape[0]
                    and 0 <= next_x < visible.shape[1]
                    and visible[next_y, next_x]
                    and not visited[next_y, next_x]
                ):
                    visited[next_y, next_x] = True
                    queue.append((next_y, next_x))
        if len(component) < total * 0.18:
            ys, xs = zip(*component)
            rgba[np.asarray(ys), np.asarray(xs), :] = 0
    return Image.fromarray(rgba, mode="RGBA")


def _frame_boundaries(image: Image.Image) -> list[int]:
    """Find quiet gutters near the eight nominal cells instead of hard slicing."""
    alpha = np.asarray(image.getchannel("A"), dtype=np.uint8)
    projection = (alpha > ALPHA_THRESHOLD).sum(axis=0).astype(np.float64)
    projection = np.convolve(projection, np.ones(9) / 9, mode="same")
    width = image.width
    nominal_cell = width / FRAME_COUNT
    boundaries = [0]
    for index in range(1, FRAME_COUNT):
        nominal = round(index * nominal_cell)
        radius = round(nominal_cell * 0.23)
        start = max(boundaries[-1] + 32, nominal - radius)
        end = min(width - 32, nominal + radius)
        window = projection[start:end]
        minimum = window.min()
        candidates = np.flatnonzero(window <= minimum + 0.01) + start
        boundary = int(candidates[np.argmin(np.abs(candidates - nominal))])
        boundaries.append(boundary)
    boundaries.append(width)
    return boundaries


def _split_source(spec: AssetSpec) -> list[Image.Image]:
    source = Image.open(spec.source).convert("RGBA")
    if spec.matte == "chroma":
        source = _remove_green_matte(source)
    elif spec.matte == "checker":
        source = _remove_checker_matte(source)
    elif spec.matte == "checker_lantern":
        source = _remove_checker_matte(
            source, neutral_floor=160, max_spread=45
        )
    boundaries = _frame_boundaries(source)
    frames: list[Image.Image] = []
    for index in range(FRAME_COUNT):
        frames.append(
            _remove_edge_fragments(
                source.crop(
                    (boundaries[index], 0, boundaries[index + 1], source.height)
                )
            )
        )
    return frames


def _normalized_frame(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    alpha = rgba.getchannel("A")
    bbox = alpha.point(lambda value: 255 if value > ALPHA_THRESHOLD else 0).getbbox()
    if bbox is None:
        raise ValueError("frame has no visible painted pixels")
    subject = rgba.crop(bbox)
    scale = SUBJECT_LONG_EDGE / max(subject.size)
    size = (
        max(1, round(subject.width * scale)),
        max(1, round(subject.height * scale)),
    )
    subject = subject.resize(size, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (FRAME_SIZE, FRAME_SIZE), (0, 0, 0, 0))
    x = (FRAME_SIZE - subject.width) // 2
    y = FRAME_SIZE - MIN_MARGIN - subject.height
    canvas.alpha_composite(subject, (x, y))
    return canvas


def _build_frames(spec: AssetSpec) -> list[Image.Image]:
    generated = _split_source(spec)
    frames = [_normalized_frame(frame) for frame in generated[: FRAME_COUNT - 1]]
    # The final frame is mechanically derived from the shipped static artwork,
    # so the animation-to-static handoff is pixel-identical after normalization.
    frames.append(_normalized_frame(Image.open(spec.static).convert("RGBA")))
    return frames


def _save_lossless_webp(frames: list[Image.Image], output: Path) -> None:
    strip = Image.new(
        "RGBA", (FRAME_SIZE * FRAME_COUNT, FRAME_SIZE), (0, 0, 0, 0)
    )
    for index, frame in enumerate(frames):
        strip.alpha_composite(frame, (index * FRAME_SIZE, 0))
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="support-open-") as temporary:
        png = Path(temporary) / "strip.png"
        strip.save(png, optimize=True)
        subprocess.run(
            [
                shutil.which("cwebp") or "cwebp",
                "-quiet",
                "-lossless",
                "-exact",
                "-m",
                "6",
                str(png),
                "-o",
                str(output),
            ],
            check=True,
        )


def _checkerboard(size: tuple[int, int], tile: int = 24) -> Image.Image:
    image = Image.new("RGB", size, "#fffaf1")
    draw = ImageDraw.Draw(image)
    alternate = "#eadfce"
    for y in range(0, size[1], tile):
        for x in range(0, size[0], tile):
            if ((x // tile) + (y // tile)) % 2:
                draw.rectangle((x, y, x + tile - 1, y + tile - 1), fill=alternate)
    return image


def _save_contact_sheet(spec: AssetSpec, frames: list[Image.Image]) -> None:
    header = 52
    contact = _checkerboard((FRAME_SIZE * FRAME_COUNT, FRAME_SIZE + header))
    draw = ImageDraw.Draw(contact)
    font = ImageFont.load_default(size=22)
    for index, frame in enumerate(frames):
        x = index * FRAME_SIZE
        contact.paste(frame, (x, header), frame)
        draw.text(
            (x + 18, 14),
            f"{spec.slug}  frame {index + 1}",
            fill="#5f4d40",
            font=font,
        )
    contact.save(QA_DIR / f"support_open_{spec.slug}_contact.png", optimize=True)


def _save_frame_eight_compare(spec: AssetSpec, frame: Image.Image) -> None:
    expected = _normalized_frame(Image.open(spec.static).convert("RGBA"))
    width = FRAME_SIZE * 2
    header = 52
    compare = _checkerboard((width, FRAME_SIZE + header))
    compare.paste(frame, (0, header), frame)
    compare.paste(expected, (FRAME_SIZE, header), expected)
    draw = ImageDraw.Draw(compare)
    font = ImageFont.load_default(size=20)
    draw.text((18, 14), "animation frame 8", fill="#5f4d40", font=font)
    draw.text(
        (FRAME_SIZE + 18, 14), "normalized static", fill="#5f4d40", font=font
    )
    compare.save(
        QA_DIR / f"support_open_{spec.slug}_frame8_compare.png", optimize=True
    )


def _frame_metrics(frame: Image.Image) -> dict[str, object]:
    bbox = frame.getchannel("A").point(
        lambda value: 255 if value > ALPHA_THRESHOLD else 0
    ).getbbox()
    if bbox is None:
        raise ValueError("frame has no visible painted pixels")
    left, top, right, bottom = bbox
    width = right - left
    height = bottom - top
    return {
        "bbox": [left, top, right, bottom],
        "margins": [left, top, FRAME_SIZE - right, FRAME_SIZE - bottom],
        "long_edge": max(width, height),
        "long_edge_ratio": round(max(width, height) / FRAME_SIZE, 4),
    }


def _validate_asset(spec: AssetSpec) -> dict[str, object]:
    image = Image.open(spec.output).convert("RGBA")
    if image.size != (FRAME_SIZE * FRAME_COUNT, FRAME_SIZE):
        raise ValueError(f"{spec.output}: expected 4096x512, got {image.size}")
    alpha = image.getchannel("A")
    if alpha.getextrema() == (255, 255):
        raise ValueError(f"{spec.output}: missing transparent alpha")

    frames = [
        image.crop((index * FRAME_SIZE, 0, (index + 1) * FRAME_SIZE, FRAME_SIZE))
        for index in range(FRAME_COUNT)
    ]
    metrics = [_frame_metrics(frame) for frame in frames]
    for index, metric in enumerate(metrics, start=1):
        margins = metric["margins"]
        long_edge = metric["long_edge"]
        if min(margins) < MIN_MARGIN - 2:
            raise ValueError(
                f"{spec.slug} frame {index}: unsafe margin {margins}"
            )
        if not 399 <= long_edge <= 420:
            raise ValueError(
                f"{spec.slug} frame {index}: long edge {long_edge} outside 78-82%"
            )

    expected = np.asarray(
        _normalized_frame(Image.open(spec.static).convert("RGBA")), dtype=np.int16
    )
    actual = np.asarray(frames[-1], dtype=np.int16)
    frame_eight_delta = int(np.abs(expected - actual).max())
    if frame_eight_delta != 0:
        raise ValueError(
            f"{spec.slug} frame 8 differs from normalized static by {frame_eight_delta}"
        )

    info = subprocess.run(
        [shutil.which("webpinfo") or "webpinfo", str(spec.output)],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    if "Format: Lossless" not in info:
        raise ValueError(f"{spec.output}: WebP is not lossless")

    return {
        "asset": str(spec.output.relative_to(ROOT)),
        "size": list(image.size),
        "mode": image.mode,
        "lossless": True,
        "frame8_max_channel_delta": frame_eight_delta,
        "frames": metrics,
    }


def build() -> None:
    QA_DIR.mkdir(parents=True, exist_ok=True)
    for spec in SPECS:
        frames = _build_frames(spec)
        _save_lossless_webp(frames, spec.output)
        _save_contact_sheet(spec, frames)
        _save_frame_eight_compare(spec, frames[-1])


def validate() -> None:
    report = {"assets": [_validate_asset(spec) for spec in SPECS]}
    (QA_DIR / "support_open_validation.json").write_text(
        json.dumps(report, ensure_ascii=True, indent=2) + "\n",
        encoding="utf-8",
    )
    print("support-open assets: PASS")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--check", action="store_true", help="validate existing outputs without rebuilding"
    )
    args = parser.parse_args()
    if not args.check:
        build()
    validate()


if __name__ == "__main__":
    main()
