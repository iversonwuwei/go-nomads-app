import 'dart:developer';
import 'dart:async';

import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/core/sync/sync.dart';
import 'package:df_admin_mobile/features/city/application/use_cases/city_use_cases.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';
import 'package:df_admin_mobile/services/signalr_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:get/get.dart';

/// 城市列表控制器 - 使用新的数据同步框架优化版本
///
/// 改进点：
/// 1. 继承 PaginatedRefreshableController，统一分页和刷新逻辑
/// 2. 使用 hybrid 刷新策略：时间过期 + 事件驱动
/// 3. 自动订阅数据变更事件
/// 4. 统一的加载状态管理
/// 5. 防重复请求机制
class CityStateControllerV2 extends PaginatedRefreshableController {
  // ==================== Dependencies ====================
  final GetCitiesUseCase _getCitiesUseCase;
  final GetRecommendedCitiesUseCase _getRecommendedCitiesUseCase;
  final GetPopularCitiesUseCase _getPopularCitiesUseCase;
  final ToggleCityFavoriteUseCase _toggleCityFavoriteUseCase;
  final GetFavoriteCitiesUseCase _getFavoriteCitiesUseCase;
  final ICityRepository _cityRepository;

  CityStateControllerV2({
    required GetCitiesUseCase getCitiesUseCase,
    required GetRecommendedCitiesUseCase getRecommendedCitiesUseCase,
    required GetPopularCitiesUseCase getPopularCitiesUseCase,
    required ToggleCityFavoriteUseCase toggleCityFavoriteUseCase,
    required GetFavoriteCitiesUseCase getFavoriteCitiesUseCase,
    required ICityRepository cityRepository,
  })  : _getCitiesUseCase = getCitiesUseCase,
        _getRecommendedCitiesUseCase = getRecommendedCitiesUseCase,
        _getPopularCitiesUseCase = getPopularCitiesUseCase,
        _toggleCityFavoriteUseCase = toggleCityFavoriteUseCase,
        _getFavoriteCitiesUseCase = getFavoriteCitiesUseCase,
        _cityRepository = cityRepository;

  // ==================== 继承配置 ====================
  
  @override
  String get entityType => 'city_list';

  @override
  RefreshStrategy get refreshStrategy => RefreshStrategy.hybrid;

  @override
  Duration? get customCacheDuration => const Duration(minutes: 5);

  // ==================== State ====================
  
  /// 城市列表数据
  final RxList<City> cities = <City>[].obs;

  // 正在生成图片的城市 ID 集合
  final RxSet<String> generatingImageCityIds = <String>{}.obs;

  // 筛选条件
  final RxString searchQuery = ''.obs;
  final Rx<String?> selectedCountryId = Rx<String?>(null);

  // 高级筛选 (未来扩展)
  final RxList<String> selectedRegions = <String>[].obs;
  final RxList<String> selectedCountries = <String>[].obs;
  final RxList<String> selectedCities = <String>[].obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 5000.0.obs;
  final RxDouble minInternet = 0.0.obs;
  final RxDouble minRating = 0.0.obs;
  final RxInt maxAqi = 500.obs;
  final RxList<String> selectedClimates = <String>[].obs;

  // 推荐城市
  final RxList<City> recommendedCities = <City>[].obs;
  final RxList<City> popularCities = <City>[].obs;

  // 收藏
  final RxList<City> favoriteCities = <City>[].obs;

  // SignalR 订阅
  StreamSubscription<Map<String, dynamic>>? _cityImageUpdatedSubscription;
  
  // 数据变更事件订阅
  StreamSubscription<DataChangedEvent>? _dataChangedSubscription;

  // 兼容性属性 - 保持与旧代码兼容
  bool get hasMoreData => hasMore.value;
  int get totalCitiesCount => cities.length;
  bool get hasCities => cities.isNotEmpty;
  bool get canLoadMore => hasMore.value && !isLoadingMore.value;
  
  /// 是否有加载错误 - 兼容原控制器
  RxBool get hasError => RxBool(errorMessage.value != null);
  
  /// 是否有活动的筛选条件 - 兼容原控制器
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

  /// 可选区域列表 - 兼容原控制器
  List<String> get availableRegions {
    return cities.where((city) => city.region != null).map((city) => city.region!).toSet().toList()..sort();
  }

  /// 可选国家列表 - 兼容原控制器
  List<String> get availableCountries {
    return cities.where((city) => city.country != null).map((city) => city.country!).toSet().toList()..sort();
  }

  /// 可选城市名称列表 - 兼容原控制器
  List<String> get availableCities {
    return cities.map((city) => city.name).toSet().toList()..sort();
  }

  /// 可选气候类型列表 - 兼容原控制器
  List<String> get availableClimates {
    return <String>[];
  }

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    _setupSignalRListeners();
    _setupDataChangeListeners();
    
    // 初始加载 - 使用基类的智能加载（检查缓存有效性）
    initialLoad();
    
    // 加载推荐和热门城市
    loadRecommendedCities();
    loadPopularCities();
  }

  @override
  void onClose() {
    _cityImageUpdatedSubscription?.cancel();
    _cityImageUpdatedSubscription = null;
    _dataChangedSubscription?.cancel();
    _dataChangedSubscription = null;
    
    // 清理状态
    cities.clear();
    recommendedCities.clear();
    popularCities.clear();
    favoriteCities.clear();
    generatingImageCityIds.clear();
    
    // 清理筛选条件
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

  // ==================== 实现基类抽象方法 ====================

  @override
  Future<PaginatedResult> loadPageData(int page, int pageSize) async {
    log('📄 CityController: 加载第 $page 页，每页 $pageSize 条');
    
    final result = await _getCitiesUseCase.execute(
      GetCitiesParams(
        page: page,
        pageSize: pageSize,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        countryId: selectedCountryId.value,
      ),
    );

    return result.fold(
      onSuccess: (data) {
        log('✅ 成功加载 ${data.length} 个城市');
        return PaginatedResult(
          items: data,
          totalCount: data.length, // API 未返回总数时使用当前数量
          hasMore: data.length >= pageSize,
        );
      },
      onFailure: (exception) {
        log('❌ 加载城市失败: ${exception.message}');
        
        // 非授权错误才显示 Toast
        if (exception is! UnauthorizedException) {
          AppToast.error(exception.message, title: '加载失败');
        }
        
        throw exception;
      },
    );
  }

  @override
  Future<void> onPageLoaded(List<dynamic> items, {required bool isRefresh}) async {
    final cityList = items.cast<City>();
    
    if (isRefresh) {
      cities.clear();
    }
    
    cities.addAll(cityList);
    log('📊 当前城市总数: ${cities.length}');
  }

  /// 处理数据变更事件（由事件总线触发）
  void _handleDataChanged(DataChangedEvent event) {
    // 处理城市数据变更
    if (event.entityType == 'city' || event.entityType == 'city_list') {
      log('🔔 收到城市数据变更通知: ${event.changeType}');
      
      switch (event.changeType) {
        case DataChangeType.created:
          // 新城市创建，刷新列表
          refresh();
          break;
        case DataChangeType.updated:
          // 城市更新，如果是当前列表中的城市，局部更新
          if (event.entityId != null) {
            _updateCityInList(event.entityId!);
          }
          break;
        case DataChangeType.deleted:
          // 城市删除，从列表中移除
          if (event.entityId != null) {
            cities.removeWhere((city) => city.id == event.entityId);
          }
          break;
        case DataChangeType.invalidated:
          // 缓存失效，刷新列表
          refresh();
          break;
      }
    }
  }

  // ==================== 私有方法 ====================

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    _dataChangedSubscription = DataEventBus.instance.on('city', _handleDataChanged);
    
    // 也监听 city_list 事件
    DataEventBus.instance.on('city_list', _handleDataChanged);
  }

  /// 设置 SignalR 监听器
  void _setupSignalRListeners() {
    final signalRService = SignalRService();

    // 监听城市图片更新事件
    _cityImageUpdatedSubscription = signalRService.cityImageUpdatedStream.listen((data) {
      log('🖼️ [CityController] 收到城市图片更新通知: $data');

      final cityId = data['cityId'] as String?;
      final success = data['success'] as bool? ?? false;

      if (cityId == null) {
        log('⚠️ [CityController] 城市ID为空，忽略通知');
        return;
      }

      // 无论成功还是失败，都从生成中列表移除
      generatingImageCityIds.remove(cityId);

      if (!success) {
        final errorMsg = data['errorMessage'] as String? ?? '图片生成失败';
        log('❌ [CityController] 城市图片生成失败: $errorMsg');
        AppToast.error(errorMsg, title: '图片生成失败');
        return;
      }

      // 构造图片数据并更新
      final imageData = _buildImageData(data);
      updateCityImages(cityId, imageData);

      // 显示成功提示
      final cityName = data['cityName'] as String? ?? '';
      AppToast.success('$cityName 的图片已更新', title: '图片生成完成');
    });

    log('✅ [CityController] SignalR 城市图片更新监听已设置');
  }

  Map<String, dynamic> _buildImageData(Map<String, dynamic> data) {
    final imageData = <String, dynamic>{};

    final portraitUrl = data['portraitImageUrl'] as String?;
    if (portraitUrl != null) {
      imageData['portraitImage'] = {'url': portraitUrl};
    }

    final landscapeUrls = data['landscapeImageUrls'];
    if (landscapeUrls is List && landscapeUrls.isNotEmpty) {
      imageData['landscapeImages'] = landscapeUrls.map((url) => {'url': url}).toList();
    }

    return imageData;
  }

  /// 更新列表中的单个城市
  Future<void> _updateCityInList(String cityId) async {
    try {
      final result = await _cityRepository.getCityById(cityId);
      result.fold(
        onSuccess: (updatedCity) {
          final index = cities.indexWhere((c) => c.id == cityId);
          if (index != -1) {
            cities[index] = updatedCity;
            cities.refresh(); // 触发 Obx 更新
            log('✅ 已更新城市: ${updatedCity.name}');
          }
        },
        onFailure: (e) {
          log('⚠️ 更新城市失败: ${e.message}');
        },
      );
    } catch (e) {
      log('⚠️ 更新城市异常: $e');
    }
  }

  // ==================== 公共方法 ====================

  /// 搜索城市
  Future<void> searchCities(String query) async {
    searchQuery.value = query;

    if (query.trim().isEmpty) {
      // 清空搜索时，重新加载所有城市
      return refresh();
    }

    // 使用基类的刷新方法，会自动调用 loadPageData
    await forceRefresh();
  }

  /// 按国家筛选
  Future<void> filterByCountry(String? countryId) async {
    selectedCountryId.value = countryId;
    await forceRefresh();
  }

  /// 清除所有筛选
  Future<void> clearFilters() async {
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
    
    await forceRefresh();
  }

  /// 重置筛选（同步方法，兼容旧 API）
  void resetFilters() {
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
  }

  /// 获取筛选后的城市列表（兼容旧 API）
  List<City> get filteredCities {
    var result = cities.toList();
    
    // 搜索过滤
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((city) {
        return city.name.toLowerCase().contains(query) ||
            (city.nameEn?.toLowerCase().contains(query) ?? false) ||
            (city.country?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    return result;
  }

  /// 加载推荐城市
  Future<void> loadRecommendedCities() async {
    final result = await _getRecommendedCitiesUseCase.execute(
      const GetRecommendedCitiesParams(limit: 10),
    );

    result.fold(
      onSuccess: (data) {
        recommendedCities.value = data;
        log('✅ 加载推荐城市成功: ${data.length} 个');
      },
      onFailure: (exception) {
        log('❌ 加载推荐城市失败: ${exception.message}');
      },
    );
  }

  /// 加载热门城市
  Future<void> loadPopularCities() async {
    final result = await _getPopularCitiesUseCase.execute(
      const GetPopularCitiesParams(limit: 10),
    );

    result.fold(
      onSuccess: (data) {
        popularCities.value = data;
        log('✅ 加载热门城市成功: ${data.length} 个');
      },
      onFailure: (exception) {
        log('❌ 加载热门城市失败: ${exception.message}');
      },
    );
  }

  /// 切换城市收藏状态
  Future<bool> toggleFavorite(String cityId) async {
    final result = await _toggleCityFavoriteUseCase.execute(
      ToggleCityFavoriteParams(cityId: cityId),
    );

    return result.fold(
      onSuccess: (isFavorited) {
        // 更新列表中的城市状态
        final index = cities.indexWhere((c) => c.id == cityId);
        if (index != -1) {
          cities[index] = cities[index].copyWith(isFavorite: isFavorited);
          cities.refresh();
        }
        
        // 通知其他组件收藏状态变更
        DataEventBus.instance.emit(DataChangedEvent(
          entityType: 'city_favorite',
          entityId: cityId,
          version: DateTime.now().millisecondsSinceEpoch,
          changeType: isFavorited ? DataChangeType.created : DataChangeType.deleted,
        ));
        
        log('✅ 切换收藏成功: $isFavorited');
        return true;
      },
      onFailure: (exception) {
        log('❌ 切换收藏失败: ${exception.message}');
        AppToast.error(exception.message, title: '操作失败');
        return false;
      },
    );
  }

  /// 加载收藏城市
  Future<void> loadFavoriteCities() async {
    final result = await _getFavoriteCitiesUseCase.execute(const NoParams());

    result.fold(
      onSuccess: (data) {
        favoriteCities.value = data;
        log('✅ 加载收藏城市成功: ${data.length} 个');
      },
      onFailure: (exception) {
        log('❌ 加载收藏城市失败: ${exception.message}');
      },
    );
  }

  /// 更新城市图片
  void updateCityImages(String cityId, Map<String, dynamic> imageData) {
    log('🖼️ [CityController] 更新城市图片: $cityId');

    final index = cities.indexWhere((c) => c.id == cityId);
    if (index == -1) {
      log('⚠️ [CityController] 未找到城市: $cityId');
      return;
    }

    final oldCity = cities[index];

    // 解析图片数据
    Map<String, dynamic>? data;
    if (imageData.containsKey('data') && imageData['data'] is Map<String, dynamic>) {
      data = imageData['data'] as Map<String, dynamic>;
    } else if (imageData.containsKey('portraitImage') || imageData.containsKey('landscapeImages')) {
      data = imageData;
    } else {
      data = imageData;
    }

    // 提取竖屏图片 URL
    String? portraitUrl;
    final portraitImage = data['portraitImage'];
    if (portraitImage is Map<String, dynamic>) {
      portraitUrl = portraitImage['url'] as String?;
    }

    // 提取横屏图片 URL 列表
    List<String>? landscapeUrls;
    final landscapeImages = data['landscapeImages'];
    if (landscapeImages is List && landscapeImages.isNotEmpty) {
      landscapeUrls = landscapeImages
          .where((img) => img is Map<String, dynamic> && img['url'] != null)
          .map((img) => (img as Map<String, dynamic>)['url'] as String)
          .toList();
    }

    // 如果没有解析到任何图片，不更新
    if (portraitUrl == null && (landscapeUrls == null || landscapeUrls.isEmpty)) {
      log('⚠️ [CityController] 未解析到图片URL，跳过更新');
      return;
    }

    // 使用 copyWith 只更新图片字段
    final updatedCity = oldCity.copyWith(
      portraitImageUrl: portraitUrl ?? oldCity.portraitImageUrl,
      landscapeImageUrls: landscapeUrls ?? oldCity.landscapeImageUrls,
      imageUrl: portraitUrl ?? oldCity.imageUrl,
    );

    cities[index] = updatedCity;
    cities.refresh();
    log('✅ [CityController] 城市图片已更新: portrait=$portraitUrl, landscape=${landscapeUrls?.length ?? 0}张');
  }

  /// 标记城市正在生成图片
  void markCityGeneratingImage(String cityId) {
    generatingImageCityIds.add(cityId);
  }

  /// 检查城市是否正在生成图片
  bool isCityGeneratingImage(String cityId) {
    return generatingImageCityIds.contains(cityId);
  }

  /// 检查城市是否正在生成图片 - 兼容原控制器 API
  bool isGeneratingImages(String cityId) {
    return generatingImageCityIds.contains(cityId);
  }

  /// 为城市生成 AI 图片
  ///
  /// [cityId] 城市ID
  /// 返回生成结果
  Future<Result<Map<String, dynamic>>> generateCityImages(String cityId) async {
    log('🖼️ [CityStateControllerV2] 开始生成城市图片: $cityId');

    // 标记为正在生成
    generatingImageCityIds.add(cityId);

    try {
      final result = await _cityRepository.generateCityImages(cityId);

      return result.fold(
        onSuccess: (data) {
          log('✅ [CityStateControllerV2] 图片生成任务已创建，等待 SignalR 通知');
          // 注意：这里不移除 cityId，等待 SignalR 通知时再移除
          return Success(data);
        },
        onFailure: (exception) {
          log('❌ [CityStateControllerV2] 图片生成失败: ${exception.message}');
          // 失败时移除
          generatingImageCityIds.remove(cityId);
          return Failure(exception);
        },
      );
    } catch (e) {
      log('💥 [CityStateControllerV2] 生成图片异常: $e');
      // 异常时移除
      generatingImageCityIds.remove(cityId);
      return Failure(UnknownException('生成图片失败: $e'));
    }
  }

  // ==================== 兼容旧 API ====================
  
  /// 兼容旧代码：初始加载城市
  Future<void> loadInitialCities({bool refresh = true}) async {
    if (refresh) {
      await forceRefresh();
    } else {
      await initialLoad();
    }
  }

  /// 兼容旧代码：加载更多城市
  Future<void> loadMoreCities() async {
    await loadMore();
  }

  /// 切换城市收藏状态 - 兼容原控制器 API
  Future<Result<void>> toggleCityFavorite(String cityId) async {
    final result = await _toggleCityFavoriteUseCase.execute(
      ToggleCityFavoriteParams(cityId: cityId),
    );

    return result.fold(
      onSuccess: (isFavorited) {
        // 更新列表中的城市状态
        final index = cities.indexWhere((city) => city.id == cityId);
        if (index != -1) {
          cities[index] = cities[index].copyWith(isFavorite: isFavorited);
          cities.refresh();
        }
        return const Success(null);
      },
      onFailure: (exception) {
        return Failure(exception);
      },
    );
  }

  /// 加载用户收藏城市ID列表 - 兼容原控制器 API
  Future<Result<List<String>>> loadUserFavoriteCityIds() async {
    final result = await _getFavoriteCitiesUseCase.execute(const NoParams());

    return result.fold(
      onSuccess: (cities) {
        final ids = cities.map((c) => c.id).toList();
        return Success(ids);
      },
      onFailure: (exception) {
        return Failure(exception);
      },
    );
  }
}
