#!/usr/bin/env python3
"""动作条统一：异构(6/7/8/10 帧、384/448/512 高) → 规范 8×512²。
整条用同一缩放+平移(保运动)，主体统一占比+贴地；重采样到 8 帧；每帧独立重建(消除跨帧残片)。
用法：python3 tools/reframe_actions.py [--apply]"""
import sys, glob
from PIL import Image, ImageDraw

FW = 512
OUT_N = 8
TARGET = 0.80          # 主体长边占画布比例（对齐底图 stageC）
GROUND = 0.92

def reframe_strip(path):
    im = Image.open(path).convert('RGBA')
    W, H = im.size
    # 帧宽检测：多为正方形帧(帧宽=帧高)；W 不能被 H 整除时退回 512。
    fw = H if W % H == 0 else 512
    n = max(1, W // fw)
    frames = [im.crop((i * fw, 0, (i + 1) * fw, H)) for i in range(n)]
    bboxes = [f.split()[-1].getbbox() for f in frames]
    valid = [max(b[2] - b[0], b[3] - b[1]) for b in bboxes if b]
    if not valid:
        return None
    scale = TARGET * FW / max(valid)  # 统一缩放（以最大主体为准，不脉动）
    rebuilt = []
    for f, b in zip(frames, bboxes):
        canvas = Image.new('RGBA', (FW, FW), (0, 0, 0, 0))
        if b:
            subj = f.crop(b)
            nw, nh = max(1, round(subj.width * scale)), max(1, round(subj.height * scale))
            subj = subj.resize((nw, nh), Image.LANCZOS)
            x = (FW - nw) // 2                       # 每帧独立居中 → 不可能有残片
            y = round(FW * GROUND) - nh              # 贴地基线
            canvas.paste(subj, (x, max(0, y)), subj)
        rebuilt.append(canvas)
    idx = [round(i * (n - 1) / (OUT_N - 1)) for i in range(OUT_N)]  # 重采样到 8 帧
    strip = Image.new('RGBA', (FW * OUT_N, FW), (0, 0, 0, 0))
    for i, j in enumerate(idx):
        strip.paste(rebuilt[j], (i * FW, 0))
    return strip

def main():
    apply = '--apply' in sys.argv
    files = sorted(glob.glob('assets/art/pets/*/actions/pet_*_stageC_*.png'))
    if not apply:
        picks = [
            'assets/art/pets/cat/actions/pet_cat_var01_stageC_idle.png',
            'assets/art/pets/hamster/actions/pet_hamster_var01_stageC_idle.png',
            'assets/art/pets/snake/actions/pet_snake_var01_stageC_idle.png',
        ]
        rows = []
        for p in picks:
            strip = reframe_strip(p)
            th = strip.resize((FW * OUT_N // 4, FW // 4))
            rows.append((p.split('/')[3], th))
        sheet = Image.new('RGBA', (FW * OUT_N // 4 + 10, len(rows) * (FW // 4 + 20)), (250, 244, 230, 255))
        d = ImageDraw.Draw(sheet)
        for i, (name, th) in enumerate(rows):
            y = i * (FW // 4 + 20)
            d.text((5, y + 2), name, fill=(80, 60, 50))
            sheet.paste(th, (5, y + 16), th)
        sheet.convert('RGB').save('/Users/gavin/actions_preview.png')
        print('preview -> /Users/gavin/actions_preview.png')
        return
    n = 0
    for f in files:
        r = reframe_strip(f)
        if r:
            r.save(f); n += 1
    print(f'normalized {n} action strips to 8x512')

main()
