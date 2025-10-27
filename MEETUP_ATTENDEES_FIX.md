# Meetup 参与者显示修复

## 修复的问题

### 1. 参与者数量显示不正确 ❌ → ✅
**问题**: `currentAttendees` 字段映射错误,导致显示不正确的数字或负数

**原因**:
- 后端API可能返回不同的字段名: `currentParticipants`, `participantsCount`, `attendeesCount`
- 代码只检查了 `currentParticipants`,导致其他字段被忽略
- 没有对参与者数量进行边界检查,可能出现负数或超过最大值的情况

**修复**:
```dart
// 修复前
currentAttendees: event['currentParticipants'] as int? ?? 0,

// 修复后
// 获取当前参与者数量 - 支持多个可能的字段名
final currentParticipants = (event['currentParticipants'] as int?) ??
    (event['participantsCount'] as int?) ??
    (event['attendeesCount'] as int?) ??
    0;

// 确保参与者数量不为负数
final maxParticipants = event['maxParticipants'] as int? ?? 20;
final validCurrentParticipants = currentParticipants.clamp(0, maxParticipants);
```

### 2. 缺少剩余名额(Left Spots)显示 ❌ → ✅
**问题**: 列表页面没有显示剩余名额,用户无法快速看到还有多少位置

**修复**:
```dart
// 修复前
'${meetup.currentAttendees}/${meetup.maxAttendees} ${AppLocalizations.of(context)!.attendees}'

// 修复后
'${meetup.currentAttendees}/${meetup.maxAttendees} attendees • ${meetup.remainingSlots} spots left'
```

### 3. 视觉提示优化 🎨
**改进**: 根据剩余名额显示不同颜色提示
```dart
meetup.isFull 
    ? Colors.orange              // 已满 - 橙色警告
    : (meetup.remainingSlots <= 3 
        ? Colors.red             // 名额紧张 (≤3) - 红色提醒
        : null)                  // 充足 - 默认颜色
```

## 修改的文件

### `lib/pages/meetups_list_page.dart`
1. **第178-195行**: 修复 `_convertApiEventToMeetupModel` 方法
   - 支持多个参与者数量字段名
   - 添加边界检查防止负数
   - 使用 `clamp()` 确保值在有效范围内

2. **第575-583行**: 改进参与人数显示
   - 添加 "spots left" 信息
   - 根据剩余名额显示不同颜色
   - 使用更紧凑的格式: `10/20 attendees • 10 spots left`

## 测试验证

### 测试场景
1. ✅ **正常情况**: 5/20 participants → 显示 "5/20 attendees • 15 spots left"
2. ✅ **名额紧张**: 17/20 participants → 显示红色 "17/20 attendees • 3 spots left"
3. ✅ **已满**: 20/20 participants → 显示橙色 "20/20 attendees • 0 spots left"
4. ✅ **无参与者**: 0/20 participants → 显示 "0/20 attendees • 20 spots left"
5. ✅ **防止负数**: 后端返回 -5 → 自动修正为 0
6. ✅ **防止超限**: 后端返回 25(max 20) → 自动修正为 20

### API 字段兼容性
支持以下字段名获取参与者数量:
- ✅ `currentParticipants`
- ✅ `participantsCount`
- ✅ `attendeesCount`

## MeetupModel 计算属性

模型中已有的辅助属性(无需修改):
```dart
// 计算剩余名额
int get remainingSlots => maxAttendees - currentAttendees;

// 是否已满
bool get isFull => currentAttendees >= maxAttendees;
```

## 详情页状态

`meetup_detail_page.dart` **无需修改**:
- ✅ 已正确显示参与者数量和剩余名额
- ✅ 使用国际化文本 `l10n.spotsLeft('${_meetup.value.remainingSlots}')`
- ✅ 区分已满和有空位状态

## 后续优化建议

1. **实时更新**: 考虑添加 WebSocket 监听参与者变化
2. **动画效果**: 参与者数量变化时添加过渡动画
3. **百分比显示**: 可选显示参与率 (如: "75% full")
4. **等候名单**: 满员后提供等候名单功能
