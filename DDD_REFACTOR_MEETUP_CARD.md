# DDD 重构：Meetup 卡片状态管理

## 问题背景

### 原始问题
在 `data_service_page.dart` 的 meetup 列表中：
- 点击 RSVP 按钮没有反应
- 按钮逻辑颠倒（未加入显示 RSVP，已加入显示 Going）
- 参与人数和剩余名额不实时更新

### 发现的架构问题
在修复过程中发现了严重的 **DDD (Domain-Driven Design) 违规**：

**问题表现**：
- 点击一个卡片的 Going 按钮，所有卡片的按钮都会更新
- 参与人数在所有卡片上同步变化
- 跨卡片状态污染

**根本原因**：
```dart
// ❌ 错误的设计 - 全局共享状态
Obx(() {
  final currentMeetup = widget.controller.meetups.firstWhere(...);
  final attendees = currentMeetup['attendees'];
  // 所有卡片都监听同一个 controller.meetups
})
```

**违反的 DDD 原则**：
1. **单一职责原则 (SRP)**：控制器管理全局状态，卡片只是视图
2. **有界上下文 (Bounded Context)**：每个卡片应该是独立的域模型
3. **聚合根 (Aggregate Root)**：卡片不应该直接访问全局聚合

---

## DDD 重构方案

### 设计原则

每个 `_MeetupCard` 应该：
1. **拥有自己的状态** - 不依赖全局可变状态
2. **独立的生命周期** - `initState()` 初始化，`setState()` 更新
3. **明确的边界** - 只管理自己的数据，不影响其他卡片

### 重构后的架构

```
┌─────────────────────────────────────┐
│  DataServiceController (Global)     │
│  ├─ rsvpedMeetups: RxList<int>     │ ← 只用于初始状态读取
│  └─ toggleRSVP(id) - 维护全局列表   │
└─────────────────────────────────────┘
                 ↓ (初始化时读取)
┌─────────────────────────────────────┐
│  _MeetupCard (Bounded Context)      │
│  ├─ _isJoined: bool                 │ ← 本地状态
│  ├─ _currentAttendees: int          │ ← 本地状态
│  ├─ _maxAttendees: int              │ ← 本地状态
│  └─ setState() - 本地更新           │
└─────────────────────────────────────┘
```

---

## 实现细节

### 1. 添加本地状态变量

```dart
class _MeetupCardState extends State<_MeetupCard> {
  // 卡片自己的状态 - 符合 DDD 原则
  late bool _isJoined;
  late int _currentAttendees;
  late int _maxAttendees;
  
  @override
  void initState() {
    super.initState();
    // 初始化卡片自己的状态
    _currentAttendees = widget.meetup['attendees'] as int;
    _maxAttendees = widget.meetup['maxAttendees'] as int;
    
    // 从 controller 获取初始的 joined 状态
    final meetupId = widget.meetup['id'];
    final int meetupIdInt;
    if (meetupId is int) {
      meetupIdInt = meetupId;
    } else if (meetupId is String) {
      meetupIdInt = int.tryParse(meetupId) ?? 0;
    } else {
      meetupIdInt = 0;
    }
    _isJoined = widget.controller.rsvpedMeetups.contains(meetupIdInt);
  }
}
```

### 2. 更新本地状态（而非全局）

```dart
Future<void> _handleToggleJoin(BuildContext context) async {
  // ... 登录检查和 ID 转换 ...
  
  // ✅ 调用全局方法维护 rsvpedMeetups 列表
  widget.controller.toggleRSVP(meetupIdInt);
  
  // ✅ 更新卡片自己的状态
  setState(() {
    if (_isJoined) {
      _isJoined = false;
      _currentAttendees--;
    } else {
      _isJoined = true;
      _currentAttendees++;
    }
  });
  
  // 显示成功消息
  if (_isJoined) {
    AppToast.success(l10n.joinedSuccessfully);
  } else {
    AppToast.info(l10n.youLeftMeetup);
  }
}
```

### 3. 移除 Obx 包装器

**之前（错误）**：
```dart
Obx(() {
  final currentMeetup = widget.controller.meetups.firstWhere(...);
  final attendees = currentMeetup['attendees'];
  return Text('$attendees going');
})
```

**之后（正确）**：
```dart
// 直接使用本地状态
Text('$_currentAttendees going')
```

### 4. 参与者信息显示

```dart
Row(
  children: [
    // ... 头像堆叠 ...
    Text(
      '$_currentAttendees going',  // ✅ 本地状态
      style: TextStyle(...),
    ),
    const Spacer(),
    if ((_maxAttendees - _currentAttendees) > 0)
      Text(
        '${_maxAttendees - _currentAttendees} spots left',  // ✅ 本地状态
        style: TextStyle(...),
      ),
  ],
)
```

### 5. 按钮逻辑（条件渲染）

```dart
// ✅ 直接使用本地状态，不用 Obx
if (_isJoined)
  Row(
    children: [
      // RSVP'd 按钮
      Expanded(
        child: ElevatedButton(
          onPressed: () => _handleToggleJoin(context),
          child: Text('RSVP\'d'),
        ),
      ),
      // Chat 按钮
      Expanded(
        child: ElevatedButton(
          onPressed: () { /* 跳转聊天 */ },
          child: Text('Chat'),
        ),
      ),
    ],
  )
else
  // Going 按钮
  SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () => _handleToggleJoin(context),
      child: Text('Going'),
    ),
  ),
```

---

## 重构效果对比

### 之前（全局状态 - 错误）

| 问题 | 表现 |
|------|------|
| 跨卡片污染 | 点击卡片 A，卡片 B、C、D 都更新 |
| 性能问题 | 所有卡片重新渲染（使用 `Obx`） |
| 状态不准确 | `firstWhere()` 可能匹配错误 |
| 违反 DDD | 卡片无边界，共享可变状态 |

### 之后（本地状态 - 正确）

| 优势 | 效果 |
|------|------|
| 独立性 | 每个卡片独立管理状态 |
| 性能优化 | 只有被点击的卡片重新渲染 |
| 状态准确 | 状态由卡片自己维护 |
| 符合 DDD | 每个卡片是独立的有界上下文 |

---

## DDD 原则验证

### ✅ 单一职责原则 (SRP)
- `DataServiceController`：管理全局 RSVP 列表
- `_MeetupCard`：管理单个卡片的视图和交互
- `_MeetupCardState`：管理单个卡片的状态

### ✅ 有界上下文 (Bounded Context)
每个卡片是一个独立的域：
```
Meetup Card Domain
├─ State: _isJoined, _currentAttendees
├─ Behavior: _handleToggleJoin()
└─ Boundary: 不影响其他卡片
```

### ✅ 聚合根 (Aggregate Root)
- 卡片状态的聚合根是 `_MeetupCardState`
- 只通过 `setState()` 修改状态
- 不直接操作外部聚合（`controller.meetups`）

### ✅ 依赖倒置原则 (DIP)
```dart
// 卡片依赖抽象（初始数据），不依赖具体实现
_isJoined = widget.controller.rsvpedMeetups.contains(meetupIdInt);  // 初始化
// 后续更新由自己管理
setState(() { _isJoined = !_isJoined; });
```

---

## 技术要点

### 类型安全处理
```dart
// 处理 API 返回的 String ID 和数据库的 int ID
final meetupId = widget.meetup['id'];
final int meetupIdInt;
if (meetupId is int) {
  meetupIdInt = meetupId;
} else if (meetupId is String) {
  meetupIdInt = int.tryParse(meetupId) ?? 0;
} else {
  print('❌ 无效的 meetup id 类型: ${meetupId.runtimeType}');
  return;
}
```

### 登录状态检查
```dart
if (!userStateController.isLoggedIn) {
  AppToast.warning(l10n.pleaseLoginToCreateMeetup);
  Get.toNamed(AppRoutes.login);
  return;
}
```

### Toast 反馈
```dart
if (_isJoined) {
  AppToast.success(l10n.joinedSuccessfully, title: l10n.joined);
} else {
  AppToast.info(l10n.youLeftMeetup, title: l10n.leftMeetup);
}
```

---

## 测试验证

### 测试场景

1. **独立性测试**
   - ✅ 点击卡片 A 的 Going，只有卡片 A 更新
   - ✅ 卡片 B、C、D 状态不变

2. **参与人数更新**
   - ✅ 点击 Going：`_currentAttendees++`
   - ✅ 点击 RSVP'd：`_currentAttendees--`

3. **按钮状态切换**
   - ✅ 未加入 → 显示 "Going" 按钮
   - ✅ 已加入 → 显示 "RSVP'd" + "Chat" 按钮

4. **剩余名额计算**
   - ✅ 实时更新：`${_maxAttendees - _currentAttendees} spots left`

---

## 性能优化

### 渲染优化
**之前**：
```dart
Obx(() { /* 所有卡片监听同一个 observable */ })
// 性能：O(n) - n 为卡片数量
```

**之后**：
```dart
setState(() { /* 只更新当前卡片 */ })
// 性能：O(1) - 常数时间
```

### 内存优化
- 不再需要在 `Obx` 中执行 `firstWhere()` 查找
- 减少不必要的 Widget 重建
- 每个卡片只维护 3 个简单状态变量

---

## 文件修改

### 修改的文件
- `lib/pages/data_service_page.dart`

### 修改位置
- `_MeetupCardState` 类（约 2185-2640 行）

### 关键变更
1. ✅ 添加本地状态变量：`_isJoined`, `_currentAttendees`, `_maxAttendees`
2. ✅ 在 `initState()` 中初始化状态
3. ✅ 移除 `Obx` 包装器（参与者信息）
4. ✅ 移除 `Obx` 包装器（按钮逻辑）
5. ✅ 使用 `setState()` 更新本地状态
6. ✅ 保留登录检查和类型转换逻辑

---

## 总结

### 重构成果
1. **符合 DDD 原则** - 每个卡片是独立的有界上下文
2. **性能提升** - 减少不必要的重新渲染
3. **代码清晰** - 状态管理逻辑更简单
4. **可测试性** - 每个卡片可独立测试

### 架构改进
- **从**：全局共享可变状态（Obx 监听）
- **到**：本地独立状态（setState 更新）

### DDD 合规性
- ✅ 单一职责原则
- ✅ 有界上下文
- ✅ 聚合根模式
- ✅ 依赖倒置

---

## 参考资料

- **DDD (Domain-Driven Design)**：Eric Evans
- **Flutter State Management**：StatefulWidget + setState
- **GetX Best Practices**：局部响应式 vs 全局响应式
- **Clean Architecture**：Robert C. Martin

---

**重构日期**：2024
**问题发现者**：用户（准确识别 DDD 违规）
**重构实施者**：AI Assistant
**验证状态**：✅ 编译通过，无错误
