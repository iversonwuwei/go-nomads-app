import 'package:get/get.dart';

import '../../../../core/core.dart';
import '../../../../widgets/app_toast.dart';
import '../../application/use_cases/city_use_cases.dart';
import '../../domain/entities/city.dart';

/// 城市状态控制器 (Presentation Layer)
///
/// 负责管理城市相关的 UI 状态,协调 Use Cases 执行
class CityStateController extends GetxController {
  // ==================== Dependencies ====================
  final GetCitiesUseCase _getCitiesUseCase;
  final SearchCityListUseCase _searchCitiesUseCase;
  final GetRecommendedCitiesUseCase _getRecommendedCitiesUseCase;
  final GetPopularCitiesUseCase _getPopularCitiesUseCase;
  final ToggleCityFavoriteUseCase _toggleCityFavoriteUseCase;
  final GetFavoriteCitiesUseCase _getFavoriteCitiesUseCase;
  final GetUserFavoriteCityIdsUseCase _getUserFavoriteCityIdsUseCase;

  CityStateController({
    required GetCitiesUseCase getCitiesUseCase,
    required SearchCityListUseCase searchCitiesUseCase,
    required GetRecommendedCitiesUseCase getRecommendedCitiesUseCase,
    required GetPopularCitiesUseCase getPopularCitiesUseCase,
    required ToggleCityFavoriteUseCase toggleCityFavoriteUseCase,
    required GetFavoriteCitiesUseCase getFavoriteCitiesUseCase,
    required GetUserFavoriteCityIdsUseCase getUserFavoriteCityIdsUseCase,
  })  : _getCitiesUseCase = getCitiesUseCase,
        _searchCitiesUseCase = searchCitiesUseCase,
        _getRecommendedCitiesUseCase = getRecommendedCitiesUseCase,
        _getPopularCitiesUseCase = getPopularCitiesUseCase,
        _toggleCityFavoriteUseCase = toggleCityFavoriteUseCase,
        _getFavoriteCitiesUseCase = getFavoriteCitiesUseCase,
        _getUserFavoriteCityIdsUseCase = getUserFavoriteCityIdsUseCase;

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);
  final RxList<City> cities = <City>[].obs;

  // 分页状态
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  // 筛选状态
  final RxString searchQuery = ''.obs;
  final Rx<String?> selectedCountryId = Rx<String?>(null);

  // 高级筛选 (客户端筛选)
  final RxList<String> selectedRegions = <String>[].obs;
  final RxList<String> selectedCountries = <String>[].obs;
  final RxList<String> selectedCities = <String>[].obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 5000.0.obs;
  final RxDouble minInternet = 0.0.obs;
  final RxDouble minRating = 0.0.obs;
  final RxInt maxAqi = 500.obs;
  final RxList<String> selectedClimates = <String>[].obs;

  // 推荐和热门
  final RxList<City> recommendedCities = <City>[].obs;
  final RxList<City> popularCities = <City>[].obs;

  // 收藏
  final RxList<City> favoriteCities = <City>[].obs;

  // 总城市数量 (用于显示统计)
  int get totalCitiesCount => cities.length;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    // 不在这里自动加载，由页面决定何时加载
    // loadInitialCities();
  }

  // ==================== Public Methods ====================

  /// 初始加载城市列表 (第一页)
  Future<void> loadInitialCities() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = null;
    _currentPage = 1;
    _hasMoreData = true;
    cities.clear();

    // print('📡 开始加载初始城市数据...');

    final result = await _getCitiesUseCase.execute(
      GetCitiesParams(
        page: _currentPage,
        pageSize: _pageSize,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        countryId: selectedCountryId.value,
      ),
    );

    result.fold(
      onSuccess: (data) {
        // print('✅ 成功加载 ${data.length} 个城市');
        cities.value = data;
        _hasMoreData = data.length >= _pageSize;
        isLoading.value = false;
      },
      onFailure: (exception) {
        // print('❌ 加载城市失败: ${exception.message}');
        hasError.value = true;
        errorMessage.value = exception.message;
        isLoading.value = false;
        
        // 如果是未授权错误，静默处理（不显示 Toast）
        // 因为 AuthStateController 会处理 401 错误并跳转登录页
        if (exception is! UnauthorizedException) {
          AppToast.error(exception.message, title: '加载失败');
        } else {
          print('⚠️ 加载城市失败: Token 无效或过期');
        }
      },
    );
  }

  /// 加载更多城市 (下一页)
  Future<void> loadMoreCities() async {
    if (isLoadingMore.value || !_hasMoreData) {
      // print('⚠️ 已经在加载中或没有更多数据');
      return;
    }

    isLoadingMore.value = true;
    _currentPage++;

    // print('📡 加载第 $_currentPage 页...');

    final result = await _getCitiesUseCase.execute(
      GetCitiesParams(
        page: _currentPage,
        pageSize: _pageSize,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        countryId: selectedCountryId.value,
      ),
    );

    result.fold(
      onSuccess: (data) {
        // print('✅ 成功加载 ${data.length} 个城市');
        cities.addAll(data);
        _hasMoreData = data.length >= _pageSize;
        isLoadingMore.value = false;
      },
      onFailure: (exception) {
        // print('❌ 加载更多失败: ${exception.message}');
        _currentPage--; // 回滚页码
        isLoadingMore.value = false;
        AppToast.error(exception.message, title: '加载失败');
      },
    );
  }

  /// 搜索城市
  Future<void> searchCities(String query) async {
    searchQuery.value = query;

    if (query.trim().isEmpty) {
      // 如果搜索为空,重新加载全部
      return loadInitialCities();
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = null;
    cities.clear();

    // print('🔍 搜索城市: $query');

    final result = await _searchCitiesUseCase.execute(
      SearchCitiesParams(keyword: query, pageSize: _pageSize),
    );

    result.fold(
      onSuccess: (data) {
        // print('✅ 搜索到 ${data.length} 个城市');
        cities.value = data;
        isLoading.value = false;
      },
      onFailure: (exception) {
        // print('❌ 搜索失败: ${exception.message}');
        hasError.value = true;
        errorMessage.value = exception.message;
        isLoading.value = false;
        AppToast.error(exception.message, title: '搜索失败');
      },
    );
  }

  /// 按国家筛选
  Future<void> filterByCountry(String? countryId) async {
    selectedCountryId.value = countryId;
    return loadInitialCities();
  }

  /// 清除筛选
  Future<void> clearFilters() async {
    searchQuery.value = '';
    selectedCountryId.value = null;
    return loadInitialCities();
  }

  /// 重置所有高级筛选 (客户端筛选)
  void resetFilters() {
    selectedRegions.clear();
    selectedCountries.clear();
    minPrice.value = 0.0;
    maxPrice.value = 5000.0;
    minInternet.value = 0.0;
    minRating.value = 0.0;
    maxAqi.value = 500;
    selectedClimates.clear();
    searchQuery.value = '';
    selectedCountryId.value = null;
  }

  /// 获取筛选后的城市列表 (客户端筛选)
  List<City> get filteredCities {
    var items = cities.toList();

    // 地区筛选
    if (selectedRegions.isNotEmpty) {
      items = items
          .where((city) =>
              city.region != null && selectedRegions.contains(city.region))
          .toList();
    }

    // 国家筛选 (客户端)
    if (selectedCountries.isNotEmpty) {
      items = items
          .where((city) =>
              city.country != null && selectedCountries.contains(city.country))
          .toList();
    }

    // 价格筛选 (使用 costScore * 500 派生实际价格)
    items = items.where((city) {
      if (city.costScore == null) return true;
      final estimatedCost = city.costScore! * 500; // 0-5 score → $0-2500 range
      return estimatedCost >= minPrice.value && estimatedCost <= maxPrice.value;
    }).toList();

    // 网速筛选 (使用 internetScore * 20 派生网速)
    items = items.where((city) {
      if (city.internetScore == null) return true;
      final estimatedSpeed =
          city.internetScore! * 20; // 0-5 score → 0-100 Mbps range
      return estimatedSpeed >= minInternet.value;
    }).toList();

    // 评分筛选
    items = items.where((city) {
      if (city.overallScore == null) return true;
      return city.overallScore! >= minRating.value;
    }).toList();

    // AQI 筛选
    items = items.where((city) {
      if (city.airQualityIndex == null) return true;
      return city.airQualityIndex! <= maxAqi.value;
    }).toList();

    // 气候筛选 (City 实体没有 climate 字段,这里跳过筛选)
    // 如果需要气候筛选,可以从温度范围推断
    if (selectedClimates.isNotEmpty) {
      // 暂时不筛选,因为 City 实体没有 climate 字段
      // 可以考虑根据温度范围推断气候类型
    }

    return items;
  }

  /// 刷新列表
  @override
  Future<void> refresh() async {
    return loadInitialCities();
  }

  /// 加载推荐城市
  Future<void> loadRecommendedCities(
      {String? countryId, int limit = 10}) async {
    // print('📡 加载推荐城市...');

    final result = await _getRecommendedCitiesUseCase.execute(
      GetRecommendedCitiesParams(countryId: countryId, limit: limit),
    );

    result.fold(
      onSuccess: (data) {
        // print('✅ 成功加载 ${data.length} 个推荐城市');
        recommendedCities.value = data;
      },
      onFailure: (exception) {
        // print('❌ 加载推荐城市失败: ${exception.message}');
        AppToast.error(exception.message, title: '加载失败');
      },
    );
  }

  /// 加载热门城市
  Future<void> loadPopularCities({int limit = 10}) async {
    // print('📡 加载热门城市...');

    final result = await _getPopularCitiesUseCase.execute(
      GetPopularCitiesParams(limit: limit),
    );

    result.fold(
      onSuccess: (data) {
        // print('✅ 成功加载 ${data.length} 个热门城市');
        popularCities.value = data;
      },
      onFailure: (exception) {
        // print('❌ 加载热门城市失败: ${exception.message}');
        AppToast.error(exception.message, title: '加载失败');
      },
    );
  }

  /// 切换城市收藏状态
  Future<void> toggleFavorite(String cityId) async {
    // print('💖 切换收藏状态: $cityId');

    final result = await _toggleCityFavoriteUseCase.execute(
      ToggleCityFavoriteParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (isFavorited) {
        // print('✅ 收藏状态已更新: $isFavorited');

        // 更新本地列表中的收藏状态
        final index = cities.indexWhere((city) => city.id == cityId);
        if (index != -1) {
          cities[index] = cities[index].copyWith(isFavorite: isFavorited);
          cities.refresh();
        }

        AppToast.success(
          isFavorited ? '已添加到收藏' : '已取消收藏',
          title: '成功',
        );
      },
      onFailure: (exception) {
        // print('❌ 收藏操作失败: ${exception.message}');
        AppToast.error(exception.message, title: '操作失败');
      },
    );
  }

  /// 加载收藏城市列表
  Future<void> loadFavoriteCities() async {
    // print('📡 加载收藏城市...');

    final result = await _getFavoriteCitiesUseCase.execute(const NoParams());

    result.fold(
      onSuccess: (data) {
        // print('✅ 成功加载 ${data.length} 个收藏城市');
        favoriteCities.value = data;
      },
      onFailure: (exception) {
        // print('❌ 加载收藏城市失败: ${exception.message}');
        AppToast.error(exception.message, title: '加载失败');
      },
    );
  }

  /// 切换城市收藏状态 (给 city_list_page 使用)
  Future<Result<void>> toggleCityFavorite(String cityId) async {
    // print('💖 切换收藏状态: $cityId');

    final result = await _toggleCityFavoriteUseCase.execute(
      ToggleCityFavoriteParams(cityId: cityId),
    );

    return result.fold(
      onSuccess: (isFavorited) {
        // print('✅ 收藏状态已更新: $isFavorited');

        // 更新本地列表中的收藏状态
        final index = cities.indexWhere((city) => city.id == cityId);
        if (index != -1) {
          cities[index] = cities[index].copyWith(isFavorite: isFavorited);
          cities.refresh();
        }

        return const Success(null);
      },
      onFailure: (exception) {
        // print('❌ 收藏操作失败: ${exception.message}');
        return Failure(exception);
      },
    );
  }

  /// 加载用户收藏的城市ID列表 (给 city_list_page 使用)
  Future<Result<List<String>>> loadUserFavoriteCityIds() async {
    // print('📡 加载收藏城市ID列表...');

    final result =
        await _getUserFavoriteCityIdsUseCase.execute(const NoParams());

    return result.fold(
      onSuccess: (ids) {
        // print('✅ 成功加载 ${ids.length} 个收藏城市ID');
        return Success(ids);
      },
      onFailure: (exception) {
        // print('❌ 加载收藏城市ID失败: ${exception.message}');
        return Failure(exception);
      },
    );
  }

  // ==================== Computed Properties ====================

  /// 是否有城市数据
  bool get hasCities => cities.isNotEmpty;

  /// 是否可以加载更多
  bool get canLoadMore => _hasMoreData && !isLoadingMore.value;

  /// 是否还有更多数据 (用于分页)
  bool get hasMoreData => _hasMoreData;

  /// 当前搜索结果数量
  int get searchResultCount => cities.length;

  /// 是否有激活的筛选条件
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
    return cities
        .where((city) => city.region != null)
        .map((city) => city.region!)
        .toSet()
        .toList()
      ..sort();
  }

  /// 获取所有可用的国家列表
  List<String> get availableCountries {
    return cities
        .where((city) => city.country != null)
        .map((city) => city.country!)
        .toSet()
        .toList()
      ..sort();
  }

  /// 获取所有可用的城市名称列表
  List<String> get availableCities {
    return cities.map((city) => city.name).toSet().toList()..sort();
  }

  /// 获取所有可用的气候类型列表 (如果 City 实体有 climate 字段)
  List<String> get availableClimates {
    // 注意: City 实体可能没有 climate 字段
    // 这里返回空列表,或者可以从温度推断气候类型
    return <String>[];
  }
}
