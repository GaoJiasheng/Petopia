#!/usr/bin/env python3
"""Build or verify the deterministic manifest of assets bundled by Flutter."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets/provenance/release_asset_manifest.json"
SUPPORTED_SUFFIXES = {
    ".json",
    ".m4a",
    ".png",
    ".wav",
    ".webp",
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def declared_assets() -> list[Path]:
    pubspec = (ROOT / "pubspec.yaml").read_text()
    declarations = re.findall(r"^\s{4}-\s+(assets/\S+)\s*$", pubspec, re.M)
    paths: set[Path] = set()
    for declaration in declarations:
        candidate = ROOT / declaration
        if candidate.is_dir():
            paths.update(
                path
                for path in candidate.rglob("*")
                if path.is_file() and path.suffix.lower() in SUPPORTED_SUFFIXES
            )
        elif candidate.is_file() and candidate.suffix.lower() in SUPPORTED_SUFFIXES:
            paths.add(candidate)
    return sorted(paths, key=lambda path: path.relative_to(ROOT).as_posix())


def source_for(path: Path) -> Path | None:
    relative = path.relative_to(ROOT)
    parts = relative.parts
    if parts[:3] == ("assets", "runtime", "support"):
        return (
            ROOT
            / "assets/art/support"
            / path.with_suffix(".png").name
        )
    if parts[:3] == ("assets", "runtime", "pets"):
        return path.with_suffix(".png")
    if parts[:4] == ("assets", "runtime", "postcards", "backgrounds"):
        return (
            ROOT
            / "assets/art/postcards/backgrounds"
            / path.with_suffix(".jpg").name
        )
    if parts[:4] in {
        ("assets", "runtime", "postcards", "poses"),
        ("assets", "runtime", "postcards", "stickers"),
    }:
        return (
            ROOT
            / "assets/art/postcards"
            / parts[3]
            / path.with_suffix(".png").name
        )
    if parts[:5] == ("assets", "runtime", "yard", "themes", "wide"):
        return (
            ROOT
            / "assets/art/world/themes/wide"
            / path.with_suffix(".jpg").name
        )
    if parts[:4] == ("assets", "art", "world", "themes"):
        return (
            ROOT
            / "assets/art/world/exports_1290/themes"
            / f"{path.stem}_1290x2796.png"
        )
    if path.suffix.lower() == ".webp":
        return path.with_suffix(".png")
    return None


def category(path: Path) -> str:
    relative = path.relative_to(ROOT).as_posix()
    if relative.startswith("assets/audio/"):
        return "audio"
    if relative.startswith("assets/runtime/"):
        return "runtime-art"
    if relative.startswith("assets/art/"):
        return "art"
    return "content-data"


def build_manifest() -> dict[str, object]:
    entries: list[dict[str, object]] = []
    for path in declared_assets():
        source = source_for(path)
        entry: dict[str, object] = {
            "asset": path.relative_to(ROOT).as_posix(),
            "bytes": path.stat().st_size,
            "category": category(path),
            "sha256": sha256(path),
        }
        if source is not None and source.exists():
            entry["source"] = source.relative_to(ROOT).as_posix()
            entry["sourceSha256"] = sha256(source)
        entries.append(entry)

    counts: dict[str, int] = {}
    bytes_by_category: dict[str, int] = {}
    for entry in entries:
        key = str(entry["category"])
        counts[key] = counts.get(key, 0) + 1
        bytes_by_category[key] = bytes_by_category.get(key, 0) + int(entry["bytes"])

    return {
        "schemaVersion": 1,
        "scope": "Assets declared by pubspec.yaml for the Petopia release bundle.",
        "license": "ASSET_LICENSE applies to art and audio; LICENSE applies to code.",
        "declarations": {
            "generatedForPetopia": True,
            "thirdPartyAudioSamples": False,
            "thirdPartyStockArt": False,
        },
        "provenance": {
            "art": "assets/art/LICENSES.md",
            "audio": "assets/audio/LICENSES.md",
            "rightsRegister": "docs/app-store/asset-rights-register.md",
        },
        "counts": dict(sorted(counts.items())),
        "bytesByCategory": dict(sorted(bytes_by_category.items())),
        "entries": entries,
    }


def render(manifest: dict[str, object]) -> str:
    return json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--check",
        action="store_true",
        help="fail instead of writing when the committed manifest is stale",
    )
    args = parser.parse_args()
    expected = render(build_manifest())
    if args.check:
        if not OUTPUT.exists() or OUTPUT.read_text() != expected:
            print(
                "release asset manifest is stale; run "
                "python3 tools/build_release_asset_manifest.py"
            )
            return 1
        print(f"Verified {OUTPUT.relative_to(ROOT)}")
        return 0
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(expected)
    print(f"Wrote {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
