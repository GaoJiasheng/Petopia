#!/usr/bin/env python3
"""Petopia App 图标：暖色院子渐变底 + 橘猫，输出全套 iOS 尺寸（不透明 RGB）。"""
import os
from PIL import Image, ImageFilter, ImageDraw

ICONSET = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
SRC_CAT = "assets/art/pets/cat/pet_cat_var01_stageA.png"
S = 1024

# 1) 暖色渐变底（奶油→嫩草），呼应院子
bg = Image.new("RGB", (S, S))
top = (252, 239, 214)      # 奶油
bot = (206, 232, 198)      # 嫩草
for y in range(S):
    t = y / (S - 1)
    r = int(top[0] * (1 - t) + bot[0] * t)
    g = int(top[1] * (1 - t) + bot[1] * t)
    b = int(top[2] * (1 - t) + bot[2] * t)
    for x_line in range(0):
        pass
    ImageDraw.Draw(bg).line([(0, y), (S, y)], fill=(r, g, b))

# 柔和高光晕（中上部提亮）
glow = Image.new("L", (S, S), 0)
gd = ImageDraw.Draw(glow)
gd.ellipse([S*0.18, S*0.05, S*0.82, S*0.7], fill=90)
glow = glow.filter(ImageFilter.GaussianBlur(120))
white = Image.new("RGB", (S, S), (255, 252, 245))
bg = Image.composite(white, bg, glow)

# 2) 猫：裁到内容包围盒 → 缩放居中，带柔和落影
cat = Image.open(SRC_CAT).convert("RGBA")
bbox = cat.split()[3].getbbox()
if bbox:
    cat = cat.crop(bbox)
target_w = int(S * 0.62)
scale = target_w / cat.width
cat = cat.resize((target_w, int(cat.height * scale)), Image.LANCZOS)
cx = (S - cat.width) // 2
cy = int(S * 0.54 - cat.height / 2)

# 落影
shadow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
sh = Image.new("L", (S, S), 0)
alpha = cat.split()[3]
sh.paste(alpha, (cx, cy + int(S * 0.02)))
sh = sh.filter(ImageFilter.GaussianBlur(22))
shadow_col = Image.new("RGBA", (S, S), (120, 100, 80, 90))
shadow_col.putalpha(sh.point(lambda p: int(p * 0.35)))
base = bg.convert("RGBA")
base = Image.alpha_composite(base, shadow_col)

# 贴猫
base.alpha_composite(cat, (cx, cy))
icon = base.convert("RGB")  # 去 alpha：App Store 要求图标不透明

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
    icon.resize((px, px), Image.LANCZOS).save(os.path.join(ICONSET, name))
print(f"wrote {len(specs)} icons; 1024 mode = {icon.mode} (must be RGB)")
