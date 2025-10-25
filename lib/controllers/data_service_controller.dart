import 'package:get/get.dart';

import '../models/city_option.dart';
import '../models/country_option.dart';
import '../services/data/city_data_service.dart';
import '../services/data/meetup_data_service.dart';
import '../services/events_api_service.dart';
import '../services/home_api_service.dart';
import '../services/location_api_service.dart';
import '../widgets/app_toast.dart';

class DataServiceController extends GetxController {
  // 数据服务
  final CityDataService _cityService = CityDataService();
  final MeetupDataService _meetupService = MeetupDataService();
  final LocationApiService _locationApiService = LocationApiService();
  final HomeApiService _homeApiService = HomeApiService();
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
      print('🔄 开始加载首页数据...');

      // 优先从 Home API 加载聚合数据
      try {
        await _loadFromHomeApi();
        print('✅ Home API 数据加载成功');
      } catch (apiError) {
        print('⚠️ Home API 失败，回退到本地数据库: $apiError');
        // 回退到本地数据库
        await loadCountries();
        await _loadCitiesFromDatabase();
        await _loadMeetupsFromDatabase();
      }
    } catch (e) {
      print('❌ 数据加载失败: $e');
      AppToast.error('数据加载失败，请稍后重试');
    } finally {
      isLoading.value = false;
    }
  }

  /// 从 Home API 加载聚合数据
  Future<void> _loadFromHomeApi() async {
    try {
      print('📡 调用 Home API...');

      // 调用 API
      final homeFeed = await _homeApiService.getHomeFeed(
        cityLimit: 20,
        meetupLimit: 30,
      );

      print(
          '✅ Home API 返回: ${homeFeed.cityCount} 城市, ${homeFeed.meetupCount} 活动');

      // 转换城市数据到 dataItems 格式（用于现有UI）
      print('📊 开始转换城市数据...');
      final convertedCities = <Map<String, dynamic>>[];

      for (var i = 0; i < homeFeed.cities.length; i++) {
        try {
          final city = homeFeed.cities[i];
          final weather = city.weather;

          convertedCities.add({
            'city': city.name,
            'country': city.country,
            'region': _guessRegion(city.country),
            'climate': _guessClimate(weather?.temperature),
            'image': city.imageUrl ??
                'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
            'temperature': weather?.temperature.toInt() ?? 25,
            'feelsLike': weather?.feelsLike.toInt() ?? 25,
            'weather': _getWeatherFromCode(weather?.weather),
            'internet': 20, // 默认值，后续可从其他API获取
            'price': 1500, // 默认值
            'rank': i + 1,
            'badge': city.meetupCount > 5 ? 'Popular' : '',
            'ratings': ['😊', '👍', '🌟'],
            'overall': 4.0,
            'cost': 4.0,
            'internetScore': 4.0,
            'liked': 4.0,
            'safety': 4.0,
            'aqi': weather?.airQualityIndex ?? 50,
            'aqiLevel': _getAqiLevel(weather?.airQualityIndex),
            'population': '1M',
            'timezone': 'GMT',
            'humidity': weather?.humidity ?? 70,
            'about': city.description ?? '',
          });
        } catch (e) {
          print('❌ 转换城市数据失败 [索引 $i]: $e');
          rethrow;
        }
      }

      dataItems.value = convertedCities;
      print('✅ 城市数据转换完成: ${dataItems.length} 条');

      // 转换活动数据到 meetups 格式（用于现有UI）
      print('📊 开始转换活动数据...');
      final convertedMeetups = <Map<String, dynamic>>[];

      for (var i = 0; i < homeFeed.meetups.length; i++) {
        try {
          final meetup = homeFeed.meetups[i];

          convertedMeetups.add({
            'id': meetup.id,
            'city': meetup.cityName ?? 'Unknown',
            'country': 'Unknown', // TODO: 从城市数据中查找
            'type': _guessMeetupType(meetup.title),
            'title': meetup.title,
            'venue': meetup.location,
            'date': meetup.startTime,
            'time': _formatTime(meetup.startTime.toIso8601String()),
            'attendees': meetup.participantCount,
            'maxAttendees': meetup.maxParticipants ?? 20,
            'organizer': meetup.creatorName ?? 'Organizer',
            'organizerAvatar': 'https://i.pravatar.cc/150?img=1',
            'image': meetup.imageUrl ??
                'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
            'description': meetup.description ?? '',
          });
        } catch (e) {
          print('❌ 转换活动数据失败 [索引 $i]: $e');
          rethrow;
        }
      }

      meetups.value = convertedMeetups;
      print('✅ 活动数据转换完成: ${meetups.length} 条');

      print('✅ 数据转换完成');
    } catch (e, stackTrace) {
      print('❌ Home API 加载失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 辅助方法: 根据国家猜测地区
  String _guessRegion(String country) {
    // 简单的地区映射
    const asianCountries = [
      'Thailand',
      'Vietnam',
      'Indonesia',
      'Japan',
      'China',
      'Singapore'
    ];
    const europeanCountries = [
      'Portugal',
      'Spain',
      'Italy',
      'France',
      'Germany',
      'UK'
    ];

    if (asianCountries.contains(country)) return 'Asia';
    if (europeanCountries.contains(country)) return 'Europe';
    return 'Asia';
  }

  /// 辅助方法: 根据温度猜测气候
  String _guessClimate(double? temperature) {
    if (temperature == null) return 'Warm';
    if (temperature > 30) return 'Hot';
    if (temperature > 20) return 'Warm';
    if (temperature > 10) return 'Mild';
    if (temperature > 0) return 'Cool';
    return 'Cold';
  }

  /// 辅助方法: 根据天气代码获取天气状态
  String _getWeatherFromCode(String? weather) {
    if (weather == null) return 'sunny';
    final w = weather.toLowerCase();
    if (w.contains('clear') || w.contains('sun')) return 'sunny';
    if (w.contains('cloud')) return 'cloudy';
    if (w.contains('rain')) return 'rainy';
    if (w.contains('snow')) return 'snowy';
    return 'sunny';
  }

  /// 辅助方法: 猜测活动类型
  String _guessMeetupType(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('drink') || lower.contains('beer')) return 'Drinks';
    if (lower.contains('cowork')) return 'Coworking';
    if (lower.contains('dinner') || lower.contains('lunch')) return 'Dinner';
    if (lower.contains('workshop')) return 'Workshop';
    if (lower.contains('network')) return 'Networking';
    return 'Activity';
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
    try {
      // 获取 Events API 服务
      final eventsApiService = _getEventsApiService();

      // 确保有城市ID - 如果没有提供则尝试查找
      String? cityId = params['cityId'];
      if (cityId == null || cityId.isEmpty) {
        final cityName = params['city'] as String?;
        if (cityName != null && cityName.isNotEmpty) {
          // 尝试从已加载的城市列表中查找
          CityOption? matchedCity;
          for (final cityList in citiesByCountry.values) {
            for (final city in cityList) {
              if (city.name.toLowerCase() == cityName.toLowerCase()) {
                matchedCity = city;
                break;
              }
            }
            if (matchedCity != null) break;
          }

          if (matchedCity != null) {
            cityId = matchedCity.id;
            print('✅ 找到匹配的城市ID: $cityId for $cityName');
          } else {
            print('⚠️ 未找到城市 $cityName 的ID，将以null提交');
          }
        }
      }

      // 转换数据格式
      final eventData = _convertToEventData(params);
      // 更新城市ID
      if (cityId != null && cityId.isNotEmpty) {
        eventData['cityId'] = cityId;
      } else {
        eventData['cityId'] = null;
      }

      print('📤 正在创建活动: ${eventData['title']}');
      print('📍 城市ID: ${eventData['cityId']}');
      print('� 城市ID类型: ${eventData['cityId'].runtimeType}');
      print('�📅 开始时间: ${eventData['startTime']}');
      print('📊 完整请求数据: $eventData');

      // 调用 API
      final apiResponse = await eventsApiService.createEvent(eventData);

      print('✅ Events API 响应成功');

      // 从响应中提取数据
      final responseData =
          apiResponse['data'] as Map<String, dynamic>? ?? apiResponse;

      final eventId = responseData['id'];
      print('✅ Event ID: $eventId');

      // 持久化到本地数据库以便离线访问
      await _persistMeetupSnapshot(responseData, params);

      // 更新内存中的列表
      final newMeetup = {
        'id': eventId,
        'city': params['city'],
        'country': params['country'],
        'type': params['type'],
        'title': params['title'],
        'venue': params['venue'],
        'date': params['date'],
        'time': params['time'],
        'attendees': responseData['currentParticipants'] ?? 1,
        'maxAttendees': params['maxAttendees'],
        'cityId': cityId,
        'countryId': params['countryId'],
        'organizer': 'You',
        'organizerAvatar': 'https://i.pravatar.cc/150?img=68',
        'image': responseData['imageUrl'] ??
            params['imageUrl'] ??
            'https://images.unsplash.com/photo-1511578314322-379afb476865?w=400',
        'description': params['description'],
        'status': responseData['status'] ?? 'upcoming',
      };

      meetups.add(newMeetup);
      meetups.refresh();

      // 自动 RSVP (因为创建者自动成为参与者)
      if (eventId != null) {
        final eventIdInt = eventId is String
            ? int.tryParse(eventId) ?? eventId.hashCode
            : (eventId is int ? eventId : eventId.hashCode);
        rsvpedMeetups.add(eventIdInt);
      }

      AppToast.success(
        'Your meetup "${params['title']}" has been created successfully',
        title: 'Meetup Created!',
      );
    } catch (e) {
      print('❌ Events API 创建失败: $e');
      // 重新抛出异常以便上层捕获并回退到本地存储
      rethrow;
    }
  }

  /// 将远程创建的 meetup 同步保存到本地数据库
  Future<void> _persistMeetupSnapshot(
    Map<String, dynamic> responseData,
    Map<String, dynamic> originalParams,
  ) async {
    try {
      // 获取城市ID
      int? cityIdInt;
      final cityId = originalParams['cityId'];
      if (cityId is int) {
        cityIdInt = cityId;
      } else if (cityId is String) {
        cityIdInt = int.tryParse(cityId);
      }

      // 如果还是没有城市ID,尝试从城市名称查找
      cityIdInt ??= await _ensureCityIdForLocalMeetup(originalParams['city']);
      if (cityIdInt == null) {
        print('⚠️ 无法获取城市ID,跳过本地持久化');
        return;
      }

      // 准备数据库数据
      final meetupData = {
        'title': originalParams['title'],
        'description': originalParams['description'] ?? '',
        'city_id': cityIdInt,
        'location': originalParams['venue'],
        'start_time': responseData['startTime'] ??
            (originalParams['date'] as DateTime).toIso8601String(),
        'category': originalParams['type'],
        'max_participants': originalParams['maxAttendees'],
        'current_participants': responseData['currentParticipants'] ?? 1,
        'image_url': responseData['imageUrl'] ??
            originalParams['imageUrl'] ??
            'https://images.unsplash.com/photo-1511578314322-379afb476865?w=400',
        'status': responseData['status'] ?? 'upcoming',
        'organizer_id': 1, // TODO: 从当前用户获取
        'remote_id': responseData['id']?.toString(), // 保存远程ID以便后续同步
      };

      // 保存到数据库
      await _meetupService.createMeetup(meetupData);
      print('✅ Meetup 已同步到本地数据库');
    } catch (e) {
      print('⚠️ 保存到本地数据库失败,但远程创建成功: $e');
      // 不抛出异常,因为远程创建已经成功
    }
  }

  /// 确保本地有城市ID,如果没有则创建占位符
  Future<int?> _ensureCityIdForLocalMeetup(String? cityName) async {
    if (cityName == null || cityName.isEmpty) {
      return null;
    }

    try {
      // 先尝试从数据库查找
      final existingCityId = await _getCityIdByName(cityName);
      if (existingCityId != null) {
        return existingCityId;
      }

      // 如果找不到,返回null让上层处理
      print('⚠️ 本地数据库中未找到城市: $cityName');
      return null;
    } catch (e) {
      print('❌ 查找城市ID失败: $e');
      return null;
    }
  }

  /// 通过本地数据库创建活动（回退方案）
  Future<void> _createMeetupLocally(Map<String, dynamic> params) async {
    try {
      // 获取城市ID
      int? cityId;
      final providedCityId = params['cityId'];
      if (providedCityId is int) {
        cityId = providedCityId;
      } else if (providedCityId is String && providedCityId.isNotEmpty) {
        cityId = int.tryParse(providedCityId);
      }

      // 如果没有城市ID,尝试从城市名称查找
      cityId ??= await _ensureCityIdForLocalMeetup(params['city']);
      if (cityId == null) {
        AppToast.error('City not found in database. Please try again.');
        return;
      }

      // 组合日期和时间
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

      // 处理图片
      String mainImageUrl = params['imageUrl'] as String? ?? '';
      if (mainImageUrl.isEmpty) {
        final images = params['images'];
        if (images is List && images.isNotEmpty) {
          mainImageUrl = images.first.toString();
        }
      }
      if (mainImageUrl.isEmpty) {
        mainImageUrl =
            'https://images.unsplash.com/photo-1511578314322-379afb476865?w=400';
      }

      // 准备数据库数据
      final meetupData = {
        'title': params['title'],
        'description': params['description'] ?? '',
        'city_id': cityId,
        'location': params['venue'],
        'start_time': startDateTime.toIso8601String(),
        'category': params['type'],
        'max_participants': params['maxAttendees'],
        'current_participants': 1, // 创建者自动加入
        'image_url': mainImageUrl,
        'status': 'upcoming',
        'organizer_id': 1, // TODO: 从当前用户获取
      };

      print('💾 保存到本地数据库: ${meetupData['title']}');

      // 保存到数据库
      final newId = await _meetupService.createMeetup(meetupData);

      print('✅ 本地数据库保存成功，ID: $newId');

      // 更新内存中的列表
      final newMeetup = {
        'id': newId,
        'city': params['city'],
        'country': params['country'] ?? 'Unknown',
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
        'image': mainImageUrl,
        'description': params['description'] ?? '',
        'status': 'upcoming',
      };

      meetups.add(newMeetup);
      meetups.refresh();

      // 自动 RSVP
      rsvpedMeetups.add(newId);

      AppToast.success(
        'Your meetup "${params['title']}" has been created successfully (saved locally)',
        title: 'Meetup Created!',
      );
    } catch (e) {
      print('❌ 本地保存失败: $e');
      AppToast.error(
        'Failed to create meetup: ${e.toString()}',
        title: 'Error',
      );
      rethrow;
    }
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

    // 准备图片数据
    List<String> imagesList = [];
    if (params['images'] != null) {
      final images = params['images'];
      if (images is List) {
        imagesList = images.map((img) => img.toString()).toList();
      }
    }

    // 第一张图片作为主图
    String? mainImageUrl = params['imageUrl'] as String?;
    if ((mainImageUrl == null || mainImageUrl.isEmpty) &&
        imagesList.isNotEmpty) {
      mainImageUrl = imagesList.first;
    }

    // 构建标准的 Events API 请求体
    final eventData = <String, dynamic>{
      'title': params['title'],
      'description': (params['description'] as String?)?.isNotEmpty == true
          ? params['description']
          : null,
      'location': params['venue'],
      'address': params['address'],
      'category': _mapTypeToCategory(params['type']),
      'startTime': startDateTime.toUtc().toIso8601String(),
      'endTime': null, // 可以根据需要添加结束时间
      'maxParticipants': params['maxAttendees'],
      'locationType': 'physical', // 默认为实体活动
      'meetingLink': null,
    };

    // 只在有值时添加可选字段
    final cityIdValue = params['cityId'];
    if (cityIdValue != null &&
        cityIdValue is String &&
        cityIdValue.isNotEmpty &&
        cityIdValue.contains('-')) {
      // 确保是有效的 GUID 格式（包含至少一个'-'符号）
      eventData['cityId'] = cityIdValue;
    } else {
      // 如果 cityId 无效，传递 null
      eventData['cityId'] = null;
    }

    if (mainImageUrl != null && mainImageUrl.isNotEmpty) {
      eventData['imageUrl'] = mainImageUrl;
    }

    if (imagesList.isNotEmpty) {
      eventData['images'] = imagesList;
    }

    if (params['latitude'] != null) {
      eventData['latitude'] = params['latitude'];
    }

    if (params['longitude'] != null) {
      eventData['longitude'] = params['longitude'];
    }

    if (params['tags'] != null && (params['tags'] as List).isNotEmpty) {
      eventData['tags'] = params['tags'];
    }

    return eventData;
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
