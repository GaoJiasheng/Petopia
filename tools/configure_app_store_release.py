#!/usr/bin/env python3
"""Apply Petopia's checked-in App Store metadata to an editable release."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

from app_store_connect_api import request


ROOT = Path(__file__).resolve().parents[1]
APP_ID = "6787161287"
PRIVACY_URL = "https://blog.gavingao.cn/petopia/privacy.html"
SUPPORT_URL = "https://blog.gavingao.cn/petopia/support.html"
MARKETING_URL = "https://blog.gavingao.cn/petopia/"

IAP_LOCALIZATIONS = {
    "com.petopia.petopia.support.treat": {
        "en-US": ("A Treat", "A decorative garden treat that stays for 24 hours."),
        "zh-Hans": ("一份小点心", "在院子里展示 24 小时的装饰点心。"),
    },
    "com.petopia.petopia.support.lantern": {
        "en-US": ("A Warm Lantern", "Keeps the garden lantern glowing for 24 hours."),
        "zh-Hans": ("点亮一盏暖灯", "在小院里亮 24 小时的装饰暖灯。"),
    },
    "com.petopia.petopia.support.bouquet": {
        "en-US": ("Garden Bouquet", "Flowers bloom in the yard for seven days."),
        "zh-Hans": ("送来一篮花", "在院子里展示七天的装饰花篮。"),
    },
    "com.petopia.petopia.support.guardian": {
        "en-US": (
            "Garden Keeper",
            "Permanent lantern, keepsake badge, and special letter.",
        ),
        "zh-Hans": (
            "小院守护者",
            "永久点亮守护灯，并解锁纪念徽章和特别来信。",
        ),
    },
}


def _json_body(value: object) -> bytes:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":")).encode()


def _backtick_value(markdown: str, label: str) -> str:
    match = re.search(rf"^- {label}.*?[:：]\s*`([^`]*)`", markdown, re.MULTILINE)
    if not match:
        raise SystemExit(f"Could not read metadata field: {label}")
    return match.group(1)


def _description(markdown: str, heading: str, next_heading: str) -> str:
    match = re.search(
        rf"^## {heading}\s*$\n(.*?)^## {next_heading}\s*$",
        markdown,
        re.MULTILINE | re.DOTALL,
    )
    if not match:
        raise SystemExit(f"Could not read description section: {heading}")
    blocks = []
    for block in re.split(r"\n\s*\n", match.group(1).strip()):
        lines = [line.strip() for line in block.splitlines()]
        if all(line.startswith("- ") for line in lines):
            blocks.append("\n".join(lines))
        else:
            blocks.append(" ".join(lines))
    return "\n\n".join(blocks)


def _metadata(locale: str) -> dict[str, str]:
    path = ROOT / "docs" / "app-store" / f"metadata-{locale}.md"
    markdown = path.read_text()
    if locale == "en-US":
        return {
            "name": _backtick_value(markdown, r"App name"),
            "subtitle": _backtick_value(markdown, r"Subtitle"),
            "keywords": _backtick_value(markdown, r"Keywords"),
            "promotionalText": _backtick_value(markdown, r"Promotional text"),
            "description": _description(markdown, "Description", "Version Notes"),
        }
    return {
        "name": _backtick_value(markdown, r"App 名称"),
        "subtitle": _backtick_value(markdown, r"副标题"),
        "keywords": _backtick_value(markdown, r"关键词"),
        "promotionalText": _backtick_value(markdown, r"促销文本"),
        "description": _description(markdown, "描述", "首发版本说明"),
    }


def _review_notes() -> str:
    markdown = (ROOT / "docs" / "app-store" / "review-notes-en-US.md").read_text()
    markdown = re.sub(r"^# App Review Notes \(English, U\.S\.\)\s*", "", markdown)
    markdown = markdown.replace("## Review Notes", "Review Notes")
    markdown = markdown.replace("## Suggested Review Path", "Suggested Review Path")
    return markdown.strip()


def _patch(resource_type: str, resource_id: str, attributes: dict[str, object]) -> None:
    request(
        "PATCH",
        f"/v1/{resource_type}/{resource_id}",
        _json_body(
            {
                "data": {
                    "type": resource_type,
                    "id": resource_id,
                    "attributes": attributes,
                }
            }
        ),
    )


def _review_submission_iap_items() -> tuple[str | None, list[dict[str, str]]]:
    submissions = request(
        "GET",
        f"/v1/apps/{APP_ID}/reviewSubmissions?limit=50",
        None,
    )["data"]
    editable = [
        item
        for item in submissions
        if item["attributes"]["state"] == "READY_FOR_REVIEW"
    ]
    if not editable:
        return None, []
    if len(editable) != 1:
        raise SystemExit(f"Expected at most one editable review submission, found {len(editable)}")
    submission_id = editable[0]["id"]
    items = request(
        "GET",
        f"/v1/reviewSubmissions/{submission_id}/items?include=inAppPurchaseVersion&limit=200",
        None,
    )["data"]
    iap_items = []
    for item in items:
        relationship = item.get("relationships", {}).get("inAppPurchaseVersion")
        if relationship and relationship.get("data"):
            iap_items.append(
                {
                    "itemId": item["id"],
                    "versionId": relationship["data"]["id"],
                }
            )
    return submission_id, iap_items


def _add_iap_review_item(submission_id: str, version_id: str) -> None:
    request(
        "POST",
        "/v1/reviewSubmissionItems",
        _json_body(
            {
                "data": {
                    "type": "reviewSubmissionItems",
                    "relationships": {
                        "reviewSubmission": {
                            "data": {
                                "type": "reviewSubmissions",
                                "id": submission_id,
                            }
                        },
                        "inAppPurchaseVersion": {
                            "data": {
                                "type": "inAppPurchaseVersions",
                                "id": version_id,
                            }
                        },
                    },
                }
            }
        ),
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", default="1.0")
    parser.add_argument("--build", default="24")
    args = parser.parse_args()

    versions = request(
        "GET",
        f"/v1/apps/{APP_ID}/appStoreVersions?filter[platform]=IOS&limit=50",
        None,
    )["data"]
    matches = [item for item in versions if item["attributes"]["versionString"] == args.version]
    if len(matches) != 1:
        raise SystemExit(f"Expected one editable iOS {args.version} version, found {len(matches)}")
    version = matches[0]
    if version["attributes"]["appStoreState"] != "PREPARE_FOR_SUBMISSION":
        raise SystemExit(f"Version is not editable: {version['attributes']['appStoreState']}")

    builds = request(
        "GET",
        f"/v1/builds?filter[app]={APP_ID}&filter[version]={args.build}&limit=20",
        None,
    )["data"]
    valid_builds = [
        item
        for item in builds
        if item["attributes"]["processingState"] == "VALID"
        and item["attributes"]["buildAudienceType"] == "APP_STORE_ELIGIBLE"
        and item["attributes"]["usesNonExemptEncryption"] is False
    ]
    if len(valid_builds) != 1:
        raise SystemExit(f"Expected one valid build {args.build}, found {len(valid_builds)}")
    build = valid_builds[0]
    request(
        "PATCH",
        f"/v1/appStoreVersions/{version['id']}/relationships/build",
        _json_body({"data": {"type": "builds", "id": build["id"]}}),
    )
    print(f"build: {args.build} ({build['id']})")

    app_infos = request("GET", f"/v1/apps/{APP_ID}/appInfos?limit=50", None)["data"]
    if len(app_infos) != 1:
        raise SystemExit(f"Expected one editable app info, found {len(app_infos)}")
    app_info_id = app_infos[0]["id"]
    info_localizations = request(
        "GET",
        f"/v1/appInfos/{app_info_id}/appInfoLocalizations?limit=50",
        None,
    )["data"]
    info_by_locale = {item["attributes"]["locale"]: item for item in info_localizations}

    version_localizations = request(
        "GET",
        f"/v1/appStoreVersions/{version['id']}/appStoreVersionLocalizations?limit=50",
        None,
    )["data"]
    version_by_locale = {
        item["attributes"]["locale"]: item for item in version_localizations
    }

    for locale in ("en-US", "zh-Hans"):
        metadata = _metadata(locale)
        if locale not in info_by_locale or locale not in version_by_locale:
            raise SystemExit(f"Missing existing localization: {locale}")
        _patch(
            "appInfoLocalizations",
            info_by_locale[locale]["id"],
            {
                "name": metadata["name"],
                "subtitle": metadata["subtitle"],
                "privacyPolicyUrl": PRIVACY_URL,
            },
        )
        _patch(
            "appStoreVersionLocalizations",
            version_by_locale[locale]["id"],
            {
                "description": metadata["description"],
                "keywords": metadata["keywords"],
                "marketingUrl": MARKETING_URL,
                "promotionalText": metadata["promotionalText"],
                "supportUrl": SUPPORT_URL,
            },
        )
        print(f"metadata: {locale}")

    review = request(
        "GET",
        f"/v1/appStoreVersions/{version['id']}/appStoreReviewDetail",
        None,
    )["data"]
    _patch("appStoreReviewDetails", review["id"], {"notes": _review_notes()})
    print("review notes: en-US")

    purchases = request(
        "GET",
        f"/v1/apps/{APP_ID}/inAppPurchasesV2?limit=200",
        None,
    )["data"]
    purchases_by_product = {item["attributes"]["productId"]: item for item in purchases}
    if set(purchases_by_product) != set(IAP_LOCALIZATIONS):
        raise SystemExit("App Store Connect IAP products do not match the checked-in catalog")
    submission_id, review_items = _review_submission_iap_items()
    if review_items and len(review_items) != len(IAP_LOCALIZATIONS):
        raise SystemExit(
            f"Expected four IAP review items before metadata update, found {len(review_items)}"
        )
    detached_version_ids: list[str] = []
    try:
        if submission_id:
            for item in review_items:
                request("DELETE", f"/v1/reviewSubmissionItems/{item['itemId']}", None)
                detached_version_ids.append(item["versionId"])
            if detached_version_ids:
                print("iap review items: temporarily detached")
        for product_id, localizations in IAP_LOCALIZATIONS.items():
            purchase = purchases_by_product[product_id]
            existing = request(
                "GET",
                f"/v2/inAppPurchases/{purchase['id']}/inAppPurchaseLocalizations?limit=50",
                None,
            )["data"]
            existing_by_locale = {
                item["attributes"]["locale"]: item for item in existing
            }
            for locale, (name, description) in localizations.items():
                if locale not in existing_by_locale:
                    raise SystemExit(f"Missing {locale} localization for {product_id}")
                localization = existing_by_locale[locale]
                _patch(
                    "inAppPurchaseLocalizations",
                    localization["id"],
                    {"name": name, "description": description},
                )
            screenshot = request(
                "GET",
                f"/v2/inAppPurchases/{purchase['id']}/appStoreReviewScreenshot",
                None,
            )["data"]
            state = screenshot["attributes"]["assetDeliveryState"]["state"]
            if state != "COMPLETE":
                raise SystemExit(f"IAP review screenshot is not complete: {product_id}")
            print(f"iap: {product_id}")
    finally:
        if submission_id:
            for version_id in detached_version_ids:
                _add_iap_review_item(submission_id, version_id)
            if detached_version_ids:
                print("iap review items: restored")

    _, verified_review_items = _review_submission_iap_items()
    if review_items and len(verified_review_items) != len(review_items):
        raise SystemExit("IAP review item restoration did not preserve all four products")

    print("App Store Connect release metadata is synchronized.")


if __name__ == "__main__":
    main()
