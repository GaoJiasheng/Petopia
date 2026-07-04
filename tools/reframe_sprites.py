#!/usr/bin/env python3
"""重构底图立绘框选：裁到完整主体 → 按阶段统一占比放大 → 贴地基线居中到 512。
保留 A小→C大 的成长感；主体完整不裁（耳朵/尾巴都在，只是变大变正）。
用法：python3 tools/reframe_sprites.py [--apply]  （不加 --apply 只对 cat 出预览）"""
import sys, glob, os
from PIL import Image

CANVAS = 512
GROUND = 0.93          # 主体底边落在画布 93% 处（统一站在地面）
TARGET = {'A': 0.60, 'B': 0.72, 'C': 0.80, 'D': 0.76}  # 主体长边占画布比例（成长）

def reframe(path):
    im = Image.open(path).convert('RGBA')
    bb = im.split()[-1].getbbox()
    if not bb:
        return None
    subj = im.crop(bb)
    stage = path[-5]  # ...stageX.png
    target = TARGET.get(stage, 0.78) * CANVAS
    scale = target / max(subj.width, subj.height)
    nw, nh = max(1, round(subj.width * scale)), max(1, round(subj.height * scale))
    subj = subj.resize((nw, nh), Image.LANCZOS)
    canvas = Image.new('RGBA', (CANVAS, CANVAS), (0, 0, 0, 0))
    x = (CANVAS - nw) // 2
    y = round(CANVAS * GROUND) - nh
    canvas.alpha_composite(subj, (x, max(0, y)))
    return canvas

def main():
    apply = '--apply' in sys.argv
    pats = 'assets/art/pets/*/pet_*_var0[1-5]_stage[A-D].png'
    files = sorted(glob.glob(pats))
    if not apply:  # 预览：只做 cat，输出 before/after 对比图
        cells = []
        from PIL import ImageDraw
        for st in 'ABCD':
            p = f'assets/art/pets/cat/pet_cat_var01_stage{st}.png'
            before = Image.open(p).convert('RGBA').resize((200, 200))
            after = reframe(p).resize((200, 200))
            for tag, img in [(f'{st} before', before), (f'{st} after', after)]:
                d = ImageDraw.Draw(img); d.rectangle([0, 0, 199, 199], outline=(255, 0, 0), width=2)
                cells.append((tag, img))
        sheet = Image.new('RGBA', (len(cells) * 210, 230), (250, 244, 230, 255))
        dd = ImageDraw.Draw(sheet)
        for i, (t, img) in enumerate(cells):
            sheet.paste(img, (i * 210 + 5, 25), img); dd.text((i * 210 + 8, 6), t, fill=(80, 60, 50))
        out = '/Users/gavin/reframe_preview.png'
        sheet.convert('RGB').save(out); print('preview ->', out)
        return
    n = 0
    for f in files:
        r = reframe(f)
        if r:
            r.save(f); n += 1
    print(f'reframed {n} base sprites')

main()
