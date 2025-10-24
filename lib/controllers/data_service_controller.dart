import 'package:get/get.dart';

import '../models/city_option.dart';
import '../models/country_option.dart';
import '../services/data/city_data_service.dart';
import '../services/data/meetup_data_service.dart';
import '../services/events_api_service.dart';
import '../services/location_api_service.dart';
import '../widgets/app_toast.dart';

class DataServiceController extends GetxController {
  // 数据服务
  final CityDataService _cityService = CityDataService();
  final MeetupDataService _meetupService = MeetupDataService();
  final LocationApiService _locationApiService = LocationApiService();
  // 响应式数据
  final RxBool isLoading = true.obs;
  final RxBool isGridView = true.obs;
  final RxString sortBy = 'popular'.obs;
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> dataItems = <Map<String, dynamic>>[].obs;
  final RxList<CountryOption> countries = <CountryOption>[].obs;
  final RxMap<String, List<CityOption>> citiesByCountry =
      <String, List<CityOption>>{}.obs;
  final RxBool isLoadingCountries = false.obs;
  final RxMap<String, bool> cityLoadingStates = <String, bool>{}.obs;

  // 用户登录状态 (模拟)
  final RxBool isLoggedIn = true.obs; // 在实际应用中，这应该从认证服务获取

  // 筛选状态 - Nomads.com 风格
  final RxList<String> selectedRegions = <String>[].obs; // 地区筛选
  final RxList<String> selectedCountries = <String>[].obs; // 国家筛选
  final RxList<String> selectedCities = <String>[].obs; // 城市筛选
  final RxDouble minPrice = 0.0.obs; // 最低价格
  final RxDouble maxPrice = 5000.0.obs; // 最高价格
  final RxDouble minInternet = 0.0.obs; // 最低网速
  final RxDouble minRating = 0.0.obs; // 最低评分
  final RxInt maxAqi = 500.obs; // 最大AQI
  final RxList<String> selectedClimates = <String>[].obs; // 气候筛选

  // 可用的筛选选项
  final List<String> availableRegions = [
    'Asia',
    'Europe',
    'Americas',
    'Africa',
    'Oceania'
  ];

  final List<String> availableClimates = [
    'Hot',
    'Warm',
    'Mild',
    'Cool',
    'Cold'
  ];

  // Meetups 数据 - Nomads.com 风格
  final RxList<Map<String, dynamic>> meetups = <Map<String, dynamic>>[].obs;
  final RxList<int> rsvpedMeetups = <int>[].obs; // 用户已RSVP的meetup IDs

  // Meetup 类型
  final List<String> meetupTypes = [
    'Drinks',
    'Coworking',
    'Dinner',
    'Activity',
    'Workshop',
    'Networking'
  ];

  // 可用的城市列表（从数据中提取）
  List<String> get availableCities {
    if (countries.isNotEmpty && citiesByCountry.isNotEmpty) {
      final remoteCities = citiesByCountry.values
          .expand((cityList) => cityList)
          .map((city) => city.name)
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      if (remoteCities.isNotEmpty) {
        return remoteCities;
      }
    }

    return dataItems.map((item) => item['city'] as String).toSet().toList()
      ..sort();
  }

  // 可用的国家列表（从数据中提取）
  List<String> get availableCountries {
    if (countries.isNotEmpty) {
      final remoteCountries = countries
          .where((country) => country.isActive)
          .map((country) => country.name)
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      if (remoteCountries.isNotEmpty) {
        return remoteCountries;
      }
    }

    return dataItems.map((item) => item['country'] as String).toSet().toList()
      ..sort();
  }

  List<String> getCitiesByCountry(String country) {
    if (country.isEmpty) {
      return <String>[];
    }

    final matchedCountry = countries.firstWhereOrNull((item) =>
        item.id == country ||
        item.name == country ||
        (item.nameZh?.isNotEmpty ?? false) && item.nameZh == country);

    if (matchedCountry != null) {
      final cachedRemoteCities = citiesByCountry[matchedCountry.id];
      if (cachedRemoteCities != null && cachedRemoteCities.isNotEmpty) {
        return cachedRemoteCities
            .map((city) => city.name)
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      }
    }

    return dataItems
        .where((item) => (item['country'] as String?) == country)
        .map((item) => item['city'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  // 根据城市获取对应的国家
  String getCountryByCity(String city) {
    final cityData = dataItems.firstWhereOrNull((item) => item['city'] == city);
    return cityData?['country'] as String? ?? 'Thailand';
  }

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  // 初始化数据
  void initializeData() async {
    isLoading.value = true;

    try {
      await loadCountries();
      // 从数据库加载城市数据
      await _loadCitiesFromDatabase();

      // 从数据库加载活动数据
      await _loadMeetupsFromDatabase();
    } catch (e) {
      print('Error loading data: $e');
      // AppToast.showError('加载数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCountries({bool forceRefresh = false}) async {
    if (isLoadingCountries.value) {
      return;
    }

    if (countries.isNotEmpty && !forceRefresh) {
      return;
    }

    try {
      isLoadingCountries.value = true;
      final fetchedCountries = await _locationApiService.fetchCountries();
      fetchedCountries
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      countries.assignAll(
        fetchedCountries.where((country) => country.isActive).toList(),
      );
    } catch (e) {
      print('Error loading countries: $e');
      AppToast.error('无法获取国家列表');
    } finally {
      isLoadingCountries.value = false;
    }
  }

  Future<List<CityOption>> loadCitiesByCountry(
    String countryId, {
    bool forceRefresh = false,
  }) async {
    if (countryId.isEmpty) {
      return <CityOption>[];
    }

    if (!forceRefresh) {
      final cached = citiesByCountry[countryId];
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    if (cityLoadingStates[countryId] == true) {
      // Waiting for existing request to complete.
      while (cityLoadingStates[countryId] == true) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return citiesByCountry[countryId] ?? <CityOption>[];
    }

    try {
      cityLoadingStates[countryId] = true;
      cityLoadingStates.refresh();

      final fetchedCities =
          await _locationApiService.fetchCitiesByCountry(countryId);
      fetchedCities
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      citiesByCountry[countryId] = fetchedCities;
      citiesByCountry.refresh();
      return fetchedCities;
    } catch (e) {
      print('Error loading cities for country $countryId: $e');
      AppToast.error('无法获取城市列表');
      return <CityOption>[];
    } finally {
      cityLoadingStates[countryId] = false;
      cityLoadingStates.refresh();
    }
  }

  // 从数据库加载城市数据
  Future<void> _loadCitiesFromDatabase() async {
    try {
      final cities = await _cityService.getAllCities();

      // 转换数据格式以匹配现有的UI结构
      dataItems.value = cities.map((city) {
        return {
          'city': city['name'],
          'country': city['country'],
          'region': city['region'] ?? 'Asia',
          'climate': city['climate'] ?? 'Warm',
          'image': city['image_url'],
          'temperature': city['temperature'] ?? 25,
          'feelsLike': city['temperature'] ?? 25,
          'weather': _getWeatherFromClimate(city['climate']),
          'internet': (city['internet_speed'] as num?)?.toInt() ?? 20,
          'price': (city['cost_of_living'] as num?)?.toInt() ?? 1500,
          'rank': cities.indexOf(city) + 1,
          'badge': _getBadgeForCity(city),
          'ratings': ['😊', '👍', '🌟'],
          'overall': (city['overall_score'] as num?)?.toDouble() ?? 4.0,
          'cost': _calculateCostScore(city['cost_of_living']),
          'internetScore': _calculateInternetScore(city['internet_speed']),
          'liked': (city['overall_score'] as num?)?.toDouble() ?? 4.0,
          'safety': (city['safety_score'] as num?)?.toDouble() ?? 4.0,
          'aqi': city['aqi'] ?? 50,
          'aqiLevel': _getAqiLevel(city['aqi']),
          'population': city['population'] ?? '1M',
          'timezone': city['timezone'] ?? 'GMT',
          'humidity': city['humidity'] ?? 70,
          'about': city['description'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error loading cities: $e');
      rethrow;
    }
  }

  // 从数据库加载活动数据
  Future<void> _loadMeetupsFromDatabase() async {
    try {
      final dbMeetups = await _meetupService.getUpcomingMeetups(days: 30);

      // 转换数据格式
      final List<Map<String, dynamic>> convertedMeetups = [];

      for (var meetup in dbMeetups) {
        final cityId = meetup['city_id'] as int?;
        final cityInfo = await _getCityInfoById(cityId);

        convertedMeetups.add({
          'id': meetup['id'],
          'city': cityInfo['name'],
          'country': cityInfo['country'],
          'type': meetup['category'] ?? 'Activity',
          'title': meetup['title'],
          'venue': meetup['location'],
          'date':
              DateTime.tryParse(meetup['start_time'] ?? '') ?? DateTime.now(),
          'time': _formatTime(meetup['start_time']),
          'attendees': meetup['current_participants'] ?? 0,
          'maxAttendees': meetup['max_participants'] ?? 20,
          'organizer': 'Organizer', // TODO: 从用户表获取
          'organizerAvatar': 'https://i.pravatar.cc/150?img=1',
          'image': meetup['image_url'] ??
              'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
          'description': meetup['description'] ?? '',
        });
      }

      meetups.value = convertedMeetups;
    } catch (e) {
      print('Error loading meetups: $e');
      rethrow;
    }
  }

  // 辅助方法:根据城市ID获取城市信息
  Future<Map<String, dynamic>> _getCityInfoById(int? cityId) async {
    if (cityId == null) return {'name': 'Unknown', 'country': 'Unknown'};

    try {
      final city = await _cityService.getCityById(cityId);
      return {
        'name': city?['name'] ?? 'Unknown',
        'country': city?['country'] ?? 'Unknown',
      };
    } catch (e) {
      return {'name': 'Unknown', 'country': 'Unknown'};
    }
  }

  // 辅助方法:根据气候获取天气
  String _getWeatherFromClimate(String? climate) {
    switch (climate) {
      case 'Hot':
        return 'sunny';
      case 'Warm':
        return 'cloudy';
      case 'Cool':
        return 'rainy';
      case 'Cold':
        return 'snowy';
      default:
        return 'sunny';
    }
  }

  // 辅助方法:获取城市徽章
  String _getBadgeForCity(Map<String, dynamic> city) {
    final score = (city['overall_score'] as num?)?.toDouble() ?? 0;
    final price = (city['cost_of_living'] as num?)?.toDouble() ?? 0;

    if (score >= 4.7) return 'Popular';
    if (price < 1500) return 'Best Value';
    if (score >= 4.5) return 'Trending';
    return '';
  }

  // 辅助方法:计算生活成本评分
  double _calculateCostScore(num? cost) {
    if (cost == null) return 3.0;
    if (cost < 1000) return 5.0;
    if (cost < 1500) return 4.5;
    if (cost < 2000) return 4.0;
    if (cost < 3000) return 3.5;
    return 3.0;
  }

  // 辅助方法:计算网速评分
  double _calculateInternetScore(num? speed) {
    if (speed == null) return 3.0;
    if (speed >= 50) return 5.0;
    if (speed >= 30) return 4.5;
    if (speed >= 20) return 4.0;
    if (speed >= 10) return 3.5;
    return 3.0;
  }

  // 辅助方法:获取AQI等级
  String _getAqiLevel(int? aqi) {
    if (aqi == null) return '';
    if (aqi > 150) return '😷';
    if (aqi > 50) return '😷';
    return '';
  }

  // 辅助方法:格式化时间
  String _formatTime(String? isoTime) {
    if (isoTime == null) return '00:00';
    try {
      final dt = DateTime.parse(isoTime);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  // 旧的生成模拟数据方法(保留以防需要)
  void _generateMockData_deprecated() {
    final cities = [
      {
        'city': 'Bangkok',
        'country': 'Thailand',
        'region': 'Asia', // 地区
        'climate': 'Hot', // 气候
        'image':
            'https://images.unsplash.com/photo-1508009603885-50cf7c579365?w=400',
        'temperature': 32,
        'feelsLike': 41, // 体感温度
        'weather': 'sunny',
        'internet': 24,
        'price': 1561,
        'rank': 1,
        'badge': 'Popular', // 徽章：Popular, Best Value, Hidden Gem等
        'ratings': ['🔥', '🎉', '😊'],
        'overall': 4.8, // 改为5分制评分
        'cost': 4.9,
        'internetScore': 3.5,
        'liked': 4.0,
        'safety': 4.5,
        'aqi': 56, // 空气质量指数
        'aqiLevel': '😷', // 空气质量等级emoji
        'population': '10.5M',
        'timezone': 'GMT+7',
        'humidity': 75,
        'about':
            'Bangkok is a vibrant digital nomad hub with incredible food, affordable living, and a thriving expat community. Great coworking spaces and fast internet make it perfect for remote work.',
      },
      {
        'city': 'Chiang Mai',
        'country': 'Thailand',
        'region': 'Asia',
        'climate': 'Warm',
        'image':
            'https://images.unsplash.com/photo-1598970434795-0c54fe7c0648?w=400',
        'temperature': 29,
        'feelsLike': 35,
        'weather': 'cloudy',
        'internet': 20,
        'price': 1271,
        'rank': 2,
        'badge': 'Best Value',
        'ratings': ['☁️', '💪', '😊'],
        'overall': 4.6,
        'cost': 4.8,
        'internetScore': 3.2,
        'liked': 3.9,
        'safety': 4.7,
        'aqi': 252,
        'aqiLevel': '😷',
        'population': '1.2M',
        'timezone': 'GMT+7',
        'humidity': 68,
        'about':
            'Chiang Mai offers a perfect blend of affordability, nature, and digital nomad infrastructure. The Old City is filled with temples, cafes, and coworking spaces.',
      },
      {
        'city': 'Canggu, Bali',
        'country': 'Indonesia',
        'region': 'Asia',
        'climate': 'Hot',
        'image':
            'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
        'temperature': 27,
        'feelsLike': 30,
        'weather': 'sunny',
        'internet': 24,
        'price': 1896,
        'rank': 3,
        'badge': 'Trending',
        'ratings': ['🌴', '😍', '☺️'],
        'overall': 4.7,
        'cost': 4.5,
        'internetScore': 3.5,
        'liked': 4.8,
        'safety': 4.4,
        'aqi': 177,
        'aqiLevel': '😷',
        'population': '50K',
        'timezone': 'GMT+8',
        'humidity': 82,
        'about':
            'Surf, work, and wellness paradise. Canggu has become the ultimate digital nomad destination with amazing beaches, healthy food, and vibrant coworking scene.',
      },
      {
        'city': 'Tokyo',
        'country': 'Japan',
        'region': 'Asia',
        'climate': 'Mild',
        'image':
            'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
        'temperature': 23,
        'feelsLike': 23,
        'weather': 'cloudy',
        'internet': 27,
        'price': 3321,
        'rank': 4,
        'badge': '',
        'ratings': ['🏮', '🍜', '😊'],
        'overall': 4.2,
        'cost': 3.0,
        'internetScore': 4.0,
        'liked': 4.5,
        'safety': 5.0,
        'aqi': 38,
        'aqiLevel': '',
        'population': '14M',
        'timezone': 'GMT+9',
        'humidity': 65,
        'about':
            'Ultra-modern city with incredible infrastructure, safety, and food. Expensive but worth it for the unique culture and unmatched efficiency.',
      },
      {
        'city': 'Seoul',
        'country': 'South Korea',
        'region': 'Asia',
        'climate': 'Cool',
        'image':
            'https://images.unsplash.com/photo-1517154421773-0529f29ea451?w=400',
        'temperature': 18,
        'feelsLike': 19,
        'weather': 'rainy',
        'internet': 32,
        'price': 2519,
        'rank': 5,
        'badge': '',
        'ratings': ['🌃', '🎮', '😊'],
        'overall': 4.0,
        'cost': 3.8,
        'internetScore': 4.5,
        'liked': 4.2,
        'safety': 4.8,
        'aqi': 31,
        'aqiLevel': '',
        'population': '10M',
        'timezone': 'GMT+9',
        'humidity': 70,
        'about':
            'Tech-forward city with blazing fast internet, incredible food scene, and efficient public transport. Great for digital nomads who love urban energy.',
      },
      {
        'city': 'Lisbon',
        'country': 'Portugal',
        'region': 'Europe',
        'climate': 'Mild',
        'image':
            'https://images.unsplash.com/photo-1585208798174-6cedd86e019a?w=400',
        'temperature': 23,
        'feelsLike': 23,
        'weather': 'sunny',
        'internet': 28,
        'price': 3857,
        'rank': 6,
        'badge': 'Hot Spot',
        'ratings': ['🌉', '🍷', '😊'],
        'overall': 4.6,
        'cost': 3.2,
        'internetScore': 4.0,
        'liked': 4.7,
        'safety': 4.5,
        'aqi': 38,
        'aqiLevel': '',
        'population': '2.8M',
        'timezone': 'GMT+1',
        'humidity': 72,
        'about':
            'Beautiful coastal city with amazing weather, great food, and a booming startup scene. Perfect balance of European culture and beach lifestyle.',
      },
      {
        'city': 'Mexico City',
        'country': 'Mexico',
        'region': 'Americas',
        'climate': 'Mild',
        'image':
            'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=400',
        'temperature': 21,
        'feelsLike': 21,
        'weather': 'sunny',
        'internet': 13,
        'price': 2057,
        'rank': 7,
        'badge': '',
        'ratings': ['🌮', '🎨', '☺️'],
        'overall': 3.8,
        'cost': 4.2,
        'internetScore': 2.5,
        'liked': 4.0,
        'safety': 3.5,
        'aqi': 55,
        'aqiLevel': '😷',
        'population': '9M',
        'timezone': 'GMT-6',
        'humidity': 58,
        'about':
            'Vibrant cultural capital with incredible food, art, and nightlife. Large digital nomad community and affordable living, though internet can be spotty.',
      },
      {
        'city': 'Singapore',
        'country': 'Singapore',
        'region': 'Asia',
        'climate': 'Hot',
        'image':
            'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=400',
        'temperature': 31,
        'feelsLike': 37,
        'weather': 'sunny',
        'internet': 50,
        'price': 4520,
        'rank': 8,
        'badge': '',
        'ratings': ['🏙️', '🌟', '😊'],
        'overall': 4.3,
        'cost': 2.5,
        'internetScore': 5.0,
        'liked': 4.0,
        'safety': 5.0,
        'aqi': 25,
        'aqiLevel': '',
        'population': '5.7M',
        'timezone': 'GMT+8',
        'humidity': 85,
        'about':
            'Ultra-clean, safe, and efficient city-state with world-class infrastructure. Expensive but perfect for business-minded nomads.',
      },
    ];

    dataItems.value = cities;
  }

  // 生成 Meetup 模拟数据 - Nomads.com 风格
  void _generateMeetupData() {
    final now = DateTime.now();

    meetups.value = [
      {
        'id': 1,
        'city': 'Bangkok',
        'country': 'Thailand',
        'type': 'Drinks',
        'title': 'Digital Nomad Happy Hour',
        'venue': 'Octave Rooftop Bar',
        'date': now.add(const Duration(days: 2)),
        'time': '18:00',
        'attendees': 24,
        'maxAttendees': 30,
        'organizer': 'Sarah Chen',
        'organizerAvatar': 'https://i.pravatar.cc/150?img=1',
        'image':
            'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400',
        'description':
            'Join us for drinks and networking with fellow digital nomads in Bangkok!',
      },
      {
        'id': 2,
        'city': 'Chiang Mai',
        'country': 'Thailand',
        'type': 'Coworking',
        'title': 'Morning Coworking Session',
        'venue': 'Punspace Nimman',
        'date': now.add(const Duration(days: 3)),
        'time': '09:00',
        'attendees': 12,
        'maxAttendees': 20,
        'organizer': 'Alex Wong',
        'organizerAvatar': 'https://i.pravatar.cc/150?img=12',
        'image':
            'https://images.unsplash.com/photo-1497215728101-856f4ea42174?w=400',
        'description':
            'Start your day with focused work alongside other remote workers.',
      },
      {
        'id': 3,
        'city': 'Canggu, Bali',
        'country': 'Indonesia',
        'type': 'Activity',
        'title': 'Sunset Surf Session',
        'venue': 'Batu Bolong Beach',
        'date': now.add(const Duration(days: 4)),
        'time': '16:30',
        'attendees': 8,
        'maxAttendees': 15,
        'organizer': 'Mike Johnson',
        'organizerAvatar': 'https://i.pravatar.cc/150?img=33',
        'image':
            'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=400',
        'description':
            'Catch some waves and watch the sunset with the nomad community!',
      },
      {
        'id': 4,
        'city': 'Lisbon',
        'country': 'Portugal',
        'type': 'Dinner',
        'title': 'Portuguese Food Experience',
        'venue': 'Time Out Market',
        'date': now.add(const Duration(days: 5)),
        'time': '19:30',
        'attendees': 16,
        'maxAttendees': 20,
        'organizer': 'Emma Silva',
        'organizerAvatar': 'https://i.pravatar.cc/150?img=5',
        'image':
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
        'description':
            'Taste the best of Portuguese cuisine with fellow food lovers!',
      },
      {
        'id': 5,
        'city': 'Tokyo',
        'country': 'Japan',
        'type': 'Workshop',
        'title': 'Japanese Language Exchange',
        'venue': 'WeWork Shibuya',
        'date': now.add(const Duration(days: 6)),
        'time': '15:00',
        'attendees': 10,
        'maxAttendees': 15,
        'organizer': 'Yuki Tanaka',
        'organizerAvatar': 'https://i.pravatar.cc/150?img=47',
        'image':
            'https://images.unsplash.com/photo-1528164344705-47542687000d?w=400',
        'description':
            'Practice Japanese with locals and learn about the culture.',
      },
      {
        'id': 6,
        'city': 'Mexico City',
        'country': 'Mexico',
        'type': 'Networking',
        'title': 'Startup Founders Meetup',
        'venue': 'Curators',
        'date': now.add(const Duration(days: 7)),
        'time': '17:00',
        'attendees': 20,
        'maxAttendees': 25,
        'organizer': 'Carlos Rodriguez',
        'organizerAvatar': 'https://i.pravatar.cc/150?img=15',
        'image':
            'https://images.unsplash.com/photo-1511578314322-379afb476865?w=400',
        'description':
            'Connect with startup founders and entrepreneurs in CDMX.',
      },
      {
        'id': 7,
        'city': 'Bangkok',
        'country': 'Thailand',
        'type': 'Activity',
        'title': 'Temple Tour & Photography',
        'venue': 'Wat Pho',
        'date': now.add(const Duration(days: 8)),
        'time': '08:00',
        'attendees': 15,
        'maxAttendees': 20,
        'organizer': 'Lisa Park',
        'organizerAvatar': 'https://i.pravatar.cc/150?img=9',
        'image':
            'https://images.unsplash.com/photo-1563492065599-3520f775eeed?w=400',
        'description':
            'Explore Bangkok\'s beautiful temples with a local photographer.',
      },
      {
        'id': 8,
        'city': 'Seoul',
        'country': 'South Korea',
        'type': 'Drinks',
        'title': 'K-BBQ & Drinks Night',
        'venue': 'Gangnam District',
        'date': now.add(const Duration(days: 9)),
        'time': '19:00',
        'attendees': 18,
        'maxAttendees': 22,
        'organizer': 'Ji-woo Kim',
        'organizerAvatar': 'https://i.pravatar.cc/150?img=20',
        'image':
            'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=400',
        'description':
            'Experience authentic Korean BBQ and nightlife in Gangnam!',
      },
    ];
  }

  // RSVP to a meetup
  void toggleRSVP(int meetupId) {
    if (rsvpedMeetups.contains(meetupId)) {
      // Cancel RSVP
      rsvpedMeetups.remove(meetupId);
      final meetup = meetups.firstWhere((m) => m['id'] == meetupId);
      meetup['attendees'] = (meetup['attendees'] as int) - 1;
    } else {
      // Add RSVP
      rsvpedMeetups.add(meetupId);
      final meetup = meetups.firstWhere((m) => m['id'] == meetupId);
      meetup['attendees'] = (meetup['attendees'] as int) + 1;
    }
    meetups.refresh(); // 刷新列表
  }

  // 获取即将到来的meetups（下个月内）
  List<Map<String, dynamic>> get upcomingMeetups {
    final now = DateTime.now();
    final nextMonth = now.add(const Duration(days: 30));

    return meetups.where((meetup) {
      final date = meetup['date'] as DateTime;
      return date.isAfter(now) && date.isBefore(nextMonth);
    }).toList()
      ..sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
  }

  // 按城市过滤meetups
  List<Map<String, dynamic>> getMeetupsByCity(String city) {
    return upcomingMeetups.where((meetup) => meetup['city'] == city).toList();
  }

  // 切换视图
  void toggleView() {
    isGridView.value = !isGridView.value;
  }

  // 更改排序
  void changeSortBy(String newSort) {
    sortBy.value = newSort;
    _sortItems();
  }

  // 更新搜索查询
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // 排序数据
  void _sortItems() {
    final items = dataItems.toList();

    switch (sortBy.value) {
      case 'cost':
        items.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'internet':
        items.sort((a, b) => b['internet'].compareTo(a['internet']));
        break;
      case 'safety':
        items.sort((a, b) => b['safety'].compareTo(a['safety']));
        break;
      case 'popular':
      default:
        items.sort((a, b) => a['rank'].compareTo(b['rank']));
        break;
    }

    dataItems.value = items;
  }

  // 获取过滤后的数据 - 应用所有筛选条件
  List<Map<String, dynamic>> get filteredItems {
    var items = dataItems.toList();

    // 搜索筛选
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      items = items.where((item) {
        final city = item['city'].toString().toLowerCase();
        final country = item['country'].toString().toLowerCase();
        return city.contains(query) || country.contains(query);
      }).toList();
    }

    // 地区筛选
    if (selectedRegions.isNotEmpty) {
      items = items.where((item) {
        return selectedRegions.contains(item['region']);
      }).toList();
    }

    // 国家筛选
    if (selectedCountries.isNotEmpty) {
      items = items.where((item) {
        return selectedCountries.contains(item['country']);
      }).toList();
    }

    // 城市筛选
    if (selectedCities.isNotEmpty) {
      items = items.where((item) {
        return selectedCities.contains(item['city']);
      }).toList();
    }

    // 价格筛选
    items = items.where((item) {
      final price = item['price'] as int;
      return price >= minPrice.value && price <= maxPrice.value;
    }).toList();

    // 网速筛选
    items = items.where((item) {
      final internet = item['internet'] as int;
      return internet >= minInternet.value;
    }).toList();

    // 评分筛选
    items = items.where((item) {
      final rating = item['overall'] as double;
      return rating >= minRating.value;
    }).toList();

    // AQI筛选
    items = items.where((item) {
      final aqi = item['aqi'] as int;
      return aqi <= maxAqi.value;
    }).toList();

    // 气候筛选
    if (selectedClimates.isNotEmpty) {
      items = items.where((item) {
        return selectedClimates.contains(item['climate']);
      }).toList();
    }

    return items;
  }

  // 重置所有筛选
  void resetFilters() {
    selectedRegions.clear();
    selectedCountries.clear();
    selectedCities.clear();
    minPrice.value = 0.0;
    maxPrice.value = 5000.0;
    minInternet.value = 0.0;
    minRating.value = 0.0;
    maxAqi.value = 500;
    selectedClimates.clear();
  }

  // 检查是否有活动筛选
  bool get hasActiveFilters {
    return selectedRegions.isNotEmpty ||
        selectedCountries.isNotEmpty ||
        selectedCities.isNotEmpty ||
        minPrice.value > 0 ||
        maxPrice.value < 5000 ||
        minInternet.value > 0 ||
        minRating.value > 0 ||
        maxAqi.value < 500 ||
        selectedClimates.isNotEmpty;
  }

  // 刷新数据
  void refreshData() {
    initializeData();
  }

  // 创建新的 Meetup
  Future<void> createMeetup({
    required String title,
    required String city,
    required String country,
    required String type,
    required String venue,
    required DateTime date,
    required String time,
    required int maxAttendees,
    required String description,
    String? cityId,
    String? countryId,
    String? imageUrl,
    List<String>? images,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? tags,
  }) async {
    try {
      // 首先尝试使用新的 Events API
      await _createMeetupViaAPI({
        'title': title,
        'city': city,
        'country': country,
        'type': type,
        'venue': venue,
        'date': date,
        'time': time,
        'maxAttendees': maxAttendees,
        'description': description,
        'cityId': cityId,
        'countryId': countryId,
        'imageUrl': imageUrl,
        'images': images,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'tags': tags,
      });
    } catch (apiError) {
      print('⚠️ Events API failed, falling back to local storage: $apiError');

      // 如果 API 失败，回退到本地数据库存储
      await _createMeetupLocally({
        'title': title,
        'city': city,
        'country': country,
        'type': type,
        'venue': venue,
        'date': date,
        'time': time,
        'maxAttendees': maxAttendees,
        'description': description,
        'cityId': cityId,
        'countryId': countryId,
        'imageUrl': imageUrl,
      });
    }
  }

  /// 通过 Events API 创建活动
  Future<void> _createMeetupViaAPI(Map<String, dynamic> params) async {
    // 获取 Events API 服务
    final eventsApiService = _getEventsApiService();

    // 转换数据格式
    final eventData = _convertToEventData(params);

    // 调用 API
    final response = await eventsApiService.createEvent(eventData);

    // 更新内存中的列表
    final newMeetup = {
      'id': response['id'],
      'city': params['city'],
      'country': params['country'],
      'type': params['type'],
      'title': params['title'],
      'venue': params['venue'],
      'date': params['date'],
      'time': params['time'],
      'attendees': 1, // 创建者自动加入
      'maxAttendees': params['maxAttendees'],
      'cityId': params['cityId'],
      'countryId': params['countryId'],
      'organizer': 'You',
      'organizerAvatar': 'https://i.pravatar.cc/150?img=68',
      'image': params['imageUrl'] ??
          'https://images.unsplash.com/photo-1511578314322-379afb476865?w=400',
      'description': params['description'],
    };

    meetups.add(newMeetup);
    meetups.refresh();

    // 自动 RSVP (如果需要的话)
    final eventId = response['id'];
    if (eventId != null) {
      rsvpedMeetups.add(eventId is String
          ? int.tryParse(eventId) ?? eventId.hashCode
          : eventId);
    }

    AppToast.success(
      'Your meetup "${params['title']}" has been created successfully',
      title: 'Meetup Created!',
    );
  }

  /// 通过本地数据库创建活动（回退方案）
  Future<void> _createMeetupLocally(Map<String, dynamic> params) async {
    // 获取城市ID
    int? cityId;
    final providedCityId = params['cityId'];
    if (providedCityId is int) {
      cityId = providedCityId;
    } else if (providedCityId is String) {
      cityId = int.tryParse(providedCityId);
    }

    cityId ??= await _getCityIdByName(params['city']);
    if (cityId == null) {
      AppToast.error('City not found in database');
      return;
    }

    // 准备数据库数据
    final meetupData = {
      'title': params['title'],
      'description': params['description'],
      'city_id': cityId,
      'location': params['venue'],
      'start_time': (params['date'] as DateTime).toIso8601String(),
      'category': params['type'],
      'max_participants': params['maxAttendees'],
      'current_participants': 1, // 创建者自动加入
      'image_url': params['imageUrl'] ??
          'https://images.unsplash.com/photo-1511578314322-379afb476865?w=400',
      'status': 'upcoming',
      'organizer_id': 1, // TODO: 从当前用户获取
    };

    // 保存到数据库
    final newId = await _meetupService.createMeetup(meetupData);

    // 更新内存中的列表
    final newMeetup = {
      'id': newId,
      'city': params['city'],
      'country': params['country'],
      'type': params['type'],
      'title': params['title'],
      'venue': params['venue'],
      'date': params['date'],
      'time': params['time'],
      'attendees': 1, // 创建者自动加入
      'maxAttendees': params['maxAttendees'],
      'cityId': params['cityId'],
      'countryId': params['countryId'],
      'organizer': 'You', // 在实际应用中从用户资料获取
      'organizerAvatar': 'https://i.pravatar.cc/150?img=68',
      'image': params['imageUrl'] ??
          'https://images.unsplash.com/photo-1511578314322-379afb476865?w=400',
      'description': params['description'],
    };

    meetups.add(newMeetup);
    meetups.refresh();

    // 自动 RSVP
    rsvpedMeetups.add(newId);

    AppToast.success(
      'Your meetup "${params['title']}" has been created successfully (saved locally)',
      title: 'Meetup Created!',
    );
  }

  /// 获取 Events API 服务实例
  EventsApiService _getEventsApiService() {
    return EventsApiService();
  }

  /// 转换数据格式为 Events API 格式
  Map<String, dynamic> _convertToEventData(Map<String, dynamic> params) {
    // 组合日期和时间为完整的 DateTime
    final time = params['time'] as String;
    final date = params['date'] as DateTime;
    final timeParts = time.split(':');
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    return {
      'title': params['title'],
      'description': (params['description'] as String).isNotEmpty
          ? params['description']
          : null,
      'cityId': params['cityId'],
      'countryId': params['countryId'],
      'location': params['venue'],
      'address': params['address'],
      'imageUrl': params['imageUrl'],
      'images': params['images'] ?? [],
      'category': _mapTypeToCategory(params['type']),
      'startTime': startDateTime.toIso8601String(),
      'endTime': null, // 可以根据需要添加结束时间
      'maxParticipants': params['maxAttendees'],
      'locationType': 'physical', // 默认为实体活动
      'meetingLink': null, // 如果是线上活动可以添加
      'latitude': params['latitude'],
      'longitude': params['longitude'],
      'tags': params['tags'] ?? [],
    };
  }

  /// 将前端的 type 映射到后端的 category
  String _mapTypeToCategory(String type) {
    switch (type.toLowerCase()) {
      case 'drinks':
        return 'social';
      case 'coworking':
        return 'business';
      case 'dinner':
        return 'social';
      case 'activity':
        return 'other';
      case 'workshop':
        return 'tech';
      case 'networking':
        return 'business';
      default:
        return 'other';
    }
  }

  // 辅助方法:根据城市名称获取城市ID
  Future<int?> _getCityIdByName(String cityName) async {
    try {
      final cities = await _cityService.getAllCities();
      final city = cities.firstWhere(
        (c) => c['name'] == cityName,
        orElse: () => {},
      );
      return city['id'] as int?;
    } catch (e) {
      print('Error getting city ID: $e');
      return null;
    }
  }
}
