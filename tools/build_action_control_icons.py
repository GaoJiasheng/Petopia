#!/usr/bin/env python3
"""Build the four hand-painted care-bar icons from project-owned masters."""

from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
CANVAS_SIZE = 96
ALPHA_THRESHOLD = 8
BATH_CHROMA = (
    ROOT
    / "assets/art/qa/chroma_sources/action_control_refresh_20260822"
    / "bath_basin_chroma.png"
)
BATH_MASTER = ROOT / "assets/art/source/action_controls/action_bath_master.png"

ICON_SPECS = (
    (
        ROOT / "assets/art/pets/action_props/pet_action_prop_feed.png",
        ROOT / "assets/art/ui/ui_icon_act_feed.png",
        (84, 68),
    ),
    (
        ROOT / "assets/art/pets/action_props/pet_action_prop_pat.png",
        ROOT / "assets/art/ui/ui_icon_act_pat.png",
        (84, 68),
    ),
    (
        ROOT / "assets/art/pets/action_props/pet_action_prop_play.png",
        ROOT / "assets/art/ui/ui_icon_act_toy.png",
        (84, 76),
    ),
    (
        BATH_MASTER,
        ROOT / "assets/art/ui/ui_icon_act_bath.png",
        (86, 78),
    ),
)


def _remove_green_matte(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.float32).copy()
    red, green, blue = (rgba[:, :, index] for index in range(3))
    dominance = green - np.maximum(red, blue)
    green_strength = np.clip((dominance - 38) / 150, 0, 1)
    brightness_strength = np.clip((green - 155) / 90, 0, 1)
    matte_strength = green_strength * brightness_strength
    alpha = 1 - matte_strength

    # Recover edge color from the green composite so pale cream and aqua
    # watercolor stay clean after downsampling.
    recoverable = alpha > 0.04
    background = np.zeros_like(rgba[:, :, :3])
    background[:, :, 1] = 255
    recovered = rgba[:, :, :3].copy()
    recovered[recoverable] = (
        rgba[:, :, :3][recoverable]
        - (1 - alpha[recoverable, None]) * background[recoverable]
    ) / alpha[recoverable, None]
    rgba[:, :, :3] = np.clip(recovered, 0, 255)
    rgba[:, :, 3] = np.where(alpha < 0.02, 0, alpha * 255)
    # The generator can leave a handful of colored single pixels at the canvas
    # perimeter. The subject was authored with a 14% safe area, so clearing a
    # narrow outer strip cannot touch the illustration and prevents those
    # fragments from shrinking the fitted icon.
    border = round(min(image.size) * 0.06)
    rgba[:border, :, 3] = 0
    rgba[-border:, :, 3] = 0
    rgba[:, :border, 3] = 0
    rgba[:, -border:, 3] = 0
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba.astype(np.uint8), mode="RGBA")


def _visible_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.point(lambda value: 255 if value >= ALPHA_THRESHOLD else 0).getbbox()
    if bbox is None:
        raise ValueError("asset has no visible subject")
    return bbox


def _fit_subject(
    source: Image.Image,
    *,
    canvas_size: int,
    max_size: tuple[int, int],
) -> Image.Image:
    bbox = _visible_bbox(source)
    padding = max(2, round(max(source.size) * 0.006))
    crop = source.crop(
        (
            max(0, bbox[0] - padding),
            max(0, bbox[1] - padding),
            min(source.width, bbox[2] + padding),
            min(source.height, bbox[3] + padding),
        )
    )
    scale = min(max_size[0] / crop.width, max_size[1] / crop.height)
    target = (
        max(1, round(crop.width * scale)),
        max(1, round(crop.height * scale)),
    )
    crop = crop.resize(target, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    canvas.alpha_composite(
        crop,
        ((canvas_size - crop.width) // 2, (canvas_size - crop.height) // 2),
    )
    return canvas


def main() -> int:
    bath = _remove_green_matte(Image.open(BATH_CHROMA))
    BATH_MASTER.parent.mkdir(parents=True, exist_ok=True)
    _fit_subject(bath, canvas_size=512, max_size=(430, 390)).save(
        BATH_MASTER,
        optimize=True,
    )

    for source_path, output_path, max_size in ICON_SPECS:
        icon = _fit_subject(
            Image.open(source_path).convert("RGBA"),
            canvas_size=CANVAS_SIZE,
            max_size=max_size,
        )
        output_path.parent.mkdir(parents=True, exist_ok=True)
        icon.save(output_path, optimize=True)
        print(f"Wrote {output_path.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
