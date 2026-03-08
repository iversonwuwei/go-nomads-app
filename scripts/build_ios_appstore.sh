#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_NAME=""
BUILD_NUMBER=""
NO_CODESIGN="false"
EXPORT_METHOD="app-store-connect"
FLUTTER_EXPORT_METHOD=""

resign_local_test_bundle() {
  local app_bundle="$ROOT_DIR/build/ios/iphoneos/Runner.app"
  local framework_bundle="$app_bundle/Frameworks/objective_c.framework"
  local identity=""

  if [[ ! -d "$app_bundle" ]]; then
    echo "[3/4] Skip re-sign: Runner.app not found at $app_bundle"
    return 0
  fi

  if [[ ! -d "$framework_bundle" ]]; then
    echo "[3/4] Skip re-sign: objective_c.framework not found"
    return 0
  fi

  identity="$(codesign -dvv "$app_bundle" 2>&1 | awk -F= '/^Authority=Apple Development:/ {print $2; exit}')"
  if [[ -z "$identity" ]]; then
    identity="$(codesign -dvv "$app_bundle" 2>&1 | awk -F= '/^Authority=Apple Distribution:/ {print $2; exit}')"
  fi

  if [[ -z "$identity" ]]; then
    echo "[3/4] Skip re-sign: signing identity not found from Runner.app"
    return 0
  fi

  echo "[3/4] Re-sign native framework for local install compatibility"
  /usr/bin/codesign --force --sign "$identity" --timestamp=none "$framework_bundle"
  /usr/bin/codesign --force --sign "$identity" --timestamp=none --preserve-metadata=entitlements,requirements,flags "$app_bundle"
}

usage() {
  cat <<EOF
Usage:
  ./scripts/build_ios_appstore.sh --build-name 1.0.1 --build-number 2 [--export-method app-store-connect|development|ad-hoc|enterprise] [--no-codesign]

Options:
  --build-name      iOS version name (CFBundleShortVersionString)
  --build-number    iOS build number (CFBundleVersion)
  --export-method   IPA export method (default: app-store-connect)
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
    --export-method)
      EXPORT_METHOD="$2"
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

case "$EXPORT_METHOD" in
  app-store-connect|development|ad-hoc|enterprise)
    ;;
  *)
    echo "Invalid --export-method: $EXPORT_METHOD"
    usage
    exit 1
    ;;
esac

case "$EXPORT_METHOD" in
  app-store-connect)
    FLUTTER_EXPORT_METHOD="app-store"
    ;;
  *)
    FLUTTER_EXPORT_METHOD="$EXPORT_METHOD"
    ;;
esac

cd "$ROOT_DIR"

echo "[1/3] flutter pub get"
flutter pub get

echo "[2/3] flutter build ipa"
if [[ "$NO_CODESIGN" == "true" ]]; then
  flutter build ipa --release --build-name "$BUILD_NAME" --build-number "$BUILD_NUMBER" --export-method "$FLUTTER_EXPORT_METHOD" --no-codesign
else
  flutter build ipa --release --build-name "$BUILD_NAME" --build-number "$BUILD_NUMBER" --export-method "$FLUTTER_EXPORT_METHOD"
fi

if [[ "$NO_CODESIGN" == "false" && "$FLUTTER_EXPORT_METHOD" != "app-store" ]]; then
  resign_local_test_bundle
  echo "[4/4] Done"
else
  echo "[3/3] Done"
fi

echo "Archive: $ROOT_DIR/build/ios/archive/Runner.xcarchive"
echo "IPA: $ROOT_DIR/build/ios/ipa"
