#!/usr/bin/env python3
"""Petopia · Minimax 批量任务派发器

把耗 token 的机械活（如内容 md→JSON 转换、样板数据生成）外包给 Minimax。
读取 .env / 环境变量中的 MINIMAX_API_KEY / MINIMAX_BASE_URL / MINIMAX_MODEL /
MINIMAX_CHAT_PATH，向 Minimax（OpenAI 兼容 chat completions）发送一个任务，
把回复写到 --out（或 stdout）。仅依赖标准库。

用法:
  python3 tools/minimax_dispatch.py --ping
  python3 tools/minimax_dispatch.py --system sys.md --prompt task.md --out out.json
  cat task.md | python3 tools/minimax_dispatch.py            # 从 stdin 读 prompt

约定：派发前由 Claude（监工）产出自包含的 system+prompt（含"只输出 JSON、
不要解释"之类硬约束），产物落回仓库后由 Claude 评审再合并。
"""
import argparse
import json
import os
import sys
import urllib.request
import urllib.error


def load_dotenv(path=".env"):
    """极简 .env 解析：KEY=VALUE，忽略注释与空行。不覆盖已存在的环境变量。"""
    if not os.path.exists(path):
        return
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            k, v = k.strip(), v.strip().strip('"').strip("'")
            os.environ.setdefault(k, v)


def cfg():
    load_dotenv()
    key = os.environ.get("MINIMAX_API_KEY", "").strip()
    if not key:
        sys.exit("✗ 缺少 MINIMAX_API_KEY（放进 .env 或 export）")
    base = os.environ.get("MINIMAX_BASE_URL", "https://api.minimaxi.com/v1").rstrip("/")
    path = os.environ.get("MINIMAX_CHAT_PATH", "/chat/completions")
    model = os.environ.get("MINIMAX_MODEL", "MiniMax-M2")
    return key, base + path, model


def call(system, prompt, temperature=0.3, max_tokens=None):
    key, url, model = cfg()
    messages = []
    if system:
        messages.append({"role": "system", "content": system})
    messages.append({"role": "user", "content": prompt})
    payload = {"model": model, "messages": messages, "temperature": temperature}
    if max_tokens:
        payload["max_tokens"] = max_tokens
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=300) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        sys.exit(f"✗ HTTP {e.code}: {e.read().decode('utf-8', 'ignore')[:800]}")
    except urllib.error.URLError as e:
        sys.exit(f"✗ 网络错误: {e}")
    try:
        return data["choices"][0]["message"]["content"]
    except (KeyError, IndexError):
        sys.exit("✗ 非预期响应结构:\n" + json.dumps(data, ensure_ascii=False)[:800])


def read_arg(val):
    """--system/--prompt 支持传文件路径或直接传字符串。"""
    if val and os.path.exists(val):
        with open(val, "r", encoding="utf-8") as f:
            return f.read()
    return val


def main():
    ap = argparse.ArgumentParser(description="Minimax 批量任务派发器")
    ap.add_argument("--system", help="system 提示（文件路径或字符串）")
    ap.add_argument("--prompt", help="user 任务（文件路径或字符串；缺省读 stdin）")
    ap.add_argument("--out", help="输出文件（缺省打印到 stdout）")
    ap.add_argument("--temperature", type=float, default=0.3)
    ap.add_argument("--max-tokens", type=int, default=None)
    ap.add_argument("--ping", action="store_true", help="连通性自检（小额调用）")
    args = ap.parse_args()

    if args.ping:
        out = call("You are a health check.", "回复且仅回复：pong", temperature=0)
        print("✓ 连通:", out.strip())
        return

    prompt = read_arg(args.prompt) if args.prompt else sys.stdin.read()
    if not prompt.strip():
        sys.exit("✗ 缺少 prompt（--prompt 或 stdin）")
    system = read_arg(args.system) if args.system else None

    out = call(system, prompt, temperature=args.temperature, max_tokens=args.max_tokens)
    if args.out:
        with open(args.out, "w", encoding="utf-8") as f:
            f.write(out)
        print(f"✓ 已写入 {args.out}（{len(out)} 字）")
    else:
        sys.stdout.write(out)


if __name__ == "__main__":
    main()
