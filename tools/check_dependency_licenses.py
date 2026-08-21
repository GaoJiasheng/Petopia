#!/usr/bin/env python3
"""Audit licenses for every Dart/Flutter package in the resolved build graph."""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from collections import Counter
from pathlib import Path
from urllib.parse import unquote, urlparse


ROOT = Path(__file__).resolve().parents[1]
PACKAGE_CONFIG = ROOT / ".dart_tool/package_config.json"
LICENSE_FILENAMES = (
    "LICENSE",
    "LICENSE.md",
    "LICENSE.txt",
    "COPYING",
    "COPYING.md",
)
BLOCKED_MARKERS = {
    "AGPL": "GNU AFFERO GENERAL PUBLIC LICENSE",
    "GPL": "GNU GENERAL PUBLIC LICENSE",
    "SSPL": "SERVER SIDE PUBLIC LICENSE",
}
COMPOSITE_NOTICE_PACKAGES = {"sky_engine"}


def resolve_uri(value: str, base: Path) -> Path:
    parsed = urlparse(value)
    if parsed.scheme == "file":
        return Path(unquote(parsed.path)).resolve()
    if parsed.scheme:
        raise ValueError(f"unsupported package root URI: {value}")
    return (base / unquote(value)).resolve()


def find_license(package_root: Path, flutter_license: Path | None) -> Path | None:
    for filename in LICENSE_FILENAMES:
        candidate = package_root / filename
        if candidate.is_file():
            return candidate

    if flutter_license is not None and "flutter" in package_root.parts:
        return flutter_license
    return None


def classify_license(text: str) -> str:
    normalized = " ".join(text.upper().split())
    if "MOZILLA PUBLIC LICENSE VERSION 2.0" in normalized:
        return "MPL-2.0"
    if "APACHE LICENSE VERSION 2.0" in normalized:
        return "Apache-2.0"
    if "PERMISSION IS HEREBY GRANTED, FREE OF CHARGE" in normalized:
        return "MIT"
    if "REDISTRIBUTION AND USE IN SOURCE AND BINARY FORMS" in normalized:
        if "NEITHER THE NAME" in normalized:
            return "BSD-3-Clause"
        return "BSD-2-Clause"
    return "UNKNOWN"


def flutter_sdk_license() -> Path | None:
    executable = shutil.which("flutter")
    if executable is None:
        return None
    candidate = Path(executable).resolve().parent.parent / "LICENSE"
    return candidate if candidate.is_file() else None


def audit() -> tuple[list[dict[str, str]], list[str]]:
    if not PACKAGE_CONFIG.is_file():
        return [], ["missing .dart_tool/package_config.json; run flutter pub get"]

    config = json.loads(PACKAGE_CONFIG.read_text())
    flutter_license = flutter_sdk_license()
    records: list[dict[str, str]] = []
    failures: list[str] = []
    base = PACKAGE_CONFIG.parent

    for package in sorted(config.get("packages", []), key=lambda item: item["name"]):
        name = package["name"]
        if name == "petopia":
            continue
        try:
            package_root = resolve_uri(package["rootUri"], base)
        except ValueError as error:
            failures.append(f"{name}: {error}")
            continue

        license_path = find_license(package_root, flutter_license)
        if license_path is None:
            failures.append(f"{name}: no LICENSE or COPYING file found")
            continue

        text = license_path.read_text(errors="replace")
        license_id = (
            "Composite-SDK-Notices"
            if name in COMPOSITE_NOTICE_PACKAGES
            else classify_license(text)
        )
        license_header = text[:1000].upper()
        blocked = [
            key
            for key, marker in BLOCKED_MARKERS.items()
            if marker in license_header
        ]
        if blocked:
            failures.append(f"{name}: blocked license marker {', '.join(blocked)}")
        if license_id == "UNKNOWN":
            failures.append(f"{name}: unclassified license at {license_path}")

        try:
            display_path = str(license_path.relative_to(ROOT))
        except ValueError:
            display_path = str(license_path)
        records.append(
            {
                "name": name,
                "license": license_id,
                "licensePath": display_path,
            }
        )

    return records, failures


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true", help="print machine-readable output")
    args = parser.parse_args()

    records, failures = audit()
    counts = Counter(record["license"] for record in records)
    if args.json:
        print(
            json.dumps(
                {
                    "packageCount": len(records),
                    "licenses": dict(sorted(counts.items())),
                    "packages": records,
                    "failures": failures,
                },
                indent=2,
                ensure_ascii=True,
            )
        )
    else:
        print(f"Audited {len(records)} resolved Dart/Flutter packages")
        for license_id, count in sorted(counts.items()):
            print(f"  {license_id}: {count}")
        for failure in failures:
            print(f"FAIL: {failure}")

    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
