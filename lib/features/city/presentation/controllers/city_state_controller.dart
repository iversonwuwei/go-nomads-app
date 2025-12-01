import 'dart:async';

import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/features/city/application/use_cases/city_use_cases.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';
import 'package:df_admin_mobile/services/signalr_service.dart';
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

  // 正在生成图片的城市 ID 集合
  final RxSet<String> generatingImageCityIds = <String>{}.obs;

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

  // SignalR 订阅
  StreamSubscription<Map<String, dynamic>>? _cityImageUpdatedSubscription;

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    _setupSignalRListeners();
  }

  /// 设置 SignalR 监听器
  void _setupSignalRListeners() {
    final signalRService = SignalRService();

    // 监听城市图片更新事件
    _cityImageUpdatedSubscription = signalRService.cityImageUpdatedStream.listen((data) {
      print('🖼️ [CityStateController] 收到城市图片更新通知: $data');

      final cityId = data['cityId'] as String?;
      final success = data['success'] as bool? ?? false;

      if (cityId == null) {
        print('⚠️ [CityStateController] 城市ID为空，忽略通知');
        return;
      }

      // 无论成功还是失败，都从生成中列表移除
      generatingImageCityIds.remove(cityId);

      if (!success) {
        final errorMessage = data['errorMessage'] as String? ?? '图片生成失败';
        print('❌ [CityStateController] 城市图片生成失败: $errorMessage');
        AppToast.error(errorMessage, title: '图片生成失败');
        return;
      }

      // 构造图片数据
      final imageData = <String, dynamic>{};

      // 处理竖屏图片
      final portraitUrl = data['portraitImageUrl'] as String?;
      if (portraitUrl != null) {
        imageData['portraitImage'] = {'url': portraitUrl};
      }

      // 处理横屏图片
      final landscapeUrls = data['landscapeImageUrls'];
      if (landscapeUrls is List && landscapeUrls.isNotEmpty) {
        imageData['landscapeImages'] = landscapeUrls.map((url) => {'url': url}).toList();
      }

      // 调用更新方法
      updateCityImages(cityId, imageData);

      // 显示成功提示
      final cityName = data['cityName'] as String? ?? '';
      AppToast.success('$cityName 的图片已更新', title: '图片生成完成');
    });

    print('✅ [CityStateController] SignalR 城市图片更新监听已设置');
  }

  @override
  void onClose() {
    // 取消 SignalR 订阅
    _cityImageUpdatedSubscription?.cancel();
    _cityImageUpdatedSubscription = null;
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

  /// 检查城市是否正在生成图片
  bool isGeneratingImages(String cityId) {
    return generatingImageCityIds.contains(cityId);
  }

  /// 为城市生成 AI 图片
  ///
  /// [cityId] 城市ID
  /// 返回生成结果
  Future<Result<Map<String, dynamic>>> generateCityImages(String cityId) async {
    print('🖼️ [CityStateController] 开始生成城市图片: $cityId');

    // 标记为正在生成
    generatingImageCityIds.add(cityId);

    try {
      final result = await _cityRepository.generateCityImages(cityId);

      return result.fold(
        onSuccess: (data) {
          print('✅ [CityStateController] 图片生成任务已创建，等待 SignalR 通知');
          // 注意：这里不移除 cityId，等待 SignalR 通知时再移除
          return Success(data);
        },
        onFailure: (exception) {
          print('❌ [CityStateController] 图片生成失败: ${exception.message}');
          // 失败时移除
          generatingImageCityIds.remove(cityId);
          return Failure(exception);
        },
      );
    } catch (e) {
      print('💥 [CityStateController] 生成图片异常: $e');
      // 异常时移除
      generatingImageCityIds.remove(cityId);
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

  /// 只更新城市图片字段（不影响其他数据如温度等）
  ///
  /// [cityId] 城市ID
  /// [imageData] 图片生成结果数据
  void updateCityImages(String cityId, Map<String, dynamic> imageData) {
    print('🖼️ [CityStateController] 更新城市图片: $cityId');
    print('🖼️ [CityStateController] 原始数据: $imageData');

    final index = cities.indexWhere((c) => c.id == cityId);
    if (index == -1) {
      print('⚠️ [CityStateController] 未找到城市: $cityId');
      return;
    }

    final oldCity = cities[index];

    // 从返回数据中提取图片信息
    // 后端返回格式: { success: true, data: { portraitImage: {...}, landscapeImages: [...] } }
    // 或者直接是 data 层级的内容
    Map<String, dynamic>? data;
    if (imageData.containsKey('data') && imageData['data'] is Map<String, dynamic>) {
      data = imageData['data'] as Map<String, dynamic>;
    } else if (imageData.containsKey('portraitImage') || imageData.containsKey('landscapeImages')) {
      // 直接就是 data 层级
      data = imageData;
    }

    print('🖼️ [CityStateController] 解析后的 data: $data');

    if (data == null) {
      print('⚠️ [CityStateController] 图片数据为空，尝试直接使用 imageData');
      data = imageData;
    }

    // 提取竖屏图片 URL
    String? portraitUrl;
    final portraitImage = data['portraitImage'];
    if (portraitImage is Map<String, dynamic>) {
      portraitUrl = portraitImage['url'] as String?;
    }
    print('🖼️ [CityStateController] 竖屏图片: $portraitUrl');

    // 提取横屏图片 URL 列表
    List<String>? landscapeUrls;
    final landscapeImages = data['landscapeImages'];
    if (landscapeImages is List && landscapeImages.isNotEmpty) {
      landscapeUrls = landscapeImages
          .where((img) => img is Map<String, dynamic> && img['url'] != null)
          .map((img) => (img as Map<String, dynamic>)['url'] as String)
          .toList();
    }
    print('🖼️ [CityStateController] 横屏图片数量: ${landscapeUrls?.length ?? 0}');

    // 如果没有解析到任何图片，不更新
    if (portraitUrl == null && (landscapeUrls == null || landscapeUrls.isEmpty)) {
      print('⚠️ [CityStateController] 未解析到图片URL，跳过更新');
      return;
    }

    // 使用 copyWith 只更新图片字段，保留其他所有数据
    final updatedCity = oldCity.copyWith(
      portraitImageUrl: portraitUrl ?? oldCity.portraitImageUrl,
      landscapeImageUrls: landscapeUrls ?? oldCity.landscapeImageUrls,
      // 如果有竖屏图片，也更新主图
      imageUrl: portraitUrl ?? oldCity.imageUrl,
    );

    cities[index] = updatedCity;
    cities.refresh();
    print('✅ [CityStateController] 城市图片已更新: portrait=$portraitUrl, landscape=${landscapeUrls?.length ?? 0}张');
  }
}
