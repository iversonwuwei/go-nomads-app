#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_NAME=""
BUILD_NUMBER=""
NO_CODESIGN="false"

usage() {
  cat <<EOF
Usage:
  ./scripts/build_ios_appstore.sh --build-name 1.0.1 --build-number 2 [--no-codesign]

Options:
  --build-name      iOS version name (CFBundleShortVersionString)
  --build-number    iOS build number (CFBundleVersion)
  --no-codesign     Build archive without signing
  -h, --help        Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-name)
      BUILD_NAME="$2"
      shift 2
      ;;
    --build-number)
      BUILD_NUMBER="$2"
      shift 2
      ;;
    --no-codesign)
      NO_CODESIGN="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$BUILD_NAME" || -z "$BUILD_NUMBER" ]]; then
  echo "--build-name and --build-number are required."
  usage
  exit 1
fi

cd "$ROOT_DIR"

echo "[1/3] flutter pub get"
flutter pub get

echo "[2/3] flutter build ipa"
if [[ "$NO_CODESIGN" == "true" ]]; then
  flutter build ipa --release --build-name "$BUILD_NAME" --build-number "$BUILD_NUMBER" --no-codesign
else
  flutter build ipa --release --build-name "$BUILD_NAME" --build-number "$BUILD_NUMBER"
fi

echo "[3/3] Done"
echo "Archive: $ROOT_DIR/build/ios/archive/Runner.xcarchive"
echo "IPA: $ROOT_DIR/build/ios/ipa"
