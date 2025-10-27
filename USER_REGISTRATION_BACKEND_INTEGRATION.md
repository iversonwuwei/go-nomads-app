# 用户注册后端 API 集成完成

## 集成概述

成功将 `register_page.dart` 从使用本地数据库 (`AccountDao`) 迁移到使用后端注册 API。

## 修改文件

### 1. `lib/pages/register_page.dart`

#### 变更内容

**导入语句更新:**
```dart
// 旧导入
import '../services/database/account_dao.dart';

// 新导入
import '../services/auth_service.dart';
import '../services/http_service.dart';
```

**服务实例更新:**
```dart
// 旧
final _accountDao = AccountDao();

// 新
final _authService = AuthService();
```

**注册逻辑更新:**
```dart
// 旧的本地数据库注册
final accountId = await _accountDao.registerAccount(
  email: _emailController.text.trim(),
  username: _usernameController.text.trim(),
  password: _passwordController.text,
  name: _usernameController.text.trim(),
);

if (accountId != null) {
  // 成功...
} else {
  // 失败...
}

// 新的后端 API 注册
final response = await _authService.register(
  username: _usernameController.text.trim(),
  email: _emailController.text.trim(),
  password: _passwordController.text,
  confirmPassword: _confirmPasswordController.text,
);

// 成功 - response 包含 {accessToken, refreshToken, user}
print('✅ 注册成功: ${response['user']}');
```

**错误处理改进:**
```dart
// 新增 HttpException 捕获，显示后端返回的具体错误信息
on HttpException catch (e) {
  print('❌ 注册失败 (HttpException): ${e.message}');
  AppToast.error(
    e.message,
    title: '注册失败',
  );
}
```

### 2. `lib/services/auth_service.dart`

#### 变更内容

**修复字段映射:**
```dart
// 旧的请求体 (与后端不匹配)
data: {
  'username': username,      // ❌ 后端不接受
  'email': email,
  'password': password,
  'confirmPassword': confirmPassword,  // ❌ 后端不需要
}

// 新的请求体 (与后端 RegisterDto 匹配)
data: {
  'name': username,          // ✅ 后端使用 'name' 字段
  'email': email,
  'password': password,
  if (phone != null && phone.isNotEmpty) 'phone': phone,
}
```

**添加前端密码验证:**
```dart
// 在发送请求前验证密码确认
if (password != confirmPassword) {
  throw HttpException('两次输入的密码不一致');
}
```

**自动 Token 管理:**
```dart
// 注册成功后自动保存 token
final accessToken = _extractAccessToken(data);
if (accessToken != null) {
  _httpService.setAuthToken(accessToken);
  final refreshToken = _extractRefreshToken(data);
  await _persistTokens(
    accessToken: accessToken,
    refreshToken: refreshToken,
  );
}
```

## 后端 API 信息

### 端点
```
POST /api/v1/auth/register
```

### 请求体 (RegisterDto)
```json
{
  "name": "string",       // 必填，2-100字符
  "email": "string",      // 必填，邮箱格式
  "password": "string",   // 必填，6-100字符
  "phone": "string"       // 可选，手机号格式
}
```

### 响应体 (ApiResponse<AuthResponseDto>)
```json
{
  "success": true,
  "message": "注册成功",
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "id": "uuid",
      "name": "用户名",
      "email": "user@example.com",
      "phone": "13800138000",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

### 错误响应
```json
{
  "success": false,
  "message": "邮箱已被注册",
  "errors": ["Email already exists"]
}
```

## 后端源码文件

### 控制器
- **文件**: `go-noma/src/Services/UserService/UserService/API/Controllers/AuthController.cs`
- **路由**: `[Route("api/v1/auth")]`
- **方法**: `[HttpPost("register")]`

### DTO
- **RegisterDto**: `go-noma/src/Services/UserService/UserService/Application/DTOs/RegisterDto.cs`
- **AuthResponseDto**: `go-noma/src/Services/UserService/UserService/Application/DTOs/AuthResponseDto.cs`
- **UserDto**: `go-noma/src/Services/UserService/UserService/Application/DTOs/UserDto.cs`

## 集成优势

### 1. **统一用户管理**
- ✅ 用户数据存储在后端数据库 (PostgreSQL/Supabase)
- ✅ 支持跨设备登录
- ✅ 数据一致性保证

### 2. **安全性提升**
- ✅ 密码在后端使用 BCrypt 哈希
- ✅ JWT Token 认证
- ✅ Refresh Token 自动管理

### 3. **功能扩展**
- ✅ 注册成功后自动返回 Token
- ✅ 可选的手机号字段
- ✅ 完整的错误处理

### 4. **用户体验**
- ✅ 显示后端返回的具体错误信息
- ✅ 注册成功后可直接使用 Token 进行后续操作
- ✅ 平滑的错误提示

## 数据流程

```
用户填写表单
    ↓
前端验证 (密码确认、必填项)
    ↓
调用 AuthService.register()
    ↓
前端验证密码是否一致
    ↓
发送 POST /api/v1/auth/register
    ↓
后端验证 (RegisterDto)
    ↓
检查邮箱是否已存在
    ↓
密码 BCrypt 哈希
    ↓
保存用户到数据库
    ↓
生成 JWT Token
    ↓
返回 AuthResponseDto
    ↓
HttpService 拦截器解包 ApiResponse
    ↓
AuthService 自动保存 Token
    ↓
显示成功提示
    ↓
跳转到登录页面
```

## 测试场景

### 1. 成功注册
```
输入: 
  - username: "testuser"
  - email: "test@example.com"
  - password: "password123"
  - confirmPassword: "password123"
  - agreeToTerms: true

期望: 
  - ✅ 显示 "欢迎加入我们的社区" 成功提示
  - ✅ Token 自动保存
  - ✅ 跳转到登录页面
```

### 2. 邮箱已存在
```
输入: 已注册的邮箱

期望:
  - ❌ 显示 "邮箱已被注册" 错误提示
  - ❌ 停留在注册页面
```

### 3. 密码不一致
```
输入:
  - password: "password123"
  - confirmPassword: "password456"

期望:
  - ❌ 前端验证失败
  - ❌ 显示 "两次输入的密码不一致" 错误提示
  - ❌ 不发送请求到后端
```

### 4. 未同意条款
```
输入: agreeToTerms: false

期望:
  - ❌ 显示 "请先同意服务条款和隐私政策" 警告
  - ❌ 不发送请求到后端
```

### 5. 网络错误
```
场景: 后端服务不可用

期望:
  - ❌ 显示 "注册过程中发生错误，请稍后重试"
  - ❌ 停留在注册页面
  - ❌ 允许用户重试
```

## API 配置

### 端点配置
**文件**: `lib/config/api_config.dart`

```dart
// 注册端点
static const String registerEndpoint = '/auth/register';

// 完整 URL (开发环境)
// Android 模拟器: http://10.0.2.2:5000/api/v1/auth/register
// iOS 模拟器:    http://localhost:5000/api/v1/auth/register
// 真机测试:      http://192.168.1.100:5000/api/v1/auth/register (需配置)
```

### 环境切换
```dart
// 修改 api_config.dart
static const bool kIsProduction = false;  // 开发模式
static const bool usePhysicalDevice = false;  // 使用真机时设为 true
```

## 后续优化建议

### 1. 添加用户名唯一性验证
```dart
// 在输入框失去焦点时检查用户名是否已存在
onFieldSubmitted: () async {
  final isAvailable = await _authService.checkUsernameAvailability(
    _usernameController.text.trim()
  );
  if (!isAvailable) {
    // 显示用户名已存在提示
  }
}
```

### 2. 添加邮箱验证功能
```dart
// 注册后发送验证邮件
// 需要后端支持 /auth/verify-email 端点
```

### 3. 密码强度指示器
```dart
// 实时显示密码强度
PasswordStrengthIndicator(
  password: _passwordController.text,
)
```

### 4. 社交登录集成
```dart
// Google、Apple、微信登录
// 需要后端支持对应的 OAuth 端点
```

## 调试技巧

### 1. 查看请求日志
```dart
// HttpService 已配置日志拦截器
// 控制台会打印:
// 📤 POST /api/v1/auth/register
// 请求体: {...}
// 📥 200 OK
// 响应体: {...}
```

### 2. 检查 Token 保存
```dart
// 在注册成功后打印
print('✅ Token: ${_authService._httpService.authToken}');
```

### 3. 测试后端连接
```bash
# 测试后端注册端点
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'
```

## 常见问题

### Q1: 注册失败，显示 "注册失败，请稍后重试"
**原因**: 后端服务未启动或网络不通
**解决**: 
1. 检查后端服务是否运行在 `http://localhost:5000`
2. Android 模拟器需使用 `http://10.0.2.2:5000`
3. 真机测试需配置 `physicalDeviceUrl`

### Q2: 显示 "邮箱已被注册"
**原因**: 数据库中已存在相同邮箱
**解决**: 使用不同的邮箱或清理测试数据

### Q3: Token 没有自动保存
**原因**: 后端返回的 Token 字段名不匹配
**解决**: 检查 `_extractAccessToken()` 方法是否正确提取 Token

### Q4: iOS 模拟器无法连接后端
**原因**: iOS 模拟器可以使用 localhost
**解决**: 确保 `api_config.dart` 中 iOS 平台配置为 `http://localhost:5000`

## 相关文档

- [Backend Login Integration](./BACKEND_LOGIN_INTEGRATION.md)
- [API Configuration Guide](./API_INTEGRATION_GUIDE.md)
- [后端 API 文档](../go-noma/docs/API.md)
- [用户服务文档](../go-noma/src/Services/UserService/README.md)

## 完成时间

**日期**: 2024-01-XX  
**版本**: v1.0.0  
**状态**: ✅ 完成并测试

---

**下一步**: 可以开始集成用户登录、个人资料编辑等其他用户相关功能。
