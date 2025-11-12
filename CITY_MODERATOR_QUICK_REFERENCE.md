# City Moderator - 快速参考

## 🎯 功能说明

为每个城市添加版主管理系统，支持：
- 普通用户申请成为版主
- 管理员指定/更换版主
- 显示版主信息

## 📍 UI 位置

在城市详情页的**图片轮播下方**显示版主管理蒙层，根据用户角色和版主状态动态显示。

## 🎨 四种显示状态

### 1. 无版主 + 普通用户
```
┌────────────────────────────────────────┐
│ 🤝  成为城市版主，管理社区内容          │
│                         [立即申请]     │
└────────────────────────────────────────┘
```
- **颜色**: 红色渐变 (#FF4458 → DeepOrange)
- **操作**: 点击弹出申请确认对话框

### 2. 无版主 + 管理员
```
┌────────────────────────────────────────┐
│ 🛡️  该城市暂无版主                      │
│                         [指定版主]     │
└────────────────────────────────────────┘
```
- **颜色**: 橙色渐变
- **操作**: 点击打开指定版主对话框

### 3. 有版主 + 普通用户
```
┌────────────────────────────────────────┐
│ 👤  ✓ 城市版主：张三                    │
│     zhang.san@example.com              │
└────────────────────────────────────────┘
```
- **颜色**: 蓝色渐变
- **模式**: 只读，不可操作

### 4. 有版主 + 管理员
```
┌────────────────────────────────────────┐
│ 👤  ✓ 版主：张三      [更换版主]        │
└────────────────────────────────────────┘
```
- **颜色**: 蓝色渐变
- **操作**: 点击可更换版主

## 🔌 API 端点

### 申请成为版主
```http
POST /api/v1/cities/moderator/apply
Authorization: Bearer <token>
Content-Type: application/json

{
  "cityId": "city-uuid-here"
}
```

### 指定版主（仅管理员）
```http
POST /api/v1/cities/moderator/assign
Authorization: Bearer <token>
Content-Type: application/json

{
  "cityId": "city-uuid-here",
  "userId": "user-uuid-here"
}
```

## 💾 数据结构

### 后端 C# 实体
```csharp
public class City
{
    [Column("moderator_id")]
    public Guid? ModeratorId { get; set; }
}

public class ModeratorDto
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string? Email { get; set; }
    public string? Avatar { get; set; }
}
```

### Flutter Dart 实体
```dart
class Moderator {
  final String id;
  final String name;
  final String? email;
  final String? avatar;
}

class City {
  final String? moderatorId;
  final Moderator? moderator;
  // ... 其他字段
}
```

## 🔐 权限矩阵

| 操作 | 普通用户 | 版主 | 管理员 |
|------|---------|------|--------|
| 查看版主信息 | ✅ | ✅ | ✅ |
| 申请成为版主 | ✅ | ❌ | ❌ |
| 指定版主 | ❌ | ❌ | ✅ |
| 更换版主 | ❌ | ❌ | ✅ |

## 🛠️ 关键代码位置

### Flutter
```
lib/features/city/domain/entities/city.dart
  ↳ class Moderator
  ↳ class City (添加 moderatorId, moderator)

lib/features/city/infrastructure/repositories/city_repository.dart
  ↳ applyModerator(cityId)
  ↳ assignModerator(cityId, userId)

lib/pages/city_detail_page.dart
  ↳ _buildModeratorManagementOverlay()
  ↳ _showApplyModeratorDialog()
  ↳ _handleApplyModerator()
```

### .NET Core
```
CityService/Domain/Entities/City.cs
  ↳ ModeratorId 字段

CityService/Application/DTOs/CityDtos.cs
  ↳ ModeratorDto, ApplyModeratorDto, AssignModeratorDto

CityService/Application/Services/CityApplicationService.cs
  ↳ ApplyModeratorAsync()
  ↳ AssignModeratorAsync()

CityService/API/Controllers/CitiesController.cs
  ↳ POST /moderator/apply
  ↳ POST /moderator/assign
```

## 🧪 测试检查清单

- [ ] 无版主时普通用户看到"申请成为版主"按钮
- [ ] 无版主时管理员看到"指定版主"按钮
- [ ] 有版主时显示版主信息横幅
- [ ] 管理员可以看到"更换版主"按钮
- [ ] 点击申请按钮显示确认对话框
- [ ] 确认申请后调用 API 成功
- [ ] API 返回错误时显示错误提示
- [ ] 申请成功后刷新城市信息显示版主
- [ ] 版主头像、姓名、邮箱正确显示

## 📱 UI 效果预览

```
┌─────────────────────────────────────────┐
│                                         │
│         [城市图片轮播]                   │
│                                         │
│  ● ○ ○ ○                               │ ← 轮播指示器
│                                         │
│  ┌────────────────────────────────┐   │
│  │ 🤝 成为城市版主，管理社区内容   │   │ ← 版主蒙层
│  │                   [立即申请]    │   │
│  └────────────────────────────────┘   │
├─────────────────────────────────────────┤
│  ⭐ 4.5  |  📝 128 评论               │
└─────────────────────────────────────────┘
```

## 🔄 申请流程

```
点击"立即申请"
    ↓
显示申请对话框
    ↓
确认申请
    ↓
调用 API
    ↓
成功 → 提示成功 + 刷新城市信息
失败 → 提示错误原因
```

## ⚠️ 注意事项

1. **权限检查**: 使用 `TokenStorageService().isAdmin()` 判断用户角色
2. **数据刷新**: 申请成功后调用 `controller.loadCityDetail(cityId)` 刷新
3. **错误处理**: 使用 `result.fold()` 处理 Success 和 Failure
4. **UI 位置**: 蒙层固定在图片轮播下方 24px 处
5. **用户搜索**: 指定版主功能需要后续实现用户搜索接口

## 🚀 快速集成

### 后端部署
```bash
# 1. 数据库迁移（添加 moderator_id 字段）
dotnet ef migrations add AddModeratorToCity
dotnet ef database update

# 2. 重新编译和部署
dotnet build
dotnet publish
```

### 前端部署
```bash
# 1. 确保依赖安装
flutter pub get

# 2. 检查编译
flutter analyze

# 3. 运行
flutter run
```

---

**快速参考版本**: v1.0  
**更新时间**: 2025-01-XX
