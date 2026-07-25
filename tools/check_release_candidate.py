#!/usr/bin/env python3
"""Deterministic local release gate for Petopia iOS/App Store candidates."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
FAILURES: list[str] = []
WIDE_THEME_SLUGS = (
    "autumnjam",
    "bambootea",
    "candybake",
    "fourseasons",
    "meadow",
    "moongreen",
    "mossrain",
    "sakura",
    "seaside",
    "snowhut",
    "starcamp",
    "wheatkite",
)
WIDE_LUXURY_DECOR_FILES = (
    "deco_welcome_bell.png",
    "deco_arch_flower.png",
    "deco_tree_seasonal.png",
    "deco_attic_house.png",
    "deco_album_shelf.png",
    "deco_pond_small.png",
    "deco_mailbox_red.png",
)


def run(label: str, command: list[str]) -> None:
    print(f"\n== {label} ==", flush=True)
    result = subprocess.run(command, cwd=ROOT, check=False)
    if result.returncode:
        FAILURES.append(f"{label} exited with {result.returncode}")


def require(condition: bool, message: str) -> None:
    if not condition:
        FAILURES.append(message)


def static_checks() -> None:
    pubspec = (ROOT / "pubspec.yaml").read_text()
    version_match = re.search(r"^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$", pubspec, re.M)
    require(version_match is not None, "pubspec version must use x.y.z+build format")
    require("A new Flutter project" not in pubspec, "pubspec description is still the template")

    privacy = ROOT / "ios/Runner/PrivacyInfo.xcprivacy"
    project = (ROOT / "ios/Runner.xcodeproj/project.pbxproj").read_text()
    require(privacy.exists(), "missing ios/Runner/PrivacyInfo.xcprivacy")
    require(
        project.count("PrivacyInfo.xcprivacy") >= 3,
        "privacy manifest is not referenced by the Runner resources target",
    )

    info = (ROOT / "ios/Runner/Info.plist").read_text()
    require("ITSAppUsesNonExemptEncryption" in info, "missing encryption declaration")
    require("CFBundleLocalizations" in info, "missing app localization declaration")
    require("UISupportedInterfaceOrientations~ipad" in info, "missing iPad orientations")
    for orientation in (
        "UIInterfaceOrientationPortrait",
        "UIInterfaceOrientationPortraitUpsideDown",
        "UIInterfaceOrientationLandscapeLeft",
        "UIInterfaceOrientationLandscapeRight",
    ):
        require(orientation in info, f"missing iPad orientation {orientation}")
    require("UIRequiresFullScreen" not in info, "iPad multitasking is disabled")

    settings = (ROOT / "lib/ui/settings_screen.dart").read_text()
    require("appInfoProvider" in settings, "settings version is not read from package metadata")
    require("导出存档" in settings and "导入存档" in settings, "backup controls are missing")

    app_info = (ROOT / "lib/app/app_info.dart").read_text()
    for url in (
        "https://blog.gavingao.cn/petopia/",
        "https://blog.gavingao.cn/petopia/privacy.html",
        "https://blog.gavingao.cn/petopia/support.html",
    ):
        require(url in app_info, f"missing production URL {url}")

    license_text = (ROOT / "LICENSE").read_text()
    require(
        "Apache License" in license_text and "Version 2.0" in license_text,
        "LICENSE is not Apache-2.0",
    )

    generated = ROOT / "assets/data/locations.json"
    if generated.exists():
        data = json.loads(generated.read_text())
        locations = data.get("items") or data.get("locations") or []
        require(len(locations) == 40, f"expected 40 travel locations, found {len(locations)}")


def asset_checks() -> None:
    pubspec = (ROOT / "pubspec.yaml").read_text()
    decor_dir = ROOT / "assets/art/world/decor"
    for filename in WIDE_LUXURY_DECOR_FILES:
        relative = f"assets/art/world/decor/{filename}"
        require((decor_dir / filename).exists(), f"missing wide luxury decor {relative}")
        require(relative in pubspec, f"wide luxury decor is not bundled: {relative}")

    wide_dir = ROOT / "assets/art/world/themes/wide"
    provenance_path = wide_dir / "provenance.json"
    require(provenance_path.exists(), "missing iPad wide theme provenance")
    provenance_assets: dict[str, str] = {}
    if provenance_path.exists():
        provenance = json.loads(provenance_path.read_text())
        require(
            provenance.get("thirdPartyAssets") is False,
            "iPad wide theme provenance is ambiguous",
        )
        provenance_assets = {
            item["asset"]: item["sha256"]
            for item in provenance.get("assets", [])
            if isinstance(item, dict)
            and isinstance(item.get("asset"), str)
            and isinstance(item.get("sha256"), str)
        }
    for slug in WIDE_THEME_SLUGS:
        path = wide_dir / f"yard_theme_{slug}_bg_wide.jpg"
        require(path.exists(), f"missing iPad wide theme {path.relative_to(ROOT)}")
        if not path.exists():
            continue
        with Image.open(path) as image:
            require(
                image.size == (2732, 2048),
                f"{path.relative_to(ROOT)} is {image.size}, expected 2732x2048",
            )
            require(
                image.format == "JPEG",
                f"{path.relative_to(ROOT)} must be an opaque JPEG",
            )
            require(
                "A" not in image.getbands() and "transparency" not in image.info,
                f"{path.relative_to(ROOT)} must not contain alpha",
            )
        expected_hash = provenance_assets.get(path.name)
        require(expected_hash is not None, f"missing provenance hash: {path.name}")
        if expected_hash is not None:
            actual_hash = hashlib.sha256(path.read_bytes()).hexdigest()
            require(actual_hash == expected_hash, f"theme hash mismatch: {path.name}")

    lossless_runtime_assets = [
        *ROOT.glob("assets/runtime/pets/*/actions/*.webp"),
        *ROOT.glob("assets/art/world/layouts/yard_luxury0[2-6]_delta.webp"),
        *ROOT.glob("assets/art/world/fx/yard_fx_*.webp"),
    ]
    require(
        len(lossless_runtime_assets) == 58,
        f"expected 58 lossless WebP runtime assets, found {len(lossless_runtime_assets)}",
    )
    for webp_path in lossless_runtime_assets:
        png_path = webp_path.with_suffix(".png")
        require(png_path.exists(), f"missing PNG art master for {webp_path.relative_to(ROOT)}")
        if not png_path.exists():
            continue
        with Image.open(png_path) as png, Image.open(webp_path) as webp:
            require(
                png.size == webp.size,
                f"WebP size mismatch: {webp_path.relative_to(ROOT)}",
            )
            difference = ImageChops.difference(
                png.convert("RGBA"),
                webp.convert("RGBA"),
            )
            require(
                difference.getbbox() is None,
                f"WebP is not pixel-lossless: {webp_path.relative_to(ROOT)}",
            )

    manifest_path = ROOT / "assets/audio/provenance/sfx_provenance_manifest.json"
    require(manifest_path.exists(), "missing SFX provenance manifest")
    if not manifest_path.exists():
        return
    manifest = json.loads(manifest_path.read_text())
    require(manifest.get("thirdPartySamples") is False, "SFX provenance is ambiguous")
    assets = manifest.get("assets")
    require(isinstance(assets, list) and len(assets) == 8, "expected 8 original SFX/UI assets")
    if not isinstance(assets, list):
        return
    for item in assets:
        if not isinstance(item, dict):
            require(False, "invalid SFX provenance entry")
            continue
        relative = item.get("asset")
        expected_hash = item.get("sha256")
        if not isinstance(relative, str) or not isinstance(expected_hash, str):
            require(False, "invalid SFX provenance path/hash")
            continue
        path = ROOT / relative
        require(path.exists(), f"missing audio asset {relative}")
        if path.exists():
            actual_hash = hashlib.sha256(path.read_bytes()).hexdigest()
            require(actual_hash == expected_hash, f"audio hash mismatch: {relative}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--skip-flutter",
        action="store_true",
        help="run only static, plist, and raster checks",
    )
    args = parser.parse_args()

    static_checks()
    asset_checks()
    run("plist validation", ["plutil", "-lint", "ios/Runner/Info.plist", "ios/Runner/PrivacyInfo.xcprivacy"])
    run("runtime raster audit", [sys.executable, "tools/audit_runtime_art.py"])
    run(
        "postcard content alignment",
        [sys.executable, "tools/annotate_postcard_location_affinity.py"],
    )
    if not args.skip_flutter:
        run("Flutter analyze", ["flutter", "analyze"])
        run("Flutter tests", ["flutter", "test"])

    print("\n== release result ==")
    if FAILURES:
        for failure in FAILURES:
            print(f"FAIL: {failure}")
        return 1
    print("PASS: release candidate checks are green")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
