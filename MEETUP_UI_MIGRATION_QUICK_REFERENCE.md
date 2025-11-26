# Meetup UI 迁移快速参考

## 🚀 快速开始

### 基本迁移模式

#### 1. 导入更新
```dart
// 旧导入
import '../controllers/data_service_controller.dart';
import '../models/meetup_model.dart';

// 新导入
import '../features/meetup/presentation/controllers/meetup_state_controller.dart';
import '../features/meetup/domain/entities/meetup.dart';
```

#### 2. Controller 获取
```dart
// 旧方式 - 单个 controller
final controller = Get.find<DataServiceController>();
final meetups = controller.upcomingMeetups;

// 新方式 - 分离职责
final dataController = Get.find<DataServiceController>();
final meetupController = Get.find<MeetupStateController>();
final meetups = meetupController.upcomingMeetups;
```

#### 3. 类型声明
```dart
// 旧: Map-based
final Map<String, dynamic> meetup;
final List<Map<String, dynamic>> meetups;

// 新: Entity-based
final Meetup meetup;
final List<Meetup> meetups;
```

---

## 📋 属性访问速查表

### Meetup 基本属性
| 旧 Map 访问 | 新实体访问 | 类型 |
|------------|-----------|------|
| `meetup['id']` | `meetup.id` | String |
| `meetup['title']` | `meetup.title` | String |
| `meetup['description']` | `meetup.description` | String |
| `meetup['type']` | `meetup.type.value` | String |
| `meetup['images']` | `meetup.images` | List\<String\> |

### Schedule (日程)
| 旧访问 | 新访问 | 说明 |
|-------|-------|------|
| `meetup['date']` | `meetup.schedule.startTime` | DateTime |
| `meetup['time']` | `meetup.schedule.startTime` | 提取时分: `.hour`, `.minute` |
| N/A | `meetup.schedule.endTime` | DateTime? (可选) |

### Location (位置)
| 旧访问 | 新访问 |
|-------|-------|
| `meetup['city']` | `meetup.location.city` |
| `meetup['country']` | `meetup.location.country` |
| `meetup['cityId']` | `meetup.location.cityId` |

### Venue (场地)
| 旧访问 | 新访问 |
|-------|-------|
| `meetup['venue']` | `meetup.venue.name` |
| N/A | `meetup.venue.address` |

### Capacity (容量)
| 旧访问 | 新访问 |
|-------|-------|
| `meetup['attendees']` | `meetup.capacity.currentAttendees` |
| `meetup['maxAttendees']` | `meetup.capacity.maxAttendees` |
| N/A | `meetup.capacity.remainingSlots` |
| N/A | `meetup.capacity.isFull` |

### Organizer (组织者)
| 旧访问 | 新访问 |
|-------|-------|
| `meetup['organizer']` | `meetup.organizer.name` |
| `meetup['organizerId']` | `meetup.organizer.id` |
| `meetup['organizerAvatar']` | `meetup.organizer.avatarUrl` |

### 参与状态
| 旧访问 | 新访问 | 说明 |
|-------|-------|------|
| `meetup['isParticipant']` | `meetup.attendeeIds.contains(userId)` | 检查用户是否参与 |
| `controller.rsvpedMeetups.contains(id)` | 同左 | 本地状态(暂时保留) |

---

## 🔄 API 调用转换

### 创建 Meetup
```dart
// ❌ 旧方式
await controller.createMeetup(
  title: 'Tech Meetup',
  type: 'networking',
  city: 'Bangkok',
  country: 'Thailand',
  date: DateTime(2024, 1, 15),
  time: '18:00',
  venue: 'Coffee Shop',
  // ...
);

// ✅ 新方式
final startDateTime = DateTime(2024, 1, 15, 18, 0); // 合并日期和时间
final meetupType = MeetupType.fromString('networking'); // 转换为值对象

await meetupController.createMeetup(
  title: 'Tech Meetup',
  type: meetupType,
  cityId: 'bangkok-thailand',
  venue: 'Coffee Shop',
  venueAddress: '123 Main St',
  startTime: startDateTime,
  // ...
);
```

### 获取 Meetup 列表
```dart
// ❌ 旧方式
final List<Map<String, dynamic>> meetups = controller.upcomingMeetups;

// ✅ 新方式
final List<Meetup> meetups = meetupController.upcomingMeetups;
```

---

## 🎨 Widget 迁移模式

### StatelessWidget 示例
```dart
class MyMeetupWidget extends StatelessWidget {
  // ❌ 旧
  // final Map<String, dynamic> meetup;
  
  // ✅ 新
  final Meetup meetup;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ❌ Text(meetup['title']),
        // ✅
        Text(meetup.title),
        
        // ❌ Text('${meetup['attendees']}/${meetup['maxAttendees']}'),
        // ✅
        Text('${meetup.capacity.currentAttendees}/${meetup.capacity.maxAttendees}'),
        
        // ❌ Text(meetup['city']),
        // ✅
        Text(meetup.location.city),
      ],
    );
  }
}
```

### StatefulWidget 示例
```dart
class _MeetupCardState extends State<MeetupCard> {
  late bool _isJoined;
  
  @override
  void initState() {
    super.initState();
    
    // ❌ 旧方式 - 从 Map 获取
    // _isJoined = widget.meetup['isParticipant'] ?? false;
    
    // ✅ 新方式 - 从 controller 或 attendeeIds 获取
    final meetupIdInt = int.tryParse(widget.meetup.id) ?? 0;
    _isJoined = widget.controller.rsvpedMeetups.contains(meetupIdInt);
  }
  
  // Getter 示例
  int get _currentAttendees {
    // ❌ return widget.meetup['attendees'] as int;
    // ✅
    return widget.meetup.capacity.currentAttendees;
  }
}
```

---

## 🕒 日期时间格式化

### 显示日期
```dart
// ❌ 旧方式
final date = meetup['date'] as DateTime;
final dateStr = '${date.month}/${date.day}/${date.year}';

// ✅ 新方式
final startTime = meetup.schedule.startTime;
final dateStr = DateFormat('MMM dd, yyyy').format(startTime);
```

### 显示时间
```dart
// ❌ 旧方式
final timeStr = meetup['time'] as String; // "18:00"

// ✅ 新方式
final startTime = meetup.schedule.startTime;
final timeStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
// 或使用 DateFormat
final timeStr = DateFormat.Hm().format(startTime);
```

### 合并日期和时间
```dart
// 创建 Meetup 时需要合并
final DateTime _selectedDate;
final TimeOfDay _selectedTime;

// ✅ 合并为 startTime
final startDateTime = DateTime(
  _selectedDate.year,
  _selectedDate.month,
  _selectedDate.day,
  _selectedTime.hour,
  _selectedTime.minute,
);
```

---

## 🎯 MeetupType 转换

### 创建 MeetupType
```dart
// ❌ 旧方式 - 字符串
String type = 'networking';

// ✅ 新方式 - 值对象
MeetupType type = MeetupType.fromString('networking');

// 常用类型
MeetupType.networking  // 'networking'
MeetupType.workshop    // 'workshop'
MeetupType.social      // 'social'
MeetupType.coworking   // 'coworking'
MeetupType.sports      // 'sports'
MeetupType.culture     // 'culture'
MeetupType.other       // 'other'
```

### 获取类型字符串
```dart
// ✅ 使用 .value
String typeStr = meetup.type.value;  // "networking"
String typeStr = meetup.type.toString();  // 同上
```

---

## 🧭 导航参数转换

### 跳转到 City Chat
```dart
Get.toNamed(
  AppRoutes.cityChat,
  arguments: {
    // ❌ 'city': meetup['city'],
    // ❌ 'country': meetup['country'],
    // ❌ 'meetupId': meetup['id'],
    // ❌ 'meetupTitle': meetup['title'],
    
    // ✅
    'city': meetup.location.city,
    'country': meetup.location.country,
    'meetupId': meetup.id,
    'meetupTitle': meetup.title,
  },
);
```

### 跳转到 Meetup Detail
```dart
// ⚠️ 当前 MeetupDetailPage 尚未迁移
// 临时禁用:
onTap: () {
  AppToast.info('Meetup detail page is under migration');
}

// 🚧 迁移完成后:
// Get.to(() => MeetupDetailPage(meetup: meetup));
```

---

## ⚠️ 常见陷阱

### 1. Map 操作符不可用
```dart
// ❌ 错误
widget.meetup['city'] = 'New City';  // Meetup 实体不可变!

// ✅ 正确 - 创建新实体(如果需要)
// 通常应该通过 MeetupStateController 的方法更新
```

### 2. 嵌套属性访问
```dart
// ❌ 忘记嵌套结构
int attendees = meetup.currentAttendees;  // ❌ 属性不存在

// ✅ 正确的嵌套访问
int attendees = meetup.capacity.currentAttendees;
```

### 3. 可选值处理
```dart
// ⚠️ endTime 是可选的
final endTime = meetup.schedule.endTime;  // DateTime?

// ✅ 安全访问
if (meetup.schedule.endTime != null) {
  final endTime = meetup.schedule.endTime!;
  // 使用 endTime
}
```

### 4. Type 转换
```dart
// ❌ 直接使用字符串
final color = _getTypeColor(meetup.type);  // 错误!

// ✅ 获取字符串值
final color = _getTypeColor(meetup.type.value);
```

---

## 🔧 常用代码片段

### 检查 Meetup 是否满员
```dart
if (meetup.capacity.isFull) {
  // 显示满员提示
}

// 或
if (meetup.capacity.remainingSlots == 0) {
  // 同上
}
```

### 检查用户是否可以加入
```dart
final currentUserId = userController.currentUser.value?.id ?? '';
if (meetup.canJoin(currentUserId)) {
  // 显示 Join 按钮
}
```

### 显示剩余名额
```dart
final remaining = meetup.capacity.maxAttendees - meetup.capacity.currentAttendees;
// 或
final remaining = meetup.capacity.remainingSlots;

Text('$remaining spots left');
```

### 格式化完整的日期时间显示
```dart
final startTime = meetup.schedule.startTime;
final dateStr = DateFormat('MMM dd').format(startTime);  // "Jan 15"
final timeStr = DateFormat.Hm().format(startTime);       // "18:00"

Text('$dateStr at $timeStr');  // "Jan 15 at 18:00"
```

---

## 📚 相关文档

- 完整迁移文档: `MEETUP_UI_MIGRATION_COMPLETE.md`
- Meetup 实体定义: `lib/features/meetup/domain/entities/meetup.dart`
- MeetupStateController: `lib/features/meetup/presentation/controllers/meetup_state_controller.dart`

---

## 🆘 故障排查

### 编译错误: "The getter 'xxx' isn't defined for the type 'Meetup'"
**原因**: 直接访问了不存在的属性  
**解决**: 检查正确的嵌套结构(如 `capacity.currentAttendees` 而不是 `currentAttendees`)

### 编译错误: "The operator '[]' isn't defined for the type 'Meetup'"
**原因**: 仍在使用 Map 访问方式  
**解决**: 改为使用实体属性访问 (`meetup.property` 而不是 `meetup['property']`)

### 运行时错误: "Null check operator used on a null value"
**原因**: 访问可选属性未检查 null  
**解决**: 检查 `endTime`, `avatarUrl` 等可选属性是否为 null

---

**提示**: 使用 IDE 的自动补全功能探索 Meetup 实体的可用属性!
