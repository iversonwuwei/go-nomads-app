# City Moderator 功能完成总结

## 📋 功能概述

为每个城市添加版主管理功能，支持用户申请成为版主和管理员指定版主。

## ✅ 完成内容

### 1. 后端实现（.NET Core - go-noma/CityService）

#### 1.1 实体层修改
- **文件**: `City.cs`
- **修改**: 添加 `moderator_id` 字段（Guid?）

#### 1.2 DTO 层修改
- **文件**: `CityDtos.cs`
- **新增 DTO**:
  - `ModeratorDto`: 版主信息（Id, Name, Email, Avatar）
  - `ApplyModeratorDto`: 申请版主请求（CityId, Reason）
  - `AssignModeratorDto`: 指定版主请求（CityId, UserId）
- **修改**:
  - `CityDto`: 添加 `ModeratorId` 和 `Moderator` 字段
  - `UpdateCityDto`: 添加 `ModeratorId` 字段（仅管理员可设置）

#### 1.3 应用服务层
- **文件**: `CityApplicationService.cs`
- **新增方法**:
  ```csharp
  Task<bool> ApplyModeratorAsync(Guid userId, ApplyModeratorDto dto)
  // 申请成为版主，检查城市存在性和版主状态
  
  Task<bool> AssignModeratorAsync(AssignModeratorDto dto)
  // 管理员指定版主（无需检查权限，由 Controller 处理）
  ```

#### 1.4 控制器层
- **文件**: `CitiesController.cs`
- **新增端点**:
  - `POST /api/v1/cities/moderator/apply` - 申请成为版主（需登录）
  - `POST /api/v1/cities/moderator/assign` - 指定版主（仅管理员）
- **辅助方法**: `GetCurrentUserId()` - 从 JWT Token 获取用户 ID

#### 1.5 接口层
- **文件**: `ICityService.cs`
- **新增接口方法**:
  ```csharp
  Task<bool> ApplyModeratorAsync(Guid userId, ApplyModeratorDto dto);
  Task<bool> AssignModeratorAsync(AssignModeratorDto dto);
  ```

### 2. Flutter 前端实现（open-platform-app）

#### 2.1 领域层（Domain Layer）

**文件**: `lib/features/city/domain/entities/city.dart`

**新增实体**:
```dart
class Moderator {
  final String id;
  final String name;
  final String? email;
  final String? avatar;
  // 包含 fromJson, toJson, ==, hashCode
}
```

**修改 City 实体**:
```dart
class City {
  // 新增字段
  final String? moderatorId;
  final Moderator? moderator;
  
  // 更新了 fromJson, toJson, copyWith 方法
}
```

#### 2.2 仓储层（Infrastructure Layer）

**文件**: `lib/features/city/domain/repositories/i_city_repository.dart`
```dart
// 新增接口方法
Future<Result<bool>> applyModerator(String cityId);
Future<Result<bool>> assignModerator(String cityId, String userId);
```

**文件**: `lib/features/city/infrastructure/repositories/city_repository.dart`
```dart
// 实现接口方法
@override
Future<Result<bool>> applyModerator(String cityId) async {
  // POST /cities/moderator/apply
}

@override
Future<Result<bool>> assignModerator(String cityId, String userId) async {
  // POST /cities/moderator/assign
}
```

#### 2.3 表现层（Presentation Layer）

**文件**: `lib/pages/city_detail_page.dart`

**核心功能**:

1. **版主管理蒙层** - 在图片轮播下方显示
   - 位置：`Positioned(bottom: 24, left: 16, right: 16)`
   - 根据版主状态和用户角色动态显示不同 UI

2. **四种显示状态**:

   a. **无版主 + 普通用户**
   ```dart
   _buildApplyModeratorButton()
   // 红色渐变按钮："成为城市版主，管理社区内容"
   // 点击触发 _showApplyModeratorDialog()
   ```

   b. **无版主 + 管理员**
   ```dart
   _buildAssignModeratorButton()
   // 橙色渐变按钮："该城市暂无版主"
   // 点击触发 _showAssignModeratorDialog()
   ```

   c. **有版主 + 普通用户**
   ```dart
   _buildModeratorInfoBanner(moderator)
   // 蓝色渐变横幅：显示版主信息（头像、姓名、邮箱）
   // 只读模式
   ```

   d. **有版主 + 管理员**
   ```dart
   _buildModeratorInfoWithChange(moderator)
   // 蓝色渐变横幅 + "更换版主"按钮
   ```

3. **对话框交互**:
   - `_showApplyModeratorDialog()`: 申请确认对话框，显示版主权限说明
   - `_showAssignModeratorDialog()`: 指定版主对话框（待完善用户搜索）

4. **API 调用**:
   ```dart
   Future<void> _handleApplyModerator() async {
     final repository = Get.find<ICityRepository>();
     final result = await repository.applyModerator(cityId);
     
     result.fold(
       onSuccess: (_) => // 成功提示 + 刷新城市信息
       onFailure: (error) => // 错误提示
     );
   }
   ```

5. **权限检查**:
   ```dart
   Future<bool> _checkIsAdmin() async {
     final tokenService = TokenStorageService();
     return await tokenService.isAdmin();
   }
   ```

## 🎨 UI 设计特点

1. **渐变背景**：
   - 申请按钮：红色到深橙色渐变
   - 指定按钮：橙色到深橙色渐变
   - 版主信息：蓝色渐变

2. **半透明蒙层**：
   - 使用 `Colors.withValues(alpha: 0.9)` 实现半透明效果
   - 与图片轮播自然融合

3. **阴影效果**：
   ```dart
   boxShadow: [
     BoxShadow(
       color: Colors.black.withValues(alpha: 0.3),
       blurRadius: 8,
       offset: const Offset(0, 2),
     ),
   ]
   ```

4. **圆角设计**：`BorderRadius.circular(12)`

## 📊 API 端点

### 后端 API（CityService）

| 端点 | 方法 | 权限 | 描述 |
|------|------|------|------|
| `/api/v1/cities/moderator/apply` | POST | 需登录 | 申请成为版主 |
| `/api/v1/cities/moderator/assign` | POST | 仅管理员 | 指定版主 |

### 请求示例

**申请版主**:
```json
POST /api/v1/cities/moderator/apply
{
  "cityId": "city-uuid-here"
}
```

**指定版主**:
```json
POST /api/v1/cities/moderator/assign
{
  "cityId": "city-uuid-here",
  "userId": "user-uuid-here"
}
```

## 🔐 权限控制

### 后端
- **申请版主**: 检查 JWT Token 是否存在，从 Claims 获取 UserId
- **指定版主**: 需要 `[Authorize(Roles = "admin")]` 特性

### 前端
- **UI 显示**: 通过 `TokenStorageService.isAdmin()` 判断用户角色
- **动态按钮**: 根据 `city.moderatorId` 和用户角色显示不同 UI
- **API 调用**: 所有请求自动携带 Token（由 HttpService 处理）

## 🧪 测试要点

### 功能测试
1. **无版主场景**:
   - [ ] 普通用户看到"申请成为版主"按钮
   - [ ] 管理员看到"指定版主"按钮
   - [ ] 点击申请按钮显示确认对话框
   - [ ] 确认申请后调用 API 并刷新城市信息

2. **有版主场景**:
   - [ ] 普通用户看到版主信息横幅（只读）
   - [ ] 管理员看到版主信息 + "更换版主"按钮
   - [ ] 显示版主头像、姓名、邮箱

3. **API 测试**:
   - [ ] 申请接口返回成功
   - [ ] 申请接口返回失败（如已有版主）
   - [ ] 指定接口需要管理员权限
   - [ ] Token 过期时正确处理

### UI 测试
- [ ] 蒙层在图片轮播下方正确显示
- [ ] 渐变效果和阴影正常
- [ ] 对话框正常弹出和关闭
- [ ] Toast 提示正确显示

## 📝 待优化功能

1. **用户搜索功能**:
   - `_showAssignModeratorDialog()` 中需要实现用户搜索
   - 显示用户列表（头像、姓名、邮箱）
   - 支持输入搜索

2. **版主权限管理**:
   - 版主可以编辑城市内容
   - 版主可以审核用户提交
   - 版主可以管理评论

3. **申请审核流程**:
   - 申请记录存储（可选）
   - 管理员审核界面
   - 申请状态通知

4. **版主变更记录**:
   - 记录版主变更历史
   - 显示变更时间和操作人

## 🔄 数据流

### 申请版主流程
```
用户点击"立即申请"
  ↓
_showApplyModeratorDialog() 显示确认对话框
  ↓
用户点击"确认申请"
  ↓
_handleApplyModerator()
  ↓
CityRepository.applyModerator(cityId)
  ↓
POST /api/v1/cities/moderator/apply
  ↓
CityApplicationService.ApplyModeratorAsync()
  ↓
检查城市存在 && 检查是否已有版主
  ↓
设置 city.ModeratorId = currentUserId
  ↓
UpdateAsync(city.Id, city)
  ↓
返回成功
  ↓
AppToast.success() + controller.loadCityDetail()
```

### 指定版主流程（待完善）
```
管理员点击"指定版主"
  ↓
_showAssignModeratorDialog() 显示用户搜索对话框
  ↓
搜索并选择用户
  ↓
确认指定
  ↓
CityRepository.assignModerator(cityId, userId)
  ↓
POST /api/v1/cities/moderator/assign
  ↓
CityApplicationService.AssignModeratorAsync()
  ↓
设置 city.ModeratorId = userId
  ↓
返回成功
  ↓
刷新城市信息
```

## 📦 文件修改列表

### 后端（go-noma）
1. `CityService/Domain/Entities/City.cs` ✅
2. `CityService/Application/DTOs/CityDtos.cs` ✅
3. `CityService/Application/Services/CityApplicationService.cs` ✅
4. `CityService/API/Controllers/CitiesController.cs` ✅
5. `CityService/Domain/Services/ICityService.cs` ✅

### 前端（open-platform-app）
1. `lib/features/city/domain/entities/city.dart` ✅
2. `lib/features/city/domain/repositories/i_city_repository.dart` ✅
3. `lib/features/city/infrastructure/repositories/city_repository.dart` ✅
4. `lib/pages/city_detail_page.dart` ✅

## 🎉 完成状态

- ✅ 后端 API 实现完成
- ✅ Flutter 实体和仓储完成
- ✅ UI 交互实现完成
- ✅ 权限控制实现完成
- ⏳ 用户搜索功能（待后续实现）

## 🚀 部署建议

1. **后端部署**:
   - 确保数据库迁移已执行（添加 `moderator_id` 字段）
   - 确保 JWT 配置正确（包含 Role Claims）
   - 测试管理员权限验证

2. **前端部署**:
   - 确保 API 配置正确（BaseUrl）
   - 确保 Token 存储正常工作
   - 测试不同用户角色的 UI 显示

## 📞 技术支持

如有问题，请查看：
- 后端编译错误：检查 `get_errors` 输出
- 前端编译错误：运行 `flutter analyze`
- API 调用失败：检查网络日志和 Token

---

**生成时间**: 2025-01-XX
**版本**: v1.0
**状态**: ✅ 功能完成，可进入测试阶段
