#!/usr/bin/env python3
"""宠物美术验收 check（返工交付后跑）。汇集历次踩坑，逐项自动核验，输出 PASS/FAIL。
用法：python3 tools/check_pet_art.py
退出码 0=全过；非0=有 FAIL。"""
import os, glob
from PIL import Image

ROOT = 'assets/art/pets'
SPECIES = ['cat', 'shiba', 'rabbit', 'hamster', 'turtle', 'parrot', 'snake',
           'chameleon', 'ember', 'uni', 'boo', 'starbug']
FANTASY = {'ember', 'uni', 'boo', 'starbug'}
ACTIONS = ['idle', 'eat', 'pat', 'play', 'bath', 'sit', 'sleep', 'walk']
STAGES = 'ABCD'

# —— 阈值（历次问题固化）——
SOLID = 200
EDGE_RUN = 22          # 边缘连续实心>=此值 = 截断
MARGIN_MIN = 0.08      # 主体四周最小透明边距（顶/左/右）
FILL_LO, FILL_HI = 0.68, 0.86   # 主体长边占比允许区间（统一饱满）
FRAME_SCALE_TOL = 0.12  # 动作8帧间主体尺寸波动上限（防脉动）
FRAME_BASE_TOL = 0.06   # 动作8帧间贴地基线波动上限（防上下跳）
FAILS = []

def fail(msg): FAILS.append(msg)

def alpha_bbox(img):
    return img.split()[-1].getbbox()

def edge_clipped(img):
    a = img.split()[-1].load(); w, h = img.size
    def run(line):
        b = c = 0
        for v in line:
            c = c + 1 if v >= SOLID else 0; b = max(b, c)
        return b
    top = run([a[x, 0] for x in range(w)])
    left = run([a[0, y] for y in range(h)])
    right = run([a[w-1, y] for y in range(h)])
    return top >= EDGE_RUN or left >= EDGE_RUN or right >= EDGE_RUN

def check_complete(img, tag, canvas=512, check_fill=True):
    if edge_clipped(img):
        fail(f'{tag}: 主体触碰画框边缘（截断）')
    bb = alpha_bbox(img)
    if not bb:
        fail(f'{tag}: 空图'); return
    w, h = img.size
    m = min(bb[0], bb[1], w - bb[2]) / canvas  # 顶/左/右最小边距
    if m < MARGIN_MIN:
        fail(f'{tag}: 安全边距不足（{m*100:.0f}%<{MARGIN_MIN*100:.0f}%）')
    if check_fill:  # 问号渍(mystery)是氛围渍、非实体主体，不核占比
        fill = max(bb[2]-bb[0], bb[3]-bb[1]) / canvas
        if not (FILL_LO <= fill <= FILL_HI):
            fail(f'{tag}: 主体占比 {fill*100:.0f}% 不在 {int(FILL_LO*100)}-{int(FILL_HI*100)}%')

def check_base():
    for sp in SPECIES:
        for st in STAGES:
            for v in range(1, 6):
                p = f'{ROOT}/{sp}/pet_{sp}_var0{v}_stage{st}.png'
                if not os.path.exists(p):
                    fail(f'缺文件 {p}'); continue
                im = Image.open(p).convert('RGBA')
                if im.size != (512, 512):
                    fail(f'{p}: 尺寸 {im.size}≠512²')
                check_complete(im, f'{sp}/var0{v}_stage{st}')

def check_actions():
    for sp in SPECIES:
        for act in ACTIONS:
            p = f'{ROOT}/{sp}/actions/pet_{sp}_var01_stageC_{act}.png'
            if not os.path.exists(p):
                fail(f'缺动作 {p}'); continue
            im = Image.open(p).convert('RGBA')
            if im.size != (4096, 512):
                fail(f'{p}: 尺寸 {im.size}≠4096×512(8帧)')
                continue
            sizes, bases = [], []
            for i in range(8):
                f = im.crop((i*512, 0, (i+1)*512, 512))
                check_complete(f, f'{sp}/{act}#帧{i}')
                bb = alpha_bbox(f)
                if bb:
                    sizes.append(max(bb[2]-bb[0], bb[3]-bb[1]))
                    bases.append(bb[3])
            if sizes:
                if (max(sizes)-min(sizes))/max(sizes) > FRAME_SCALE_TOL:
                    fail(f'{sp}/{act}: 8帧主体尺寸脉动过大')
                if (max(bases)-min(bases))/512 > FRAME_BASE_TOL:
                    fail(f'{sp}/{act}: 8帧贴地基线跳动过大')

def check_dex():
    for sp in SPECIES:
        need = ['color', 'silhouette'] + (['mystery'] if sp in FANTASY else [])
        for k in need:
            p = f'{ROOT}/dex/pet_{sp}_dex_{k}.png'
            if not os.path.exists(p):
                fail(f'缺图鉴 {p}'); continue
            im = Image.open(p).convert('RGBA')
            check_complete(im, f"dex/{sp}_{k}", canvas=im.size[0], check_fill=(k!="mystery"))
            if k == 'silhouette':  # 剪影不得被削平顶（头部一刀切）
                a = im.split()[-1]; bb = a.getbbox()
                if bb:
                    row = [a.getpixel((x, bb[1])) for x in range(bb[0], bb[2])]
                    flat = sum(1 for v in row if v >= SOLID)
                    if flat > 0.55 * (bb[2]-bb[0]):
                        fail(f'dex/{sp}_silhouette: 顶部疑似被削平（头部一刀切）')

def _fill_base(img):
    bb = alpha_bbox(img)
    if not bb:
        return None, None
    w, h = img.size
    return max(bb[2]-bb[0], bb[3]-bb[1]) / w, bb[3] / h  # (占比, 贴地基线)

MATCH_TOL = 0.10  # 静态↔动作 屏上尺寸允许差异

def check_static_action_match():
    """静态立绘(各阶段)与动作条主体的屏上尺寸/基线必须一致，否则播动作忽大忽小。"""
    for sp in SPECIES:
        # 参考：各阶段 var01 立绘的占比/基线
        base = {}
        for st in STAGES:
            p = f'{ROOT}/{sp}/pet_{sp}_var01_stage{st}.png'
            if os.path.exists(p):
                base[st] = _fill_base(Image.open(p).convert('RGBA'))
        if 'C' not in base or base['C'][0] is None:
            continue
        ref_fill, ref_base = base['C']
        # 各阶段之间也要一致（动画在任意阶段触发）
        for st, (fl, bs) in base.items():
            if fl and abs(fl - ref_fill) > MATCH_TOL:
                fail(f'{sp}: stage{st} 占比({fl*100:.0f}%) 与 stageC({ref_fill*100:.0f}%) 差异>{int(MATCH_TOL*100)}% → 换档忽大忽小')
        # 动作条 vs 立绘
        for act in ACTIONS:
            p = f'{ROOT}/{sp}/actions/pet_{sp}_var01_stageC_{act}.png'
            if not os.path.exists(p):
                continue
            im = Image.open(p).convert('RGBA')
            if im.size != (4096, 512):
                continue
            fl, bs = _fill_base(im.crop((0, 0, 512, 512)))
            if fl and abs(fl - ref_fill) > MATCH_TOL:
                fail(f'{sp}/{act}: 动作占比({fl*100:.0f}%) 与静态({ref_fill*100:.0f}%) 差异>{int(MATCH_TOL*100)}% → 播动作突兀')
            if bs and abs(bs - ref_base) > FRAME_BASE_TOL:
                fail(f'{sp}/{act}: 动作基线与静态不一致 → 播动作位置跳')

def check_id_dir_match():
    """species.json 的 id 必须与美术目录/文件命名一致（防 cham≠pet_chameleon 这类空白）。"""
    import json
    try:
        items = json.load(open('assets/data/species.json'))['items']
    except Exception:
        return
    for s in items:
        d = s['id'].replace('pet_', '')
        if not os.path.isdir(f'{ROOT}/{d}'):
            fail(f'{s["id"]}: 美术目录 {ROOT}/{d}/ 不存在（id↔目录不匹配 → app 空白）')
        if not os.path.exists(f'{ROOT}/portraits/pet_{d}.png'):
            fail(f'{s["id"]}: 头像 portraits/pet_{d}.png 不存在（id↔命名不匹配）')
        if not os.path.exists(f'{ROOT}/dex/{s["id"]}_dex_color.png'):
            fail(f'{s["id"]}: 图鉴 dex/{s["id"]}_dex_color.png 不存在（id↔命名不匹配）')

def check_postcard_naming():
    """明信片贴纸/姿态目录也必须用完整物种名，不得沿用旧缩写（防 cham 类命名再现）。"""
    import re
    for f in glob.glob('assets/art/postcards/stickers/*.png') + glob.glob('assets/art/postcards/poses/*.png'):
        base = os.path.basename(f)
        if re.search(r'(?<![a-z])cham(?![a-z])', base):
            fail(f'{f}: 使用了变色龙旧缩写 cham（应为 chameleon）')

check_id_dir_match(); check_postcard_naming(); check_base(); check_actions(); check_dex(); check_static_action_match()
print('=' * 50)
if FAILS:
    print(f'❌ {len(FAILS)} 项 FAIL：')
    for f in FAILS[:60]:
        print('  -', f)
    if len(FAILS) > 60:
        print(f'  … 另有 {len(FAILS)-60} 项')
    raise SystemExit(1)
print('✅ 全部通过：尺寸/无截断/边距/占比/帧稳定/剪影 均达标')
