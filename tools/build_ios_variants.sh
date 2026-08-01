#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 testflight-tools|app-store <build-number> [flutter build ipa options...]"
}

if [[ $# -lt 2 ]]; then
  usage
  exit 64
fi

variant="$1"
build_number="$2"
shift 2

case "$variant" in
  testflight-tools)
    export OTHER_SWIFT_FLAGS='$(inherited) -DPETOPIA_TESTFLIGHT_TOOLS'
    flutter build ipa \
      --release \
      --build-number="$build_number" \
      --dart-define=PETOPIA_TESTFLIGHT_TOOLS=true \
      "$@"
    ;;
  app-store)
    unset OTHER_SWIFT_FLAGS || true
    flutter build ipa \
      --release \
      --build-number="$build_number" \
      "$@"
    ;;
  *)
    usage
    exit 64
    ;;
esac
