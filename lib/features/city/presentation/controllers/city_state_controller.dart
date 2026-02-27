import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/core.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/city/application/use_cases/city_use_cases.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/city/domain/repositories/i_city_repository.dart';
import 'package:go_nomads_app/services/signalr_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 城市列表控制器 - 使用新的数据同步框架优化版本
///
/// 改进点：
/// 1. 继承 PaginatedRefreshableController，统一分页和刷新逻辑
/// 2. 使用 hybrid 刷新策略：时间过期 + 事件驱动
/// 3. 自动订阅数据变更事件
/// 4. 统一的加载状态管理
/// 5. 防重复请求机制
class CityStateController extends PaginatedRefreshableController {
  // ==================== Dependencies ====================
  final GetCitiesUseCase _getCitiesUseCase;
  final GetRecommendedCitiesUseCase _getRecommendedCitiesUseCase;
  final GetPopularCitiesUseCase _getPopularCitiesUseCase;
  final ToggleCityFavoriteUseCase _toggleCityFavoriteUseCase;
  final GetFavoriteCitiesUseCase _getFavoriteCitiesUseCase;
  final ICityRepository _cityRepository;

  CityStateController({
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
  StreamSubscription<Map<String, dynamic>>? _cityModeratorUpdatedSubscription;

  // 图片生成任务轮询回退 (cityId -> Timer)
  final Map<String, Timer> _imageTaskPollingTimers = {};

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

    // ⚡ 优化：延迟加载数据，避免启动时阻塞
    // 数据将在首页显示时按需加载，或由 ensureDataLoaded() 触发
    log('🎬 CityStateController 初始化完成（延迟加载模式）');
  }

  /// 确保数据已加载（供页面调用）
  /// 如果数据未加载，则触发加载
  Future<void> ensureDataLoaded() async {
    if (cities.isEmpty && !isLoading.value) {
      log('📦 CityStateController: 触发首次数据加载');
      await initialLoad();
      // 并行加载推荐和热门城市
      loadRecommendedCities();
      loadPopularCities();
    }
  }

  @override
  void onClose() {
    _cityImageUpdatedSubscription?.cancel();
    _cityImageUpdatedSubscription = null;
    _cityModeratorUpdatedSubscription?.cancel();
    _cityModeratorUpdatedSubscription = null;
    _dataChangedSubscription?.cancel();
    _dataChangedSubscription = null;

    // 取消所有图片生成轮询定时器
    for (final timer in _imageTaskPollingTimers.values) {
      timer.cancel();
    }
    _imageTaskPollingTimers.clear();

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

    // 监听收藏状态变更事件
    DataEventBus.instance.on('city_favorite', _handleFavoriteChanged);

    // 监听评论变更事件（评论数和评分会影响城市列表显示）
    DataEventBus.instance.on('city_review', _handleReviewChanged);

    // 监听评分变更事件（静默更新列表中的城市评分）
    DataEventBus.instance.on('city_rating', _handleRatingChanged);
  }

  /// 处理评分变更事件（静默更新，不请求后端）
  void _handleRatingChanged(DataChangedEvent event) {
    log('🔔 [城市列表] _handleRatingChanged 被调用: entityId=${event.entityId}, metadata=${event.metadata}');

    if (event.entityId == null) return;

    final rawScore = event.metadata?['overallScore'];
    final newScore = rawScore is num ? rawScore.toDouble() : null;
    if (newScore == null) {
      log('⚠️ [城市列表] newScore 为 null，跳过');
      return;
    }

    log('🔔 [城市列表] 收到评分变更通知: ${event.entityId}, newScore=$newScore');

    // 更新主列表
    final index = cities.indexWhere((c) => c.id == event.entityId);
    if (index != -1) {
      cities[index] = cities[index].copyWith(overallScore: newScore);
      cities.refresh();
      log('✅ [城市列表] 已静默更新城市评分: ${cities[index].name} -> $newScore');
    }

    // 更新推荐列表
    final recIndex = recommendedCities.indexWhere((c) => c.id == event.entityId);
    if (recIndex != -1) {
      recommendedCities[recIndex] = recommendedCities[recIndex].copyWith(overallScore: newScore);
      recommendedCities.refresh();
    }

    // 更新热门列表
    final popIndex = popularCities.indexWhere((c) => c.id == event.entityId);
    if (popIndex != -1) {
      popularCities[popIndex] = popularCities[popIndex].copyWith(overallScore: newScore);
      popularCities.refresh();
    }

    // 更新收藏列表
    final favIndex = favoriteCities.indexWhere((c) => c.id == event.entityId);
    if (favIndex != -1) {
      favoriteCities[favIndex] = favoriteCities[favIndex].copyWith(overallScore: newScore);
      favoriteCities.refresh();
    }
  }

  /// 处理评论变更事件
  void _handleReviewChanged(DataChangedEvent event) {
    if (event.entityId == null) return;

    log('🔔 [城市列表] 收到评论变更通知: ${event.entityId} (${event.changeType})');

    // 检查城市是否在列表中
    final index = cities.indexWhere((c) => c.id == event.entityId);
    log('🔍 [城市列表] 城市在列表中的索引: $index (总数: ${cities.length})');

    if (index != -1) {
      log('🔍 [城市列表] 更新前: ${cities[index].name}, score=${cities[index].overallScore}, reviewCount=${cities[index].reviewCount}');
    }

    // 评论变更会影响城市的评分和评论数，需要更新该城市在列表中的数据
    _updateCityInList(event.entityId!);
  }

  /// 处理收藏状态变更事件
  void _handleFavoriteChanged(DataChangedEvent event) {
    if (event.entityId == null) return;

    final cityId = event.entityId!;
    final isFavorite = event.changeType == DataChangeType.created;

    log('🔔 [城市列表] 收到收藏状态变更: $cityId -> $isFavorite');

    // 更新主列表中的城市状态
    final index = cities.indexWhere((c) => c.id == cityId);
    if (index != -1) {
      cities[index] = cities[index].copyWith(isFavorite: isFavorite);
      cities.refresh();
      log('✅ [城市列表] 已更新城市收藏状态: ${cities[index].name}');
    }

    // 更新推荐城市列表
    final recIndex = recommendedCities.indexWhere((c) => c.id == cityId);
    if (recIndex != -1) {
      recommendedCities[recIndex] = recommendedCities[recIndex].copyWith(isFavorite: isFavorite);
      recommendedCities.refresh();
    }

    // 更新热门城市列表
    final popIndex = popularCities.indexWhere((c) => c.id == cityId);
    if (popIndex != -1) {
      popularCities[popIndex] = popularCities[popIndex].copyWith(isFavorite: isFavorite);
      popularCities.refresh();
    }

    // 更新收藏列表
    if (isFavorite) {
      // 添加到收藏列表（如果不存在）
      final favIndex = favoriteCities.indexWhere((c) => c.id == cityId);
      if (favIndex == -1 && index != -1) {
        favoriteCities.add(cities[index]);
      }
    } else {
      // 从收藏列表移除
      favoriteCities.removeWhere((c) => c.id == cityId);
    }
  }

  /// 设置 SignalR 监听器
  void _setupSignalRListeners() {
    final signalRService = SignalRService();

    // 监听城市图片更新事件
    _cityImageUpdatedSubscription = signalRService.cityImageUpdatedStream.listen((data) {
      log('🖼️ [CityController] 收到城市图片更新通知 (SignalR): $data');

      final cityId = data['cityId'] as String?;
      final success = data['success'] as bool? ?? false;

      if (cityId == null) {
        log('⚠️ [CityController] 城市ID为空，忽略通知');
        return;
      }

      // 取消该城市的轮询定时器（SignalR 已收到，无需继续轮询）
      _cancelPollingTimer(cityId);

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

    // 监听城市版主变更事件 (来自其他设备的审核操作)
    _cityModeratorUpdatedSubscription = signalRService.cityModeratorUpdatedStream.listen((data) {
      log('👤 [CityController] 收到城市版主变更通知: $data');

      final cityId = data['cityId'] as String?;
      if (cityId == null) {
        log('⚠️ [CityController] 城市ID为空，忽略通知');
        return;
      }

      // 仅更新版主字段（轻量接口）
      _updateCityModeratorInList(cityId);
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
      log('📡 [城市列表] 开始获取城市最新数据: $cityId');
      final result = await _cityRepository.getCityById(cityId);
      result.fold(
        onSuccess: (updatedCity) {
          log('📦 [城市列表] 获取到城市数据: ${updatedCity.name}, score=${updatedCity.overallScore}, reviewCount=${updatedCity.reviewCount}');
          final index = cities.indexWhere((c) => c.id == cityId);
          if (index != -1) {
            log('🔄 [城市列表] 更新前: score=${cities[index].overallScore}, reviewCount=${cities[index].reviewCount}');
            cities[index] = updatedCity;
            cities.refresh(); // 触发 Obx 更新
            log('✅ [城市列表] 更新后: score=${cities[index].overallScore}, reviewCount=${cities[index].reviewCount}');
          } else {
            log('⚠️ [城市列表] 城市不在列表中: $cityId');
          }
        },
        onFailure: (e) {
          log('⚠️ [城市列表] 更新城市失败: ${e.message}');
        },
      );
    } catch (e) {
      log('⚠️ [城市列表] 更新城市异常: $e');
    }
  }

  /// 仅更新城市版主字段
  Future<void> _updateCityModeratorInList(String cityId) async {
    try {
      log('📡 [城市列表] 开始获取城市版主摘要: $cityId');
      final result = await _cityRepository.getCityModeratorSummary(cityId);
      result.fold(
        onSuccess: (summary) {
          final index = cities.indexWhere((c) => c.id == cityId);
          if (index != -1) {
            cities[index] = cities[index].copyWith(
              moderatorId: summary.moderatorId,
              moderator: summary.moderator,
              isCurrentUserModerator: summary.isCurrentUserModerator,
              isCurrentUserAdmin: summary.isCurrentUserAdmin,
            );
            cities.refresh();
          }

          final recIndex = recommendedCities.indexWhere((c) => c.id == cityId);
          if (recIndex != -1) {
            recommendedCities[recIndex] = recommendedCities[recIndex].copyWith(
              moderatorId: summary.moderatorId,
              moderator: summary.moderator,
              isCurrentUserModerator: summary.isCurrentUserModerator,
              isCurrentUserAdmin: summary.isCurrentUserAdmin,
            );
            recommendedCities.refresh();
          }

          final popIndex = popularCities.indexWhere((c) => c.id == cityId);
          if (popIndex != -1) {
            popularCities[popIndex] = popularCities[popIndex].copyWith(
              moderatorId: summary.moderatorId,
              moderator: summary.moderator,
              isCurrentUserModerator: summary.isCurrentUserModerator,
              isCurrentUserAdmin: summary.isCurrentUserAdmin,
            );
            popularCities.refresh();
          }

          final favIndex = favoriteCities.indexWhere((c) => c.id == cityId);
          if (favIndex != -1) {
            favoriteCities[favIndex] = favoriteCities[favIndex].copyWith(
              moderatorId: summary.moderatorId,
              moderator: summary.moderator,
              isCurrentUserModerator: summary.isCurrentUserModerator,
              isCurrentUserAdmin: summary.isCurrentUserAdmin,
            );
            favoriteCities.refresh();
          }

          log('✅ [城市列表] 版主字段已更新: moderatorId=${summary.moderatorId}, moderator=${summary.moderator?.name}');
        },
        onFailure: (e) {
          log('⚠️ [城市列表] 获取版主摘要失败: ${e.message}');
        },
      );
    } catch (e) {
      log('⚠️ [城市列表] 获取版主摘要异常: $e');
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
    // 从本地列表获取已知收藏状态，避免额外 HTTP 请求
    final city = cities.firstWhereOrNull((c) => c.id == cityId) ??
        recommendedCities.firstWhereOrNull((c) => c.id == cityId) ??
        popularCities.firstWhereOrNull((c) => c.id == cityId);
    final result = await _toggleCityFavoriteUseCase.execute(
      ToggleCityFavoriteParams(
        cityId: cityId,
        currentIsFavorited: city?.isFavorite,
      ),
    );

    return result.fold(
      onSuccess: (isFavorited) {
        // 通知其他组件收藏状态变更（包括自己的 _handleFavoriteChanged）
        // 不在这里直接更新列表，统一由 _handleFavoriteChanged 处理，避免二次更新
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

    // 缓存破坏参数
    final cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();

    // 提取竖屏图片 URL
    String? portraitUrl;
    final portraitImage = data['portraitImage'];
    if (portraitImage is Map<String, dynamic>) {
      portraitUrl = portraitImage['url'] as String?;
      if (portraitUrl != null && portraitUrl.isNotEmpty) {
        portraitUrl = _appendCacheBuster(portraitUrl, cacheBuster);
      }
    }

    // 提取横屏图片 URL 列表
    List<String>? landscapeUrls;
    final landscapeImages = data['landscapeImages'];
    if (landscapeImages is List && landscapeImages.isNotEmpty) {
      landscapeUrls = landscapeImages
          .where((img) => img is Map<String, dynamic> && img['url'] != null)
          .map((img) => _appendCacheBuster((img as Map<String, dynamic>)['url'] as String, cacheBuster))
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

  /// 添加缓存破坏参数到 URL
  String _appendCacheBuster(String url, String cacheBuster) {
    if (url.isEmpty) return url;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=$cacheBuster';
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
  ///
  /// 1. 确保 SignalR 已连接（尝试重连）
  /// 2. 调用后端 API 创建异步图片生成任务
  /// 3. 启动轮询回退机制（防止 SignalR 未连接时永远卡在加载状态）
  Future<Result<Map<String, dynamic>>> generateCityImages(String cityId) async {
    log('🖼️ [CityStateController] 开始生成城市图片: $cityId');

    // 标记为正在生成
    generatingImageCityIds.add(cityId);

    // 1. 确保 SignalR 已连接并加入用户组（最佳努力，不阻塞主流程）
    _ensureSignalRForImageGeneration();

    try {
      final result = await _cityRepository.generateCityImages(cityId);

      return result.fold(
        onSuccess: (data) {
          log('✅ [CityStateController] 图片生成任务已创建，等待 SignalR 通知 + 轮询回退');

          // 2. 提取 taskId，启动轮询回退
          final taskId = data['data']?['taskId'] as String?;
          if (taskId != null) {
            _startImageTaskPolling(cityId, taskId);
          } else {
            log('⚠️ [CityStateController] 未获取到 taskId，无法启动轮询回退');
            // 设置超时兜底：5 分钟后强制移除加载状态
            _startTimeoutFallback(cityId);
          }

          return Success(data);
        },
        onFailure: (exception) {
          log('❌ [CityStateController] 图片生成失败: ${exception.message}');
          generatingImageCityIds.remove(cityId);
          return Failure(exception);
        },
      );
    } catch (e) {
      log('💥 [CityStateController] 生成图片异常: $e');
      generatingImageCityIds.remove(cityId);
      return Failure(UnknownException('生成图片失败: $e'));
    }
  }

  /// 确保 SignalR 已连接（用于图片生成前）
  void _ensureSignalRForImageGeneration() {
    final signalRService = SignalRService();
    if (signalRService.isConnected) return;

    // 异步尝试重连，不阻塞主流程
    Future.microtask(() async {
      try {
        final userId = _getCurrentUserId();
        final connected = await signalRService.ensureConnected(
          userId: userId,
          maxRetries: 2,
        );
        if (connected) {
          log('✅ [CityStateController] SignalR 重连成功');
        } else {
          log('⚠️ [CityStateController] SignalR 重连失败，将依赖轮询回退');
        }
      } catch (e) {
        log('⚠️ [CityStateController] SignalR 重连异常: $e');
      }
    });
  }

  /// 获取当前用户 ID
  String? _getCurrentUserId() {
    try {
      final authController = Get.find<AuthStateController>();
      return authController.currentUser.value?.id;
    } catch (_) {
      return null;
    }
  }

  /// 启动图片生成任务轮询（轮询回退机制）
  ///
  /// 每 5 秒查询一次任务状态，最多轮询 60 次（5 分钟）
  /// 当 SignalR 事件先到达时，轮询定时器会被取消
  void _startImageTaskPolling(String cityId, String taskId) {
    // 取消之前的轮询（如果有）
    _cancelPollingTimer(cityId);

    log('⏰ [CityStateController] 启动图片生成轮询回退: cityId=$cityId, taskId=$taskId');

    var pollCount = 0;
    const maxPolls = 60; // 最多轮询 5 分钟 (60 * 5秒)
    const pollInterval = Duration(seconds: 5);

    _imageTaskPollingTimers[cityId] = Timer.periodic(pollInterval, (timer) async {
      pollCount++;

      // 如果已经不在生成列表中（SignalR 事件已处理），停止轮询
      if (!generatingImageCityIds.contains(cityId)) {
        log('ℹ️ [CityStateController] 轮询停止：城市 $cityId 已不在生成列表中');
        timer.cancel();
        _imageTaskPollingTimers.remove(cityId);
        return;
      }

      // 超过最大轮询次数，强制结束
      if (pollCount > maxPolls) {
        log('⏰ [CityStateController] 轮询超时：cityId=$cityId, 已轮询 $pollCount 次');
        timer.cancel();
        _imageTaskPollingTimers.remove(cityId);
        generatingImageCityIds.remove(cityId);
        AppToast.error('图片生成超时，请稍后刷新页面查看', title: '生成超时');
        return;
      }

      // 查询任务状态
      try {
        final statusResult = await _cityRepository.checkImageTaskStatus(taskId);
        statusResult.fold(
          onSuccess: (statusData) {
            final taskData = statusData['data'] as Map<String, dynamic>?;
            final status = taskData?['status'] as String? ?? '';

            log('🔍 [CityStateController] 轮询任务状态 ($pollCount/$maxPolls): taskId=$taskId, status=$status');

            if (status == 'completed') {
              log('✅ [CityStateController] 轮询检测到任务完成: cityId=$cityId');
              timer.cancel();
              _imageTaskPollingTimers.remove(cityId);

              // 处理完成：从生成列表移除，刷新城市数据
              generatingImageCityIds.remove(cityId);
              _refreshCityAfterImageGeneration(cityId);
            } else if (status == 'failed') {
              log('❌ [CityStateController] 轮询检测到任务失败: cityId=$cityId');
              timer.cancel();
              _imageTaskPollingTimers.remove(cityId);

              generatingImageCityIds.remove(cityId);
              final errorMsg = taskData?['error'] as String? ?? '图片生成失败';
              AppToast.error(errorMsg, title: '图片生成失败');
            }
            // status == 'processing' 或其他状态，继续轮询
          },
          onFailure: (e) {
            log('⚠️ [CityStateController] 轮询查询失败 ($pollCount): ${e.message}');
            // 查询失败不终止轮询，继续尝试
          },
        );
      } catch (e) {
        log('⚠️ [CityStateController] 轮询异常 ($pollCount): $e');
      }
    });
  }

  /// 超时兜底（没有 taskId 时使用）
  void _startTimeoutFallback(String cityId) {
    _cancelPollingTimer(cityId);

    _imageTaskPollingTimers[cityId] = Timer(const Duration(minutes: 5), () {
      if (generatingImageCityIds.contains(cityId)) {
        log('⏰ [CityStateController] 超时兜底触发: cityId=$cityId');
        generatingImageCityIds.remove(cityId);
        _imageTaskPollingTimers.remove(cityId);

        // 尝试刷新城市数据（可能图片已生成但通知丢失）
        _refreshCityAfterImageGeneration(cityId);
      }
    });
  }

  /// 取消指定城市的轮询定时器
  void _cancelPollingTimer(String cityId) {
    final timer = _imageTaskPollingTimers.remove(cityId);
    if (timer != null) {
      timer.cancel();
      log('🛑 [CityStateController] 已取消轮询定时器: cityId=$cityId');
    }
  }

  /// 图片生成完成后刷新城市数据
  ///
  /// 从后端重新获取城市最新数据（包含新生成的图片 URL）
  Future<void> _refreshCityAfterImageGeneration(String cityId) async {
    try {
      log('🔄 [CityStateController] 刷新城市数据（图片生成后）: $cityId');
      final result = await _cityRepository.getCityById(cityId);
      result.fold(
        onSuccess: (updatedCity) {
          // 更新所有列表中的该城市
          _updateCityInAllLists(cityId, updatedCity);
          AppToast.success('${updatedCity.name} 的图片已更新', title: '图片生成完成');
          log('✅ [CityStateController] 城市数据已刷新: ${updatedCity.name}');
        },
        onFailure: (e) {
          log('⚠️ [CityStateController] 刷新城市数据失败: ${e.message}');
        },
      );
    } catch (e) {
      log('⚠️ [CityStateController] 刷新城市数据异常: $e');
    }
  }

  /// 更新所有列表中的城市数据
  void _updateCityInAllLists(String cityId, City updatedCity) {
    final index = cities.indexWhere((c) => c.id == cityId);
    if (index != -1) {
      cities[index] = updatedCity;
      cities.refresh();
    }

    final recIndex = recommendedCities.indexWhere((c) => c.id == cityId);
    if (recIndex != -1) {
      recommendedCities[recIndex] = updatedCity;
      recommendedCities.refresh();
    }

    final popIndex = popularCities.indexWhere((c) => c.id == cityId);
    if (popIndex != -1) {
      popularCities[popIndex] = updatedCity;
      popularCities.refresh();
    }

    final favIndex = favoriteCities.indexWhere((c) => c.id == cityId);
    if (favIndex != -1) {
      favoriteCities[favIndex] = updatedCity;
      favoriteCities.refresh();
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
    // 从本地列表获取已知收藏状态，避免额外 HTTP 请求
    final city = cities.firstWhereOrNull((c) => c.id == cityId) ??
        recommendedCities.firstWhereOrNull((c) => c.id == cityId) ??
        popularCities.firstWhereOrNull((c) => c.id == cityId);
    final result = await _toggleCityFavoriteUseCase.execute(
      ToggleCityFavoriteParams(
        cityId: cityId,
        currentIsFavorited: city?.isFavorite,
      ),
    );

    return result.fold(
      onSuccess: (isFavorited) {
        // 通知其他组件收藏状态变更（包括自己的 _handleFavoriteChanged）
        // 不在这里直接更新列表，统一由 _handleFavoriteChanged 处理，避免二次更新
        DataEventBus.instance.emit(DataChangedEvent(
          entityType: 'city_favorite',
          entityId: cityId,
          version: DateTime.now().millisecondsSinceEpoch,
          changeType: isFavorited ? DataChangeType.created : DataChangeType.deleted,
        ));

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
