#!/usr/bin/env python3
"""从 var01_stageA 立绘裁出主体、居中到透明正方形 → 干净的领养/相册头像。
避免直接用 pet_*_dex_color（图鉴合成卡：含探头的第二只 + 徽章）导致裁切错乱。"""
import os
from PIL import Image

SPECIES = ["cat", "shiba", "rabbit", "hamster", "boo", "chameleon",
           "ember", "parrot", "snake", "starbug", "turtle", "uni"]
OUT = "assets/art/pets/portraits"
os.makedirs(OUT, exist_ok=True)

for sp in SPECIES:
    src = f"assets/art/pets/{sp}/pet_{sp}_var01_stageA.png"
    if not os.path.exists(src):
        print("skip", sp); continue
    img = Image.open(src).convert("RGBA")
    bbox = img.split()[3].getbbox()
    if bbox:
        img = img.crop(bbox)
    # 居中到透明正方形，四周留 8% 边距
    side = int(max(img.width, img.height) * 1.16)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.alpha_composite(img, ((side - img.width) // 2, (side - img.height) // 2))
    canvas.save(f"{OUT}/pet_{sp}.png")
    print(f"pet_{sp}.png  {side}x{side}")
print("done")
