#!/usr/bin/env python3
"""确定性解析 docs/content-postcards.md → assets/data/postcard_templates.json，
并给 locations.json 每个地点补一个「按类别的规范 vibe」以便 incident 匹配。"""
import json, re, sys, collections

SRC = "docs/content-postcards.md"
OUT = "assets/data/postcard_templates.json"
LOC = "assets/data/locations.json"

PNAME2ID = {
    "贪吃": "p_glutton", "慵懒": "p_lazy", "好奇": "p_curious", "胆小": "p_timid",
    "活力": "p_energetic", "黏人": "p_clingy", "高冷": "p_aloof", "淘气": "p_naughty",
    "温柔": "p_gentle", "爱幻想": "p_dreamy",
}
CAT2POOL = {
    "海滨": "enc_seaside", "山地": "enc_mountain", "城市": "enc_city", "乡野": "enc_countryside",
    "森林": "enc_forest", "沙漠异域": "enc_desert", "极地水域": "enc_polar", "奇幻": "enc_fantasy",
}
CAT2VIBE = {
    "海滨": "seaside", "山地": "mountain", "城市": "city", "乡野": "countryside",
    "森林": "forest", "沙漠异域": "desert", "极地水域": "polar", "奇幻": "fantasy",
}
POSE = {
    "惊讶": "surprise", "合影": "photo", "眺望": "gaze", "睡": "sleep", "吃": "eat",
    "跑": "run", "奔跑": "run", "泡": "soak", "泡澡": "soak", "戏水": "soak",
    "戴帽": "hat", "帽": "hat", "凝视": "gaze", "发呆": "idle", "玩": "run",
}

def bias(cell):
    cell = cell.strip()
    if not cell or cell in ("—", "-", "各×1"):
        return {}
    out = {}
    for name in re.split(r"[、，,/\s]+", cell):
        name = name.strip()
        if name in PNAME2ID:
            out[PNAME2ID[name]] = 2.0
    return out

def pose_of(cell):
    cell = cell.strip()
    for k, v in POSE.items():
        if k in cell:
            return v
    return "idle"

def main():
    lines = open(SRC, encoding="utf-8").read().splitlines()
    section = 0
    persona = None
    tcat = None            # 当前模板类别（§2）
    ecat = None            # 当前遭遇类别（§3）
    icat = None            # 当前碰撞类别（§4）
    templates, encounters, incidents = [], [], []

    tpl_re = re.compile(r"`(tpl_[a-z0-9_]+)`「(.+)」\s*\[([^\]]*)\]\s*[｜|]\s*(?:\*\*)?要点(?:\*\*)?[:：](.+)")
    enc_re = re.compile(r"^\|\s*(enc_[a-z0-9_]+)\s*\|([^|]*)\|([^|]*)\|([^|]*)\|")
    inc_re = re.compile(r"^\|\s*(inc_[a-z0-9_]+)\s*\|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|")
    p_re = re.compile(r"^##\s*2\.\d+\s*\S*?（(p_\w+)）")
    tcat_re = re.compile(r"^###\s*2\.\d+\.\d+\s*(\S+)")
    ecat_re = re.compile(r"^##\s*3\.\d+\s*(\S+?)（")
    icat_re = re.compile(r"^##\s*4\.\d+\s*.*?（(\S+?)）")

    for ln in lines:
        if ln.startswith("# 2."): section = 2
        elif ln.startswith("# 3."): section = 3
        elif ln.startswith("# 4."): section = 4
        elif ln.startswith("# 5.") or ln.startswith("# 6."): section = 9

        if section == 2:
            m = p_re.match(ln)
            if m: persona = m.group(1); continue
            m = tcat_re.match(ln)
            if m: tcat = m.group(1); continue
            m = tpl_re.search(ln)
            if m and persona and tcat:
                skel = m.group(2).strip()
                slots = sorted(set(re.findall(r"\{(\w+)\}", skel)))
                templates.append({
                    "id": m.group(1), "personalityId": persona, "category": tcat,
                    "skeleton": skel, "slots": slots, "tone": m.group(4).strip(),
                })
        elif section == 3:
            m = ecat_re.match(ln)
            if m: ecat = m.group(1); continue
            m = enc_re.match(ln)
            if m and ecat:
                encounters.append({
                    "id": m.group(1).strip(), "poolId": CAT2POOL[ecat],
                    "phrase": m.group(3).strip(), "personalityBias": bias(m.group(4)),
                })
        elif section == 4:
            m = icat_re.match(ln)
            if m: icat = m.group(1); continue
            m = inc_re.match(ln)
            if m and icat and not m.group(1).startswith("inc_id"):
                incidents.append({
                    "id": m.group(1).strip(), "vibe": CAT2VIBE[icat],
                    "phrase": m.group(3).strip(), "poseHint": pose_of(m.group(5)),
                    "personalityBias": bias(m.group(4)),
                })

    doc = {"schemaVersion": 1, "templates": templates,
           "encounters": encounters, "incidents": incidents}
    json.dump(doc, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)

    # locations.json：补规范 vibe（幂等）
    ld = json.load(open(LOC, encoding="utf-8"))
    changed = 0
    for l in ld["items"]:
        v = CAT2VIBE.get(l["category"])
        if v and v not in l.get("vibeTags", []):
            l.setdefault("vibeTags", []).append(v); changed += 1
    json.dump(ld, open(LOC, "w", encoding="utf-8"), ensure_ascii=False, indent=1)

    # 报告
    tc = collections.Counter((t["personalityId"], t["category"]) for t in templates)
    print(f"templates={len(templates)} encounters={len(encounters)} incidents={len(incidents)}")
    print(f"persona×cat combos={len(tc)} (期望 80)  locations patched={changed}")
    miss = [k for k in tc if tc[k] < 3]
    if miss: print("WARN <3 骨架的组合:", miss[:10])
    empt = [t["id"] for t in templates if not t["slots"]]
    if empt: print("WARN 无槽位模板:", empt[:5])

main()
