# 后端登录集成完成

## 概述
已成功集成后端登录接口 `/api/Users/login`，实现了完整的认证流程和 Token 持久化。

## 完成的功能

### 1. API 配置
- ✅ 更新 `api_config.dart`
  - 后端地址: `http://localhost:5000`
  - 登录端点: `/api/Users/login`

### 2. 数据模型
- ✅ 创建 `login_response_model.dart`
  - `LoginResponse`: 响应外层结构
  - `LoginData`: 包含 token 和用户信息
  - `UserInfo`: 用户详细信息

### 3. Token 持久化
- ✅ 创建 `token_dao.dart` - Token 数据访问对象
  - `saveToken()`: 保存/更新 token
  - `getTokenByUserId()`: 根据用户 ID 获取 token
  - `getLatestToken()`: 获取最近的 token
  - `isTokenExpired()`: 检查 token 是否过期
  - `deleteTokenByUserId()`: 删除指定用户 token
  - `deleteAllTokens()`: 清空所有 token

- ✅ 更新 `database_service.dart`
  - 数据库版本升级到 v4
  - 添加 `tokens` 表

### 4. 认证服务
- ✅ 创建 `nomads_auth_service.dart`
  - `login()`: 调用后端登录接口
  - `logout()`: 清除 token
  - `restoreToken()`: 启动时恢复 token
  - `refreshToken()`: 刷新 token（待后端实现）
  - `isLoggedIn()`: 检查登录状态

### 5. 登录页面
- ✅ 更新 `nomads_login_page.dart`
  - 集成 `NomadsAuthService`
  - 显示加载指示器
  - 错误处理和提示
  - 登录成功后保存状态并跳转

## 使用说明

### 测试账号
- 邮箱: `walden.wuwei@gmail.com`
- 密码: `walden123456`

### 登录流程
1. 用户输入邮箱和密码
2. 调用 `/api/Users/login` 接口
3. 后端返回响应:
   - 成功: `{success: true, data: {...}}`
   - 失败: `{success: false, message: "错误信息"}`
4. 登录成功后:
   - 保存 access_token 到 `HttpService`
   - 持久化 token 到 SQLite `tokens` 表
   - 保存用户状态到 `UserStateController`
   - 跳转到首页

### Token 管理
```dart
// 所有后续 API 请求自动携带 token
Authorization: Bearer <access_token>

// Token 存储在 SQLite
tokens 表结构:
- user_id: 用户ID
- access_token: 访问令牌
- refresh_token: 刷新令牌
- token_type: Bearer
- expires_in: 3600 秒
- created_at: 创建时间
- updated_at: 更新时间
```

## 响应数据结构

### 成功响应
```json
{
  "success": true,
  "message": "登录成功",
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "id": "9d789131-e560-47cf-9ff1-b05f9c345207",
      "name": "walden",
      "email": "walden.wuwei@gmail.com",
      "phone": "13898624819",
      "createdAt": "2025-10-22T14:45:11",
      "updatedAt": "2025-10-22T14:45:11"
    }
  },
  "errors": []
}
```

### 失败响应
```json
{
  "success": false,
  "message": "用户名或密码错误",
  "data": null,
  "errors": []
}
```

## 调试日志

登录过程会输出详细日志：
```
🔐 开始登录验证...
   邮箱: walden.wuwei@gmail.com
🔐 开始调用后端登录接口...
   接口: /api/Users/login
   邮箱: walden.wuwei@gmail.com
✅ 后端响应状态码: 200
✅ 后端响应数据: {...}
🎉 登录成功！
   用户: walden
   Token: eyJhbGciOiJIUzI1NiI...
💾 开始保存 token 到数据库...
✅ Token 已保存到 SQLite
✅ 用户状态已保存
🚀 准备跳转到主页...
```

## 文件清单

### 新增文件
1. `lib/models/login_response_model.dart` - 登录响应模型
2. `lib/services/database/token_dao.dart` - Token 数据访问层
3. `lib/services/nomads_auth_service.dart` - 认证服务

### 修改文件
1. `lib/config/api_config.dart` - 更新端口和登录端点
2. `lib/services/database_service.dart` - 添加 tokens 表
3. `lib/pages/nomads_login_page.dart` - 集成后端登录

## 待完成功能

### 1. Token 自动刷新
```dart
// 在 HttpService 拦截器中实现
if (response.statusCode == 401) {
  // Token 过期，尝试刷新
  await nomadsAuthService.refreshToken(userId);
  // 重试原请求
}
```

### 2. 启动时恢复登录状态
```dart
// 在 main.dart 中
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authService = NomadsAuthService();
  final isLoggedIn = await authService.restoreToken();
  
  runApp(MyApp(isLoggedIn: isLoggedIn));
}
```

### 3. 登出功能
```dart
// 在用户设置页面
await nomadsAuthService.logout();
Get.offAllNamed('/login');
```

## 测试步骤

1. **确保后端服务运行**
   ```bash
   # 后端应该运行在 http://localhost:5000
   ```

2. **iOS 模拟器测试**
   - 使用 `http://localhost:5000` ✅

3. **Android 模拟器测试**
   - 修改配置: `ApiConfig.setBaseUrl('http://10.0.2.2:5000')`

4. **真机测试**
   - 修改配置: `ApiConfig.setBaseUrl('http://你的局域网IP:5000')`

5. **登录测试**
   - 打开 App
   - 进入登录页面
   - 输入: `walden.wuwei@gmail.com` / `walden123456`
   - 点击登录
   - 检查控制台日志
   - 验证是否跳转到首页

## 错误处理

已实现的错误处理：
- ✅ 网络连接失败
- ✅ 服务器错误 (500)
- ✅ 认证失败 (401)
- ✅ 用户名或密码错误
- ✅ Token 保存失败（不影响登录）
- ✅ 超时错误

## 安全建议

1. **生产环境配置**
   - 使用 HTTPS: `https://api.yourdomain.com`
   - 不要在代码中硬编码密码

2. **Token 安全**
   - Token 存储在本地 SQLite（相对安全）
   - 考虑使用 flutter_secure_storage 加密存储

3. **密码输入**
   - 已实现密码隐藏/显示切换
   - 考虑添加密码强度检查

## 下一步

1. 实现其他页面的后端集成（首页数据、城市列表等）
2. 实现 Token 自动刷新机制
3. 添加注册功能
4. 添加忘记密码功能
5. 实现用户资料编辑
