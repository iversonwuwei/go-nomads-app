# 社交登录功能实现文档

## 概述

实现了微信、支付宝、QQ、Apple、Google 等社交平台的快捷登录功能。

## 架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                         RegisterPage                                 │
│                    _handleSocialLogin()                              │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     AuthStateController                              │
│                     socialLogin(type)                                │
└─────────────────────────────────────────────────────────────────────┘
                        │                │
                        ▼                ▼
        ┌───────────────────┐    ┌───────────────────┐
        │ SocialLoginService │    │ SocialLoginUseCase │
        │  (SDK 调用)        │    │  (后端 API)        │
        └───────────────────┘    └───────────────────┘
                 │                        │
                 ▼                        ▼
        ┌───────────────────┐    ┌───────────────────┐
        │ WeChat/Alipay SDK │    │   AuthRepository   │
        │   (fluwx/tobias)  │    │   /social-login    │
        └───────────────────┘    └───────────────────┘
```

## 文件清单

### 新增文件
- `lib/services/social_login_service.dart` - 社交 SDK 调用封装

### 修改文件
- `lib/features/auth/domain/repositories/iauth_repository.dart` - 添加 `SocialAuthProvider` 枚举和 `socialLogin` 接口
- `lib/features/auth/infrastructure/repositories/auth_repository.dart` - 实现 `socialLogin` API 调用
- `lib/features/auth/application/use_cases/auth_use_cases.dart` - 添加 `SocialLoginUseCase`
- `lib/features/auth/presentation/controllers/auth_state_controller.dart` - 添加 `socialLogin` 方法
- `lib/pages/register_page.dart` - 连接社交登录按钮到实际登录逻辑
- `lib/core/di/dependency_injection.dart` - 注册依赖

## 登录流程

1. 用户点击社交登录按钮（如微信）
2. `RegisterPage._handleSocialLogin()` 调用 `AuthStateController.socialLogin(type)`
3. `AuthStateController` 调用 `SocialLoginService.login(type)` 唤起对应 SDK
4. SDK 返回授权码 (code) 或 access_token
5. `AuthStateController` 调用 `SocialLoginUseCase` 将授权信息发送给后端
6. 后端验证授权信息，创建/查找用户，返回 AuthToken
7. 前端保存 token，完成登录

## 后端 API

### 端点
```
POST /auth/social-login
```

### 请求体
```json
{
  "provider": "wechat",  // wechat, alipay, qq, apple, google
  "code": "授权码",
  "accessToken": "访问令牌 (可选)",
  "openId": "用户唯一标识 (可选)"
}
```

### 响应
```json
{
  "accessToken": "JWT Token",
  "refreshToken": "刷新令牌",
  "expiresIn": 3600
}
```

## 支持的平台

| 平台 | SDK 包 | 状态 |
|------|--------|------|
| 微信 | fluwx ^5.7.5 | ✅ 已实现 |
| 支付宝 | tobias ^3.0.0 | ⏳ 待完善 |
| QQ | - | ⏳ 待实现 |
| Apple | sign_in_with_apple | ⏳ 待实现 |
| Google | google_sign_in | ⏳ 待实现 |

## 微信登录配置

### iOS
1. 在 Info.plist 添加 URL Scheme
2. 配置 Universal Link

### Android
1. 在 AndroidManifest.xml 注册 WXEntryActivity
2. 确保签名与微信开放平台一致

## 测试

### 微信登录测试
1. 安装微信 App
2. 确保 App 签名与微信开放平台配置一致
3. 点击微信登录按钮
4. 授权后检查是否成功跳转回 App

## 注意事项

1. **微信 AppId**: 在 `SocialSdkService` 中配置 `wechatAppId`
2. **后端 API**: 需要后端实现 `/auth/social-login` 接口
3. **用户合并**: 如果社交账号绑定的手机号/邮箱已存在，需要合并账号
4. **首次登录**: 首次使用社交登录可能需要补充手机号/邮箱

## 代码示例

### 调用社交登录
```dart
// 在任意页面调用
final authController = Get.find<AuthStateController>();
final success = await authController.socialLogin(SocialLoginType.wechat);

if (success) {
  // 登录成功
  Get.offAllNamed('/');
}
```

### 添加新的社交平台
```dart
// 1. 在 SocialLoginType 枚举添加新类型
enum SocialLoginType {
  wechat,
  alipay,
  qq,
  apple,
  google,
  newPlatform, // 新增
}

// 2. 在 SocialLoginService 添加登录方法
Future<SocialLoginResult> loginWithNewPlatform() async {
  // 实现 SDK 调用
}

// 3. 在 login() 方法的 switch 中添加 case
switch (type) {
  case SocialLoginType.newPlatform:
    return loginWithNewPlatform();
  // ...
}

// 4. 在 SocialAuthProvider 枚举添加对应值
enum SocialAuthProvider {
  wechat,
  alipay,
  qq,
  apple,
  google,
  newPlatform, // 新增
}
```
