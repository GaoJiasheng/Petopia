#!/usr/bin/env python3
"""Synchronize one ordered App Store screenshot set from a local directory."""

from __future__ import annotations

import argparse
import hashlib
import json
import time
from pathlib import Path

from app_store_connect_api import request, upload_screenshot


def _json_body(value: object) -> bytes:
    return json.dumps(value, separators=(",", ":")).encode()


def _wait_until_complete(screenshot_id: str) -> dict[str, object]:
    for _ in range(60):
        response = request("GET", f"/v1/appScreenshots/{screenshot_id}", None)
        screenshot = response["data"]
        state = screenshot["attributes"]["assetDeliveryState"]["state"]
        if state == "COMPLETE":
            return screenshot
        if state == "FAILED":
            errors = screenshot["attributes"]["assetDeliveryState"].get("errors")
            raise SystemExit(f"Screenshot {screenshot_id} failed: {errors}")
        time.sleep(2)
    raise SystemExit(f"Screenshot {screenshot_id} did not finish processing")


def _find_or_create_set(localization_id: str, display_type: str) -> str:
    response = request(
        "GET",
        f"/v1/appStoreVersionLocalizations/{localization_id}/appScreenshotSets?limit=50",
        None,
    )
    matches = [
        item
        for item in response["data"]
        if item["attributes"]["screenshotDisplayType"] == display_type
    ]
    if len(matches) == 1:
        return matches[0]["id"]
    if matches:
        raise SystemExit(f"Multiple screenshot sets found for {display_type}")
    created = request(
        "POST",
        "/v1/appScreenshotSets",
        _json_body(
            {
                "data": {
                    "type": "appScreenshotSets",
                    "attributes": {"screenshotDisplayType": display_type},
                    "relationships": {
                        "appStoreVersionLocalization": {
                            "data": {
                                "type": "appStoreVersionLocalizations",
                                "id": localization_id,
                            }
                        }
                    },
                }
            }
        ),
    )
    return created["data"]["id"]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--localization-id", required=True)
    parser.add_argument("--display-type", required=True)
    parser.add_argument("--source-dir", type=Path, required=True)
    args = parser.parse_args()

    files = sorted(args.source_dir.glob("*.png"))
    if not files:
        raise SystemExit(f"No PNG files found in {args.source_dir}")

    screenshot_set_id = _find_or_create_set(
        args.localization_id,
        args.display_type,
    )
    response = request(
        "GET",
        f"/v1/appScreenshotSets/{screenshot_set_id}/appScreenshots?limit=200",
        None,
    )
    remote = {item["attributes"]["fileName"]: item for item in response["data"]}
    desired_names = {file_path.name for file_path in files}

    ordered_ids: list[str] = []
    for file_path in files:
        checksum = hashlib.md5(file_path.read_bytes()).hexdigest()
        existing = remote.get(file_path.name)
        if existing and existing["attributes"]["sourceFileChecksum"] == checksum:
            ordered_ids.append(existing["id"])
            print(f"keep {file_path.name}")
            continue
        if existing:
            request("DELETE", f"/v1/appScreenshots/{existing['id']}", None)
            print(f"replace {file_path.name}")
        else:
            print(f"add {file_path.name}")
        committed = upload_screenshot(file_path, screenshot_set_id)
        screenshot_id = committed["data"]["id"]
        _wait_until_complete(screenshot_id)
        ordered_ids.append(screenshot_id)

    for file_name, existing in remote.items():
        if file_name not in desired_names:
            request("DELETE", f"/v1/appScreenshots/{existing['id']}", None)
            print(f"delete {file_name}")

    request(
        "PATCH",
        f"/v1/appScreenshotSets/{screenshot_set_id}/relationships/appScreenshots",
        _json_body(
            {
                "data": [
                    {"type": "appScreenshots", "id": screenshot_id}
                    for screenshot_id in ordered_ids
                ]
            }
        ),
    )
    verified = request(
        "GET",
        f"/v1/appScreenshotSets/{screenshot_set_id}/appScreenshots?limit=200",
        None,
    )
    actual_names = [item["attributes"]["fileName"] for item in verified["data"]]
    expected_names = [file_path.name for file_path in files]
    if actual_names != expected_names:
        raise SystemExit(
            f"Screenshot order mismatch: expected {expected_names}, got {actual_names}"
        )
    print(f"complete {args.display_type}: {', '.join(actual_names)}")


if __name__ == "__main__":
    main()
