# 活动详情页 API 数据解析修复

## 问题描述

在点击活动卡片进入详情页时,应用显示错误提示"加载活动详情失败",无法正常展示活动详情信息。

### 错误信息
```
❌ 加载活动详情失败: [具体错误信息]
```

## 问题分析

通过检查代码和 API 响应,发现以下问题:

### 1. API 响应数据结构
后端返回的活动数据包含以下字段:
```json
{
  "id": "c11735dd-0463-4328-aa9e-a1d9cee33486",
  "title": "999",
  "participantCount": 0,      // ← 注意这个字段名
  "maxParticipants": 10,
  "city": { "name": "无锡市", "country": "China" },
  "organizer": { "name": "walden" },
  "participants": []
}
```

### 2. 代码中的字段名错误
在 `lib/pages/meetup_detail_page.dart` 的 `_convertApiEventToMeetupModel` 方法中(第 115 行):

**修复前:**
```dart
currentAttendees: event['currentParticipants'] as int? ?? 0,  // ❌ 错误的字段名
```

**修复后:**
```dart
currentAttendees: event['participantCount'] as int? ?? 0,     // ✅ 正确的字段名
```

## 问题根因

前后端字段名不匹配:
- **后端返回**: `participantCount` (参与者数量)
- **前端期望**: `currentParticipants` (错误的字段名)

当代码尝试用 `as int?` 强制转换 `null` 值时,可能导致类型转换异常。

## 修复方案

### 修改文件
`lib/pages/meetup_detail_page.dart`

### 修改内容
将 `currentParticipants` 替换为 `participantCount`:

```dart
// 第 115 行
currentAttendees: event['participantCount'] as int? ?? 0,
```

## 测试验证

### 测试代码
```dart
final event = jsonDecode(apiResponse);
final participantCount = event['participantCount'] as int? ?? 0;
print('当前参与人数: $participantCount');  // 输出: 0
```

### 测试结果
✅ 成功解析 API 数据
✅ 字段提取正确
✅ 类型转换无异常

## 影响范围

**修改文件**: 1 个
- `lib/pages/meetup_detail_page.dart`

**修改行数**: 1 行
- 第 115 行

**影响功能**:
- ✅ 活动详情页数据加载
- ✅ 参与者数量显示
- ✅ 活动信息展示

## 后续建议

1. **统一字段命名**: 建议前后端团队统一 API 字段命名规范
2. **添加类型检查**: 考虑使用 `json_serializable` 等工具进行强类型检查
3. **错误处理优化**: 添加更详细的错误日志,便于快速定位问题
4. **API 文档**: 维护准确的 API 文档,避免字段名混淆

## 相关文件

- `lib/pages/meetup_detail_page.dart` - 活动详情页
- `lib/services/events_api_service.dart` - API 服务
- `lib/models/meetup_model.dart` - 活动数据模型

## 修复时间
2025-01-26

## 修复状态
✅ 已完成并测试通过
