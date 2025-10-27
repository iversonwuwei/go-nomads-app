# Meetup 参与者数量显示问题调试指南

## 问题描述
Meetup list 页面中的参与者和剩余席位显示的数量不对。

## 已修复的问题

### 1. 字段名映射问题
**问题**: `meetups_list_page.dart` 和 `meetup_detail_page.dart` 使用了不同的字段名

**修复前**:
```dart
// meetups_list_page.dart - 没有检查 participantCount
final currentParticipants = (event['currentParticipants'] as int?) ??
    (event['participantsCount'] as int?) ??
    (event['attendeesCount'] as int?) ??
    (event['participants'] as int?) ??
    0;
```

**修复后**:
```dart
// meetups_list_page.dart - 优先使用 participantCount，与 detail page 保持一致
final currentParticipants = (event['participantCount'] as int?) ??
    (event['currentParticipants'] as int?) ??
    (event['participantsCount'] as int?) ??
    (event['attendeesCount'] as int?) ??
    (event['participants'] as int?) ??
    0;
```

## 调试步骤

### 步骤 1: 查看控制台日志
运行 App 后，在加载 Meetup 列表时，控制台会输出每个活动的字段信息：

```
🔍 Event 123 - isParticipant: true
  participantCount: 5          <-- 后端实际返回的字段
  currentParticipants: null
  participantsCount: null
  attendeesCount: null
  participants: null
  maxParticipants: 20
  ✅ 最终使用: currentAttendees=5, maxAttendees=20
```

**检查点**:
- 确认哪个字段有值（应该是 `participantCount`）
- 确认 `maxParticipants` 的值是否正确
- 确认 `isParticipant` 是否正确反映用户的参与状态

### 步骤 2: 检查数据转换
在 `_MeetupListCardState.initState()` 中，会打印初始状态：

```
🔍 MeetupListCard initState:
   ID: 123
   Title: Coffee Meetup
   isJoined: true
   Attendees: 5 / 20
```

**检查点**:
- 确认 `currentAttendees` 和 `maxAttendees` 是否正确
- 确认 `isJoined` 状态是否正确

### 步骤 3: 测试加入/退出功能
点击 "Going" 或 "Joined" 按钮，观察控制台输出：

```
✅ 成功加入活动: Coffee Meetup
🔄 Meetup Coffee Meetup 数据更新:
   isJoined: false -> true
   Attendees: 5 -> 6
```

**检查点**:
- 确认 API 调用成功
- 确认本地状态更新正确
- 确认 UI 立即刷新

## 常见问题排查

### 问题 1: 参与人数始终为 0
**可能原因**:
- 后端返回的字段名不是 `participantCount`
- HttpService 拦截器解包有问题

**解决方法**:
1. 查看控制台日志，确认哪个字段有值
2. 如果是新字段，添加到字段检查列表中

### 问题 2: 点击后参与人数不更新
**可能原因**:
- `didUpdateWidget` 没有触发
- 父级的 `_meetups` 列表没有更新

**解决方法**:
1. 检查 `onUpdated` 回调是否被调用
2. 检查父级是否调用了 `_meetups.refresh()`

### 问题 3: 剩余席位计算错误
**可能原因**:
- `_maxAttendees` 或 `_currentAttendees` 的值不正确
- getter `_remainingSlots` 计算错误

**解决方法**:
```dart
int get _remainingSlots => _maxAttendees - _currentAttendees;
```
确保这两个变量都是正确的整数值。

## 验证清单

- [ ] 控制台显示正确的 `participantCount` 值
- [ ] `_MeetupListCard` 初始化时状态正确
- [ ] 点击 "Going" 按钮后参与人数 +1
- [ ] 点击 "Joined" 按钮后参与人数 -1
- [ ] 剩余席位 = maxAttendees - currentAttendees
- [ ] UI 立即更新，无需刷新页面

## 相关文件

- `lib/pages/meetups_list_page.dart` - Meetup 列表页
- `lib/pages/meetup_detail_page.dart` - Meetup 详情页
- `lib/services/events_api_service.dart` - API 服务
- `lib/models/meetup_model.dart` - Meetup 数据模型

## 后端 API 字段对照表

| 后端字段 | 前端字段 | 说明 |
|----------|----------|------|
| `participantCount` | `currentAttendees` | ✅ 当前参与人数 |
| `maxParticipants` | `maxAttendees` | ✅ 最大参与人数 |
| `isParticipant` | `isJoined` | ✅ 用户是否已参与 |
| `category` | `type` | 活动类型 |
| `location` | `venue` | 活动地点 |
| `startTime` | `dateTime` | 活动时间 |

## 修复验证

修复后，重新运行 App 并执行以下测试：

1. **测试初始显示**
   - 打开 Meetup 列表页
   - 检查每个卡片的参与人数和剩余席位
   - 验证数字是否合理（如 5/20, 15 spots left）

2. **测试加入功能**
   - 点击未参与活动的 "Going" 按钮
   - 验证按钮变为 "Joined"
   - 验证参与人数 +1
   - 验证剩余席位 -1

3. **测试退出功能**
   - 点击已参与活动的 "Joined" 按钮
   - 验证按钮变为 "Going"
   - 验证参与人数 -1
   - 验证剩余席位 +1

4. **测试边界情况**
   - 活动满员时，验证显示 "Full"
   - 活动已结束时，验证显示 "Ended"

## 预期结果

修复后，Meetup 列表页应该：
- ✅ 正确显示参与人数（如 5/20）
- ✅ 正确显示剩余席位（如 15 spots left）
- ✅ 点击后立即更新 UI
- ✅ 数字始终准确，与后端同步

---

**修复日期**: 2025-01-27  
**修复文件**: `lib/pages/meetups_list_page.dart` (第 179-186 行)  
**关键修改**: 添加 `participantCount` 为首选字段，与 `meetup_detail_page.dart` 保持一致
