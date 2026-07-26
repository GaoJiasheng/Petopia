#!/usr/bin/env python3
"""Validate Profile-mode Flutter frame timing output from a physical device."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


REQUIRED_METRICS = {
    "frame_count",
    "90th_percentile_frame_build_time_millis",
    "99th_percentile_frame_build_time_millis",
    "90th_percentile_frame_rasterizer_time_millis",
    "99th_percentile_frame_rasterizer_time_millis",
    "missed_frame_build_budget_count",
    "missed_frame_rasterizer_budget_count",
}


def find_report(value: Any, report_key: str) -> dict[str, Any] | None:
    if not isinstance(value, dict):
        return None
    candidate = value.get(report_key)
    if isinstance(candidate, dict) and REQUIRED_METRICS <= candidate.keys():
        return candidate
    if REQUIRED_METRICS <= value.keys():
        return value
    for child in value.values():
        report = find_report(child, report_key)
        if report is not None:
            return report
    return None


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Check Flutter Profile frame timing against the Petopia launch budget."
    )
    parser.add_argument("report", type=Path)
    parser.add_argument("--report-key", default="care_interactions")
    parser.add_argument("--p90-ms", type=float, default=16.0)
    parser.add_argument("--p99-ms", type=float, default=32.0)
    parser.add_argument("--max-missed-ratio", type=float, default=0.05)
    args = parser.parse_args()

    try:
        payload = json.loads(args.report.read_text())
    except (OSError, json.JSONDecodeError) as error:
        parser.error(f"cannot read performance report: {error}")
    report = find_report(payload, args.report_key)
    if report is None:
        parser.error(f"report key {args.report_key!r} has no frame timing summary")

    frame_count = int(report["frame_count"])
    failures: list[str] = []
    if frame_count < 60:
        failures.append(f"only {frame_count} frames were sampled; expected at least 60")

    for phase in ("build", "rasterizer"):
        p90 = float(report[f"90th_percentile_frame_{phase}_time_millis"])
        p99 = float(report[f"99th_percentile_frame_{phase}_time_millis"])
        missed = int(report[f"missed_frame_{phase}_budget_count"])
        missed_ratio = missed / max(1, frame_count)
        if p90 > args.p90_ms:
            failures.append(f"{phase} p90 {p90:.2f}ms exceeds {args.p90_ms:.2f}ms")
        if p99 > args.p99_ms:
            failures.append(f"{phase} p99 {p99:.2f}ms exceeds {args.p99_ms:.2f}ms")
        if missed_ratio > args.max_missed_ratio:
            failures.append(
                f"{phase} missed-frame ratio {missed_ratio:.2%} exceeds "
                f"{args.max_missed_ratio:.2%}"
            )

    if failures:
        print(f"FAIL: Profile frame budget ({frame_count} frames)")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print(
        "PASS: Profile frame budget "
        f"({frame_count} frames, "
        f"build p90/p99="
        f"{report['90th_percentile_frame_build_time_millis']:.2f}/"
        f"{report['99th_percentile_frame_build_time_millis']:.2f}ms, "
        f"raster p90/p99="
        f"{report['90th_percentile_frame_rasterizer_time_millis']:.2f}/"
        f"{report['99th_percentile_frame_rasterizer_time_millis']:.2f}ms)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
