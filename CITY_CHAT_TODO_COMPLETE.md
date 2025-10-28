# City Chat 参与者 API 集成完成总结

## 概述

完成了 City Chat 页面"View All"模态框中显示真实用户参与者的功能，集成了后端 API 来获取活动参与者和用户详细信息。

## 完成的功能

### 1. 后端 API 开发

#### 1.1 批量获取用户 API

**文件**: `src/Services/UserService/UserService/API/Controllers/UsersController.cs`

添加了批量获取用户的 API 端点：

```csharp
[HttpPost("batch")]
public async Task<ActionResult<ApiResponse<List<UserDto>>>> GetUsersByIds(
    [FromBody] BatchUserIdsRequest request,
    CancellationToken cancellationToken = default)
```

**特性**:
- 端点: `POST /api/v1/users/batch`
- 限制: 单次最多批量获取 100 个用户
- 请求体: `{ "userIds": ["id1", "id2", ...] }`
- 响应: `ApiResponse<List<UserDto>>`

#### 1.2 服务层实现

**文件**: `src/Services/UserService/UserService/Application/Services/UserApplicationService.cs`

添加了批量获取用户的服务方法：

```csharp
public async Task<List<UserDto>> GetUsersByIdsAsync(
    List<string> ids, 
    CancellationToken cancellationToken = default)
```

**特性**:
- 自动去重用户ID
- 日志记录成功获取的用户数量
- 处理不存在的用户（跳过）

#### 1.3 接口定义

**文件**: `src/Services/UserService/UserService/Application/Services/IUserService.cs`

添加了接口定义：

```csharp
Task<List<UserDto>> GetUsersByIdsAsync(
    List<string> ids, 
    CancellationToken cancellationToken = default);
```

#### 1.4 请求 DTO

**文件**: `src/Services/UserService/UserService/API/Controllers/UsersController.cs`

添加了批量请求 DTO：

```csharp
public class BatchUserIdsRequest
{
    [Required(ErrorMessage = "用户ID列表不能为空")]
    public List<string> UserIds { get; set; } = new();
}
```

### 2. Flutter 前端开发

#### 2.1 用户 API 服务

**文件**: `lib/services/user_api_service.dart` (新建)

创建了用户 API 服务类：

```dart
class UserApiService {
  // 批量获取用户信息
  Future<List<Map<String, dynamic>>> batchGetUsers(List<string> userIds)
  
  // 获取单个用户信息
  Future<Map<String, dynamic>?> getUser(String userId)
}
```

**特性**:
- 支持批量获取用户
- 自动处理认证 token
- 错误处理和日志记录
- 返回空列表而不是抛出异常

#### 2.2 API 配置更新

**文件**: `lib/config/api_config.dart`

添加了用户批量获取端点：

```dart
static const String userBatchEndpoint = '/users/batch';
```

#### 2.3 ChatController 更新

**文件**: `lib/controllers/chat_controller.dart`

完成了所有 TODO：

1. **集成用户服务**
   ```dart
   final UserApiService _userApiService = UserApiService();
   final TokenStorageService _tokenService = TokenStorageService();
   ```

2. **添加认证 token**
   - 在加载参与者时自动附加 Bearer token
   - 在批量获取用户时自动附加 Bearer token

3. **实现真实数据转换**
   ```dart
   Future<List<OnlineUser>> _convertParticipantsToUsers(
       List<dynamic> participantsJson) async
   ```
   
   **功能**:
   - 从 ParticipantResponse 提取所有 userId
   - 批量调用用户服务获取详细信息
   - 合并参与者数据和用户数据
   - 错误回退到模拟数据
   - 使用真实的用户名、头像

## 数据流

```
1. 用户点击 "View All" 按钮
   ↓
2. ChatController.loadParticipantsFromApi()
   ↓
3. GET /api/v1/events/{eventId}/participants
   ↓
4. 获取 ParticipantResponse[] { userId, status, registeredAt }
   ↓
5. 提取所有 userId
   ↓
6. POST /api/v1/users/batch { userIds: [...] }
   ↓
7. 获取 UserDto[] { id, name, email, avatar }
   ↓
8. 合并数据创建 OnlineUser[]
   ↓
9. 在 UI 中显示真实用户信息
```

## API 端点总结

| 端点 | 方法 | 用途 |
|------|------|------|
| `/api/v1/events/{id}/participants` | GET | 获取活动参与者列表 |
| `/api/v1/users/batch` | POST | 批量获取用户详细信息 |
| `/api/v1/users/{id}` | GET | 获取单个用户信息 |

## 测试

### 后端测试

运行测试脚本：

```bash
bash test-users-batch.sh
```

测试用例：
1. 正常批量获取用户
2. 空用户ID列表
3. 超过100个用户ID的限制

### 前端测试

1. 进入 City Chat 页面
2. 点击 "View All" 按钮
3. 验证显示真实用户信息：
   - 用户名（来自后端）
   - 用户头像（来自后端）
   - 在线状态（基于 registeredAt）

## 错误处理

### 后端

1. **验证**：
   - 空用户ID列表 → 400 Bad Request
   - 超过100个用户 → 400 Bad Request

2. **异常处理**：
   - 数据库错误 → 500 Internal Server Error
   - 返回部分成功的用户

### 前端

1. **API 失败**：
   - 网络错误 → 回退到模拟数据
   - 超时 → 回退到模拟数据
   - 服务器错误 → 回退到模拟数据

2. **数据缺失**：
   - 用户服务返回部分用户 → 缺失的用户使用模拟数据
   - 用户没有头像 → 使用默认头像

## 性能优化

1. **批量请求**：
   - 一次性获取所有用户，减少 HTTP 请求次数
   - 避免 N+1 查询问题

2. **超时设置**：
   - API 请求超时: 10秒
   - 避免长时间等待

3. **限制**：
   - 单次最多 100 个用户
   - 防止过大的请求

## 安全性

1. **认证**：
   - 所有 API 请求附加 Bearer token
   - 使用 TokenStorageService 管理 token

2. **授权**：
   - 后端可以添加权限检查
   - 确保用户有权限查看参与者

## 待改进项

标记为 TODO 的功能（非紧急）：

1. **ChatRoom 模型增强**：
   ```dart
   // 在 ChatRoom 中添加 eventId 字段
   // 避免硬编码映射关系
   ```

2. **在线状态优化**：
   ```dart
   // 当前基于 registeredAt 判断在线状态
   // 未来可以集成实时在线状态追踪
   ```

3. **后端 Chat API**：
   ```
   // 可以实现 GET /api/v1/chats/{id}/participants
   // 直接返回聊天室的参与者
   ```

## 相关文件

### 后端

- `src/Services/UserService/UserService/API/Controllers/UsersController.cs`
- `src/Services/UserService/UserService/Application/Services/IUserService.cs`
- `src/Services/UserService/UserService/Application/Services/UserApplicationService.cs`

### 前端

- `lib/services/user_api_service.dart` (新建)
- `lib/config/api_config.dart`
- `lib/controllers/chat_controller.dart`
- `lib/pages/city_chat_page.dart`

### 测试

- `test-users-batch.sh` (新建)

## 总结

✅ **已完成所有 TODO 项目**：

1. ✅ 后端批量获取用户 API
2. ✅ 前端用户服务集成
3. ✅ 认证 token 集成
4. ✅ 真实用户数据显示
5. ✅ 错误处理和回退机制
6. ✅ 测试脚本

现在用户在 City Chat 页面点击 "View All" 后，将看到：
- 真实的用户名（从后端数据库获取）
- 真实的用户头像（从后端数据库获取）
- 基于注册时间的在线状态
- 完整的加载状态和错误处理
