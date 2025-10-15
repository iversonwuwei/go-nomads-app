# SQLite 数据库使用指南

## 📋 概述

本项目已集成 SQLite 数据库支持,用于临时替代后端服务,实现本地数据存储功能。

## 🗄️ 数据库结构

### 核心表

1. **users** - 用户表
   - 存储用户基本信息、个人资料
   - 支持手机号登录认证

2. **cities** - 城市表
   - 存储城市信息、评分指标
   - 包含位置坐标、生活成本等数据

3. **coworking_spaces** - 共享办公空间表
   - 存储办公空间信息、价格
   - 关联城市表

4. **meetups** - 活动聚会表
   - 存储活动详情、时间地点
   - 关联组织者和城市

5. **meetup_participants** - 活动参与者表
   - 管理用户参与的活动
   - 多对多关联关系

6. **reviews** - 评论表
   - 通用评论系统
   - 支持对不同类型对象评论

7. **travel_plans** - 旅行计划表
   - 存储用户的旅行规划

8. **chat_messages** - 聊天消息表
   - 存储聊天室消息

9. **favorites** - 收藏表
   - 管理用户收藏的内容

## 🚀 快速开始

### 1. 安装依赖

已在 `pubspec.yaml` 中添加:

```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.3
  path_provider: ^2.1.1
```

运行:
```bash
flutter pub get
```

### 2. 初始化数据库

在 `main.dart` 中初始化数据库:

```dart
import 'package:df_admin_mobile/services/database_service.dart';
import 'package:df_admin_mobile/services/database_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化数据库
  final dbInitializer = DatabaseInitializer();
  await dbInitializer.initializeDatabase();
  
  runApp(MyApp());
}
```

### 3. 使用 DAO 访问数据

#### 用户操作示例

```dart
import 'package:df_admin_mobile/services/database/user_dao.dart';

// 创建 DAO 实例
final userDao = UserDao();

// 插入用户
await userDao.insertUser({
  'phone': '13800138000',
  'password': '123456',
  'nickname': '测试用户',
  'email': 'test@example.com',
});

// 登录验证
final user = await userDao.login('13800138000', '123456');
if (user != null) {
  print('登录成功: ${user['nickname']}');
}

// 查询用户
final userById = await userDao.getUserById(1);
final userByPhone = await userDao.getUserByPhone('13800138000');

// 更新用户
await userDao.updateUser(1, {
  'nickname': '新昵称',
  'bio': '更新后的个人简介',
});

// 获取所有用户
final allUsers = await userDao.getAllUsers();
```

#### 城市操作示例

```dart
import 'package:df_admin_mobile/services/database/city_dao.dart';

final cityDao = CityDao();

// 插入城市
await cityDao.insertCity({
  'name': 'Chiang Mai',
  'country': 'Thailand',
  'description': '清迈是泰国北部的文化中心',
  'cost_of_living': 800.0,
  'internet_speed': 50.0,
  'safety_score': 85.0,
});

// 查询城市
final city = await cityDao.getCityById(1);
final cities = await cityDao.getAllCities();

// 搜索城市
final searchResults = await cityDao.searchCities('mai');

// 按国家查询
final thaiCities = await cityDao.getCitiesByCountry('Thailand');
```

#### 活动操作示例

```dart
import 'package:df_admin_mobile/services/database/meetup_dao.dart';

final meetupDao = MeetupDao();

// 创建活动
await meetupDao.insertMeetup({
  'title': 'Coffee Chat',
  'description': '数字游民咖啡聊天',
  'organizer_id': 1,
  'city_id': 1,
  'location': 'Cafe Name',
  'start_time': DateTime.now().add(Duration(days: 1)).toIso8601String(),
  'max_participants': 15,
  'status': 'upcoming',
});

// 用户加入活动
await meetupDao.joinMeetup(1, 1); // meetupId, userId

// 检查用户是否已加入
final hasJoined = await meetupDao.hasUserJoined(1, 1);

// 获取用户加入的活动
final joinedMeetups = await meetupDao.getUserJoinedMeetups(1);

// 获取活动参与者
final participants = await meetupDao.getMeetupParticipants(1);

// 用户退出活动
await meetupDao.leaveMeetup(1, 1);
```

#### 评论操作示例

```dart
import 'package:df_admin_mobile/services/database/review_dao.dart';

final reviewDao = ReviewDao();

// 添加评论
await reviewDao.insertReview({
  'user_id': 1,
  'target_type': 'city', // city, meetup, coworking
  'target_id': 1,
  'rating': 4.5,
  'content': '这是一个很棒的城市!',
});

// 获取评论列表
final reviews = await reviewDao.getReviewsByTarget('city', 1);

// 计算平均评分
final avgRating = await reviewDao.getAverageRating('city', 1);

// 获取评论数量
final count = await reviewDao.getReviewCount('city', 1);
```

#### 收藏操作示例

```dart
import 'package:df_admin_mobile/services/database/favorite_dao.dart';

final favoriteDao = FavoriteDao();

// 添加收藏
await favoriteDao.addFavorite(1, 'city', 1); // userId, targetType, targetId

// 取消收藏
await favoriteDao.removeFavorite(1, 'city', 1);

// 检查是否收藏
final isFavorited = await favoriteDao.isFavorited(1, 'city', 1);

// 获取收藏的城市列表
final favoriteCities = await favoriteDao.getFavoriteCities(1);

// 获取收藏的活动列表
final favoriteMeetups = await favoriteDao.getFavoriteMeetups(1);
```

#### 聊天操作示例

```dart
import 'package:df_admin_mobile/services/database/chat_dao.dart';

final chatDao = ChatDao();

// 发送消息
await chatDao.insertMessage({
  'room_id': 'meetup_1',
  'sender_id': 1,
  'sender_name': '用户名',
  'sender_avatar': 'avatar_url',
  'message': '大家好!',
  'message_type': 'text',
});

// 获取聊天室消息
final messages = await chatDao.getMessagesByRoom('meetup_1', limit: 50);

// 删除聊天室消息
await chatDao.deleteRoomMessages('meetup_1');
```

## 🛠️ 数据库管理

### 清空所有数据

```dart
final dbService = DatabaseService();
await dbService.clearAllData();
```

### 重置数据库(清空并重新初始化示例数据)

```dart
final dbInitializer = DatabaseInitializer();
await dbInitializer.resetDatabase();
```

### 删除数据库文件

```dart
final dbService = DatabaseService();
await dbService.deleteDatabase();
```

### 关闭数据库连接

```dart
final dbService = DatabaseService();
await dbService.close();
```

## 📊 示例数据

初始化时会自动插入以下示例数据:

- **3个示例用户**
  - 手机号: 13800138000, 13800138001, 13800138002
  - 密码: 123456

- **5个示例城市**
  - Chiang Mai (泰国)
  - Bali (印尼)
  - Lisbon (葡萄牙)
  - Bangkok (泰国)
  - Medellin (哥伦比亚)

- **3个示例共享办公空间**
  - Punspace (清迈)
  - Hubud (巴厘岛)
  - Second Home Lisboa (里斯本)

- **4个示例活动**
  - Digital Nomad Coffee Chat
  - Sunset Beach Yoga
  - Startup & Tech Networking
  - Weekend Hiking Adventure

## 🔑 关键特性

### 1. 单例模式
DatabaseService 使用单例模式,确保整个应用只有一个数据库实例。

### 2. 自动时间戳
所有表都自动记录 `created_at` 和 `updated_at` 时间戳。

### 3. 外键关联
表之间使用外键建立关联关系,支持级联删除。

### 4. 索引优化
关键字段添加索引,提高查询性能。

### 5. 事务支持
支持数据库事务,确保数据一致性。

## 📱 在控制器中使用

### GetX 控制器示例

```dart
import 'package:get/get.dart';
import 'package:df_admin_mobile/services/database/city_dao.dart';

class CityController extends GetxController {
  final CityDao _cityDao = CityDao();
  
  var cities = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCities();
  }

  Future<void> loadCities() async {
    try {
      isLoading.value = true;
      cities.value = await _cityDao.getAllCities();
    } catch (e) {
      print('Error loading cities: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchCities(String keyword) async {
    try {
      isLoading.value = true;
      cities.value = await _cityDao.searchCities(keyword);
    } catch (e) {
      print('Error searching cities: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
```

## 🔄 数据迁移

当需要升级数据库结构时,修改 `DatabaseService` 中的 `_onUpgrade` 方法:

```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // 添加新列
    await db.execute('ALTER TABLE users ADD COLUMN last_login TEXT');
  }
  
  if (oldVersion < 3) {
    // 创建新表
    await db.execute('''
      CREATE TABLE new_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');
  }
}
```

## ⚠️ 注意事项

1. **数据持久化**: SQLite 数据存储在本地设备,卸载应用会删除数据
2. **线程安全**: sqflite 已处理线程安全问题
3. **性能优化**: 对于大量数据操作,使用事务批处理
4. **错误处理**: 建议在所有数据库操作中添加 try-catch
5. **数据同步**: 这是本地存储方案,后续需要与后端 API 同步

## 🎯 下一步

1. 在各个页面的 Controller 中集成数据库操作
2. 替换现有的模拟数据为数据库查询
3. 实现数据的增删改查功能
4. 添加数据验证和错误处理
5. 考虑添加数据加密(敏感信息)
6. 实现离线优先的同步策略

## 📚 参考资料

- [sqflite 官方文档](https://pub.dev/packages/sqflite)
- [SQLite 语法参考](https://www.sqlite.org/lang.html)
- [Flutter 数据持久化](https://flutter.dev/docs/cookbook/persistence/sqlite)

---

**提示**: 这是一个临时的本地存储解决方案。在生产环境中,建议与后端 API 结合使用,实现完整的数据同步机制。
