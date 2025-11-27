import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/features/city/application/use_cases/city_use_cases.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:get/get.dart';

/// ??????? (Presentation Layer)
///
/// ????????? UI ??,?? Use Cases ??
class CityStateController extends GetxController {
  // ==================== Dependencies ====================
  final GetCitiesUseCase _getCitiesUseCase;
  final SearchCityListUseCase _searchCitiesUseCase;
  final GetRecommendedCitiesUseCase _getRecommendedCitiesUseCase;
  final GetPopularCitiesUseCase _getPopularCitiesUseCase;
  final ToggleCityFavoriteUseCase _toggleCityFavoriteUseCase;
  final GetFavoriteCitiesUseCase _getFavoriteCitiesUseCase;
  final GetUserFavoriteCityIdsUseCase _getUserFavoriteCityIdsUseCase;
  final ICityRepository _cityRepository;

  CityStateController({
    required GetCitiesUseCase getCitiesUseCase,
    required SearchCityListUseCase searchCitiesUseCase,
    required GetRecommendedCitiesUseCase getRecommendedCitiesUseCase,
    required GetPopularCitiesUseCase getPopularCitiesUseCase,
    required ToggleCityFavoriteUseCase toggleCityFavoriteUseCase,
    required GetFavoriteCitiesUseCase getFavoriteCitiesUseCase,
    required GetUserFavoriteCityIdsUseCase getUserFavoriteCityIdsUseCase,
    required ICityRepository cityRepository,
  })  : _getCitiesUseCase = getCitiesUseCase,
        _searchCitiesUseCase = searchCitiesUseCase,
        _getRecommendedCitiesUseCase = getRecommendedCitiesUseCase,
        _getPopularCitiesUseCase = getPopularCitiesUseCase,
        _toggleCityFavoriteUseCase = toggleCityFavoriteUseCase,
        _getFavoriteCitiesUseCase = getFavoriteCitiesUseCase,
        _getUserFavoriteCityIdsUseCase = getUserFavoriteCityIdsUseCase,
        _cityRepository = cityRepository;

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);
  final RxList<City> cities = <City>[].obs;

  // ????
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  // ????
  final RxString searchQuery = ''.obs;
  final Rx<String?> selectedCountryId = Rx<String?>(null);

  // ???? (?????)
  final RxList<String> selectedRegions = <String>[].obs;
  final RxList<String> selectedCountries = <String>[].obs;
  final RxList<String> selectedCities = <String>[].obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 5000.0.obs;
  final RxDouble minInternet = 0.0.obs;
  final RxDouble minRating = 0.0.obs;
  final RxInt maxAqi = 500.obs;
  final RxList<String> selectedClimates = <String>[].obs;

  // ?????
  final RxList<City> recommendedCities = <City>[].obs;
  final RxList<City> popularCities = <City>[].obs;

  // ??
  final RxList<City> favoriteCities = <City>[].obs;

  // ????? (??????)
  int get totalCitiesCount => cities.length;

  // ==================== Lifecycle ====================

  @override
  void onClose() {
    // ?????????
    cities.clear();
    recommendedCities.clear();
    popularCities.clear();
    favoriteCities.clear();

    // ??????
    isLoading.value = false;
    isLoadingMore.value = false;
    hasError.value = false;
    errorMessage.value = null;

    // ??????
    _currentPage = 1;
    _hasMoreData = true;

    // ??????
    searchQuery.value = '';
    selectedCountryId.value = null;
    selectedRegions.clear();
    selectedCountries.clear();
    selectedCities.clear();
    minPrice.value = 0.0;
    maxPrice.value = 5000.0;
    minInternet.value = 0.0;
    minRating.value = 0.0;
    maxAqi.value = 500;
    selectedClimates.clear();

    super.onClose();
  }

  // ==================== Public Methods ====================

  /// ???????? (???)
  Future<void> loadInitialCities({bool refresh = true}) async {
    // 如果不是强制刷新，且已有数据，跳过加载
    if (!refresh && cities.isNotEmpty) {
      print('🔄 CityController: 已有缓存数据，跳过加载');
      return;
    }

    // 防止重复请求
    if (isLoading.value) {
      print('⚠️ CityController: 正在加载中，跳过重复请求');
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = null;
    _currentPage = 1;
    _hasMoreData = true;
    cities.clear();

    // print('?? ??????????...');

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
        // print('? ???? ${data.length} ???');
        cities.value = data;
        _hasMoreData = data.length >= _pageSize;
        isLoading.value = false;
      },
      onFailure: (exception) {
        // print('? ??????: ${exception.message}');
        hasError.value = true;
        errorMessage.value = exception.message;
        isLoading.value = false;

        // ????????,????(??? Toast)
        // ?? AuthStateController ??? 401 ????????
        if (exception is! UnauthorizedException) {
          AppToast.error(exception.message, title: '????');
        } else {
          print('?? ??????: Token ?????');
        }
      },
    );
  }

  /// ?????? (???)
  Future<void> loadMoreCities() async {
    if (isLoadingMore.value || !_hasMoreData) {
      // print('?? ?????????????');
      return;
    }

    isLoadingMore.value = true;
    _currentPage++;

    // print('?? ??? $_currentPage ?...');

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
        // print('? ???? ${data.length} ???');
        cities.addAll(data);
        _hasMoreData = data.length >= _pageSize;
        isLoadingMore.value = false;
      },
      onFailure: (exception) {
        // print('? ??????: ${exception.message}');
        _currentPage--; // ????
        isLoadingMore.value = false;
        AppToast.error(exception.message, title: '????');
      },
    );
  }

  /// ????
  Future<void> searchCities(String query) async {
    searchQuery.value = query;

    if (query.trim().isEmpty) {
      // ??????,??????
      return loadInitialCities();
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = null;
    cities.clear();

    // print('?? ????: $query');

    final result = await _searchCitiesUseCase.execute(
      SearchCitiesParams(keyword: query, pageSize: _pageSize),
    );

    result.fold(
      onSuccess: (data) {
        // print('? ??? ${data.length} ???');
        cities.value = data;
        isLoading.value = false;
      },
      onFailure: (exception) {
        // print('? ????: ${exception.message}');
        hasError.value = true;
        errorMessage.value = exception.message;
        isLoading.value = false;
        AppToast.error(exception.message, title: '????');
      },
    );
  }

  /// ?????
  Future<void> filterByCountry(String? countryId) async {
    selectedCountryId.value = countryId;
    return loadInitialCities();
  }

  /// ????
  Future<void> clearFilters() async {
    searchQuery.value = '';
    selectedCountryId.value = null;
    return loadInitialCities();
  }

  /// ???????? (?????)
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

  /// ?????????? (?????)
  List<City> get filteredCities {
    var items = cities.toList();

    // ????
    if (selectedRegions.isNotEmpty) {
      items = items.where((city) => city.region != null && selectedRegions.contains(city.region)).toList();
    }

    // ???? (???)
    if (selectedCountries.isNotEmpty) {
      items = items.where((city) => city.country != null && selectedCountries.contains(city.country)).toList();
    }

    // ???? (?? costScore * 500 ??????)
    items = items.where((city) {
      if (city.costScore == null) return true;
      final estimatedCost = city.costScore! * 500; // 0-5 score ? $0-2500 range
      return estimatedCost >= minPrice.value && estimatedCost <= maxPrice.value;
    }).toList();

    // ???? (?? internetScore * 20 ????)
    items = items.where((city) {
      if (city.internetScore == null) return true;
      final estimatedSpeed = city.internetScore! * 20; // 0-5 score ? 0-100 Mbps range
      return estimatedSpeed >= minInternet.value;
    }).toList();

    // ????
    items = items.where((city) {
      if (city.overallScore == null) return true;
      return city.overallScore! >= minRating.value;
    }).toList();

    // AQI ??
    items = items.where((city) {
      if (city.airQualityIndex == null) return true;
      return city.airQualityIndex! <= maxAqi.value;
    }).toList();

    // ???? (City ???? climate ??,??????)
    // ????????,?????????
    if (selectedClimates.isNotEmpty) {
      // ?????,?? City ???? climate ??
      // ????????????????
    }

    return items;
  }

  /// ????
  @override
  Future<void> refresh() async {
    return loadInitialCities();
  }

  /// ??????
  Future<void> loadRecommendedCities({String? countryId, int limit = 10}) async {
    // print('?? ??????...');

    final result = await _getRecommendedCitiesUseCase.execute(
      GetRecommendedCitiesParams(countryId: countryId, limit: limit),
    );

    result.fold(
      onSuccess: (data) {
        // print('? ???? ${data.length} ?????');
        recommendedCities.value = data;
      },
      onFailure: (exception) {
        // print('? ????????: ${exception.message}');
        AppToast.error(exception.message, title: '????');
      },
    );
  }

  /// ??????
  Future<void> loadPopularCities({int limit = 10}) async {
    // print('?? ??????...');

    final result = await _getPopularCitiesUseCase.execute(
      GetPopularCitiesParams(limit: limit),
    );

    result.fold(
      onSuccess: (data) {
        // print('? ???? ${data.length} ?????');
        popularCities.value = data;
      },
      onFailure: (exception) {
        // print('? ????????: ${exception.message}');
        AppToast.error(exception.message, title: '????');
      },
    );
  }

  /// ????????
  Future<void> toggleFavorite(String cityId) async {
    // print('?? ??????: $cityId');

    final result = await _toggleCityFavoriteUseCase.execute(
      ToggleCityFavoriteParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (isFavorited) {
        // print('? ???????: $isFavorited');

        // ????????????
        final index = cities.indexWhere((city) => city.id == cityId);
        if (index != -1) {
          cities[index] = cities[index].copyWith(isFavorite: isFavorited);
          cities.refresh();
        }

        AppToast.success(
          isFavorited ? '??????' : '?????',
          title: '??',
        );
      },
      onFailure: (exception) {
        // print('? ??????: ${exception.message}');
        AppToast.error(exception.message, title: '????');
      },
    );
  }

  /// ????????
  Future<void> loadFavoriteCities() async {
    // print('?? ??????...');

    final result = await _getFavoriteCitiesUseCase.execute(const NoParams());

    result.fold(
      onSuccess: (data) {
        // print('? ???? ${data.length} ?????');
        favoriteCities.value = data;
      },
      onFailure: (exception) {
        // print('? ????????: ${exception.message}');
        AppToast.error(exception.message, title: '????');
      },
    );
  }

  /// ???????? (? city_list_page ??)
  Future<Result<void>> toggleCityFavorite(String cityId) async {
    // print('?? ??????: $cityId');

    final result = await _toggleCityFavoriteUseCase.execute(
      ToggleCityFavoriteParams(cityId: cityId),
    );

    return result.fold(
      onSuccess: (isFavorited) {
        // print('? ???????: $isFavorited');

        // ????????????
        final index = cities.indexWhere((city) => city.id == cityId);
        if (index != -1) {
          cities[index] = cities[index].copyWith(isFavorite: isFavorited);
          cities.refresh();
        }

        return const Success(null);
      },
      onFailure: (exception) {
        // print('? ??????: ${exception.message}');
        return Failure(exception);
      },
    );
  }

  /// ?????????ID?? (? city_list_page ??)
  Future<Result<List<String>>> loadUserFavoriteCityIds() async {
    // print('?? ??????ID??...');

    final result = await _getUserFavoriteCityIdsUseCase.execute(const NoParams());

    return result.fold(
      onSuccess: (ids) {
        // print('? ???? ${ids.length} ?????ID');
        return Success(ids);
      },
      onFailure: (exception) {
        // print('? ??????ID??: ${exception.message}');
        return Failure(exception);
      },
    );
  }

  // ==================== Computed Properties ====================

  /// ???????
  bool get hasCities => cities.isNotEmpty;

  /// ????????
  bool get canLoadMore => _hasMoreData && !isLoadingMore.value;

  /// ???????? (????)
  bool get hasMoreData => _hasMoreData;

  /// ????????
  int get searchResultCount => cities.length;

  /// ??????????
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

  /// ???????????
  List<String> get availableRegions {
    return cities.where((city) => city.region != null).map((city) => city.region!).toSet().toList()..sort();
  }

  /// ???????????
  List<String> get availableCountries {
    return cities.where((city) => city.country != null).map((city) => city.country!).toSet().toList()..sort();
  }

  /// ?????????????
  List<String> get availableCities {
    return cities.map((city) => city.name).toSet().toList()..sort();
  }

  /// ????????????? (?? City ??? climate ??)
  List<String> get availableClimates {
    // ??: City ?????? climate ??
    // ???????,?????????????
    return <String>[];
  }

  /// 为城市生成 AI 图片
  ///
  /// [cityId] 城市ID
  /// 返回生成结果
  Future<Result<Map<String, dynamic>>> generateCityImages(String cityId) async {
    print('🖼️ [CityStateController] 开始生成城市图片: $cityId');

    try {
      final result = await _cityRepository.generateCityImages(cityId);

      return result.fold(
        onSuccess: (data) {
          print('✅ [CityStateController] 图片生成成功');
          return Success(data);
        },
        onFailure: (exception) {
          print('❌ [CityStateController] 图片生成失败: ${exception.message}');
          return Failure(exception);
        },
      );
    } catch (e) {
      print('💥 [CityStateController] 生成图片异常: $e');
      return Failure(UnknownException('生成图片失败: $e'));
    }
  }

  /// 刷新单个城市数据
  ///
  /// [cityId] 城市ID
  /// 更新本地城市列表中的对应城市数据
  Future<void> refreshSingleCity(String cityId) async {
    print('🔄 [CityStateController] 刷新单个城市数据: $cityId');

    final result = await _cityRepository.getCityById(cityId);

    result.fold(
      onSuccess: (city) {
        print('✅ [CityStateController] 获取城市数据成功');
        // 更新列表中的城市数据
        final index = cities.indexWhere((c) => c.id == cityId);
        if (index != -1) {
          cities[index] = city;
          cities.refresh();
          print('🔄 [CityStateController] 城市列表已更新');
        }
      },
      onFailure: (exception) {
        print('❌ [CityStateController] 刷新城市数据失败: ${exception.message}');
      },
    );
  }
}
