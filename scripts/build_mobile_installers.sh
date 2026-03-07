#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PUBSPEC="$ROOT_DIR/pubspec.yaml"
IOS_EXPORT_METHOD="app-store-connect"
RUN_IOS_PREFLIGHT="true"
LOG_DIR="$ROOT_DIR/scripts/reports"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/build_mobile_installers_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

on_error() {
  local exit_code=$?
  echo
  echo "Build failed with exit code: $exit_code"
  echo "Log file: $LOG_FILE"
  echo "pubspec version remains unchanged."
  exit "$exit_code"
}
trap on_error ERR

usage() {
  cat <<EOF
Usage:
  ./scripts/build_mobile_installers.sh [--ios-export-method development|ad-hoc|enterprise|app-store-connect] [--skip-ios-preflight]

What it does:
  1) Read current version from pubspec.yaml (x.y.z+build)
  2) Build Android APK and iOS IPA using that exact version/build
  3) If both builds succeed, bump pubspec build number by +1 (x.y.z+(build+1))
  4) Copy APK to a versioned file: app-release-<version>.apk

Options:
  --ios-export-method   iOS export method for IPA (default: app-store-connect, mapped to flutter app-store)
  --skip-ios-preflight  Skip scripts/preflight_ios_appstore.sh
  -h, --help            Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ios-export-method)
      IOS_EXPORT_METHOD="$2"
      shift 2
      ;;
    --skip-ios-preflight)
      RUN_IOS_PREFLIGHT="false"
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

case "$IOS_EXPORT_METHOD" in
  development|ad-hoc|enterprise|app-store-connect)
    ;;
  *)
    echo "Invalid --ios-export-method: $IOS_EXPORT_METHOD"
    usage
    exit 1
    ;;
esac

if [[ ! -f "$PUBSPEC" ]]; then
  echo "pubspec.yaml not found: $PUBSPEC"
  exit 1
fi

current_version_line="$(grep -E '^version:[[:space:]]*' "$PUBSPEC" | head -1 | sed 's/^version:[[:space:]]*//')"

if [[ -z "$current_version_line" ]]; then
  echo "No version found in pubspec.yaml"
  exit 1
fi

if [[ "$current_version_line" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)$ ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
  build_number="${BASH_REMATCH[4]}"
else
  echo "Unsupported version format in pubspec.yaml: $current_version_line"
  echo "Expected: x.y.z+build"
  exit 1
fi

build_name="${major}.${minor}.${patch}"
next_build_number=$((build_number + 1))
next_version="${major}.${minor}.${patch}+${next_build_number}"
version_tag="${build_name}+${build_number}"
android_apk_source="$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk"
android_apk_versioned="$ROOT_DIR/build/app/outputs/flutter-apk/app-release-${version_tag}.apk"

cd "$ROOT_DIR"

echo "[1/6] Using version from pubspec: $build_name+$build_number"
echo "Log file: $LOG_FILE"

if [[ "$RUN_IOS_PREFLIGHT" == "true" ]]; then
  echo "[2/6] iOS preflight"
  ./scripts/preflight_ios_appstore.sh
else
  echo "[2/6] iOS preflight skipped"
fi

echo "[3/6] flutter pub get"
flutter pub get

echo "[4/6] Build Android APK"
flutter build apk --release --build-name "$build_name" --build-number "$build_number"

if [[ -f "$android_apk_source" ]]; then
  cp "$android_apk_source" "$android_apk_versioned"
  echo "Versioned APK: $android_apk_versioned"
else
  echo "Expected APK not found: $android_apk_source"
  exit 1
fi

echo "[5/6] Build iOS IPA"
./scripts/build_ios_appstore.sh \
  --build-name "$build_name" \
  --build-number "$build_number" \
  --export-method "$IOS_EXPORT_METHOD"

echo "[6/6] Bump pubspec build number"
awk -v new_version="$next_version" '
  BEGIN { updated = 0 }
  /^version:[[:space:]]*/ && updated == 0 {
    print "version: " new_version
    updated = 1
    next
  }
  { print }
' "$PUBSPEC" > "$PUBSPEC.tmp"
mv "$PUBSPEC.tmp" "$PUBSPEC"

echo "Done"
echo "Android APK: $ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk"
echo "Android APK (versioned): $android_apk_versioned"
echo "iOS IPA dir: $ROOT_DIR/build/ios/ipa"
echo "pubspec version updated to: $next_version"
echo "Log file: $LOG_FILE"
