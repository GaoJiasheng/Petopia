#!/usr/bin/env python3
"""Capture the yard on four booted iOS devices, including both iPad orientations."""
from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
# Physical pixels. The Flutter harness also synchronizes MediaQuery's viewport.
PROFILES = {
    "iphone69-port": ("iPhone-17-Pro-Max", 1320, 2868),
    "iphone61-port": ("iPhone-17e", 1170, 2532),
    "ipadmini-port": ("iPad-mini-A17-Pro", 1488, 2266),
    "ipad13-port": ("iPad-Pro-13-inch-M5", 2064, 2752),
    "ipadmini-land": ("iPad-mini-A17-Pro", 2266, 1488),
    "ipad13-land": ("iPad-Pro-13-inch-M5", 2752, 2064),
}
SUITES = {
    "placements": ("PETOPIA_VISUAL_PLACEMENTS", 51),
    "themes": ("PETOPIA_VISUAL_ALL_THEMES", 12),
    "luxury": ("PETOPIA_VISUAL_ALL_LUXURY", 6),
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", help="The booted iPhone UDID used to start the release gate")
    parser.add_argument("--suite", choices=SUITES, default="placements")
    parser.add_argument("--configs", nargs="+", choices=PROFILES, default=list(PROFILES))
    parser.add_argument("--output", type=Path, default=ROOT / "build/yard-visual-matrix")
    args = parser.parse_args()
    inventory = json.loads(subprocess.check_output(
        ["xcrun", "simctl", "list", "devices", "booted", "--json"], text=True))
    devices = [d for runtime in inventory["devices"].values() for d in runtime
               if d.get("isAvailable") and d["state"] == "Booted"]
    if args.device and not any(d["udid"] == args.device and "iPhone" in d["deviceTypeIdentifier"]
                               for d in devices):
        parser.error("--device must identify a booted iPhone simulator")
    selected = []
    for config in args.configs:
        model, width, height = PROFILES[config]
        matches = [d for d in devices if f".{model}" in d["deviceTypeIdentifier"]]
        if args.device:
            matches.sort(key=lambda d: d["udid"] != args.device)
        if not matches:
            parser.error(f"Boot the {model} simulator required by {config}")
        if len(matches) > 1 and matches[0]["udid"] != args.device:
            parser.error(f"Multiple booted {model} simulators; keep one booted for this audit")
        selected.append((config, matches[0], width, height))
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    define, count = SUITES[args.suite]
    results = []
    for config, device, width, height in selected:
        destination = output / args.suite / config
        destination.mkdir(parents=True, exist_ok=True)
        # Never accept an old capture as evidence for this run.
        for old in destination.glob("yard-*.png"):
            old.unlink()
        command = ["flutter", "test", "integration_test/yard_home_visual_test.dart",
                   "-d", device["udid"], f"--dart-define={define}=true",
                   "--dart-define=PETOPIA_VISUAL_HOUR=10",
                   f"--dart-define=PETOPIA_VISUAL_EXPECTED_WIDTH={width}",
                   f"--dart-define=PETOPIA_VISUAL_EXPECTED_HEIGHT={height}",
                   f"--dart-define=PETOPIA_VISUAL_DIR={destination}"]
        if width > height:
            command.append("--dart-define=PETOPIA_VISUAL_LANDSCAPE=true")
        log = output / f"{args.suite}-{config}.log"
        print(f"START {args.suite} {config} {width}x{height}", flush=True)
        with log.open("w") as stream:
            code = subprocess.run(command, cwd=ROOT, stdout=stream,
                                  stderr=subprocess.STDOUT, check=False).returncode
        captures = sorted(destination.glob("yard-*.png"))
        sizes = {}
        for path in captures:
            with Image.open(path) as image:
                sizes[path.name] = list(image.size)
        passed = code == 0 and len(captures) == count and all(
            size == [width, height] for size in sizes.values())
        results.append(dict(config=config, device=device["udid"], command=command,
                            exit_code=code, expected_pixels=[width, height],
                            captures=sizes, expected_count=count, passed=passed, log=str(log)))
        (output / f"{args.suite}-results.json").write_text(
            json.dumps(results, indent=2, ensure_ascii=False) + "\n")
        print(f"{'PASS' if passed else 'FAIL'} {config}: {len(captures)}/{count}; {log}", flush=True)
        if not passed:
            print(log.read_text()[-12000:])
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
