#!/usr/bin/env python3
"""Build Hearth & Tails launcher icons from the approved opaque RGB master."""
import os
from PIL import Image, ImageFilter

ICONSET = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
ANDROID_RES = "android/app/src/main/res"
MASTER = "docs/art-sources/app-icon/app_icon_master_2026-08-02.png"
S = 1024

icon = Image.open(MASTER).convert("RGB")
if icon.size != (S, S):
    icon = icon.resize((S, S), Image.Resampling.LANCZOS)


def resized(px: int) -> Image.Image:
    output = icon.resize((px, px), Image.Resampling.LANCZOS)
    if px <= 120:
        output = output.filter(
            ImageFilter.UnsharpMask(radius=0.55, percent=55, threshold=3)
        )
    return output

# 3) 输出全套尺寸
specs = {
    "Icon-App-20x20@1x.png": 20, "Icon-App-20x20@2x.png": 40, "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29, "Icon-App-29x29@2x.png": 58, "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40, "Icon-App-40x40@2x.png": 80, "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120, "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76, "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}
for name, px in specs.items():
    resized(px).save(os.path.join(ICONSET, name), optimize=True)

android_specs = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
for folder, px in android_specs.items():
    resized(px).save(
        os.path.join(ANDROID_RES, folder, "ic_launcher.png"), optimize=True
    )

print(
    f"wrote {len(specs)} iOS and {len(android_specs)} Android icons; "
    f"1024 mode = {icon.mode} (must be RGB)"
)
