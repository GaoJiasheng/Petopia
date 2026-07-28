#!/usr/bin/env python3
"""Deterministic local release gate for Petopia iOS/App Store candidates."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageStat


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
PORTRAIT_THEME_SLUGS = WIDE_THEME_SLUGS
WIDE_LUXURY_DECOR_FILES = (
    "deco_welcome_bell.png",
    "deco_arch_flower.png",
    "deco_tree_seasonal.png",
    "deco_attic_house.png",
    "deco_album_shelf.png",
    "deco_pond_small.png",
    "deco_mailbox_red.png",
)
POSTCARD_BACKGROUND_COUNT = 40
SUPPORT_PRODUCTS = {
    "com.petopia.petopia.support.treat": ("Consumable", "0.99"),
    "com.petopia.petopia.support.lantern": ("Consumable", "2.99"),
    "com.petopia.petopia.support.bouquet": ("Consumable", "4.99"),
    "com.petopia.petopia.support.guardian": ("NonConsumable", "6.99"),
}
DECLARED_ASSET_BUDGET_BYTES = 138 * 1024 * 1024
IOS_APP_BUDGET_BYTES = 166 * 1024 * 1024
IOS_FLUTTER_ASSET_BUDGET_BYTES = 139 * 1024 * 1024


def run(label: str, command: list[str]) -> None:
    print(f"\n== {label} ==", flush=True)
    result = subprocess.run(command, cwd=ROOT, check=False)
    if result.returncode:
        FAILURES.append(f"{label} exited with {result.returncode}")


def require(condition: bool, message: str) -> None:
    if not condition:
        FAILURES.append(message)


def psnr(source: Image.Image, runtime: Image.Image) -> float:
    difference = ImageChops.difference(
        source.convert("RGB"),
        runtime.convert("RGB"),
    )
    rms = ImageStat.Stat(difference).rms
    mse = sum(channel * channel for channel in rms) / len(rms)
    if mse == 0:
        return math.inf
    return 20 * math.log10(255 / math.sqrt(mse))


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

    launch_storyboard = (ROOT / "ios/Runner/Base.lproj/LaunchScreen.storyboard").read_text()
    launch_mark = (
        ROOT
        / "ios/Runner/Assets.xcassets/LaunchMark.imageset/LaunchMark.png"
    )
    launch_contents = (
        ROOT
        / "ios/Runner/Assets.xcassets/LaunchMark.imageset/Contents.json"
    )
    require("LaunchMark" in launch_storyboard, "native launch mark is not wired")
    require(launch_mark.exists(), "missing native launch mark image")
    require(launch_contents.exists(), "missing native launch mark manifest")
    if launch_mark.exists():
        with Image.open(launch_mark) as image:
            require(
                image.size == (512, 512),
                f"native launch mark is {image.size}, expected 512x512",
            )
            alpha = image.convert("RGBA").getchannel("A")
            bounds = alpha.getbbox()
            require(bounds is not None, "native launch mark is fully transparent")
            if bounds is not None:
                left, top, right, bottom = bounds
                require(
                    min(left, top, 512 - right, 512 - bottom) >= 24,
                    "native launch mark subject is too close to the canvas edge",
                )

    settings = (ROOT / "lib/ui/settings_screen.dart").read_text()
    require("appInfoProvider" in settings, "settings version is not read from package metadata")
    require("导出存档" in settings and "导入存档" in settings, "backup controls are missing")
    require(
        "showLicensePage" in settings and "开源许可" in settings,
        "open-source dependency licenses are not reachable in the app",
    )
    require(
        "SupportYardScreen" in settings and "支持小院" in settings,
        "the voluntary support entry is not reachable from settings",
    )

    support_config_path = ROOT / "ios/Runner/PetopiaSupport.storekit"
    scheme_path = (
        ROOT
        / "ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme"
    )
    require(support_config_path.exists(), "missing local StoreKit configuration")
    require(scheme_path.exists(), "missing shared Runner scheme")
    if support_config_path.exists():
        support_config = json.loads(support_config_path.read_text())
        products = {
            item.get("productID"): (item.get("type"), item.get("displayPrice"))
            for item in support_config.get("products", [])
            if isinstance(item, dict)
        }
        require(
            products == SUPPORT_PRODUCTS,
            "StoreKit products, types, or prices do not match the release catalog",
        )
        for item in support_config.get("products", []):
            localizations = item.get("localizations", [])
            locales = {
                localization.get("locale")
                for localization in localizations
                if isinstance(localization, dict)
            }
            require(
                {"en_US", "zh_CN"} <= locales,
                f"missing StoreKit localization for {item.get('productID')}",
            )
    if scheme_path.exists():
        scheme = scheme_path.read_text()
        require(
            "../Runner/PetopiaSupport.storekit" in scheme,
            "Runner Debug scheme does not reference PetopiaSupport.storekit",
        )
    review_notes = (ROOT / "docs/app-store/review-notes-zh-Hans.md").read_text()
    require(
        "无应用内购买" not in review_notes,
        "App Review notes incorrectly claim there are no in-app purchases",
    )

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
    asset_license = ROOT / "ASSET_LICENSE"
    rights_register = ROOT / "docs/app-store/asset-rights-register.md"
    require(asset_license.exists(), "missing proprietary ASSET_LICENSE")
    require(rights_register.exists(), "missing App Store asset rights register")
    if asset_license.exists():
        text = asset_license.read_text()
        require(
            "assets/art/" in text
            and "assets/audio/" in text
            and "assets/runtime/" in text,
            "ASSET_LICENSE does not define its complete scope",
        )

    generated = ROOT / "assets/data/locations.json"
    if generated.exists():
        data = json.loads(generated.read_text())
        locations = data.get("items") or data.get("locations") or []
        require(len(locations) == 40, f"expected 40 travel locations, found {len(locations)}")


def asset_checks() -> None:
    pubspec = (ROOT / "pubspec.yaml").read_text()
    portrait_dir = ROOT / "assets/art/world/themes"
    portrait_master_dir = ROOT / "assets/art/world/exports_1290/themes"
    for slug in PORTRAIT_THEME_SLUGS:
        path = portrait_dir / f"yard_theme_{slug}_bg.webp"
        master = portrait_master_dir / f"yard_theme_{slug}_bg_1290x2796.png"
        require(path.exists(), f"missing portrait theme {path.relative_to(ROOT)}")
        require(
            str(path.relative_to(ROOT)) in pubspec,
            f"portrait theme is not bundled: {path.relative_to(ROOT)}",
        )
        require(
            master.exists(),
            f"missing portrait theme master {master.relative_to(ROOT)}",
        )
        if master.exists():
            with Image.open(master) as image:
                require(
                    image.size == (1290, 2796),
                    f"{master.relative_to(ROOT)} is {image.size}, expected 1290x2796",
                )
        if not path.exists():
            continue
        with Image.open(path) as image:
            require(
                image.size == (1290, 2796),
                f"{path.relative_to(ROOT)} is {image.size}, expected 1290x2796",
            )
            require(
                image.format == "WEBP",
                f"{path.relative_to(ROOT)} must be WebP",
            )
            require(
                "A" not in image.getbands() and "transparency" not in image.info,
                f"{path.relative_to(ROOT)} must not contain alpha",
            )

    decor_dir = ROOT / "assets/art/world/decor"
    for filename in WIDE_LUXURY_DECOR_FILES:
        relative = f"assets/art/world/decor/{filename}"
        require((decor_dir / filename).exists(), f"missing wide luxury decor {relative}")
        require(relative in pubspec, f"wide luxury decor is not bundled: {relative}")

    wide_dir = ROOT / "assets/art/world/themes/wide"
    runtime_wide_dir = ROOT / "assets/runtime/yard/themes/wide"
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
        runtime_path = runtime_wide_dir / f"yard_theme_{slug}_bg_wide.webp"
        require(path.exists(), f"missing iPad wide theme {path.relative_to(ROOT)}")
        require(
            runtime_path.exists(),
            f"missing runtime iPad theme {runtime_path.relative_to(ROOT)}",
        )
        require(
            str(runtime_path.parent.relative_to(ROOT)) + "/" in pubspec,
            "runtime iPad theme directory is not bundled",
        )
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
        if runtime_path.exists():
            with Image.open(path) as source, Image.open(runtime_path) as runtime:
                require(
                    runtime.size == source.size,
                    f"runtime iPad theme size mismatch: {runtime_path.name}",
                )
                require(
                    runtime.format == "WEBP",
                    f"{runtime_path.relative_to(ROOT)} must be WebP",
                )
                require(
                    "A" not in runtime.getbands() and "transparency" not in runtime.info,
                    f"{runtime_path.relative_to(ROOT)} must not contain alpha",
                )
                quality = psnr(source, runtime)
                require(
                    quality >= 39,
                    f"runtime iPad theme quality {quality:.2f} dB is below 39 dB: "
                    f"{runtime_path.name}",
                )

    postcard_source_dir = ROOT / "assets/art/postcards/backgrounds"
    postcard_runtime_dir = ROOT / "assets/runtime/postcards/backgrounds"
    postcard_runtime_assets = sorted(postcard_runtime_dir.glob("*.webp"))
    require(
        len(postcard_runtime_assets) == POSTCARD_BACKGROUND_COUNT,
        f"expected {POSTCARD_BACKGROUND_COUNT} runtime postcard backgrounds, "
        f"found {len(postcard_runtime_assets)}",
    )
    require(
        "assets/runtime/postcards/backgrounds/" in pubspec,
        "runtime postcard background directory is not bundled",
    )
    for runtime_path in postcard_runtime_assets:
        source_path = postcard_source_dir / f"{runtime_path.stem}.jpg"
        require(
            source_path.exists(),
            f"missing postcard master for {runtime_path.relative_to(ROOT)}",
        )
        if not source_path.exists():
            continue
        with Image.open(source_path) as source, Image.open(runtime_path) as runtime:
            require(
                runtime.size == source.size,
                f"runtime postcard size mismatch: {runtime_path.name}",
            )
            require(
                runtime.format == "WEBP",
                f"{runtime_path.relative_to(ROOT)} must be WebP",
            )
            require(
                "A" not in runtime.getbands() and "transparency" not in runtime.info,
                f"{runtime_path.relative_to(ROOT)} must not contain alpha",
            )
            quality = psnr(source, runtime)
            require(
                quality >= 33,
                f"runtime postcard quality {quality:.2f} dB is below 33 dB: "
                f"{runtime_path.name}",
            )

    support_dir = ROOT / "assets/runtime/support"
    support_assets = sorted(support_dir.glob("*.webp"))
    require(len(support_assets) == 5, "expected 5 support runtime artworks")
    for runtime_path in support_assets:
        source_path = ROOT / "assets/art/support" / f"{runtime_path.stem}.png"
        require(
            source_path.exists(),
            f"missing support art master for {runtime_path.relative_to(ROOT)}",
        )
        if not source_path.exists():
            continue
        expected_size = (
            (1200, 800)
            if runtime_path.name == "support_guardian_postcard.webp"
            else (768, 768)
        )
        with Image.open(runtime_path) as runtime:
            require(
                runtime.size == expected_size,
                f"{runtime_path.relative_to(ROOT)} is {runtime.size}, "
                f"expected {expected_size}",
            )
            has_alpha = (
                "A" in runtime.getbands() or "transparency" in runtime.info
            )
            require(
                has_alpha == (runtime_path.name != "support_guardian_postcard.webp"),
                f"support art alpha policy mismatch: {runtime_path.name}",
            )
            if has_alpha:
                bounds = runtime.convert("RGBA").getchannel("A").getbbox()
                require(bounds is not None, f"support art is empty: {runtime_path.name}")
                if bounds is not None:
                    left, top, right, bottom = bounds
                    require(
                        min(
                            left,
                            top,
                            runtime.width - right,
                            runtime.height - bottom,
                        )
                        >= 24,
                        f"support art touches its safe area: {runtime_path.name}",
                    )

    lossless_runtime_assets = [
        *ROOT.glob("assets/runtime/pets/*/pet_*_stage?.webp"),
        *ROOT.glob("assets/runtime/pets/*/actions/*.webp"),
        *ROOT.glob("assets/runtime/postcards/poses/*.webp"),
        *ROOT.glob("assets/runtime/postcards/stickers/*.webp"),
        *ROOT.glob("assets/art/world/layouts/yard_luxury0[2-6]_delta.webp"),
        *ROOT.glob("assets/art/world/fx/yard_fx_*.webp"),
    ]
    require(
        len(lossless_runtime_assets) == 380,
        f"expected 380 lossless WebP runtime assets, found {len(lossless_runtime_assets)}",
    )
    for webp_path in lossless_runtime_assets:
        relative = webp_path.relative_to(ROOT)
        if relative.parts[:3] == ("assets", "runtime", "postcards"):
            png_path = (
                ROOT
                / "assets"
                / "art"
                / "postcards"
                / relative.parts[3]
                / webp_path.with_suffix(".png").name
            )
        else:
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

    music_manifest_path = (
        ROOT / "assets/audio/provenance/music_provenance_manifest.json"
    )
    ambient_manifest_path = (
        ROOT / "assets/audio/provenance/ambient_voc_provenance_manifest.json"
    )
    require(music_manifest_path.exists(), "missing music provenance manifest")
    require(ambient_manifest_path.exists(), "missing ambient provenance manifest")
    if music_manifest_path.exists():
        music = json.loads(music_manifest_path.read_text())
        policy = str(music.get("source_policy", ""))
        require(
            "No third-party samples" in policy,
            "music provenance does not exclude third-party samples",
        )
        require(
            len(music.get("assets", [])) == 73,
            "expected 73 music provenance entries",
        )
    if ambient_manifest_path.exists():
        ambient = json.loads(ambient_manifest_path.read_text())
        require(
            ambient.get("thirdPartySamples") is False,
            "ambient/voice provenance is ambiguous",
        )
        require(
            len(ambient.get("assets", [])) == 26,
            "expected 26 ambient/voice provenance entries",
        )

    release_manifest_path = ROOT / "assets/provenance/release_asset_manifest.json"
    require(release_manifest_path.exists(), "missing release asset manifest")
    if release_manifest_path.exists():
        release_manifest = json.loads(release_manifest_path.read_text())
        declarations = release_manifest.get("declarations", {})
        require(
            declarations.get("thirdPartyStockArt") is False,
            "release manifest does not exclude third-party stock art",
        )
        require(
            declarations.get("thirdPartyAudioSamples") is False,
            "release manifest does not exclude third-party audio samples",
        )
        total_bytes = sum(
            int(value)
            for value in release_manifest.get("bytesByCategory", {}).values()
        )
        require(
            total_bytes <= DECLARED_ASSET_BUDGET_BYTES,
            "declared release assets exceed the 138 MiB source budget: "
            f"{total_bytes / 1024 / 1024:.2f} MiB",
        )


def ios_build_checks() -> None:
    app = ROOT / "build/ios/iphoneos/Runner.app"
    flutter_assets = app / "Frameworks/App.framework/flutter_assets"
    require(app.exists(), "missing iOS device Release build")
    require(flutter_assets.exists(), "iOS Release build has no Flutter assets")
    if not app.exists() or not flutter_assets.exists():
        return

    def tree_size(path: Path) -> int:
        return sum(
            item.stat().st_size for item in path.rglob("*") if item.is_file()
        )

    app_bytes = tree_size(app)
    flutter_asset_bytes = tree_size(flutter_assets)
    require(
        app_bytes <= IOS_APP_BUDGET_BYTES,
        "iOS Runner.app exceeds the 166 MiB expanded-file budget: "
        f"{app_bytes / 1024 / 1024:.2f} MiB",
    )
    require(
        flutter_asset_bytes <= IOS_FLUTTER_ASSET_BUDGET_BYTES,
        "iOS Flutter assets exceed the 139 MiB bundle budget: "
        f"{flutter_asset_bytes / 1024 / 1024:.2f} MiB",
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--skip-flutter",
        action="store_true",
        help="run only static, plist, and raster checks",
    )
    parser.add_argument(
        "--require-ios-build",
        action="store_true",
        help="also require a device Release build within package budgets",
    )
    args = parser.parse_args()

    static_checks()
    asset_checks()
    if args.require_ios_build:
        ios_build_checks()
    run("plist validation", ["plutil", "-lint", "ios/Runner/Info.plist", "ios/Runner/PrivacyInfo.xcprivacy"])
    run("source pet art audit", [sys.executable, "tools/check_pet_art.py"])
    run("runtime raster audit", [sys.executable, "tools/audit_runtime_art.py"])
    run(
        "release asset manifest",
        [sys.executable, "tools/build_release_asset_manifest.py", "--check"],
    )
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
