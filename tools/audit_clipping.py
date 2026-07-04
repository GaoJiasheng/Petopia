#!/usr/bin/env python3
"""截断审计：扫描所有宠物美术，检测主体是否贴/超出画框边缘（头/身/尾被切）。
判据：某条边缘线(row0/末行/col0/末列)上「实心像素」(alpha>=200) 连续 run >= RUN 视为该边被切。
底边(feet)贴边视为正常，单独标注不计入缺陷。"""
import os, glob
from PIL import Image

RUN = 22          # 连续实心像素阈值
SOLID = 200       # alpha 实心阈值
FRAME = 512

def edge_runs(alpha_row):
    best = cur = 0
    for a in alpha_row:
        if a >= SOLID:
            cur += 1; best = max(best, cur)
        else:
            cur = 0
    return best

def clip_edges(img):
    """返回被切的边集合（不含 bottom）。img: RGBA 512x512（或任意方图）。"""
    a = img.split()[-1]
    w, h = img.size
    px = a.load()
    top = [px[x, 0] for x in range(w)]
    left = [px[0, y] for y in range(h)]
    right = [px[w-1, y] for y in range(h)]
    bot = [px[x, h-1] for x in range(w)]
    edges = set()
    if edge_runs(top) >= RUN: edges.add('top')
    if edge_runs(left) >= RUN: edges.add('left')
    if edge_runs(right) >= RUN: edges.add('right')
    bottom_clip = edge_runs(bot) >= RUN
    return edges, bottom_clip

def scan_frames(path):
    """动作条：8 帧逐帧检测，返回 {frame_idx: edges}。"""
    im = Image.open(path).convert('RGBA')
    n = im.width // FRAME if im.width >= FRAME*2 else 1
    out = {}
    for i in range(n):
        fr = im.crop((i*FRAME, 0, (i+1)*FRAME, im.height))
        edges, _ = clip_edges(fr)
        if edges: out[i] = sorted(edges)
    return n, out

def scan_single(path):
    im = Image.open(path).convert('RGBA')
    # 缩放到方图判定（底图尺寸各异）
    edges, _ = clip_edges(im)
    return edges

ROOT = 'assets/art/pets'
species = sorted([d for d in os.listdir(ROOT)
                  if os.path.isdir(os.path.join(ROOT, d)) and d not in ('dex','portraits','fx','personality')])

print("# 动作序列帧截断（逐帧）")
action_bad = {}
for sp in species:
    for path in sorted(glob.glob(f'{ROOT}/{sp}/actions/pet_{sp}_var01_stageC_*.png')):
        act = path.split('_')[-1].replace('.png','')
        n, bad = scan_frames(path)
        if bad:
            action_bad.setdefault(sp, {})[act] = bad

for sp in species:
    if sp in action_bad:
        print(f"\n## {sp}")
        for act, bad in action_bad[sp].items():
            frames = ', '.join(f'帧{i}({"/".join(e)})' for i, e in bad.items())
            print(f"  {act}: {frames}")

print("\n\n# 底图立绘截断（var01-05 × stageA-D）")
base_bad = {}
for sp in species:
    for path in sorted(glob.glob(f'{ROOT}/{sp}/pet_{sp}_var*_stage[A-D].png')):
        name = os.path.basename(path).replace('.png','').replace(f'pet_{sp}_','')
        edges = scan_single(path)
        if edges:
            base_bad.setdefault(sp, []).append((name, sorted(edges)))
for sp in species:
    if sp in base_bad:
        print(f"\n## {sp}: " + ', '.join(f'{n}({"/".join(e)})' for n, e in base_bad[sp]))

# 汇总
na = sum(len(v) for s in action_bad.values() for v in s.values())
print(f"\n\n# 汇总")
print(f"动作条有截断帧的物种: {sorted(action_bad.keys())}")
print(f"底图有截断的物种: {sorted(base_bad.keys())}")
