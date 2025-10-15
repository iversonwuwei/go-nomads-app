import 'database/city_dao.dart';
import 'database/coworking_dao.dart';
import 'database/meetup_dao.dart';
import 'database/user_dao.dart';
import 'database_service.dart';

/// 数据库初始化服务
/// 用于初始化数据库并插入示例数据
class DatabaseInitializer {
  final DatabaseService _dbService = DatabaseService();
  final UserDao _userDao = UserDao();
  final CityDao _cityDao = CityDao();
  final MeetupDao _meetupDao = MeetupDao();
  final CoworkingDao _coworkingDao = CoworkingDao();

  /// 初始化数据库并插入示例数据
  Future<void> initializeDatabase({bool forceReset = false}) async {
    // 确保数据库已创建
    await _dbService.database;

    // 如果需要强制重置,先清空所有数据
    if (forceReset) {
      print('🔄 强制重置数据库...');
      await _dbService.clearAllData();
    }

    // 检查是否已有数据
    final cities = await _cityDao.getAllCities();
    if (cities.isNotEmpty) {
      print('Database already initialized with ${cities.length} cities');
      return;
    }

    print('Initializing database with sample data...');

    // 插入示例用户
    await _insertSampleUsers();

    // 插入示例城市
    await _insertSampleCities();

    // 插入示例共享办公空间
    await _insertSampleCoworkings();

    // 插入示例活动
    await _insertSampleMeetups();

    print('Database initialization completed');
  }

  /// 插入示例用户
  Future<void> _insertSampleUsers() async {
    final users = [
      {
        'phone': '13800138000',
        'password': '123456',
        'nickname': '数字游民小王',
        'avatar': 'https://i.pravatar.cc/150?img=1',
        'email': 'wang@example.com',
        'bio': '热爱旅行的程序员',
        'city': 'Chiang Mai',
        'country': 'Thailand',
        'occupation': 'Software Developer',
        'skills': 'Flutter,Dart,Mobile Development',
        'interests': 'Travel,Coding,Coffee',
      },
      {
        'phone': '13800138001',
        'password': '123456',
        'nickname': '远程工作者李明',
        'avatar': 'https://i.pravatar.cc/150?img=2',
        'email': 'li@example.com',
        'bio': '自由设计师,环游世界',
        'city': 'Bali',
        'country': 'Indonesia',
        'occupation': 'UI/UX Designer',
        'skills': 'Figma,Sketch,Design',
        'interests': 'Design,Surfing,Yoga',
      },
      {
        'phone': '13800138002',
        'password': '123456',
        'nickname': '数字游民张三',
        'avatar': 'https://i.pravatar.cc/150?img=3',
        'email': 'zhang@example.com',
        'bio': '内容创作者,分享旅行故事',
        'city': 'Lisbon',
        'country': 'Portugal',
        'occupation': 'Content Creator',
        'skills': 'Writing,Photography,Video Editing',
        'interests': 'Travel,Photography,Food',
      },
    ];

    for (var user in users) {
      await _userDao.insertUser(user);
    }
    print('Inserted ${users.length} sample users');
  }

  /// 插入示例城市 - 严格按照 DataServiceController 需求,格式统一
  Future<void> _insertSampleCities() async {
    final cities = [
      // 1. Bangkok, Thailand
      {
        'name': 'Bangkok',
        'country': 'Thailand',
        'region': 'Asia',
        'climate': 'Hot',
        'description':
            'Modern metropolis with excellent infrastructure, delicious street food, and vibrant nightlife. Perfect for nomads who love urban energy.',
        'image_url':
            'https://images.unsplash.com/photo-1508009603885-50cf7c579365?w=400',
        'latitude': 13.7563,
        'longitude': 100.5018,
        'timezone': 'GMT+7',
        'population': '11M',
        'cost_of_living': 1561.0,
        'internet_speed': 24.0,
        'safety_score': 4.2,
        'overall_score': 4.8,
        'temperature': 32,
        'humidity': 75,
        'aqi': 56,
      },
      // 2. Chiang Mai, Thailand
      {
        'name': 'Chiang Mai',
        'country': 'Thailand',
        'region': 'Asia',
        'climate': 'Warm',
        'description':
            'Cultural hub of northern Thailand with ancient temples, night markets, and a thriving digital nomad community. Affordable and laid-back.',
        'image_url':
            'https://images.unsplash.com/photo-1598458028454-47f3a9aeef0e?w=400',
        'latitude': 18.7883,
        'longitude': 98.9853,
        'timezone': 'GMT+7',
        'population': '1.1M',
        'cost_of_living': 1271.0,
        'internet_speed': 20.0,
        'safety_score': 4.5,
        'overall_score': 4.6,
        'temperature': 28,
        'humidity': 68,
        'aqi': 252,
      },
      // 3. Canggu, Bali, Indonesia
      {
        'name': 'Canggu',
        'country': 'Indonesia',
        'region': 'Asia',
        'climate': 'Hot',
        'description':
            'Surf paradise with a bohemian vibe, yoga studios, and beach clubs. The ultimate spot for digital nomads who love the ocean lifestyle.',
        'image_url':
            'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
        'latitude': -8.6481,
        'longitude': 115.1373,
        'timezone': 'GMT+8',
        'population': '50K',
        'cost_of_living': 1896.0,
        'internet_speed': 24.0,
        'safety_score': 4.4,
        'overall_score': 4.7,
        'temperature': 27,
        'humidity': 82,
        'aqi': 177,
      },
      // 4. Tokyo, Japan
      {
        'name': 'Tokyo',
        'country': 'Japan',
        'region': 'Asia',
        'climate': 'Mild',
        'description':
            'Ultra-modern city with incredible infrastructure, safety, and food. Expensive but worth it for the unique culture and unmatched efficiency.',
        'image_url':
            'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
        'latitude': 35.6762,
        'longitude': 139.6503,
        'timezone': 'GMT+9',
        'population': '14M',
        'cost_of_living': 3321.0,
        'internet_speed': 27.0,
        'safety_score': 5.0,
        'overall_score': 4.2,
        'temperature': 23,
        'humidity': 65,
        'aqi': 38,
      },
      // 5. Seoul, South Korea
      {
        'name': 'Seoul',
        'country': 'South Korea',
        'region': 'Asia',
        'climate': 'Cool',
        'description':
            'Tech-forward city with blazing fast internet, incredible food scene, and efficient public transport. Great for digital nomads who love urban energy.',
        'image_url':
            'https://images.unsplash.com/photo-1517154421773-0529f29ea451?w=400',
        'latitude': 37.5665,
        'longitude': 126.9780,
        'timezone': 'GMT+9',
        'population': '10M',
        'cost_of_living': 2519.0,
        'internet_speed': 32.0,
        'safety_score': 4.8,
        'overall_score': 4.0,
        'temperature': 18,
        'humidity': 70,
        'aqi': 31,
      },
      // 6. Lisbon, Portugal
      {
        'name': 'Lisbon',
        'country': 'Portugal',
        'region': 'Europe',
        'climate': 'Mild',
        'description':
            'Beautiful coastal city with amazing weather, great food, and a booming startup scene. Perfect balance of European culture and beach lifestyle.',
        'image_url':
            'https://images.unsplash.com/photo-1585208798174-6cedd86e019a?w=400',
        'latitude': 38.7223,
        'longitude': -9.1393,
        'timezone': 'GMT+1',
        'population': '2.8M',
        'cost_of_living': 3857.0,
        'internet_speed': 28.0,
        'safety_score': 4.5,
        'overall_score': 4.6,
        'temperature': 23,
        'humidity': 72,
        'aqi': 38,
      },
      // 7. Mexico City, Mexico
      {
        'name': 'Mexico City',
        'country': 'Mexico',
        'region': 'Americas',
        'climate': 'Mild',
        'description':
            'Vibrant cultural capital with incredible food, art, and nightlife. Large digital nomad community and affordable living, though internet can be spotty.',
        'image_url':
            'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=400',
        'latitude': 19.4326,
        'longitude': -99.1332,
        'timezone': 'GMT-6',
        'population': '9M',
        'cost_of_living': 2057.0,
        'internet_speed': 13.0,
        'safety_score': 3.5,
        'overall_score': 3.8,
        'temperature': 21,
        'humidity': 58,
        'aqi': 55,
      },
      // 8. Singapore
      {
        'name': 'Singapore',
        'country': 'Singapore',
        'region': 'Asia',
        'climate': 'Hot',
        'description':
            'Ultra-clean, safe, and efficient city-state with world-class infrastructure. Expensive but perfect for business-minded nomads.',
        'image_url':
            'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=400',
        'latitude': 1.3521,
        'longitude': 103.8198,
        'timezone': 'GMT+8',
        'population': '5.7M',
        'cost_of_living': 4520.0,
        'internet_speed': 50.0,
        'safety_score': 5.0,
        'overall_score': 4.3,
        'temperature': 31,
        'humidity': 85,
        'aqi': 25,
      },
    ];

    for (var city in cities) {
      await _cityDao.insertCity(city);
    }
    print('Inserted ${cities.length} sample cities');
  }

  /// 插入示例共享办公空间
  Future<void> _insertSampleCoworkings() async {
    final coworkings = [
      {
        'name': 'Punspace',
        'city_id': 2, // Chiang Mai (修正: city_id=2)
        'address': 'Nimman Road, Chiang Mai',
        'description': '清迈最受欢迎的共享办公空间之一,位于宁曼路',
        'image_url':
            'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
        'price_per_day': 10.0,
        'price_per_month': 150.0,
        'rating': 4.8,
        'wifi_speed': 100.0,
        'has_meeting_room': 1,
        'has_coffee': 1,
        'latitude': 18.7965,
        'longitude': 98.9681,
        'phone': '+66 52 001 001',
        'email': 'hello@punspace.com',
        'website': 'https://punspace.com',
        'opening_hours': 'Mon-Fri 8:00-20:00',
      },
      {
        'name': 'Hubud',
        'city_id': 3, // Canggu (修正: city_id=3)
        'address': 'Ubud, Bali',
        'description': '巴厘岛乌布德的知名共享办公空间,竹子建筑风格',
        'image_url':
            'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800',
        'price_per_day': 12.0,
        'price_per_month': 180.0,
        'rating': 4.7,
        'wifi_speed': 80.0,
        'has_meeting_room': 1,
        'has_coffee': 1,
        'latitude': -8.5069,
        'longitude': 115.2625,
        'phone': '+62 361 123 456',
        'email': 'info@hubud.org',
        'website': 'https://hubud.org',
        'opening_hours': 'Mon-Sun 8:00-18:00',
      },
      {
        'name': 'Second Home Lisboa',
        'city_id': 6, // Lisbon (修正: city_id=6)
        'address': 'Mercado da Ribeira, Lisboa',
        'description': '里斯本市中心的现代化共享办公空间',
        'image_url':
            'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=800',
        'price_per_day': 25.0,
        'price_per_month': 350.0,
        'rating': 4.9,
        'wifi_speed': 150.0,
        'has_meeting_room': 1,
        'has_coffee': 1,
        'latitude': 38.7073,
        'longitude': -9.1452,
        'phone': '+351 21 123 4567',
        'email': 'lisboa@secondhome.io',
        'website': 'https://secondhome.io',
        'opening_hours': 'Mon-Fri 8:00-22:00',
      },
    ];

    for (var coworking in coworkings) {
      await _coworkingDao.insertCoworking(coworking);
    }
    print('Inserted ${coworkings.length} sample coworking spaces');
  }

  /// 插入示例活动
  Future<void> _insertSampleMeetups() async {
    final now = DateTime.now();

    final meetups = [
      {
        'title': 'Digital Nomad Coffee Chat',
        'description': '每周例行的数字游民咖啡聊天活动,认识新朋友,分享经验',
        'organizer_id': 1,
        'city_id': 1,
        'location': 'Ristr8to Coffee',
        'address': 'Nimman Road, Chiang Mai',
        'image_url':
            'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800',
        'category': 'Coffee',
        'start_time': now.add(Duration(days: 2)).toIso8601String(),
        'end_time': now.add(Duration(days: 2, hours: 2)).toIso8601String(),
        'max_participants': 15,
        'current_participants': 5,
        'price': 0.0,
        'status': 'upcoming',
        'latitude': 18.7965,
        'longitude': 98.9681,
      },
      {
        'title': 'Sunset Beach Yoga',
        'description': '在海滩上欣赏日落的同时练习瑜伽,适合所有水平',
        'organizer_id': 2,
        'city_id': 2,
        'location': 'Seminyak Beach',
        'address': 'Seminyak, Bali',
        'image_url':
            'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
        'category': 'Sports',
        'start_time': now.add(Duration(days: 1)).toIso8601String(),
        'end_time':
            now.add(Duration(days: 1, hours: 1, minutes: 30)).toIso8601String(),
        'max_participants': 20,
        'current_participants': 12,
        'price': 5.0,
        'status': 'upcoming',
        'latitude': -8.6910,
        'longitude': 115.1656,
      },
      {
        'title': 'Startup & Tech Networking',
        'description': '科技创业者和开发者的交流活动,分享想法和寻找合作机会',
        'organizer_id': 3,
        'city_id': 3,
        'location': 'Second Home Lisboa',
        'address': 'Mercado da Ribeira, Lisboa',
        'image_url':
            'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800',
        'category': 'Networking',
        'start_time': now.add(Duration(days: 5)).toIso8601String(),
        'end_time': now.add(Duration(days: 5, hours: 3)).toIso8601String(),
        'max_participants': 30,
        'current_participants': 18,
        'price': 0.0,
        'status': 'upcoming',
        'latitude': 38.7073,
        'longitude': -9.1452,
      },
      {
        'title': 'Weekend Hiking Adventure',
        'description': '周末徒步探险,探索清迈周边的美丽山区',
        'organizer_id': 1,
        'city_id': 1,
        'location': 'Doi Suthep',
        'address': 'Doi Suthep-Pui National Park',
        'image_url':
            'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800',
        'category': 'Outdoor',
        'start_time': now.add(Duration(days: 7)).toIso8601String(),
        'end_time': now.add(Duration(days: 7, hours: 6)).toIso8601String(),
        'max_participants': 12,
        'current_participants': 8,
        'price': 15.0,
        'status': 'upcoming',
        'latitude': 18.8049,
        'longitude': 98.9217,
      },
    ];

    for (var meetup in meetups) {
      await _meetupDao.insertMeetup(meetup);
    }
    print('Inserted ${meetups.length} sample meetups');
  }

  /// 重置数据库(清空并重新初始化)
  Future<void> resetDatabase() async {
    await _dbService.clearAllData();
    await initializeDatabase();
    print('Database reset completed');
  }
}
