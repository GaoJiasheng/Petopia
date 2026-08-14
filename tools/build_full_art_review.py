#!/usr/bin/env python3
"""Build a complete, labeled human-review package from current raster assets."""

from __future__ import annotations

import argparse
import csv
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SPECIES = (
    "boo",
    "cat",
    "chameleon",
    "ember",
    "hamster",
    "parrot",
    "rabbit",
    "shiba",
    "snake",
    "starbug",
    "turtle",
    "uni",
)
CHECKER_LIGHT = (255, 253, 248)
CHECKER_DARK = (235, 226, 211)
PAPER = (249, 244, 234)
INK = (78, 61, 49)
BORDER = (207, 190, 166)


def font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = (
        Path("/System/Library/Fonts/Supplemental/Arial.ttf"),
        Path("/System/Library/Fonts/Helvetica.ttc"),
    )
    for candidate in candidates:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size=size)
    return ImageFont.load_default(size=size)


def checker(width: int, height: int, step: int = 24) -> Image.Image:
    image = Image.new("RGB", (width, height), CHECKER_LIGHT)
    draw = ImageDraw.Draw(image)
    for y in range(0, height, step):
        for x in range(0, width, step):
            if (x // step + y // step) % 2:
                draw.rectangle((x, y, x + step - 1, y + step - 1), fill=CHECKER_DARK)
    return image


def contain(source: Image.Image, width: int, height: int) -> Image.Image:
    image = source.convert("RGBA")
    image.thumbnail((width, height), Image.Resampling.LANCZOS)
    canvas = checker(width, height)
    canvas.paste(image, ((width - image.width) // 2, (height - image.height) // 2), image)
    return canvas


def review_tile(path: Path, label: str, width: int = 360, height: int = 410) -> Image.Image:
    art_height = height - 50
    with Image.open(path) as opened:
        art = contain(opened, width, art_height)
    tile = Image.new("RGB", (width, height), PAPER)
    tile.paste(art, (0, 0))
    draw = ImageDraw.Draw(tile)
    draw.rectangle((0, 0, width - 1, art_height - 1), outline=BORDER, width=2)
    draw.text((10, art_height + 12), label, fill=INK, font=font(18))
    return tile


def save_grid(
    tiles: list[Image.Image],
    output: Path,
    columns: int,
    gutter: int = 16,
) -> None:
    if not tiles:
        return
    rows = math.ceil(len(tiles) / columns)
    cell_width = max(tile.width for tile in tiles)
    cell_height = max(tile.height for tile in tiles)
    sheet = Image.new(
        "RGB",
        (
            gutter + columns * (cell_width + gutter),
            gutter + rows * (cell_height + gutter),
        ),
        PAPER,
    )
    for index, tile in enumerate(tiles):
        row, column = divmod(index, columns)
        x = gutter + column * (cell_width + gutter)
        y = gutter + row * (cell_height + gutter)
        sheet.paste(tile, (x, y))
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, optimize=True)


def split_strip(path: Path, frame_count: int = 8) -> list[Image.Image]:
    with Image.open(path) as opened:
        strip = opened.convert("RGBA")
    frame_width = strip.width // frame_count
    return [
        strip.crop((index * frame_width, 0, (index + 1) * frame_width, strip.height))
        for index in range(frame_count)
    ]


def strip_review(path: Path, label: str, frame_size: int = 150) -> Image.Image:
    frames = split_strip(path)
    label_width = 190
    row = Image.new("RGB", (label_width + 8 * frame_size, frame_size), PAPER)
    ImageDraw.Draw(row).text((12, 58), label, fill=INK, font=font(18))
    for index, frame in enumerate(frames):
        row.paste(contain(frame, frame_size, frame_size), (label_width + index * frame_size, 0))
    return row


def save_rows(rows: list[Image.Image], output: Path, gutter: int = 10) -> None:
    if not rows:
        return
    width = max(row.width for row in rows)
    height = gutter + sum(row.height + gutter for row in rows)
    sheet = Image.new("RGB", (width + 2 * gutter, height), PAPER)
    y = gutter
    for row in rows:
        sheet.paste(row, (gutter, y))
        y += row.height + gutter
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, optimize=True)


def build(output: Path) -> list[tuple[str, str, str]]:
    manifest: list[tuple[str, str, str]] = []

    pet_dir = output / "02-pets-all-species-colors-stages"
    for species in SPECIES:
        tiles: list[Image.Image] = []
        for variant in range(1, 6):
            for stage in "ABCD":
                path = (
                    ROOT
                    / f"assets/runtime/pets/{species}/pet_{species}_var{variant:02d}_stage{stage}.webp"
                )
                label = f"{species} / var{variant:02d} / stage {stage}"
                tile = review_tile(path, label)
                tiles.append(tile)
                individual = pet_dir / "individual" / species / f"var{variant:02d}-stage{stage}.png"
                individual.parent.mkdir(parents=True, exist_ok=True)
                tile.save(individual, optimize=True)
                manifest.append(("pet-static", label, str(path.relative_to(ROOT))))
        save_grid(tiles, pet_dir / "contact-sheets" / f"{species}.png", 4)

    action_dir = output / "03-pet-actions-all-frames"
    for species in SPECIES:
        rows: list[Image.Image] = []
        paths = sorted((ROOT / f"assets/art/pets/{species}/actions").glob("*.png"))
        for path in paths:
            label = path.stem.replace(f"pet_{species}_var01_stageC_", "")
            rows.append(strip_review(path, label))
            manifest.append(("pet-action", f"{species}/{label}", str(path.relative_to(ROOT))))
        save_rows(rows, action_dir / f"{species}.png")

    pose_dir = output / "07-postcard-pet-poses"
    for species in SPECIES:
        rows: list[Image.Image] = []
        for path in sorted((ROOT / "assets/art/postcards/poses").glob(f"pc_pose_{species}_*.png")):
            label = path.stem.replace(f"pc_pose_{species}_", "")
            rows.append(review_tile(path, label, width=300, height=350))
            manifest.append(("postcard-pose", f"{species}/{label}", str(path.relative_to(ROOT))))
        save_grid(rows, pose_dir / f"{species}.png", 4)

    visitor_dir = output / "04-yard-visitors" / "asset-review"
    visitor_bases = sorted((ROOT / "assets/art/world/visitors").glob("visitor_*_yard_base.png"))
    base_tiles: list[Image.Image] = []
    portrait_tiles: list[Image.Image] = []
    strip_rows: list[Image.Image] = []
    for base in visitor_bases:
        slug = base.stem.removeprefix("visitor_").removesuffix("_yard_base")
        portrait = base.with_name(f"visitor_{slug}_portrait.png")
        strip = base.with_name(f"visitor_{slug}_yard.png")
        base_tiles.append(review_tile(base, slug, width=300, height=350))
        portrait_tiles.append(review_tile(portrait, slug, width=300, height=350))
        strip_rows.append(strip_review(strip, slug, frame_size=130))
        manifest.extend(
            (
                ("visitor-yard", slug, str(base.relative_to(ROOT))),
                ("visitor-portrait", slug, str(portrait.relative_to(ROOT))),
                ("visitor-animation", slug, str(strip.relative_to(ROOT))),
            )
        )
    save_grid(base_tiles, visitor_dir / "all-yard-masters.png", 5)
    save_grid(portrait_tiles, visitor_dir / "all-portraits.png", 5)
    save_rows(strip_rows, visitor_dir / "all-animation-frames.png")

    revisit_dir = output / "05-returning-friends-all-species-colors"
    for species in SPECIES:
        tiles = []
        for variant in range(1, 6):
            path = ROOT / f"assets/runtime/pets/{species}/pet_{species}_var{variant:02d}_stageD.webp"
            label = f"{species} / returning var{variant:02d}"
            tiles.append(review_tile(path, label))
            manifest.append(("returning-friend", label, str(path.relative_to(ROOT))))
        save_grid(tiles, revisit_dir / f"{species}.png", 5)

    postcard_dir = output / "06-postcards" / "background-art-review"
    postcard_tiles: list[Image.Image] = []
    for path in sorted((ROOT / "assets/art/postcards/backgrounds").glob("*.jpg")):
        label = path.stem.removeprefix("pc_bg_")
        tile = review_tile(path, label, width=420, height=330)
        postcard_tiles.append(tile)
        individual = postcard_dir / "individual" / f"{label}.png"
        individual.parent.mkdir(parents=True, exist_ok=True)
        tile.save(individual, optimize=True)
        manifest.append(("postcard-background", label, str(path.relative_to(ROOT))))
    for index in range(0, len(postcard_tiles), 10):
        save_grid(
            postcard_tiles[index : index + 10],
            postcard_dir / f"backgrounds-{index + 1:02d}-{min(index + 10, len(postcard_tiles)):02d}.png",
            5,
        )

    return manifest


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    manifest = build(args.output)
    with (args.output / "asset-manifest.csv").open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(("domain", "review_label", "source_asset"))
        writer.writerows(manifest)
    print(f"Wrote {len(manifest)} review entries to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
