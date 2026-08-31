#!/usr/bin/env python3
"""Poll App Store Connect for review-state changes; print only on change."""
import json, os, subprocess, sys, time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CLI = os.path.join(ROOT, "tools", "app_store_connect_api.py")
APP = "6787161287"
INTERVAL = int(os.environ.get("ASC_WATCH_INTERVAL", "3600"))
STATE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".asc_watch_state.json")
TERMINAL = {
    "PENDING_DEVELOPER_RELEASE", "READY_FOR_SALE", "REJECTED",
    "DEVELOPER_REJECTED", "METADATA_REJECTED", "INVALID_BINARY",
}

def get(path):
    out = subprocess.run([sys.executable, CLI, "GET", path, "--compact"],
                         capture_output=True, text=True, timeout=90)
    if out.returncode != 0:
        raise RuntimeError(out.stderr.strip()[:300])
    return json.loads(out.stdout)

def snapshot():
    v = get(f"/v1/apps/{APP}/appStoreVersions?limit=1&fields[appStoreVersions]=versionString,appStoreState")
    ver = v["data"][0]["attributes"]["appStoreState"] if v.get("data") else "NONE"
    r = get(f"/v1/apps/{APP}/reviewSubmissions?filter[platform]=IOS&limit=1")
    sub = r["data"][0]["attributes"]["state"] if r.get("data") else "NONE"
    return ver, sub

def load_prev():
    try:
        with open(STATE) as f:
            return tuple(json.load(f))
    except Exception:
        return None


def save_prev(cur):
    try:
        with open(STATE, "w") as f:
            json.dump(list(cur), f)
    except Exception:
        pass


prev = load_prev()
if prev is not None:
    print(f"[watch] 恢复基线 版本={prev[0]} 提审={prev[1]}，每 {INTERVAL // 60} 分钟查一次", flush=True)
while True:
    try:
        cur = snapshot()
    except Exception as e:
        print(f"[warn] 查询失败: {e}", flush=True)
        time.sleep(INTERVAL); continue
    if prev is None:
        print(f"[watch] 起始状态 版本={cur[0]} 提审={cur[1]}", flush=True)
    elif cur != prev:
        print(f"[变化] 版本 {prev[0]} -> {cur[0]} ｜ 提审 {prev[1]} -> {cur[1]}", flush=True)
    prev = cur
    save_prev(cur)
    if cur[0] in TERMINAL:
        print(f"[终态] 版本状态 = {cur[0]}，监控结束", flush=True)
        break
    time.sleep(INTERVAL)
