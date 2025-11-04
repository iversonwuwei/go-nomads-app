import 'package:get/get.dart';

import '../models/city_option.dart';
import '../models/country_option.dart';
import '../services/city_api_service.dart';
import '../services/events_api_service.dart';
import '../services/location_api_service.dart';
import '../widgets/app_toast.dart';
import 'user_state_controller.dart';

class DataServiceController extends GetxController {
  // 数据服务
  final LocationApiService _locationApiService = LocationApiService();
  final EventsApiService _eventsApiService = EventsApiService();
  final CityApiService _cityApiService = CityApiService();

  // 响应式数据 - 拆分加载状态
  final RxBool isLoading = true.obs; // 整体加载状态
  final RxBool isLoadingCities = false.obs; // 城市列表加载状态
  final RxBool isLoadingMeetups = false.obs; // 活动列表加载状态
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
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

  /// 检查用户是否已登录，如果未登录则显示提示并返回 false
  bool _requireLogin({String? action}) {
    try {
      final userStateController = Get.find<UserStateController>();
      if (!userStateController.isLoggedIn) {
        final actionText = action ?? '此操作';
        AppToast.warning('请先登录后再进行$actionText');
        // 可选：跳转到登录页面
        // Get.toNamed('/login');
        return false;
      }
      return true;
    } catch (e) {
      print('⚠️ 获取用户登录状态失败: $e');
      AppToast.warning('请先登录');
      return false;
    }
  }

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

    // 监听登录状态变化，登录成功后重新加载数据
    _setupLoginStateListener();
  }

  /// 设置登录状态监听器
  void _setupLoginStateListener() {
    try {
      final userStateController = Get.find<UserStateController>();

      // 监听登录状态变化
      ever(userStateController.loginStateChanged, (_) {
        if (userStateController.isLoggedIn) {
          print('🔔 检测到用户登录，重新加载所有数据...');
          refreshAllData();
        } else {
          print('🔔 检测到用户登出，清空数据...');
          _clearData();
        }
      });

      print('✅ 登录状态监听器已设置');
    } catch (e) {
      print('⚠️ 设置登录状态监听器失败: $e');
    }
  }

  /// 清空数据（登出时调用）
  void _clearData() {
    meetups.clear();
    dataItems.clear();
    countries.clear();
    print('✅ 数据已清空');
  }

  /// 刷新所有数据(登录成功时调用)
  Future<void> refreshAllData() async {
    print('🔄 开始刷新所有数据...');

    // 并行加载城市和活动数据,提高性能
    await Future.wait([
      refreshCities(),
      refreshMeetups(),
    ]);

    print('✅ 所有数据刷新完成');
  }

  /// 刷新城市列表(独立刷新)
  Future<void> refreshCities() async {
    print('🔄 刷新城市列表...');
    isLoadingCities.value = true;

    try {
      await _loadCitiesFromApi();
      print('✅ 城市列表刷新成功');
    } catch (e) {
      print('❌ 城市列表刷新失败: $e');
      AppToast.error('城市列表刷新失败');
    } finally {
      isLoadingCities.value = false;
    }
  }

  /// 搜索城市(从后端获取)
  Future<void> searchCities(String searchKeyword) async {
    if (searchKeyword.trim().isEmpty) {
      // 如果搜索关键词为空,重新加载所有城市
      await refreshCities();
      return;
    }

    print('🔍 搜索城市: $searchKeyword');
    isLoadingCities.value = true;

    try {
      final response = await _cityApiService.getCities(
        page: 1,
        pageSize: 100, // 搜索时加载更多结果
        search: searchKeyword,
      );

      final data = response['items'] ?? response['data'] ?? [];
      final cities = data is List ? data : [];

      print('✅ CityService 返回: ${cities.length} 城市');

      // 转换城市数据
      final convertedCities = <Map<String, dynamic>>[];

      for (var i = 0; i < cities.length; i++) {
        try {
          final city = cities[i] as Map<String, dynamic>;

          // 处理 weather 字段 - 可能是字符串或对象(WeatherDto)
          String weatherStr = 'sunny';
          int temperature = 25;
          int feelsLike = 25;

          final weatherData = city['weather'];
          if (weatherData is String) {
            weatherStr = weatherData;
          } else if (weatherData is Map<String, dynamic>) {
            // WeatherDto 对象
            weatherStr = weatherData['weather'] ??
                weatherData['weatherDescription'] ??
                weatherData['description'] ??
                weatherData['main'] ??
                weatherData['condition'] ??
                'sunny';

            // 提取温度 - Weather对象中的 temperature 字段
            if (weatherData['temperature'] != null) {
              temperature = (weatherData['temperature'] is int)
                  ? weatherData['temperature']
                  : (weatherData['temperature'] as num).toInt();
            }

            // 提取体感温度
            if (weatherData['feelsLike'] != null) {
              feelsLike = (weatherData['feelsLike'] is int)
                  ? weatherData['feelsLike']
                  : (weatherData['feelsLike'] as num).toInt();
            }
          }

          convertedCities.add({
            'id': city['id']?.toString() ?? '',
            'city': city['name'] ?? 'Unknown',
            'country': city['country'] ?? 'Unknown',
            'region': _guessRegion(city['country'] ?? 'Unknown'),
            'climate': _guessClimate(temperature.toDouble()),
            'image': city['imageUrl'] ??
                'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
            'temperature': temperature,
            'feelsLike': feelsLike,
            'weather': weatherStr,
            'internet': city['internetSpeed']?.toInt() ?? 20,
            'price': city['averageCost']?.toInt() ?? 1500,
            'rank': i + 1,
            'badge': (city['meetupCount'] ?? 0) > 5 ? 'Popular' : '',
            'ratings': ['😊', '👍', '🌟'],
            'overall': city['overallScore']?.toDouble() ?? 4.0,
            'cost': city['costScore']?.toDouble() ?? 4.0,
            'internetScore': city['internetScore']?.toDouble() ?? 4.0,
            'liked': city['likedScore']?.toDouble() ?? 4.0,
            'safety': city['safetyScore']?.toDouble() ?? 4.0,
            'aqi': city['airQualityIndex']?.toInt() ?? 50,
            'aqiLevel': _getAqiLevel(city['airQualityIndex']?.toInt()),
            'population': city['population'] ?? '1M',
            'timezone': city['timezone'] ?? 'GMT',
            'humidity': city['humidity']?.toInt() ?? 70,
            'about': city['description'] ?? '',
          });
        } catch (e) {
          print('❌ 转换城市数据失败 [索引 $i]: $e');
        }
      }

      dataItems.value = convertedCities;

      if (convertedCities.isEmpty) {
        AppToast.info('未找到匹配的城市');
      } else {
        AppToast.success('找到 ${convertedCities.length} 个城市');
      }

      print('✅ 城市搜索完成: ${convertedCities.length} 条');
    } catch (e) {
      print('❌ 城市搜索失败: $e');
      AppToast.error('搜索失败,请重试');
    } finally {
      isLoadingCities.value = false;
    }
  }

  /// 刷新活动列表(独立刷新)
  Future<void> refreshMeetups() async {
    print('🔄 刷新活动列表...');
    isLoadingMeetups.value = true;

    try {
      await _loadMeetupsFromApi();
      print('✅ 活动列表刷新成功');
    } catch (e) {
      print('❌ 活动列表刷新失败: $e');
      AppToast.error('活动列表刷新失败');
    } finally {
      isLoadingMeetups.value = false;
    }
  }

  // 初始化数据
  void initializeData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    // 设置独立加载状态
    isLoadingCities.value = true;
    isLoadingMeetups.value = true;

    try {
      print('🔄 开始加载首页数据...');

      // 并行加载城市和活动数据
      await Future.wait([
        _loadCitiesFromApi(),
        _loadMeetupsFromApi(),
      ]);

      print('✅ 首页数据加载成功');
    } catch (e) {
      print('❌ 数据加载失败: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
      AppToast.error('数据加载失败');
    } finally {
      isLoading.value = false;
      isLoadingCities.value = false;
      isLoadingMeetups.value = false;
    }
  }

  /// 从 CityService 加载城市列表
  Future<void> _loadCitiesFromApi() async {
    try {
      print('📡 调用 CityService API...');

      // 调用 CityApiService 获取城市列表
      final cityData = await _cityApiService.getCities(
        page: 1,
        pageSize: 20,
      );

      // 提取城市列表
      final cities = cityData['items'] as List<dynamic>? ?? [];

      print('✅ CityService 返回: ${cities.length} 城市');

      // 转换城市数据
      final convertedCities = <Map<String, dynamic>>[];

      for (var i = 0; i < cities.length; i++) {
        try {
          final city = cities[i] as Map<String, dynamic>;

          // 处理 weather 字段 - 可能是字符串或对象(WeatherDto)
          String weatherStr = 'sunny';
          int temperature = 25;
          int feelsLike = 25;

          final weatherData = city['weather'];
          if (weatherData is String) {
            weatherStr = weatherData;
          } else if (weatherData is Map<String, dynamic>) {
            // WeatherDto 对象
            weatherStr = weatherData['weather'] ??
                weatherData['weatherDescription'] ??
                weatherData['description'] ??
                weatherData['main'] ??
                weatherData['condition'] ??
                'sunny';

            // 提取温度 - Weather对象中的 temperature 字段
            if (weatherData['temperature'] != null) {
              temperature = (weatherData['temperature'] is int)
                  ? weatherData['temperature']
                  : (weatherData['temperature'] as num).toInt();
            }

            // 提取体感温度
            if (weatherData['feelsLike'] != null) {
              feelsLike = (weatherData['feelsLike'] is int)
                  ? weatherData['feelsLike']
                  : (weatherData['feelsLike'] as num).toInt();
            }
          }

          convertedCities.add({
            'id': city['id']?.toString() ?? '',
            'city': city['name'] ?? 'Unknown',
            'country': city['country'] ?? 'Unknown',
            'region': _guessRegion(city['country'] ?? 'Unknown'),
            'climate': _guessClimate(temperature.toDouble()),
            'image': city['imageUrl'] ??
                'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
            'temperature': temperature,
            'feelsLike': feelsLike,
            'weather': weatherStr,
            'internet': city['internetSpeed']?.toInt() ?? 20,
            'price': city['averageCost']?.toInt() ?? 1500,
            'rank': i + 1,
            'badge': (city['meetupCount'] ?? 0) > 5 ? 'Popular' : '',
            'ratings': ['😊', '👍', '🌟'],
            'overall': city['overallScore']?.toDouble() ?? 4.0,
            'cost': city['costScore']?.toDouble() ?? 4.0,
            'internetScore': city['internetScore']?.toDouble() ?? 4.0,
            'liked': city['likedScore']?.toDouble() ?? 4.0,
            'safety': city['safetyScore']?.toDouble() ?? 4.0,
            'aqi': city['airQualityIndex']?.toInt() ?? 50,
            'aqiLevel': _getAqiLevel(city['airQualityIndex']?.toInt()),
            'population': city['population'] ?? '1M',
            'timezone': city['timezone'] ?? 'GMT',
            'humidity': city['humidity']?.toInt() ?? 70,
            'about': city['description'] ?? '',
          });
        } catch (e) {
          print('❌ 转换城市数据失败 [索引 $i]: $e');
          // 继续处理其他城市,不中断整个流程
        }
      }

      dataItems.value = convertedCities;
      print('✅ 城市数据加载完成: ${dataItems.length} 条');
    } catch (e, stackTrace) {
      print('❌ CityService 加载失败: $e');
      print('   堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 从 EventService 加载活动列表
  Future<void> _loadMeetupsFromApi() async {
    try {
      print('📡 调用 EventService API...');

      // 调用 EventsApiService 获取活动列表
      // requireAuth: false 表示允许未登录用户查看活动列表
      final eventData = await _eventsApiService.getEvents(
        status: 'upcoming', // 只获取即将到来的活动
        page: 1,
        pageSize: 20,
        requireAuth: false, // 不强制要求认证
      );

      // 提取活动列表
      final events = eventData['items'] as List<dynamic>? ?? [];

      print('✅ EventService 返回: ${events.length} 活动');

      // 转换活动数据
      final convertedMeetups = <Map<String, dynamic>>[];

      for (var i = 0; i < events.length; i++) {
        try {
          final event = events[i] as Map<String, dynamic>;

          // 解析开始时间
          DateTime? startTime;
          try {
            final startTimeStr = event['startTime']?.toString();
            if (startTimeStr != null) {
              startTime = DateTime.parse(startTimeStr);
            }
          } catch (e) {
            print('⚠️ 解析活动开始时间失败: $e');
          }
          startTime ??= DateTime.now();

          // 处理 organizer 字段 - 可能是字符串或对象
          String organizerName = 'Organizer';
          final organizerData = event['organizer'];
          if (organizerData is String) {
            organizerName = organizerData;
          } else if (organizerData is Map<String, dynamic>) {
            // 如果是对象,尝试提取名称字段
            organizerName = organizerData['name'] ??
                organizerData['username'] ??
                organizerData['displayName'] ??
                'Organizer';
          }
          // 优先使用 creatorName 字段
          organizerName = event['creatorName'] ?? organizerName;

          convertedMeetups.add({
            'id': event['id'],
            'city': event['cityName'] ?? event['city'] ?? 'Unknown',
            'country': 'Unknown', // TODO: 从城市数据中查找
            'type': _guessMeetupType(event['title'] ?? ''),
            'title': event['title'] ?? 'Unknown Event',
            'venue': event['location'] ?? '',
            'date': startTime,
            'time': _formatTime(startTime.toIso8601String()),
            'attendees': event['participantCount'] ?? 0,
            'maxAttendees': event['maxParticipants'] ?? 20,
            'organizer': organizerName,
            'organizerAvatar': 'https://i.pravatar.cc/150?img=1',
            'image': event['imageUrl'] ??
                'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
            'description': event['description'] ?? '',
            'isParticipant': event['isParticipant'] ?? false,
          });
        } catch (e) {
          print('❌ 转换活动数据失败 [索引 $i]: $e');
          // 继续处理其他活动,不中断整个流程
        }
      }

      meetups.value = convertedMeetups;
      print('✅ 活动数据加载完成: ${meetups.length} 条');
    } catch (e, stackTrace) {
      print('❌ EventService 加载失败: $e');
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

  // 辅助方法:获取AQI等级
  String _getAqiLevel(int? aqi) {
    if (aqi == null || aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  // 旧的生成模拟数据方法(保留以防需要)

  // RSVP to a meetup
  void toggleRSVP(int meetupId) {
    // 检查登录状态
    if (!_requireLogin(action: 'RSVP活动')) {
      return;
    }

    if (rsvpedMeetups.contains(meetupId)) {
      // Cancel RSVP
      rsvpedMeetups.remove(meetupId);
      // 尝试更新 meetups 列表中的 attendees（如果存在）
      try {
        final meetup = meetups.firstWhere(
          (m) {
            final mId = m['id'];
            if (mId is int) {
              return mId == meetupId;
            } else if (mId is String) {
              return int.tryParse(mId) == meetupId;
            }
            return false;
          },
        );
        meetup['attendees'] = (meetup['attendees'] as int) - 1;
        meetups.refresh(); // 刷新列表
      } catch (e) {
        // meetup 不在列表中，跳过更新（使用本地状态）
        print('⚠️ Meetup $meetupId 不在 controller.meetups 中，使用本地状态');
      }
    } else {
      // Add RSVP
      rsvpedMeetups.add(meetupId);
      // 尝试更新 meetups 列表中的 attendees（如果存在）
      try {
        final meetup = meetups.firstWhere(
          (m) {
            final mId = m['id'];
            if (mId is int) {
              return mId == meetupId;
            } else if (mId is String) {
              return int.tryParse(mId) == meetupId;
            }
            return false;
          },
        );
        meetup['attendees'] = (meetup['attendees'] as int) + 1;
        meetups.refresh(); // 刷新列表
      } catch (e) {
        // meetup 不在列表中，跳过更新（使用本地状态）
        print('⚠️ Meetup $meetupId 不在 controller.meetups 中，使用本地状态');
      }
    }
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
    // 检查登录状态
    if (!_requireLogin(action: '创建活动')) {
      return;
    }

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
      print('❌ Events API failed: $apiError');
      AppToast.error(
        'Failed to create meetup. Please check your connection and try again.',
        title: 'Error',
      );
      rethrow;
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
      // 显示错误信息
      AppToast.error(
        'Failed to create meetup. Please check your connection and try again.',
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
}
