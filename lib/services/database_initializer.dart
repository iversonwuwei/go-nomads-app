import 'database/city_dao.dart';
import 'database/meetup_dao.dart';
import 'database/user_dao.dart';
import 'database_service.dart';

/// 数据库初始化服务
/// 严格按照 DataServiceController 中的测试数据格式创建
class DatabaseInitializer {
  final DatabaseService _dbService = DatabaseService();
  final UserDao _userDao = UserDao();
  final CityDao _cityDao = CityDao();
  final MeetupDao _meetupDao = MeetupDao();

  /// 初始化数据库并插入示例数据
  Future<void> initializeDatabase({bool forceReset = false}) async {
    // 如果需要强制重置,删除整个数据库文件并重新创建
    if (forceReset) {
      print('🔄 强制重置数据库...');
      await _dbService.deleteDatabase();
    }
    
    // 确保数据库已创建(如果删除了会自动重新创建)
    await _dbService.database;

    // 检查是否已有数据
    final cities = await _cityDao.getAllCities();
    if (cities.isNotEmpty && !forceReset) {
      print('✅ 数据库已初始化,包含 ${cities.length} 个城市');
      return;
    }

    print('🚀 开始初始化数据库...');

    // 插入示例用户
    await _insertSampleUsers();

    // 插入示例城市（严格按照 DataServiceController 格式）
    await _insertCitiesFromController();

    // 插入示例活动（严格按照 DataServiceController 格式）
    await _insertMeetupsFromController();

    print('✅ 数据库初始化完成！');
  }

  /// 插入示例用户
  Future<void> _insertSampleUsers() async {
    final now = DateTime.now().toIso8601String();
    
    final users = [
      {
        'phone': '13800138000',
        'password': '123456',
        'nickname': 'Sarah Chen',
        'avatar': 'https://i.pravatar.cc/150?img=1',
        'email': 'sarah@example.com',
        'bio': 'Digital Nomad & Remote Worker',
        'city': 'Bangkok',
        'country': 'Thailand',
        'occupation': 'Event Organizer',
        'created_at': now,
        'updated_at': now,
      },
      {
        'phone': '13800138001',
        'password': '123456',
        'nickname': 'Alex Wong',
        'avatar': 'https://i.pravatar.cc/150?img=12',
        'email': 'alex@example.com',
        'bio': 'Coworking Space Manager',
        'city': 'Chiang Mai',
        'country': 'Thailand',
        'occupation': 'Community Manager',
        'created_at': now,
        'updated_at': now,
      },
      {
        'phone': '13800138002',
        'password': '123456',
        'nickname': 'Mike Johnson',
        'avatar': 'https://i.pravatar.cc/150?img=33',
        'email': 'mike@example.com',
        'bio': 'Surf Instructor & Digital Nomad',
        'city': 'Canggu, Bali',
        'country': 'Indonesia',
        'occupation': 'Surf Instructor',
        'created_at': now,
        'updated_at': now,
      },
      {
        'phone': '13800138003',
        'password': '123456',
        'nickname': 'Emma Silva',
        'avatar': 'https://i.pravatar.cc/150?img=5',
        'email': 'emma@example.com',
        'bio': 'Food Blogger & Event Host',
        'city': 'Lisbon',
        'country': 'Portugal',
        'occupation': 'Food Blogger',
        'created_at': now,
        'updated_at': now,
      },
      {
        'phone': '13800138004',
        'password': '123456',
        'nickname': 'Yuki Tanaka',
        'avatar': 'https://i.pravatar.cc/150?img=47',
        'email': 'yuki@example.com',
        'bio': 'Language Teacher & Cultural Guide',
        'city': 'Tokyo',
        'country': 'Japan',
        'occupation': 'Language Teacher',
        'created_at': now,
        'updated_at': now,
      },
      {
        'phone': '13800138005',
        'password': '123456',
        'nickname': 'Carlos Rodriguez',
        'avatar': 'https://i.pravatar.cc/150?img=15',
        'email': 'carlos@example.com',
        'bio': 'Startup Founder & Entrepreneur',
        'city': 'Mexico City',
        'country': 'Mexico',
        'occupation': 'Entrepreneur',
        'created_at': now,
        'updated_at': now,
      },
      {
        'phone': '13800138006',
        'password': '123456',
        'nickname': 'Lisa Park',
        'avatar': 'https://i.pravatar.cc/150?img=9',
        'email': 'lisa@example.com',
        'bio': 'Photographer & Tour Guide',
        'city': 'Bangkok',
        'country': 'Thailand',
        'occupation': 'Photographer',
        'created_at': now,
        'updated_at': now,
      },
      {
        'phone': '13800138007',
        'password': '123456',
        'nickname': 'Ji-woo Kim',
        'avatar': 'https://i.pravatar.cc/150?img=20',
        'email': 'jiwoo@example.com',
        'bio': 'K-Culture Enthusiast & Event Planner',
        'city': 'Seoul',
        'country': 'South Korea',
        'occupation': 'Event Planner',
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (var user in users) {
      try {
        await _userDao.insertUser(user);
      } catch (e) {
        print('⚠️ 用户插入失败 (${user['nickname']}): $e');
      }
    }
    print('✅ 插入了 ${users.length} 个示例用户');
  }

  /// 插入城市数据 - 严格按照 DataServiceController._generateMockData_deprecated 格式
  Future<void> _insertCitiesFromController() async {
    final now = DateTime.now().toIso8601String();
    
    final cities = [
      {
        'name': 'Bangkok',
        'country': 'Thailand',
        'region': 'Asia',
        'climate': 'Hot',
        'image_url': 'https://images.unsplash.com/photo-1508009603885-50cf7c579365?w=400',
        'description': 'Bangkok is a vibrant digital nomad hub with incredible food, affordable living, and a thriving expat community. Great coworking spaces and fast internet make it perfect for remote work.',
        'temperature': 32.0,
        'cost_of_living': 1561.0,
        'internet_speed': 24.0,
        'safety_score': 4.5,
        'overall_score': 4.8,
        'aqi': 56,
        'population': '10.5M',
        'timezone': 'GMT+7',
        'humidity': 75,
        'latitude': 13.7563,
        'longitude': 100.5018,
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'Chiang Mai',
        'country': 'Thailand',
        'region': 'Asia',
        'climate': 'Warm',
        'image_url': 'https://images.unsplash.com/photo-1598970434795-0c54fe7c0648?w=400',
        'description': 'Chiang Mai offers a perfect blend of affordability, nature, and digital nomad infrastructure. The Old City is filled with temples, cafes, and coworking spaces.',
        'temperature': 29.0,
        'cost_of_living': 1271.0,
        'internet_speed': 20.0,
        'safety_score': 4.7,
        'overall_score': 4.6,
        'aqi': 252,
        'population': '1.2M',
        'timezone': 'GMT+7',
        'humidity': 68,
        'latitude': 18.7883,
        'longitude': 98.9853,
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'Canggu, Bali',
        'country': 'Indonesia',
        'region': 'Asia',
        'climate': 'Hot',
        'image_url': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
        'description': 'Surf, work, and wellness paradise. Canggu has become the ultimate digital nomad destination with amazing beaches, healthy food, and vibrant coworking scene.',
        'temperature': 27.0,
        'cost_of_living': 1896.0,
        'internet_speed': 24.0,
        'safety_score': 4.4,
        'overall_score': 4.7,
        'aqi': 177,
        'population': '50K',
        'timezone': 'GMT+8',
        'humidity': 82,
        'latitude': -8.6481,
        'longitude': 115.1376,
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'Tokyo',
        'country': 'Japan',
        'region': 'Asia',
        'climate': 'Mild',
        'image_url': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
        'description': 'Ultra-modern city with incredible infrastructure, safety, and food. Expensive but worth it for the unique culture and unmatched efficiency.',
        'temperature': 23.0,
        'cost_of_living': 3321.0,
        'internet_speed': 27.0,
        'safety_score': 5.0,
        'overall_score': 4.2,
        'aqi': 38,
        'population': '14M',
        'timezone': 'GMT+9',
        'humidity': 65,
        'latitude': 35.6762,
        'longitude': 139.6503,
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'Seoul',
        'country': 'South Korea',
        'region': 'Asia',
        'climate': 'Cool',
        'image_url': 'https://images.unsplash.com/photo-1517154421773-0529f29ea451?w=400',
        'description': 'Tech-forward city with blazing fast internet, incredible food scene, and efficient public transport. Great for digital nomads who love urban energy.',
        'temperature': 18.0,
        'cost_of_living': 2519.0,
        'internet_speed': 32.0,
        'safety_score': 4.8,
        'overall_score': 4.0,
        'aqi': 31,
        'population': '10M',
        'timezone': 'GMT+9',
        'humidity': 70,
        'latitude': 37.5665,
        'longitude': 126.9780,
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'Lisbon',
        'country': 'Portugal',
        'region': 'Europe',
        'climate': 'Mild',
        'image_url': 'https://images.unsplash.com/photo-1585208798174-6cedd86e019a?w=400',
        'description': 'Beautiful coastal city with amazing weather, great food, and a booming startup scene. Perfect balance of European culture and beach lifestyle.',
        'temperature': 23.0,
        'cost_of_living': 3857.0,
        'internet_speed': 28.0,
        'safety_score': 4.5,
        'overall_score': 4.6,
        'aqi': 38,
        'population': '2.8M',
        'timezone': 'GMT+1',
        'humidity': 72,
        'latitude': 38.7223,
        'longitude': -9.1393,
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'Mexico City',
        'country': 'Mexico',
        'region': 'Americas',
        'climate': 'Mild',
        'image_url': 'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=400',
        'description': 'Vibrant cultural capital with incredible food, art, and nightlife. Large digital nomad community and affordable living, though internet can be spotty.',
        'temperature': 21.0,
        'cost_of_living': 2057.0,
        'internet_speed': 13.0,
        'safety_score': 3.5,
        'overall_score': 3.8,
        'aqi': 55,
        'population': '9M',
        'timezone': 'GMT-6',
        'humidity': 58,
        'latitude': 19.4326,
        'longitude': -99.1332,
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'Singapore',
        'country': 'Singapore',
        'region': 'Asia',
        'climate': 'Hot',
        'image_url': 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=400',
        'description': 'Ultra-clean, safe, and efficient city-state with world-class infrastructure. Expensive but perfect for business-minded nomads.',
        'temperature': 31.0,
        'cost_of_living': 4520.0,
        'internet_speed': 50.0,
        'safety_score': 5.0,
        'overall_score': 4.3,
        'aqi': 25,
        'population': '5.7M',
        'timezone': 'GMT+8',
        'humidity': 85,
        'latitude': 1.3521,
        'longitude': 103.8198,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (var city in cities) {
      try {
        await _cityDao.insertCity(city);
      } catch (e) {
        print('⚠️ 城市插入失败 (${city['name']}): $e');
      }
    }
    print('✅ 插入了 ${cities.length} 个城市');
  }

  /// 插入活动数据 - 严格按照 DataServiceController._generateMeetupData 格式
  Future<void> _insertMeetupsFromController() async {
    final now = DateTime.now();
    final nowStr = DateTime.now().toIso8601String();

    // 获取城市ID映射
    final cityIdMap = await _getCityIdMap();

    final meetups = [
      {
        'title': 'Digital Nomad Happy Hour',
        'description': 'Join us for drinks and networking with fellow digital nomads in Bangkok!',
        'category': 'Drinks',
        'city_id': cityIdMap['Bangkok'],
        'location': 'Octave Rooftop Bar',
        'image_url': 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400',
        'start_time': now.add(const Duration(days: 2)).toIso8601String(),
        'max_participants': 30,
        'current_participants': 24,
        'organizer_id': 1, // Sarah Chen
        'status': 'upcoming',
        'created_at': nowStr,
        'updated_at': nowStr,
      },
      {
        'title': 'Morning Coworking Session',
        'description': 'Start your day with focused work alongside other remote workers.',
        'category': 'Coworking',
        'city_id': cityIdMap['Chiang Mai'],
        'location': 'Punspace Nimman',
        'image_url': 'https://images.unsplash.com/photo-1497215728101-856f4ea42174?w=400',
        'start_time': now.add(const Duration(days: 3)).toIso8601String(),
        'max_participants': 20,
        'current_participants': 12,
        'organizer_id': 2, // Alex Wong
        'status': 'upcoming',
        'created_at': nowStr,
        'updated_at': nowStr,
      },
      {
        'title': 'Sunset Surf Session',
        'description': 'Catch some waves and watch the sunset with the nomad community!',
        'category': 'Activity',
        'city_id': cityIdMap['Canggu, Bali'],
        'location': 'Batu Bolong Beach',
        'image_url': 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400',
        'start_time': now.add(const Duration(days: 4)).toIso8601String(),
        'max_participants': 15,
        'current_participants': 8,
        'organizer_id': 3, // Mike Johnson
        'status': 'upcoming',
        'created_at': nowStr,
        'updated_at': nowStr,
      },
      {
        'title': 'Portuguese Food Experience',
        'description': 'Taste the best of Portuguese cuisine with fellow food lovers!',
        'category': 'Dinner',
        'city_id': cityIdMap['Lisbon'],
        'location': 'Time Out Market',
        'image_url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
        'start_time': now.add(const Duration(days: 5)).toIso8601String(),
        'max_participants': 20,
        'current_participants': 16,
        'organizer_id': 4, // Emma Silva
        'status': 'upcoming',
        'created_at': nowStr,
        'updated_at': nowStr,
      },
      {
        'title': 'Japanese Language Exchange',
        'description': 'Practice Japanese with locals and learn about the culture.',
        'category': 'Workshop',
        'city_id': cityIdMap['Tokyo'],
        'location': 'WeWork Shibuya',
        'image_url': 'https://images.unsplash.com/photo-1528164344705-47542687000d?w=400',
        'start_time': now.add(const Duration(days: 6)).toIso8601String(),
        'max_participants': 15,
        'current_participants': 10,
        'organizer_id': 5, // Yuki Tanaka
        'status': 'upcoming',
        'created_at': nowStr,
        'updated_at': nowStr,
      },
      {
        'title': 'Startup Founders Meetup',
        'description': 'Connect with startup founders and entrepreneurs in CDMX.',
        'category': 'Networking',
        'city_id': cityIdMap['Mexico City'],
        'location': 'Curators',
        'image_url': 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=400',
        'start_time': now.add(const Duration(days: 7)).toIso8601String(),
        'max_participants': 25,
        'current_participants': 20,
        'organizer_id': 6, // Carlos Rodriguez
        'status': 'upcoming',
        'created_at': nowStr,
        'updated_at': nowStr,
      },
      {
        'title': 'Temple Tour & Photography',
        'description': 'Explore Bangkok\'s beautiful temples with a local photographer.',
        'category': 'Activity',
        'city_id': cityIdMap['Bangkok'],
        'location': 'Wat Pho',
        'image_url': 'https://images.unsplash.com/photo-1563492065599-3520f775eeed?w=400',
        'start_time': now.add(const Duration(days: 8)).toIso8601String(),
        'max_participants': 20,
        'current_participants': 15,
        'organizer_id': 7, // Lisa Park
        'status': 'upcoming',
        'created_at': nowStr,
        'updated_at': nowStr,
      },
      {
        'title': 'K-BBQ & Drinks Night',
        'description': 'Experience authentic Korean BBQ and nightlife in Gangnam!',
        'category': 'Drinks',
        'city_id': cityIdMap['Seoul'],
        'location': 'Gangnam District',
        'image_url': 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=400',
        'start_time': now.add(const Duration(days: 9)).toIso8601String(),
        'max_participants': 22,
        'current_participants': 18,
        'organizer_id': 8, // Ji-woo Kim
        'status': 'upcoming',
        'created_at': nowStr,
        'updated_at': nowStr,
      },
    ];

    for (var meetup in meetups) {
      try {
        await _meetupDao.insertMeetup(meetup);
      } catch (e) {
        print('⚠️ 活动插入失败 (${meetup['title']}): $e');
      }
    }
    print('✅ 插入了 ${meetups.length} 个活动');
  }

  /// 获取城市ID映射表
  Future<Map<String, int?>> _getCityIdMap() async {
    final cities = await _cityDao.getAllCities();
    final map = <String, int?>{};
    for (var city in cities) {
      map[city['name'] as String] = city['id'] as int?;
    }
    return map;
  }
}
