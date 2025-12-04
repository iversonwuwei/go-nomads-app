# 支付集成配置指南

## 概述

本文档描述了如何完成微信支付和支付宝支付的原生配置。

## 已完成的工作

### Flutter 端
1. ✅ 添加依赖: `fluwx: ^5.7.5` (微信) 和 `tobias: ^3.0.0` (支付宝)
2. ✅ 创建支付方式枚举: `payment_method.dart`
3. ✅ 创建微信支付服务: `wechat_pay_service.dart`
4. ✅ 创建支付宝服务: `alipay_service.dart`
5. ✅ 创建统一支付服务: `unified_payment_service.dart`
6. ✅ 注册服务到 DI: `dependency_injection.dart`
7. ✅ 更新会员页面支付逻辑: `membership_plan_page.dart`

### 后端
1. ✅ 添加微信支付订单创建接口: `POST /api/v1/payments/orders/wechat`
2. ✅ 添加支付宝订单创建接口: `POST /api/v1/payments/orders/alipay`
3. ✅ 添加微信支付 Webhook: `POST /api/v1/payments/webhooks/wechat`
4. ✅ 添加支付宝 Webhook: `POST /api/v1/payments/webhooks/alipay`
5. ✅ 添加 DTO: `WeChatPayOrderDto`, `AlipayOrderDto`

---

## 待完成: 原生配置

### 1. 微信支付 iOS 配置

#### 1.1 修改 `ios/Runner/Info.plist`
```xml
<!-- 添加 URL Schemes -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>wx你的微信AppId</string>
        </array>
        <key>CFBundleURLName</key>
        <string>weixin</string>
    </dict>
</array>

<!-- 添加 LSApplicationQueriesSchemes -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>weixin</string>
    <string>weixinULAPI</string>
</array>

<!-- 允许 HTTP 请求 -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

#### 1.2 配置 Universal Link (可选但推荐)
1. 在 Apple Developer Portal 启用 Associated Domains
2. 在 Xcode 中添加 Associated Domains capability
3. 添加 `applinks:你的域名`
4. 在服务器配置 `apple-app-site-association` 文件

### 2. 微信支付 Android 配置

#### 2.1 修改 `android/app/src/main/AndroidManifest.xml`
```xml
<!-- 在 application 标签内添加 -->
<activity
    android:name=".wxapi.WXPayEntryActivity"
    android:exported="true"
    android:launchMode="singleTop" />

<activity
    android:name=".wxapi.WXEntryActivity"
    android:exported="true"
    android:launchMode="singleTop" />
```

#### 2.2 创建 WXPayEntryActivity
在 `android/app/src/main/kotlin/你的包名/wxapi/` 目录下创建 `WXPayEntryActivity.kt`:

```kotlin
package 你的包名.wxapi

import io.flutter.embedding.android.FlutterActivity

class WXPayEntryActivity : FlutterActivity()
```

#### 2.3 创建 WXEntryActivity
同目录下创建 `WXEntryActivity.kt`:

```kotlin
package 你的包名.wxapi

import io.flutter.embedding.android.FlutterActivity

class WXEntryActivity : FlutterActivity()
```

### 3. 支付宝 iOS 配置

#### 3.1 修改 `ios/Runner/Info.plist`
```xml
<!-- 添加 URL Schemes -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>alipay你的AppId</string>
        </array>
        <key>CFBundleURLName</key>
        <string>alipay</string>
    </dict>
</array>

<!-- 添加 LSApplicationQueriesSchemes -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>alipay</string>
    <string>alipays</string>
</array>
```

### 4. 支付宝 Android 配置

支付宝 Android 基本无需额外配置，tobias 插件已处理。

### 5. 后端真正集成 (需要商户账号)

#### 5.1 微信支付后端配置
需要在 `appsettings.json` 添加:
```json
"WeChatPay": {
  "AppId": "你的微信开放平台AppId",
  "MchId": "你的微信支付商户号",
  "ApiKey": "你的API密钥",
  "CertPath": "证书文件路径",
  "NotifyUrl": "https://你的域名/api/v1/payments/webhooks/wechat"
}
```

#### 5.2 支付宝后端配置
需要在 `appsettings.json` 添加:
```json
"Alipay": {
  "AppId": "你的支付宝AppId",
  "PrivateKey": "你的RSA私钥",
  "AlipayPublicKey": "支付宝公钥",
  "NotifyUrl": "https://你的域名/api/v1/payments/webhooks/alipay"
}
```

---

## 初始化配置

在 Flutter 应用启动时，需要初始化微信 SDK:

```dart
// main.dart 或 dependency_injection.dart
final wechatService = Get.find<WeChatPayService>();
await wechatService.init(
  WeChatPayConfig(
    appId: 'wx你的微信AppId',
    universalLink: 'https://你的域名/app/', // iOS Universal Link
  ),
);
```

---

## 文件变更清单

### 新增文件
- `lib/features/payment/domain/entities/payment_method.dart`
- `lib/features/payment/application/services/wechat_pay_service.dart`
- `lib/features/payment/application/services/alipay_service.dart`
- `lib/features/payment/application/services/unified_payment_service.dart`

### 修改文件
- `pubspec.yaml` - 添加 fluwx 和 tobias 依赖
- `lib/core/di/dependency_injection.dart` - 注册新服务
- `lib/features/payment/domain/repositories/i_payment_repository.dart` - 添加微信/支付宝接口
- `lib/features/payment/infrastructure/repositories/payment_repository.dart` - 实现接口
- `lib/features/payment/presentation/controllers/payment_state_controller.dart` - 添加创建订单方法
- `lib/features/membership/presentation/pages/membership_plan_page.dart` - 集成支付方式选择

### 后端修改文件
- `PaymentController.cs` - 添加微信/支付宝接口和 Webhook
- `PaymentDTOs.cs` - 添加 DTO 类

---

## 测试建议

1. **模拟测试**: 当前后端返回模拟数据，可用于 UI 流程测试
2. **沙箱测试**: 配置微信/支付宝沙箱环境进行真实支付测试
3. **生产环境**: 完成商户认证后配置正式凭据

## 注意事项

1. 微信支付需要在微信开放平台注册应用
2. 支付宝需要在支付宝开放平台注册应用
3. 需要完成商户认证才能进行真实支付
4. 生产环境必须使用 HTTPS 回调地址
