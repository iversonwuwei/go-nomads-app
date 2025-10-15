# Data Service Meetup 图片点击跳转功能说明

## 功能概述

在 Data Service 页面的 Meetups 列表中,点击 meetup 卡片的**图片区域**可以直接跳转到该 meetup 的详情页面。

---

## 实现要点

### 1. 添加的导入
```dart
import '../models/meetup_model.dart';
import 'meetup_detail_page.dart';
```

### 2. 图片区域修改

**修改前**: 纯展示的 Stack
```dart
Stack(
  children: [
    ClipRRect(...), // 图片
    Positioned(...), // 类型标签
  ],
)
```

**修改后**: 包裹 GestureDetector
```dart
GestureDetector(
  onTap: () {
    final meetupModel = _convertToMeetupModel(meetup);
    Get.to(() => MeetupDetailPage(meetup: meetupModel));
  },
  child: Stack(...),
)
```

### 3. 数据转换函数

新增 `_convertToMeetupModel()` 方法,将 Map 转换为 MeetupModel:

**关键转换**:
- `date` + `time` → `dateTime` (合并日期和时间)
- `attendees` → `currentAttendees` (字段重命名)
- `organizer` → `organizerName` (字段重命名)
- `image` → `images` (单个字符串转数组)
- `rsvpedMeetups.contains(id)` → `isJoined` (检查参与状态)

---

## 用户体验

### 点击行为

| 点击区域 | 跳转目标 |
|---------|---------|
| 图片区域 | Meetup 详情页 ✅ 新功能 |
| 卡片其他区域 | Meetups 列表页 (原有) |
| RSVP 按钮 | 切换参与状态 |
| Join Chat 按钮 | 群聊页面 |

### 详情页状态

- 如果用户已 RSVP → `isJoined = true` → Chat 按钮可点击
- 如果用户未 RSVP → `isJoined = false` → Chat 按钮禁用

---

## 数据映射

```dart
DataService Map          →  MeetupModel
────────────────────────────────────────
id                       →  id (toString)
title                    →  title
type                     →  type
description              →  description
city                     →  city
country                  →  country
venue                    →  venue + venueAddress
date + time              →  dateTime (合并)
maxAttendees             →  maxAttendees
attendees                →  currentAttendees
organizer                →  organizerName
organizerAvatar          →  organizerAvatar
image                    →  images (数组)
controller.rsvpedMeetups →  isJoined (检查)
```

---

## 修改文件

✅ `lib/pages/data_service_page.dart`
- 添加 2 个导入
- 图片区域包裹 GestureDetector
- 新增 `_convertToMeetupModel()` 方法

---

## 测试要点

- [ ] 点击图片跳转到详情页
- [ ] 详情信息显示正确
- [ ] 日期时间格式正确
- [ ] isJoined 状态与 RSVP 一致
- [ ] 返回后状态保持

---

## 总结

✅ 用户可以通过点击图片快速查看 meetup 详情  
✅ 自动转换数据格式,无需手动处理  
✅ 参与状态自动同步  
✅ 与 Chat 权限控制功能联动
