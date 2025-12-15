# QQ SDK 集成完成

## 变更概述

已成功集成 `tencent_kit` 插件实现 QQ 登录功能。

## 修改的文件

### 1. pubspec.yaml
- 添加依赖 `tencent_kit: ^6.0.3`（实际安装版本为 6.2.0）
- 添加 QQ SDK 配置：
  ```yaml
  tencent_kit:
    app_id: "Ut68vSr2ye4FJ9j6"
  ```

### 2. lib/services/social_sdk_service.dart
- 添加 QQ SDK 初始化方法 `_initQQ()`
- 使用 `TencentKitPlatform.instance` API（适配 6.2.0 版本）
- 按照文档要求，先调用 `setIsPermissionGranted(granted: true)` 再调用 `registerApp()`
- 添加 `isQQInitialized` 静态属性检查初始化状态
- 更新 `isQQInstalled()` 方法使用新 API

### 3. lib/services/social_login_service.dart
- 移除旧的 `Tencent` 实例引用
- 更新 `isQQInstalled()` 使用 `SocialSdkService.isQQInitialized` 和 `TencentKitPlatform.instance`
- 更新 `loginWithQQ()` 方法：
  - 使用 `TencentKitPlatform.instance.respStream()` 监听登录回调
  - 使用 `TencentKitPlatform.instance.login()` 发起登录
  - 过滤 `TencentLoginResp` 类型的响应

### 4. ios/Runner/Info.plist
- 在 `CFBundleURLTypes` 中添加 QQ 回调 URL Scheme：
  ```xml
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>tencent</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>tencentUt68vSr2ye4FJ9j6</string>
    </array>
  </dict>
  ```
- `LSApplicationQueriesSchemes` 中已有 `mqq` 和 `mqqzone`

### 5. android/app/src/main/AndroidManifest.xml
- 已配置 QQ 包名查询权限：`com.tencent.mobileqq`
- 已配置 QQ URL Scheme 查询：`mqq`、`mqqzone`

## API 使用说明

### 初始化（已在 SocialSdkService.init() 中完成）
```dart
// 必须先设置权限，再注册 App
await TencentKitPlatform.instance.setIsPermissionGranted(granted: true);
await TencentKitPlatform.instance.registerApp(appId: qqAppId);
```

### 登录
```dart
// 检查是否安装 QQ
bool installed = await TencentKitPlatform.instance.isQQInstalled();

// 监听登录响应
TencentKitPlatform.instance.respStream().listen((resp) {
  if (resp is TencentLoginResp) {
    if (resp.ret == 0) {
      // 登录成功
      String? openid = resp.openid;
      String? accessToken = resp.accessToken;
    } else if (resp.ret == -2) {
      // 用户取消
    }
  }
});

// 发起登录
await TencentKitPlatform.instance.login(
  scope: [TencentScope.kGetSimpleUserInfo],
);
```

## QQ AppId
- 当前配置的 AppId: `Ut68vSr2ye4FJ9j6`
- 需要在腾讯开放平台申请并配置真实的 AppId

## 后续工作

1. **后端接口**：需要实现 QQ 登录的后端接口，接收 openid 和 accessToken 进行用户认证
2. **iOS Universal Link**（可选）：如需更好的用户体验，可配置 Universal Link
3. **测试**：在真机上测试 QQ 登录流程

## 测试步骤

1. 运行 `flutter pub get`
2. 在 Android 设备上安装 QQ 客户端
3. 运行应用并点击 QQ 登录按钮
4. 观察是否能正确唤起 QQ 授权页面
5. 检查授权后是否能正确获取 openid 和 accessToken

## 参考文档

- [tencent_kit pub.dev](https://pub.dev/packages/tencent_kit)
- [QQ互联开放平台](https://connect.qq.com/)
