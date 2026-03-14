# iOS Social Login Setup

This document is the single source of truth for the iOS platform-side setup of WeChat Login and QQ Login.

## App Identity

- Apple Team ID: `X8KVNA6D7G`
- iOS Bundle ID: `com.gonomads.GoNomadsApp`
- Apple App ID used by AASA: `X8KVNA6D7G.com.gonomads.GoNomadsApp`

These values come from:

- `ios/Runner.xcodeproj/project.pbxproj`
- `public/.well-known/apple-app-site-association`

## WeChat iOS Setup

Platform values to fill in WeChat Open Platform:

- AppID: `wx3b333eed7c75a444`
- Bundle ID: `com.gonomads.GoNomadsApp`
- Universal Link: `https://go-nomads.com/app/`
- URL Scheme on iOS: `wx3b333eed7c75a444`
- AppStoreID: fill the numeric Apple ID from App Store Connect

Project values already configured:

- Flutter SDK registration:
  - `lib/services/social_sdk_service.dart`
- iOS URL scheme:
  - `ios/Runner/Info.plist`
- Associated Domains:
  - `ios/Runner/Runner.entitlements`

## QQ iOS Setup

Platform values to fill in QQ Connect:

- AppID: `102822014`
- Bundle ID: `com.gonomads.GoNomadsApp`
- Universal Link host in QQ console: `go-nomads.com`
- SDK-side Universal Link in app code: `https://go-nomads.com/qq_conn/102822014/`
- URL Scheme on iOS: `tencent102822014`
- AppStoreID: fill the numeric Apple ID from App Store Connect

Important:

- QQ console field follows QQ docs and should use the host only.
- App code still uses the full Universal Link path.
- QQ validation expects AASA to contain `/qq_conn/102822014/*`.

Project values already configured:

- Flutter SDK registration:
  - `lib/services/social_sdk_service.dart`
- iOS URL scheme:
  - `ios/Runner/Info.plist`
- Associated Domains:
  - `ios/Runner/Runner.entitlements`

## Xcode Setup

The following must exist in the iOS app:

- Associated Domains capability enabled
- Domain entry: `applinks:go-nomads.com`

Already present in:

- `ios/Runner/Runner.entitlements`

## Web Domain Setup

The public AASA file must be reachable at:

- `https://go-nomads.com/.well-known/apple-app-site-association`

Current repository file:

- `go-nomads-web/public/.well-known/apple-app-site-association`

Current AASA paths:

- `/app/*`
- `/universal_link/*`
- `/qq_conn/102822014/*`

These paths match the current WeChat and QQ Universal Link usage.

## Final Verification

After platform approval and app reinstall on a real iPhone, verify:

- WeChat login opens WeChat and returns to the app
- QQ login opens QQ and returns to the app
- `https://go-nomads.com/.well-known/apple-app-site-association` returns over HTTPS without redirect issues
- The installed app contains `applinks:go-nomads.com`

## Security Note

`wechatAppSecret` should not stay in the mobile client long-term. It belongs on the backend only.
