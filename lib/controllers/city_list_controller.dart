import 'package:get/get.dart';

import '../services/cities_api_service.dart';
import '../widgets/app_toast.dart';

/// 城市列表页面专用控制器
/// 负责管理城市列表的数据加载、筛选和分页
class CityListController extends GetxController {
  final CitiesApiService _citiesApiService = CitiesApiService();

  // 响应式数据
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> cities = <Map<String, dynamic>>[].obs;

  // 分页控制
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  List<Map<String, dynamic>> _allCities = []; // 缓存所有城市数据

  // 筛选状态
  final RxString searchQuery = ''.obs;
  final RxList<String> selectedRegions = <String>[].obs;
  final RxList<String> selectedCountries = <String>[].obs;
  final RxList<String> selectedCities = <String>[].obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 5000.0.obs;
  final RxDouble minInternet = 0.0.obs;
  final RxDouble minRating = 0.0.obs;
  final RxInt maxAqi = 500.obs;
  final RxList<String> selectedClimates = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialCities();
  }

  /// 初始加载城市数据 (第一页 20 条)
  Future<void> loadInitialCities() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    _currentPage = 0;
    _hasMoreData = true;
    cities.clear();
    _allCities.clear();

    try {
      print('📡 城市列表页: 开始加载初始城市数据...');

      // 从 API 加载所有数据到缓存
      await _loadAllCitiesToCache();

      // 检查是否成功加载数据
      if (_allCities.isEmpty) {
        throw Exception('未能加载任何城市数据');
      }

      // 只显示第一页
      _loadNextPage();

      print('✅ 初始城市数据加载完成: ${cities.length} 条');
    } catch (e) {
      print('❌ 加载初始城市数据失败: $e');
      print('   错误堆栈: ${StackTrace.current}');
      hasError.value = true;
      errorMessage.value = e.toString();
      AppToast.error('加载城市数据失败');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载所有城市到缓存
  Future<void> _loadAllCitiesToCache() async {
    // 使用 CitiesApiService 加载城市列表
    // 注意: HttpService 会自动解包 API 响应的 data 字段
    final data = await _citiesApiService.getCities(
      page: 1,
      pageSize: 1000, // 一次性加载所有城市到缓存
    );

    // data 已经是解包后的数据,包含 items, totalCount 等字段
    print('🔍 API 响应数据结构: ${data.keys}');

    final items = data['items'] as List<dynamic>? ?? [];
    print('✅ Cities API 返回: ${items.length} 城市');

    // 转换城市数据到缓存
    _allCities = [];

    for (var i = 0; i < items.length; i++) {
      try {
        final city = items[i] as Map<String, dynamic>;
        final weather = city['weather'] as Map<String, dynamic>?;

        // 打印前几个城市的数据用于调试
        if (i < 3) {
          print('🔍 城市[$i] 数据: id=${city['id']}, name=${city['name']}');
        }

        _allCities.add({
          'id': city['id'], // ✅ 使用 API 返回的城市 ID (UUID)
          'city': city['name'] ?? 'Unknown',
          'country': city['country'] ?? 'Unknown',
          'region': _guessRegion(city['country'] ?? 'Unknown'),
          'climate': _guessClimate(weather?['temperature']?.toDouble()),
          'image': city['imageUrl'] ??
              'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
          'temperature': weather?['temperature']?.toInt() ?? 25,
          'feelsLike': weather?['feelsLike']?.toInt() ?? 25,
          'weather': _getWeatherFromCode(weather?['weather']?.toString()),
          'internet': 20,
          'price': 1500,
          'rank': i + 1,
          'badge': (city['meetupCount'] ?? 0) > 5 ? 'Popular' : '',
          'ratings': ['😊', '👍', '🌟'],
          'overall': 4.0,
          'cost': 4.0,
          'internetScore': 4.0,
          'liked': 4.0,
          'safety': 4.0,
          'aqi': weather?['airQualityIndex']?.toInt() ?? 50,
          'aqiLevel': _getAqiLevel(weather?['airQualityIndex']?.toInt()),
          'population': '1M',
          'timezone': 'GMT',
          'humidity': weather?['humidity']?.toInt() ?? 70,
          'about': city['description'] ?? '',
          'reviews': 0, // 默认值，实际数据从详情页加载
        });
      } catch (e) {
        print('❌ 转换城市数据失败 [索引 $i]: $e');
        print('   城市数据: ${items[i]}');
        // 继续处理下一个城市
      }
    }

    print('✅ 缓存了 ${_allCities.length} 个城市');
  }

  /// 加载下一页数据 (20 条)
  void _loadNextPage() {
    final startIndex = _currentPage * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex >= _allCities.length) {
      _hasMoreData = false;
      print('📊 没有更多数据了');
      return;
    }

    final nextPageCities = _allCities.sublist(
      startIndex,
      endIndex > _allCities.length ? _allCities.length : endIndex,
    );

    cities.addAll(nextPageCities);
    _currentPage++;

    if (endIndex >= _allCities.length) {
      _hasMoreData = false;
    }

    print(
        '📊 加载第 $_currentPage 页: ${nextPageCities.length} 条 (总共: ${cities.length}/${_allCities.length})');
  }

  /// 加载更多城市 (滚动到底部时调用)
  Future<void> loadMoreCities() async {
    if (isLoadingMore.value || !_hasMoreData) {
      return;
    }

    isLoadingMore.value = true;

    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 300));

      _loadNextPage();
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 检查是否还有更多数据
  bool get hasMoreData => _hasMoreData;

  /// 获取总城市数量(缓存中的所有城市)
  int get totalCitiesCount => _allCities.length;

  /// 获取筛选后的城市列表
  List<Map<String, dynamic>> get filteredCities {
    var items = cities.toList();

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
      items = items
          .where((item) => selectedRegions.contains(item['region']))
          .toList();
    }

    // 国家筛选
    if (selectedCountries.isNotEmpty) {
      items = items
          .where((item) => selectedCountries.contains(item['country']))
          .toList();
    }

    // 城市筛选
    if (selectedCities.isNotEmpty) {
      items =
          items.where((item) => selectedCities.contains(item['city'])).toList();
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
      items = items
          .where((item) => selectedClimates.contains(item['climate']))
          .toList();
    }

    return items;
  }

  /// 重置所有筛选
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
    searchQuery.value = '';
  }

  /// 搜索城市 - 调用后端 API
  Future<void> searchCities(String query) async {
    try {
      searchQuery.value = query;

      if (query.trim().isEmpty) {
        // 如果搜索词为空,重新加载所有城市
        await loadInitialCities();
        return;
      }

      isLoading.value = true;
      hasError.value = false;
      print('🔍 开始搜索城市: "$query"');

      // 调用后端搜索 API
      final results = await _citiesApiService.searchCities(
        query: query,
        page: 1,
        pageSize: 1000,
      );

      print('✅ 搜索返回: ${results.length} 个结果');

      // 转换搜索结果
      _allCities = [];
      cities.clear();

      for (var i = 0; i < results.length; i++) {
        try {
          final city = results[i] as Map<String, dynamic>;
          final weather = city['weather'] as Map<String, dynamic>?;

          _allCities.add({
            'id': city['id'],
            'city': city['name'] ?? 'Unknown',
            'country': city['country'] ?? 'Unknown',
            'region': _guessRegion(city['country'] ?? 'Unknown'),
            'climate': _guessClimate(weather?['temperature']?.toDouble()),
            'image': city['imageUrl'] ??
                'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
            'temperature': weather?['temperature']?.toInt() ?? 25,
            'feelsLike': weather?['feelsLike']?.toInt() ?? 25,
            'weather': _getWeatherFromCode(weather?['weather']?.toString()),
            'internet': 20,
            'price': 1500,
            'rank': i + 1,
            'badge': (city['meetupCount'] ?? 0) > 5 ? 'Popular' : '',
            'ratings': ['😊', '👍', '🌟'],
            'overall': 4.0,
            'cost': 4.0,
            'internetScore': 4.0,
            'liked': 4.0,
            'safety': 4.0,
            'aqi': weather?['airQualityIndex']?.toInt() ?? 50,
            'aqiLevel': _getAqiLevel(weather?['airQualityIndex']?.toInt()),
            'population': '1M',
            'timezone': 'GMT',
            'humidity': weather?['humidity']?.toInt() ?? 70,
            'about': city['description'] ?? '',
            'reviews': 0,
          });
        } catch (e) {
          print('❌ 转换搜索结果失败 [索引 $i]: $e');
        }
      }

      // 加载第一页
      _currentPage = 0;
      _loadNextPage();

      print('✅ 搜索完成，显示 ${cities.length} 个城市');
    } catch (e) {
      print('❌ 搜索失败: $e');
      hasError.value = true;
      errorMessage.value = '搜索失败: ${e.toString()}';
      AppToast.error('搜索失败，请重试');
    } finally {
      isLoading.value = false;
    }
  }

  /// 检查是否有激活的筛选条件
  bool get hasActiveFilters {
    return selectedRegions.isNotEmpty ||
        selectedCountries.isNotEmpty ||
        selectedCities.isNotEmpty ||
        minPrice.value > 0.0 ||
        maxPrice.value < 5000.0 ||
        minInternet.value > 0.0 ||
        minRating.value > 0.0 ||
        maxAqi.value < 500 ||
        selectedClimates.isNotEmpty;
  }

  /// 获取所有可用的地区列表
  List<String> get availableRegions {
    return _allCities.map((item) => item['region'] as String).toSet().toList()
      ..sort();
  }

  /// 获取所有可用的国家列表
  List<String> get availableCountries {
    return _allCities.map((item) => item['country'] as String).toSet().toList()
      ..sort();
  }

  /// 获取所有可用的城市列表
  List<String> get availableCities {
    return _allCities.map((item) => item['city'] as String).toSet().toList()
      ..sort();
  }

  /// 获取所有可用的气候类型列表
  List<String> get availableClimates {
    return _allCities.map((item) => item['climate'] as String).toSet().toList()
      ..sort();
  }

  // ========== 辅助方法 ==========

  String _guessRegion(String country) {
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

  String _guessClimate(double? temperature) {
    if (temperature == null) return 'Warm';
    if (temperature > 30) return 'Hot';
    if (temperature > 20) return 'Warm';
    if (temperature > 10) return 'Mild';
    if (temperature > 0) return 'Cool';
    return 'Cold';
  }

  String _getWeatherFromCode(String? weather) {
    if (weather == null) return 'sunny';
    final w = weather.toLowerCase();
    if (w.contains('clear') || w.contains('sun')) return 'sunny';
    if (w.contains('cloud')) return 'cloudy';
    if (w.contains('rain')) return 'rainy';
    if (w.contains('snow')) return 'snowy';
    return 'sunny';
  }

  String _getAqiLevel(int? aqi) {
    if (aqi == null || aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
}
