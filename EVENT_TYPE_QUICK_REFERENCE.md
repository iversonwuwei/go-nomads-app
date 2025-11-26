# 事件类型集成快速参考

## 📦 核心文件

```
lib/features/meetup/
├── domain/entities/event_type.dart              # EventType 实体
├── domain/repositories/i_event_type_repository.dart  # Repository 接口
├── infrastructure/models/event_type_dto.dart    # DTO 模型
├── infrastructure/repositories/event_type_repository.dart  # Repository 实现
└── presentation/controllers/event_type_controller.dart  # GetX Controller

lib/pages/create_meetup_page.dart                # UI 集成
```

## 🔑 关键代码

### 1. Controller 初始化
```dart
final EventTypeController _eventTypeController = Get.put(EventTypeController());
```

### 2. 加载类型
```dart
await _eventTypeController.loadEventTypes();  // 自动缓存
```

### 3. 获取本地化名称
```dart
final locale = Localizations.localeOf(context).languageCode;
final displayName = eventType.getDisplayName(locale);
```

### 4. 提交数据
```dart
final selectedEventType = _eventTypeController.getEventTypeById(_selectedTypeId!);
final meetupType = MeetupType.fromString(selectedEventType.enName.toLowerCase());
```

## 🌐 API 端点

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/api/v1/event-types` | 获取所有活跃类型 |
| GET | `/api/v1/event-types/{id}` | 获取单个类型 |

## 🎯 数据结构

### EventType 实体
```dart
class EventType {
  final String id;
  final String name;       // 中文名
  final String enName;     // 英文名
  final String? description;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  String getDisplayName(String locale);
}
```

### 数据库字段映射
```
EventType.id          → event_types.id
EventType.name        → event_types.name
EventType.enName      → event_types.en_name
EventType.sortOrder   → event_types.sort_order
EventType.isActive    → event_types.is_active
```

## 🔄 数据流

```
加载: EventTypeController → Repository → API → DTO → EventType
提交: EventType.enName → MeetupType → category (后端)
```

## 🛠️ Controller 方法

```dart
// 加载类型（自动缓存）
await controller.loadEventTypes(forceRefresh: false);

// 获取类型
final type = controller.getEventTypeById(id);

// 搜索类型
final results = controller.searchEventTypes(query);

// 获取本地化名称列表
final names = controller.getDisplayNames(locale);

// 强制刷新
await controller.refresh();

// 重置状态
controller.reset();
```

## 📊 状态变量

```dart
RxList<EventType> eventTypes;   // 类型列表
RxBool isLoading;                // 加载状态
RxString errorMessage;           // 错误信息
RxBool hasError;                 // 错误标志
```

## 🎨 UI 集成模式

### 显示选项
```dart
final localeCode = Localizations.localeOf(context).languageCode;
final displayOptions = _meetupTypes
    .map((type) => type.getDisplayName(localeCode))
    .toList();
```

### 保存选择
```dart
setState(() {
  _selectedType = displayName;      // 显示用
  _selectedTypeId = eventType.id;   // 提交用
});
```

### 提交转换
```dart
final selectedEventType = _eventTypeController.getEventTypeById(_selectedTypeId!);
final meetupType = MeetupType.fromString(selectedEventType.enName.toLowerCase());
```

## 🔍 调试技巧

### 查看缓存状态
```dart
print('缓存状态: ${_eventTypeController.eventTypes.length} 项');
print('加载标志: $_hasLoaded');
```

### 追踪加载流程
```dart
print('🔄 开始加载...');
await controller.loadEventTypes();
print('✅ 加载完成: ${controller.eventTypes.length} 项');
```

### 验证选择
```dart
print('选中类型: $_selectedType');
print('选中 ID: $_selectedTypeId');
final type = controller.getEventTypeById(_selectedTypeId!);
print('完整对象: ${type?.name} / ${type?.enName}');
```

## 🐛 常见错误

### 1. 类型列表为空
```dart
// 检查点
if (_meetupTypes.isEmpty) {
  print('⚠️ 类型列表为空，检查 API 和数据库');
}
```

### 2. 缓存未生效
```dart
// 确认使用 Get.put 而非 Get.find
final controller = Get.put(EventTypeController());  // ✅
// 而不是
// final controller = Get.find<EventTypeController>();  // ❌
```

### 3. 多语言失效
```dart
// 检查 locale
final locale = Localizations.localeOf(context).languageCode;
print('当前语言: $locale');  // 应该是 'zh' 或 'en'
```

## 📝 快速检查清单

- [ ] 数据库已初始化 (20 条类型数据)
- [ ] 后端服务运行中 (localhost:8005)
- [ ] Controller 正确注入 (Get.put)
- [ ] 首次加载成功 (控制台日志)
- [ ] 缓存机制生效 (第二次不重复请求)
- [ ] 多语言显示正确 (中英文切换)
- [ ] 选择保存正确 (id + 显示名称)
- [ ] 提交使用 enName (category 字段)
- [ ] 后备方案可用 (API 失败时)
- [ ] 无编译错误

## 🚀 一键测试命令

```powershell
# 1. 启动后端
cd e:\Workspaces\WaldenProjects\go-nomads\src\Services\EventService\EventService
dotnet run

# 2. 测试 API
curl http://localhost:8005/api/v1/event-types

# 3. 运行应用
cd e:\Workspaces\WaldenProjects\df_admin_mobile
flutter run
```

## 💡 最佳实践

1. ✅ 使用 `Get.put()` 初始化 Controller（确保单例）
2. ✅ 首次加载后自动缓存，避免重复请求
3. ✅ 根据语言环境动态显示名称
4. ✅ 提交时使用 `enName`（向后兼容）
5. ✅ API 失败时使用后备方案（用户体验）
6. ✅ 详细日志输出（便于调试）

## 📌 核心概念

- **DDD 架构**: Domain → Infrastructure → Presentation
- **GetX 状态管理**: 全局单例 + 响应式状态
- **智能缓存**: `_hasLoaded` 标志避免重复请求
- **多语言支持**: `getDisplayName(locale)` 动态切换
- **向后兼容**: 使用 `enName` 作为 `category`
- **容错设计**: API 失败时的后备方案

---

**提示**: 将此文件保存为 `EVENT_TYPE_QUICK_REFERENCE.md` 以便快速查阅！
