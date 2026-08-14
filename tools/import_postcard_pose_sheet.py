#!/usr/bin/env python3
"""Import a chroma-key pose sheet as safe postcard PNGs."""

from __future__ import annotations

import argparse
from pathlib import Path

import cv2
import numpy as np
from PIL import Image


DEFAULT_POSES = ("eat", "gaze", "hat", "photo", "run", "sleep", "soak", "surprise")
OUTPUT_SPECIES = {"cham": "chameleon"}
CANVAS_SIZE = 400
MAX_SUBJECT_SIZE = 300
BASELINE = 350
ALPHA_THRESHOLD = 16


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    binary = alpha.point(lambda value: 255 if value >= ALPHA_THRESHOLD else 0)
    bbox = binary.getbbox()
    if bbox is None:
        raise ValueError("pose cell has no visible subject")
    return bbox


def import_pose(cell: Image.Image, destination: Path) -> tuple[int, int, int, int]:
    bbox = alpha_bbox(cell)
    if min(bbox[0], bbox[1], cell.width - bbox[2], cell.height - bbox[3]) < 3:
        raise ValueError(f"visible subject touches a source-cell edge: {bbox}")

    left = max(0, bbox[0] - 3)
    top = max(0, bbox[1] - 3)
    right = min(cell.width, bbox[2] + 3)
    bottom = min(cell.height, bbox[3] + 3)
    subject = cell.crop((left, top, right, bottom))

    scale = min(
        MAX_SUBJECT_SIZE / subject.width,
        MAX_SUBJECT_SIZE / subject.height,
        1.0,
    )
    target = (
        max(1, round(subject.width * scale)),
        max(1, round(subject.height * scale)),
    )
    if target != subject.size:
        subject = subject.resize(target, Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (CANVAS_SIZE, CANVAS_SIZE), (0, 0, 0, 0))
    x = (CANVAS_SIZE - subject.width) // 2
    y = min(BASELINE - subject.height, (CANVAS_SIZE - subject.height) // 2)
    y = max(40, y)
    canvas.alpha_composite(subject, (x, y))

    final_bbox = alpha_bbox(canvas)
    margins = (
        final_bbox[0],
        final_bbox[1],
        CANVAS_SIZE - final_bbox[2],
        CANVAS_SIZE - final_bbox[3],
    )
    if min(margins) < 40:
        raise ValueError(f"final pose has insufficient safety margin: {margins}")

    destination.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(destination, optimize=True)
    return margins


def extract_pose_layers(
    sheet: Image.Image,
    columns: int,
    rows: int,
) -> list[Image.Image]:
    """Assign complete connected components to their nearest grid cell.

    Image generation can let a tail, ear, or prop cross an invisible cell border.
    Component-based extraction keeps those parts intact instead of hard-cropping
    the source sheet at the border.
    """

    rgba = np.asarray(sheet)
    visible = (rgba[:, :, 3] >= ALPHA_THRESHOLD).astype(np.uint8)
    count, labels, stats, centroids = cv2.connectedComponentsWithStats(
        visible,
        connectivity=8,
    )
    groups: list[list[int]] = [[] for _ in range(columns * rows)]
    for label in range(1, count):
        area = int(stats[label, cv2.CC_STAT_AREA])
        if area < 8:
            continue
        center_x, center_y = centroids[label]
        column = min(columns - 1, int(center_x * columns / sheet.width))
        row = min(rows - 1, int(center_y * rows / sheet.height))
        groups[row * columns + column].append(label)

    layers: list[Image.Image] = []
    for index, group in enumerate(groups):
        if not group:
            raise ValueError(f"grid cell {index} has no visible components")
        group_mask = np.isin(labels, group)
        layer = np.zeros_like(rgba)
        layer[group_mask] = rgba[group_mask]
        layers.append(Image.fromarray(layer))
    return layers


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("species")
    parser.add_argument("sheet", type=Path)
    parser.add_argument("--columns", type=int, default=4)
    parser.add_argument("--rows", type=int, default=2)
    parser.add_argument(
        "--poses",
        default=",".join(DEFAULT_POSES),
        help="Comma-separated pose names in row-major order.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("assets/art/postcards/poses"),
    )
    args = parser.parse_args()

    poses = tuple(pose.strip() for pose in args.poses.split(",") if pose.strip())
    if len(poses) != args.columns * args.rows:
        raise ValueError(
            f"expected {args.columns * args.rows} poses for "
            f"{args.columns}x{args.rows}, got {len(poses)}"
        )

    sheet = Image.open(args.sheet).convert("RGBA")
    layers = extract_pose_layers(sheet, args.columns, args.rows)
    output_species = OUTPUT_SPECIES.get(args.species, args.species)
    for pose, cell in zip(poses, layers):
        destination = args.output_dir / f"pc_pose_{output_species}_{pose}.png"
        margins = import_pose(cell, destination)
        print(f"{destination}: margins={margins}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
