#!/usr/bin/env python3
"""Deterministic local release gate for Petopia iOS/App Store candidates."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FAILURES: list[str] = []


def run(label: str, command: list[str]) -> None:
    print(f"\n== {label} ==", flush=True)
    result = subprocess.run(command, cwd=ROOT, check=False)
    if result.returncode:
        FAILURES.append(f"{label} exited with {result.returncode}")


def require(condition: bool, message: str) -> None:
    if not condition:
        FAILURES.append(message)


def static_checks() -> None:
    pubspec = (ROOT / "pubspec.yaml").read_text()
    version_match = re.search(r"^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$", pubspec, re.M)
    require(version_match is not None, "pubspec version must use x.y.z+build format")
    require("A new Flutter project" not in pubspec, "pubspec description is still the template")

    privacy = ROOT / "ios/Runner/PrivacyInfo.xcprivacy"
    project = (ROOT / "ios/Runner.xcodeproj/project.pbxproj").read_text()
    require(privacy.exists(), "missing ios/Runner/PrivacyInfo.xcprivacy")
    require(
        project.count("PrivacyInfo.xcprivacy") >= 3,
        "privacy manifest is not referenced by the Runner resources target",
    )

    info = (ROOT / "ios/Runner/Info.plist").read_text()
    require("ITSAppUsesNonExemptEncryption" in info, "missing encryption declaration")
    require("CFBundleLocalizations" in info, "missing app localization declaration")

    settings = (ROOT / "lib/ui/settings_screen.dart").read_text()
    require("appInfoProvider" in settings, "settings version is not read from package metadata")
    require("导出存档" in settings and "导入存档" in settings, "backup controls are missing")

    generated = ROOT / "assets/data/locations.json"
    if generated.exists():
        data = json.loads(generated.read_text())
        locations = data.get("items") or data.get("locations") or []
        require(len(locations) == 40, f"expected 40 travel locations, found {len(locations)}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--skip-flutter",
        action="store_true",
        help="run only static, plist, and raster checks",
    )
    args = parser.parse_args()

    static_checks()
    run("plist validation", ["plutil", "-lint", "ios/Runner/Info.plist", "ios/Runner/PrivacyInfo.xcprivacy"])
    run("runtime raster audit", [sys.executable, "tools/audit_runtime_art.py"])
    if not args.skip_flutter:
        run("Flutter analyze", ["flutter", "analyze"])
        run("Flutter tests", ["flutter", "test"])

    print("\n== release result ==")
    if FAILURES:
        for failure in FAILURES:
            print(f"FAIL: {failure}")
        return 1
    print("PASS: release candidate checks are green")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
