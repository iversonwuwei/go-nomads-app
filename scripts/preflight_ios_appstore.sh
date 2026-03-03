#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PUBSPEC="$ROOT_DIR/pubspec.yaml"
PBXPROJ="$ROOT_DIR/ios/Runner.xcodeproj/project.pbxproj"
INFO_PLIST="$ROOT_DIR/ios/Runner/Info.plist"
ENTITLEMENTS="$ROOT_DIR/ios/Runner/Runner.entitlements"

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

pass() {
  echo "✅ PASS: $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

warn() {
  echo "⚠️ WARN: $1"
  WARN_COUNT=$((WARN_COUNT + 1))
}

fail() {
  echo "❌ FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

need_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    pass "Found file: $file"
  else
    fail "Missing file: $file"
  fi
}

contains_key() {
  local plist="$1"
  local key="$2"
  /usr/libexec/PlistBuddy -c "Print :$key" "$plist" >/dev/null 2>&1
}

echo "=== iOS App Store Preflight Check ==="
echo "Project: $ROOT_DIR"
echo

need_file "$PUBSPEC"
need_file "$PBXPROJ"
need_file "$INFO_PLIST"
need_file "$ENTITLEMENTS"

echo
echo "--- Version checks ---"
if [[ -f "$PUBSPEC" ]]; then
  VERSION_LINE="$(grep -E '^version:' "$PUBSPEC" | head -1 | sed 's/^version:[[:space:]]*//')"
  if [[ -n "$VERSION_LINE" ]]; then
    pass "pubspec version found: $VERSION_LINE"
    if [[ "$VERSION_LINE" =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
      pass "Version format is valid (x.y.z+build)"
    else
      fail "Version format invalid in pubspec.yaml (expected x.y.z+build)"
    fi
  else
    fail "No version found in pubspec.yaml"
  fi
fi

echo
echo "--- Signing & bundle checks ---"
if [[ -f "$PBXPROJ" ]]; then
  TEAM_ID="$(grep -E 'DEVELOPMENT_TEAM = ' "$PBXPROJ" | head -1 | sed -E 's/.*DEVELOPMENT_TEAM = ([^;]+);.*/\1/' | tr -d '[:space:]')"
  if [[ -n "$TEAM_ID" ]]; then
    pass "Development Team set: $TEAM_ID"
  else
    fail "DEVELOPMENT_TEAM is not set"
  fi

  CODE_SIGN_STYLE="$(grep -E 'CODE_SIGN_STYLE = ' "$PBXPROJ" | head -1 | sed -E 's/.*CODE_SIGN_STYLE = ([^;]+);.*/\1/' | tr -d '[:space:]')"
  if [[ "$CODE_SIGN_STYLE" == "Automatic" || "$CODE_SIGN_STYLE" == "Manual" ]]; then
    pass "Code signing style: $CODE_SIGN_STYLE"
  else
    fail "Invalid or missing CODE_SIGN_STYLE"
  fi

  BUNDLE_ID="$(grep -E 'PRODUCT_BUNDLE_IDENTIFIER = ' "$PBXPROJ" | grep -v 'RunnerTests' | head -1 | sed -E 's/.*PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);.*/\1/' | tr -d '[:space:]')"
  if [[ -n "$BUNDLE_ID" ]]; then
    pass "Bundle identifier: $BUNDLE_ID"
  else
    fail "Missing PRODUCT_BUNDLE_IDENTIFIER for Runner target"
  fi
fi

echo
echo "--- Info.plist privacy checks ---"
if [[ -f "$INFO_PLIST" ]]; then
  PRIVACY_KEYS=(
    NSCameraUsageDescription
    NSPhotoLibraryUsageDescription
    NSLocationWhenInUseUsageDescription
    NSMicrophoneUsageDescription
    NSUserNotificationsUsageDescription
  )

  for key in "${PRIVACY_KEYS[@]}"; do
    if contains_key "$INFO_PLIST" "$key"; then
      pass "Privacy key exists: $key"
    else
      fail "Missing privacy key: $key"
    fi
  done

  if contains_key "$INFO_PLIST" "NSAppTransportSecurity:NSAllowsArbitraryLoads"; then
    ATS_ALL="$(/usr/libexec/PlistBuddy -c 'Print :NSAppTransportSecurity:NSAllowsArbitraryLoads' "$INFO_PLIST" 2>/dev/null || true)"
    if [[ "$ATS_ALL" == "true" ]]; then
      warn "NSAllowsArbitraryLoads is true (App Review may require strong justification)"
    else
      pass "NSAllowsArbitraryLoads is not true"
    fi
  else
    pass "NSAllowsArbitraryLoads key not present"
  fi
fi

echo
echo "--- Entitlements checks ---"
if [[ -f "$ENTITLEMENTS" ]]; then
  if contains_key "$ENTITLEMENTS" "com.apple.developer.associated-domains"; then
    pass "Associated Domains entitlement exists"
  else
    warn "No Associated Domains entitlement (skip if not using universal links)"
  fi
fi

echo
echo "=== Summary ==="
echo "PASS: $PASS_COUNT"
echo "WARN: $WARN_COUNT"
echo "FAIL: $FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo
  echo "Preflight failed. Fix FAIL items before App Store upload."
  exit 1
fi

echo
echo "Preflight passed. You can proceed with archive/upload to App Store Connect."
