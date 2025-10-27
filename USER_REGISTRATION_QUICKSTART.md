# 用户注册 API 集成 - 快速指南

## ✅ 集成完成

用户注册功能已成功从本地数据库迁移到后端 API。

## 📋 变更摘要

### 修改的文件
1. **lib/pages/register_page.dart** - 使用 `AuthService` 替代 `AccountDao`
2. **lib/services/auth_service.dart** - 修正请求字段映射，匹配后端 API

### 后端端点
```
POST /api/v1/auth/register
```

### 请求参数
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | String | ✅ | 用户名 (2-100字符) |
| email | String | ✅ | 邮箱地址 |
| password | String | ✅ | 密码 (6-100字符) |
| phone | String | ❌ | 手机号 (可选) |

### 响应格式
```json
{
  "success": true,
  "message": "注册成功",
  "data": {
    "accessToken": "jwt_token_here",
    "refreshToken": "refresh_token_here",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "id": "user_uuid",
      "name": "用户名",
      "email": "user@example.com"
    }
  }
}
```

## 🔑 关键改进

1. **字段映射修正**
   - 前端 `username` → 后端 `name`
   - 移除后端不需要的 `confirmPassword` 字段
   - 密码确认在前端验证

2. **自动 Token 管理**
   - 注册成功后自动保存 `accessToken` 和 `refreshToken`
   - Token 存储在本地持久化服务中

3. **错误处理增强**
   - 捕获 `HttpException` 显示后端具体错误信息
   - 支持邮箱重复、验证失败等场景

## 🧪 测试步骤

### 1. 启动后端服务
```bash
cd go-noma
docker-compose up -d
```

### 2. 测试注册 API
```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 3. 运行 Flutter 应用
```bash
cd open-platform-app
flutter run
```

### 4. 测试场景
- ✅ 正常注册流程
- ✅ 邮箱已存在
- ✅ 密码不一致 (前端验证)
- ✅ 未同意条款
- ✅ 网络错误处理

## 📦 相关文件

### Flutter 前端
- `lib/pages/register_page.dart` - 注册页面
- `lib/services/auth_service.dart` - 认证服务
- `lib/services/http_service.dart` - HTTP 客户端
- `lib/config/api_config.dart` - API 配置

### .NET 后端
- `src/Services/UserService/UserService/API/Controllers/AuthController.cs`
- `src/Services/UserService/UserService/Application/DTOs/RegisterDto.cs`
- `src/Services/UserService/UserService/Application/DTOs/AuthResponseDto.cs`

## 🐛 常见问题

**Q: Android 模拟器无法连接后端**
```
A: 使用 http://10.0.2.2:5000 替代 localhost
   已在 api_config.dart 中自动配置
```

**Q: 显示 "邮箱已被注册"**
```
A: 正常的业务逻辑，后端已存在该邮箱用户
   可使用不同邮箱或清理测试数据
```

**Q: Token 未保存**
```
A: 检查后端响应格式是否正确
   AuthService 会自动提取并保存 token
```

## 📚 详细文档

查看完整文档: [USER_REGISTRATION_BACKEND_INTEGRATION.md](./USER_REGISTRATION_BACKEND_INTEGRATION.md)

---

**集成状态**: ✅ 完成  
**测试状态**: ⏳ 待测试  
**版本**: v1.0.0
