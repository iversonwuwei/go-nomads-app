# SQLite 数据服务集成指南

## 📋 概述

本项目已将所有静态数据迁移到 SQLite 数据库,并通过统一的数据服务层进行访问和管理。

## 🗂️ 数据服务架构

### 服务层文件结构

```
lib/services/
├── database/              # DAO 层(数据访问对象)
│   ├── city_dao.dart
│   ├── meetup_dao.dart
│   ├── coworking_dao.dart
│   ├── review_dao.dart
│   ├── favorite_dao.dart
│   ├── chat_dao.dart
│   └── user_dao.dart
├── data/                  # 数据服务层
│   ├── city_data_service.dart
│   ├── meetup_data_service.dart
│   ├── coworking_data_service.dart
│   ├── review_data_service.dart
│   └── favorite_data_service.dart
├── database_service.dart  # 核心数据库服务
└── database_initializer.dart  # 数据库初始化
```

## 🎯 数据服务使用方法

### 1. 城市数据服务 (CityDataService)

```dart
import 'package:df_admin_mobile/services/data/city_data_service.dart';

class MyCityController extends GetxController {
  final CityDataService _cityService = CityDataService();

  // 获取所有城市
  Future<void> loadCities() async {
    final cities = await _cityService.getAllCities();
    print('Loaded ${cities.length} cities');
  }

  // 搜索城市
  Future<void> searchCity(String keyword) async {
    final results = await _cityService.searchCities(keyword);
  }

  // 筛选城市
  Future<void> filterCities() async {
    final filtered = await _cityService.filterCities(
      regions: ['Asia', 'Europe'],
      minPrice: 1000,
      maxPrice: 3000,
      minInternet: 20,
      minRating: 4.0,
    );
  }

  // 添加新城市
  Future<void> addCity(Map<String, dynamic> cityData) async {
    final id = await _cityService.addCity({
      'name': 'New City',
      'country': 'Country',
      'region': 'Asia',
      'cost_of_living': 1500.0,
      'internet_speed': 30.0,
      'safety_score': 4.5,
      'overall_score': 4.2,
      // ... 其他字段
    });
    print('City added with ID: $id');
  }
}
```

### 2. 活动数据服务 (MeetupDataService)

```dart
import 'package:df_admin_mobile/services/data/meetup_data_service.dart';

class MyMeetupController extends GetxController {
  final MeetupDataService _meetupService = MeetupDataService();

  // 获取即将到来的活动
  Future<void> loadUpcomingMeetups() async {
    final meetups = await _meetupService.getUpcomingMeetups(days: 30);
  }

  // 创建新活动
  Future<void> createMeetup() async {
    final id = await _meetupService.createMeetup({
      'title': 'Digital Nomad Meetup',
      'description': 'Join us for coffee and networking',
      'organizer_id': 1,
      'city_id': 1,
      'location': 'Coffee Shop',
      'category': 'Coffee',
      'start_time': DateTime.now().add(Duration(days: 7)),
      'max_participants': 20,
      'status': 'upcoming',
    });
  }

  // 用户加入活动
  Future<void> joinMeetup(int meetupId, int userId) async {
    await _meetupService.joinMeetup(meetupId, userId);
  }

  // 检查用户是否已加入
  Future<bool> checkJoined(int meetupId, int userId) async {
    return await _meetupService.hasUserJoined(meetupId, userId);
  }

  // 筛选活动
  Future<void> filterMeetups() async {
    final filtered = await _meetupService.filterMeetups(
      cityId: 1,
      category: 'Coffee',
      status: 'upcoming',
    );
  }
}
```

### 3. 共享办公空间数据服务 (CoworkingDataService)

```dart
import 'package:df_admin_mobile/services/data/coworking_data_service.dart';

class MyCoworkingController extends GetxController {
  final CoworkingDataService _coworkingService = CoworkingDataService();

  // 获取某城市的所有共享办公空间
  Future<void> loadCoworkingsByCity(int cityId) async {
    final spaces = await _coworkingService.getCoworkingsByCity(cityId);
  }

  // 添加新的共享办公空间
  Future<void> addCoworking() async {
    final id = await _coworkingService.addCoworking({
      'name': 'Awesome Coworking',
      'city_id': 1,
      'address': '123 Main St',
      'price_per_day': 15.0,
      'price_per_month': 200.0,
      'amenities': 'WiFi, Coffee, Meeting Room',
      'rating': 4.5,
    });
  }

  // 筛选共享办公空间
  Future<void> filterSpaces() async {
    final filtered = await _coworkingService.filterCoworkings(
      cityId: 1,
      minPrice: 10,
      maxPrice: 30,
      amenities: ['WiFi', 'Coffee'],
    );
  }
}
```

### 4. 评论数据服务 (ReviewDataService)

```dart
import 'package:df_admin_mobile/services/data/review_data_service.dart';

class MyReviewController extends GetxController {
  final ReviewDataService _reviewService = ReviewDataService();

  // 获取某城市的所有评论
  Future<void> loadCityReviews(int cityId) async {
    final reviews = await _reviewService.getReviewsByTarget('city', cityId);
  }

  // 添加评论
  Future<void> addReview(int userId, int cityId) async {
    final id = await _reviewService.addReview({
      'user_id': userId,
      'target_type': 'city',
      'target_id': cityId,
      'rating': 4.5,
      'content': 'Great city for digital nomads!',
    });
  }

  // 获取平均评分
  Future<double> getCityRating(int cityId) async {
    return await _reviewService.getAverageRating('city', cityId);
  }

  // 检查用户是否已评论
  Future<bool> hasReviewed(int userId, int cityId) async {
    return await _reviewService.hasUserReviewed(userId, 'city', cityId);
  }
}
```

### 5. 收藏数据服务 (FavoriteDataService)

```dart
import 'package:df_admin_mobile/services/data/favorite_data_service.dart';

class MyFavoriteController extends GetxController {
  final FavoriteDataService _favoriteService = FavoriteDataService();

  // 切换收藏状态
  Future<bool> toggleFavorite(int userId, int cityId) async {
    return await _favoriteService.toggleFavorite(userId, 'city', cityId);
  }

  // 获取用户收藏的所有城市
  Future<void> loadFavoriteCities(int userId) async {
    final cities = await _favoriteService.getFavoriteCities(userId);
  }

  // 检查是否已收藏
  Future<bool> isFavorited(int userId, int cityId) async {
    return await _favoriteService.isFavorited(userId, 'city', cityId);
  }

  // 获取收藏数量
  Future<int> getFavoriteCount(int userId) async {
    return await _favoriteService.getTotalFavoriteCount(userId);
  }
}
```

## 📝 数据迁移说明

### 已迁移到数据库的数据

1. **城市数据**
   - ✅ 从 `DataServiceController._generateMockData()` 迁移到数据库
   - ✅ 包含8个示例城市(Bangkok, Chiang Mai, Canggu, Tokyo, Seoul, Lisbon, Mexico City, Singapore)
   - ✅ 所有字段完整保存

2. **活动数据**
   - ✅ 从 `DataServiceController._generateMeetupData()` 迁移到数据库
   - ✅ 包含示例活动数据
   - ✅ 支持 RSVP 功能

3. **共享办公空间数据**
   - ✅ 预置3个示例共享办公空间
   - ✅ 支持按城市筛选

4. **用户数据**
   - ✅ 3个示例用户账号
   - ✅ 支持登录验证

## 🔄 Controller 集成示例

### DataServiceController 更新

```dart
class DataServiceController extends GetxController {
  final CityDataService _cityService = CityDataService();
  final MeetupDataService _meetupService = MeetupDataService();

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  void initializeData() async {
    isLoading.value = true;
    
    try {
      // 从数据库加载城市
      await _loadCitiesFromDatabase();
      
      // 从数据库加载活动
      await _loadMeetupsFromDatabase();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCitiesFromDatabase() async {
    final cities = await _cityService.getAllCities();
    // 转换并设置 dataItems.value
  }

  Future<void> _loadMeetupsFromDatabase() async {
    final meetups = await _meetupService.getUpcomingMeetups();
    // 转换并设置 meetups.value
  }
}
```

## 🎨 创建新数据的示例

### 创建新城市

```dart
Future<void> createCity() async {
  final cityService = CityDataService();
  
  final newCityId = await cityService.addCity({
    'name': 'Prague',
    'country': 'Czech Republic',
    'region': 'Europe',
    'climate': 'Cool',
    'description': 'Beautiful European city with rich history',
    'image_url': 'https://example.com/prague.jpg',
    'latitude': 50.0755,
    'longitude': 14.4378,
    'cost_of_living': 2200.0,
    'internet_speed': 35.0,
    'safety_score': 4.6,
    'overall_score': 4.5,
    'temperature': 15,
    'humidity': 65,
    'aqi': 42,
    'timezone': 'GMT+1',
    'population': '1.3M',
  });
  
  print('Created city with ID: $newCityId');
}
```

### 创建新活动

```dart
Future<void> createMeetup() async {
  final meetupService = MeetupDataService();
  
  final newMeetupId = await meetupService.createMeetup({
    'title': 'Weekly Coffee Meetup',
    'description': 'Join fellow digital nomads for coffee',
    'organizer_id': 1,
    'city_id': 1,
    'location': 'Starbucks Nimman',
    'address': 'Nimman Road',
    'category': 'Coffee',
    'start_time': DateTime.now().add(Duration(days: 7)),
    'end_time': DateTime.now().add(Duration(days: 7, hours: 2)),
    'max_participants': 15,
    'price': 0.0,
    'status': 'upcoming',
  });
  
  print('Created meetup with ID: $newMeetupId');
}
```

### 添加评论

```dart
Future<void> addCityReview(int userId, int cityId) async {
  final reviewService = ReviewDataService();
  
  final reviewId = await reviewService.addReview({
    'user_id': userId,
    'target_type': 'city',
    'target_id': cityId,
    'rating': 4.5,
    'content': 'Amazing city! Great for remote work and the food is incredible.',
  });
  
  print('Added review with ID: $reviewId');
}
```

## ⚡ 性能优化建议

1. **使用索引**: 数据库已为常用查询字段添加索引
2. **分页加载**: 对于大量数据,使用 LIMIT 和 OFFSET
3. **缓存数据**: Controller 中可以缓存常用数据
4. **批量操作**: 使用事务进行批量插入/更新

## 🔍 查询示例

### 复杂筛选查询

```dart
// 查找亚洲地区,月成本1000-2000美元,网速>20Mbps的城市
final cities = await cityService.filterCities(
  regions: ['Asia'],
  minPrice: 1000,
  maxPrice: 2000,
  minInternet: 20,
);

// 排序
final sorted = await cityService.sortCities(cities, 'rating');
```

### 联合查询

```dart
// 获取某城市的所有相关数据
final cityId = 1;

final city = await cityService.getCityById(cityId);
final coworkings = await coworkingService.getCoworkingsByCity(cityId);
final meetups = await meetupService.getMeetupsByCity(cityId);
final reviews = await reviewService.getReviewsByTarget('city', cityId);
final avgRating = await reviewService.getAverageRating('city', cityId);
```

## 📌 注意事项

1. **数据格式转换**: 数据库存储的数据可能需要转换才能用于UI
2. **异步操作**: 所有数据库操作都是异步的,需要使用 `await`
3. **错误处理**: 建议使用 try-catch 捕获数据库操作异常
4. **事务支持**: 对于复杂的多表操作,考虑使用事务
5. **时间格式**: 数据库使用 ISO8601 字符串存储时间,需要转换为 DateTime

## 🚀 下一步

1. **更新现有 Controller**: 将其他 Controller 也迁移到使用数据服务
2. **添加离线同步**: 实现本地数据与后端API的同步机制
3. **优化查询性能**: 根据实际使用情况优化查询语句
4. **添加数据验证**: 在插入/更新前验证数据完整性
5. **实现数据导入导出**: 支持数据备份和恢复

---

**提示**: 所有数据服务都已集成到项目中,可以直接使用!数据会在应用启动时自动初始化。
