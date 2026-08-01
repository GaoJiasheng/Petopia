#!/usr/bin/env python3
"""Synchronize Petopia's localized TestFlight metadata for an internal build."""

from __future__ import annotations

import argparse
import json

from app_store_connect_api import request


APP_ID = "6787161287"
FEEDBACK_EMAIL = "gaojiasheng.him@foxmail.com"
MARKETING_URL = "https://blog.gavingao.cn/petopia/"
PRIVACY_URL = "https://blog.gavingao.cn/petopia/privacy.html"

BETA_APP_LOCALIZATIONS = {
    "en-US": (
        "A quiet, local-first watercolor companion game. Raise one pet at a "
        "time, share everyday moments, and receive postcards after graduation. "
        "No account, ads, analytics, or tracking."
    ),
    "zh-Hans": (
        "一款安静、以本地存档为核心的水彩陪伴游戏。一次陪一位宠物长大，"
        "在毕业后收下它从旅途寄回的明信片。无账号、无广告、无分析与追踪。"
    ),
}

BETA_BUILD_LOCALIZATIONS = {
    "en-US": (
        "Internal testing build. The small +1 button in the upper-right advances "
        "local game time by one day for manual event testing. This control is "
        "compiled out of App Store builds. Please verify postcard cadence, "
        "visitors, returning companions, cooldowns, and save stability."
    ),
    "zh-Hans": (
        "内部测试版本。右上角的小型“+1”按钮会把本地游戏时间推进一天，便于人工"
        "验证事件；正式 App Store 构建会在编译时彻底移除该入口。请重点检查明信片"
        "节奏、每日来客、毕业伙伴回访、互动冷却和存档稳定性。"
    ),
}


def _body(value: object) -> bytes:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":")).encode()


def _patch(resource_type: str, resource_id: str, attributes: dict[str, object]) -> None:
    request(
        "PATCH",
        f"/v1/{resource_type}/{resource_id}",
        _body(
            {
                "data": {
                    "type": resource_type,
                    "id": resource_id,
                    "attributes": attributes,
                }
            }
        ),
    )


def _sync_app_localizations() -> None:
    existing = request(
        "GET", f"/v1/apps/{APP_ID}/betaAppLocalizations?limit=50", None
    )["data"]
    by_locale = {item["attributes"]["locale"]: item for item in existing}
    for locale, description in BETA_APP_LOCALIZATIONS.items():
        attributes = {
            "description": description,
            "feedbackEmail": FEEDBACK_EMAIL,
            "marketingUrl": MARKETING_URL,
            "privacyPolicyUrl": PRIVACY_URL,
        }
        current = by_locale.get(locale)
        if current:
            _patch("betaAppLocalizations", current["id"], attributes)
        else:
            request(
                "POST",
                "/v1/betaAppLocalizations",
                _body(
                    {
                        "data": {
                            "type": "betaAppLocalizations",
                            "attributes": {"locale": locale, **attributes},
                            "relationships": {
                                "app": {
                                    "data": {"type": "apps", "id": APP_ID}
                                }
                            },
                        }
                    }
                ),
            )
        print(f"beta app metadata: {locale}")


def _sync_build_localizations(build_id: str) -> None:
    existing = request(
        "GET", f"/v1/builds/{build_id}/betaBuildLocalizations?limit=50", None
    )["data"]
    by_locale = {item["attributes"]["locale"]: item for item in existing}
    for locale, whats_new in BETA_BUILD_LOCALIZATIONS.items():
        current = by_locale.get(locale)
        if current:
            _patch(
                "betaBuildLocalizations", current["id"], {"whatsNew": whats_new}
            )
        else:
            request(
                "POST",
                "/v1/betaBuildLocalizations",
                _body(
                    {
                        "data": {
                            "type": "betaBuildLocalizations",
                            "attributes": {"locale": locale, "whatsNew": whats_new},
                            "relationships": {
                                "build": {
                                    "data": {"type": "builds", "id": build_id}
                                }
                            },
                        }
                    }
                ),
            )
        print(f"build What's New: {locale}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--build", default="21")
    args = parser.parse_args()

    builds = request(
        "GET",
        f"/v1/builds?filter[app]={APP_ID}&filter[version]={args.build}&limit=20",
        None,
    )["data"]
    valid = [
        item
        for item in builds
        if item["attributes"]["processingState"] == "VALID"
        and item["attributes"]["usesNonExemptEncryption"] is False
    ]
    if len(valid) != 1:
        raise SystemExit(f"Expected one valid build {args.build}, found {len(valid)}")
    build_id = valid[0]["id"]

    _sync_app_localizations()
    _sync_build_localizations(build_id)

    groups = request("GET", f"/v1/apps/{APP_ID}/betaGroups?limit=50", None)["data"]
    internal = [item for item in groups if item["attributes"]["isInternalGroup"]]
    if not internal or not any(
        item["attributes"]["hasAccessToAllBuilds"] for item in internal
    ):
        raise SystemExit("No internal TestFlight group has access to all builds")
    print(f"internal groups with all-build access: {len(internal)}")
    print(f"TestFlight metadata is synchronized for build {args.build} ({build_id}).")


if __name__ == "__main__":
    main()
