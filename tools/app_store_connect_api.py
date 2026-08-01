#!/usr/bin/env python3
"""Small App Store Connect API client for release automation.

Credentials are read from ASC_KEY_ID, ASC_ISSUER_ID, and
ASC_PRIVATE_KEY_PATH. The script never persists tokens or private keys.
"""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature


API_ROOT = "https://api.appstoreconnect.apple.com"


def _base64url(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")


def _required_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise SystemExit(f"Missing required environment variable: {name}")
    return value


def _token() -> str:
    key_id = _required_env("ASC_KEY_ID")
    issuer_id = _required_env("ASC_ISSUER_ID")
    key_path = Path(_required_env("ASC_PRIVATE_KEY_PATH"))
    private_key = serialization.load_pem_private_key(key_path.read_bytes(), password=None)

    issued_at = int(time.time())
    header = _base64url(
        json.dumps(
            {"alg": "ES256", "kid": key_id, "typ": "JWT"},
            separators=(",", ":"),
        ).encode()
    )
    payload = _base64url(
        json.dumps(
            {
                "iss": issuer_id,
                "iat": issued_at,
                "exp": issued_at + 15 * 60,
                "aud": "appstoreconnect-v1",
            },
            separators=(",", ":"),
        ).encode()
    )
    message = f"{header}.{payload}".encode("ascii")
    der_signature = private_key.sign(message, ec.ECDSA(hashes.SHA256()))
    r, s = decode_dss_signature(der_signature)
    signature = _base64url(r.to_bytes(32, "big") + s.to_bytes(32, "big"))
    return f"{header}.{payload}.{signature}"


def _load_body(value: str | None) -> bytes | None:
    if value is None:
        return None
    if value.startswith("@"):
        return Path(value[1:]).read_bytes()
    return value.encode("utf-8")


def request(method: str, path: str, body: bytes | None) -> object:
    url = path if path.startswith("https://") else f"{API_ROOT}{path}"
    headers = {
        "Authorization": f"Bearer {_token()}",
        "Accept": "application/json",
    }
    if body is not None:
        headers["Content-Type"] = "application/json"
    api_request = urllib.request.Request(
        url,
        data=body,
        headers=headers,
        method=method,
    )
    try:
        with urllib.request.urlopen(api_request, timeout=60) as response:
            payload = response.read()
    except urllib.error.HTTPError as error:
        detail = error.read().decode("utf-8", errors="replace")
        raise SystemExit(f"HTTP {error.code} {error.reason}\n{detail}") from error
    except urllib.error.URLError as error:
        raise SystemExit(f"Network request failed: {error.reason}") from error
    if not payload:
        return {"status": "ok"}
    return json.loads(payload)


def upload_asset_parts(file_path: Path, operations: list[dict[str, object]]) -> None:
    with file_path.open("rb") as source:
        for operation in operations:
            source.seek(int(operation["offset"]))
            chunk = source.read(int(operation["length"]))
            headers = {
                item["name"]: item["value"]
                for item in operation.get("requestHeaders", [])
            }
            upload_request = urllib.request.Request(
                str(operation["url"]),
                data=chunk,
                headers=headers,
                method=str(operation["method"]),
            )
            try:
                with urllib.request.urlopen(upload_request, timeout=120) as response:
                    response.read()
            except urllib.error.HTTPError as error:
                detail = error.read().decode("utf-8", errors="replace")
                raise SystemExit(
                    f"Asset upload failed: HTTP {error.code} {error.reason}\n{detail}"
                ) from error


def upload_screenshot(file_path: Path, screenshot_set_id: str) -> dict[str, object]:
    reservation = request(
        "POST",
        "/v1/appScreenshots",
        json.dumps(
            {
                "data": {
                    "type": "appScreenshots",
                    "attributes": {
                        "fileSize": file_path.stat().st_size,
                        "fileName": file_path.name,
                    },
                    "relationships": {
                        "appScreenshotSet": {
                            "data": {
                                "type": "appScreenshotSets",
                                "id": screenshot_set_id,
                            }
                        }
                    },
                }
            },
            separators=(",", ":"),
        ).encode(),
    )
    screenshot = reservation["data"]
    upload_asset_parts(file_path, screenshot["attributes"]["uploadOperations"])
    checksum = hashlib.md5(file_path.read_bytes()).hexdigest()
    return request(
        "PATCH",
        f"/v1/appScreenshots/{screenshot['id']}",
        json.dumps(
            {
                "data": {
                    "type": "appScreenshots",
                    "id": screenshot["id"],
                    "attributes": {
                        "uploaded": True,
                        "sourceFileChecksum": checksum,
                    },
                }
            },
            separators=(",", ":"),
        ).encode(),
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("method", choices=("GET", "POST", "PATCH", "DELETE"))
    parser.add_argument("path", help="API path beginning with /v1 or /v2")
    parser.add_argument("--data", help="Inline JSON, or @path/to/payload.json")
    parser.add_argument("--compact", action="store_true")
    args = parser.parse_args()

    result = request(args.method, args.path, _load_body(args.data))
    if args.compact:
        json.dump(result, sys.stdout, ensure_ascii=False, separators=(",", ":"))
    else:
        json.dump(result, sys.stdout, ensure_ascii=False, indent=2)
    print()


if __name__ == "__main__":
    main()
