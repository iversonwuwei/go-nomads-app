import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/core/sync/sync.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';
import 'package:df_admin_mobile/features/city/domain/usecases/city_rating_usecases.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/services/search_service.dart';
import 'package:df_admin_mobile/services/signalr_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 城市列表控制器 - 符合 GetX 标准
class CityListController extends GetxController {
  // 依赖注入
  final ICityRepository _cityRepository;
  final CityRatingUseCases _cityRatingUseCases;
  final SearchService _searchService;
  final CityStateController _cityStateController;

  CityListController({
    required ICityRepository cityRepository,
    required CityRatingUseCases cityRatingUseCases,
    required SearchService searchService,
    required CityStateController cityStateController,
  })  : _cityRepository = cityRepository,
        _cityRatingUseCases = cityRatingUseCases,
        _searchService = searchService,
        _cityStateController = cityStateController;

  // UI 控制器
  final searchTextController = TextEditingController();
  final scrollController = ScrollController();

  // 响应式状态
  final cities = <City>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = Rx<String?>(null);
  final searchQuery = ''.obs;
  final followedCities = <String, bool>{}.obs;

  // 本地生成中状态（响应式）
  final generatingImageCityIds = <String>{}.obs;

  // SignalR 订阅
  StreamSubscription<Map<String, dynamic>>? _cityImageUpdatedSubscription;

  // EventBus 订阅
  StreamSubscription<DataChangedEvent>? _favoriteChangedSubscription;

  // 分页配置
  int _currentPage = 1;
  static const int _pageSize = 20;

  // 私有状态
  bool _isLoadingFollowedCities = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);

    // 注意：不再使用 ever(cities, ...) 同步收藏状态
    // 收藏状态由 EventBus 监听器 _setupFavoriteChangedListener 统一管理

    // 监听 CityStateController 的城市列表变化，同步图片等数据更新
    ever(_cityStateController.cities, _syncCityUpdates);

    // 监听全局 CityStateController 的生成中集合，保证本地集合同步移除已完成的 id
    ever(_cityStateController.generatingImageCityIds, (Set<String> ids) {
      // 移除本地集合中不在全局集合内的 id（即已完成或失败）
      final toRemove = <String>[];
      for (final id in generatingImageCityIds) {
        if (!ids.contains(id)) toRemove.add(id);
      }
      if (toRemove.isNotEmpty) {
        generatingImageCityIds.removeAll(toRemove);
        log('🔁 [CityListController] 同步移除已完成的生成状态: $toRemove');
      }
    });

    // 设置 SignalR 监听器，直接处理图片更新事件
    _setupSignalRListeners();

    // 设置收藏状态变更监听器
    _setupFavoriteChangedListener();

    // 初始加载
    loadCities(refresh: true);

    // 异步加载关注状态
    Future.microtask(() => _loadFollowedCities());
  }

  /// 设置收藏状态变更监听器
  void _setupFavoriteChangedListener() {
    _favoriteChangedSubscription = DataEventBus.instance.on('city_favorite', (event) {
      if (event.entityId == null) return;

      final cityId = event.entityId!;
      final isFavorite = event.changeType == DataChangeType.created;

      log('🔔 [CityListController] 收到收藏状态变更: $cityId -> $isFavorite');

      // 更新本地 followedCities 状态
      followedCities[cityId] = isFavorite;

      // 同时更新 cities 列表中的城市状态
      final index = cities.indexWhere((c) => c.id == cityId);
      if (index != -1) {
        cities[index] = cities[index].copyWith(isFavorite: isFavorite);
        // 不需要调用 cities.refresh()，因为 followedCities 已更新，UI 会响应
      }
    });
  }

  /// 设置 SignalR 监听器
  void _setupSignalRListeners() {
    final signalRService = SignalRService();

    // 监听城市图片更新事件
    _cityImageUpdatedSubscription = signalRService.cityImageUpdatedStream.listen((data) {
      log('🖼️ [CityListController] 收到城市图片更新通知: $data');

      final cityId = data['cityId'] as String?;
      final success = data['success'] as bool? ?? false;

      if (cityId == null) {
        log('⚠️ [CityListController] 城市ID为空，忽略通知');
        return;
      }

      // 无论成功还是失败，都从生成中列表移除
      generatingImageCityIds.remove(cityId);
      log('✅ [CityListController] 已移除生成状态: $cityId, 当前生成中: ${generatingImageCityIds.length}');

      if (!success) {
        log('❌ [CityListController] 城市图片生成失败');
        return;
      }

      // 更新本地城市列表中的图片
      _updateCityImageFromSignalR(cityId, data);
    });

    log('✅ [CityListController] SignalR 城市图片更新监听已设置');
  }

  /// 从 SignalR 数据更新城市图片
  void _updateCityImageFromSignalR(String cityId, Map<String, dynamic> data) {
    final index = cities.indexWhere((c) => c.id == cityId);
    if (index == -1) {
      log('⚠️ [CityListController] 未找到城市: $cityId');
      return;
    }

    final oldCity = cities[index];

    // 提取图片 URL 并添加缓存破坏参数
    final cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
    String? portraitUrl = data['portraitImageUrl'] as String?;
    if (portraitUrl != null && portraitUrl.isNotEmpty) {
      portraitUrl = _appendCacheBuster(portraitUrl, cacheBuster);
    }

    List<String>? landscapeUrls;
    final landscapeImages = data['landscapeImageUrls'];
    if (landscapeImages is List && landscapeImages.isNotEmpty) {
      landscapeUrls = landscapeImages.cast<String>().map((url) => _appendCacheBuster(url, cacheBuster)).toList();
    }

    // 使用 copyWith 更新图片字段
    final updatedCity = oldCity.copyWith(
      portraitImageUrl: portraitUrl ?? oldCity.portraitImageUrl,
      landscapeImageUrls: landscapeUrls ?? oldCity.landscapeImageUrls,
      imageUrl: portraitUrl ?? oldCity.imageUrl,
    );

    cities[index] = updatedCity;
    cities.refresh(); // 强制触发 Obx 更新
    log('✅ [CityListController] 城市图片已更新: ${updatedCity.name}, imageUrl: ${updatedCity.imageUrl}');
  }

  /// 同步 CityStateController 中的城市更新到本地列表
  void _syncCityUpdates(List<City> updatedCities) {
    bool hasUpdates = false;
    final cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();

    for (final updatedCity in updatedCities) {
      final index = cities.indexWhere((c) => c.id == updatedCity.id);
      if (index != -1) {
        // 只同步图片相关字段更新
        final localCity = cities[index];
        if (localCity.imageUrl != updatedCity.imageUrl ||
            localCity.portraitImageUrl != updatedCity.portraitImageUrl ||
            localCity.landscapeImageUrls != updatedCity.landscapeImageUrls) {
          // 添加缓存破坏参数
          final newImageUrl = updatedCity.imageUrl != null
              ? _appendCacheBuster(updatedCity.imageUrl!, cacheBuster)
              : localCity.imageUrl;
          final newPortraitUrl = updatedCity.portraitImageUrl != null
              ? _appendCacheBuster(updatedCity.portraitImageUrl!, cacheBuster)
              : localCity.portraitImageUrl;
          final newLandscapeUrls = updatedCity.landscapeImageUrls != null
              ? updatedCity.landscapeImageUrls!.map((url) => _appendCacheBuster(url, cacheBuster)).toList()
              : localCity.landscapeImageUrls;

          cities[index] = localCity.copyWith(
            imageUrl: newImageUrl,
            portraitImageUrl: newPortraitUrl,
            landscapeImageUrls: newLandscapeUrls,
          );
          hasUpdates = true;
          log('🔄 [CityListController] 同步城市图片更新: ${updatedCity.name}');
        }
      }
    }

    if (hasUpdates) {
      cities.refresh(); // 强制触发 Obx 更新
    }
  }

  /// 添加缓存破坏参数到 URL
  String _appendCacheBuster(String url, String cacheBuster) {
    if (url.isEmpty) return url;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=$cacheBuster';
  }

  @override
  void onClose() {
    searchTextController.dispose();
    scrollController.dispose();
    _cityImageUpdatedSubscription?.cancel();
    _cityImageUpdatedSubscription = null;
    _favoriteChangedSubscription?.cancel();
    _favoriteChangedSubscription = null;
    super.onClose();
  }

  // ==================== 数据加载 ====================

  /// 加载城市列表
  Future<void> loadCities({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    isLoading.value = true;
    errorMessage.value = null;
    _currentPage = 1;

    try {
      if (searchQuery.value.isNotEmpty) {
        await _searchCities(searchQuery.value);
      } else {
        await _loadFromDatabase();
      }
    } catch (e) {
      errorMessage.value = '加载失败: $e';
      log('❌ CityListController: 加载异常 - $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;

    try {
      if (searchQuery.value.isNotEmpty) {
        await _loadMoreFromSearch();
      } else {
        await _loadMoreFromDatabase();
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 搜索城市
  Future<void> search(String query) async {
    searchQuery.value = query.trim();
    await loadCities(refresh: true);
  }

  /// 清除搜索
  Future<void> clearSearch() async {
    searchTextController.clear();
    searchQuery.value = '';
    await loadCities(refresh: true);
  }

  // ==================== 私有方法 ====================

  Future<void> _searchCities(String query) async {
    log('🔍 搜索城市: $query');

    // 先尝试 Elasticsearch
    final esResult = await _searchService.searchCities(
      query: query,
      page: 1,
      pageSize: _pageSize,
    );

    bool esSuccess = false;
    esResult.fold(
      onSuccess: (data) {
        final cityList = data.items.map((item) => _convertSearchDocToCity(item.document)).toList();
        cities.assignAll(cityList);
        hasMore.value = data.totalCount > cityList.length;
        log('✅ ES搜索成功: ${cityList.length} 个城市');
        AppToast.success('Found ${cityList.length} cities (ES)');
        esSuccess = true;
      },
      onFailure: (error) {
        log('⚠️ ES搜索失败: ${error.message}');
      },
    );

    if (esSuccess) return;

    // ES 失败，回退到数据库
    log('⚠️ ES搜索失败，回退到数据库');
    final dbResult = await _cityRepository.searchCities(name: query, pageSize: _pageSize);

    dbResult.fold(
      onSuccess: (data) {
        cities.assignAll(data);
        hasMore.value = data.length >= _pageSize;
        log('✅ 数据库搜索成功: ${data.length} 个城市');
        AppToast.warning('Found ${data.length} cities (DB fallback)');
      },
      onFailure: (error) {
        errorMessage.value = error.message;
        log('❌ 数据库搜索失败: ${error.message}');
      },
    );
  }

  Future<void> _loadFromDatabase() async {
    final result = await _cityRepository.getCitiesBasic(page: 1, pageSize: _pageSize);

    result.fold(
      onSuccess: (data) {
        cities.assignAll(data);
        hasMore.value = data.length >= _pageSize;
        log('✅ 加载了 ${data.length} 个城市');

        // 从城市数据初始化收藏状态
        for (final city in data) {
          followedCities[city.id] = city.isFavorite;
        }

        // 异步补充数据
        if (data.isNotEmpty) {
          final ids = data.map((c) => c.id).toList();
          Future.microtask(() => _loadCityCountsAsync(ids));
          Future.microtask(() => _loadCityRatingsAsync(ids));
        }
      },
      onFailure: (error) {
        errorMessage.value = error.message;
        log('❌ 加载失败: ${error.message}');
      },
    );
  }

  Future<void> _loadMoreFromSearch() async {
    final esResult = await _searchService.searchCities(
      query: searchQuery.value,
      page: _currentPage + 1,
      pageSize: _pageSize,
    );

    bool esSuccess = false;
    esResult.fold(
      onSuccess: (data) {
        if (data.items.isEmpty) {
          hasMore.value = false;
        } else {
          final cityList = data.items.map((item) => _convertSearchDocToCity(item.document)).toList();
          cities.addAll(cityList);
          _currentPage++;
          hasMore.value = cities.length < data.totalCount;
        }
        esSuccess = true;
      },
      onFailure: (error) {
        log('⚠️ ES加载更多失败: ${error.message}');
      },
    );

    if (!esSuccess) {
      // ES 失败则不加载更多
    }
  }

  Future<void> _loadMoreFromDatabase() async {
    final result = await _cityRepository.getCitiesBasic(
      page: _currentPage + 1,
      pageSize: _pageSize,
    );

    result.fold(
      onSuccess: (data) {
        if (data.isEmpty) {
          hasMore.value = false;
        } else {
          cities.addAll(data);
          _currentPage++;
          hasMore.value = data.length >= _pageSize;

          final ids = data.map((c) => c.id).toList();
          Future.microtask(() => _loadCityCountsAsync(ids));
          Future.microtask(() => _loadCityRatingsAsync(ids));
        }
      },
      onFailure: (error) {
        log('❌ 加载更多失败: ${error.message}');
      },
    );
  }

  /// 异步加载聚合数据
  Future<void> _loadCityCountsAsync(List<String> cityIds) async {
    if (cityIds.isEmpty) return;
    try {
      final result = await _cityRepository.getCityCountsBatch(cityIds);
      result.fold(
        onSuccess: (countsMap) {
          for (var i = 0; i < cities.length; i++) {
            final city = cities[i];
            final counts = countsMap[city.id];
            if (counts != null) {
              cities[i] = city.copyWith(
                meetupCount: counts.meetupCount,
                coworkingCount: counts.coworkingCount,
                reviewCount: counts.reviewCount,
                averageCost: counts.averageCost,
              );
            }
          }
          cities.refresh();
          log('✅ 异步补充聚合数据: ${countsMap.length} 个城市');
        },
        onFailure: (error) {
          log('⚠️ 聚合数据加载失败: ${error.message}');
        },
      );
    } catch (e) {
      log('⚠️ 聚合数据加载异常: $e');
    }
  }

  /// 异步加载评分
  Future<void> _loadCityRatingsAsync(List<String> cityIds) async {
    if (cityIds.isEmpty) return;
    log('📊 开始异步加载评分: ${cityIds.length} 个城市');
    for (final cityId in cityIds) {
      try {
        final info = await _cityRatingUseCases.getCityRatings(cityId);
        log('📊 获取到评分: cityId=$cityId, overallScore=${info.overallScore}');
        final idx = cities.indexWhere((c) => c.id == cityId);
        if (idx != -1) {
          final oldScore = cities[idx].overallScore;
          cities[idx] = cities[idx].copyWith(overallScore: info.overallScore);
          log('📊 更新城市评分: ${cities[idx].name} $oldScore -> ${info.overallScore}');
        }
      } catch (e) {
        log('⚠️ 评分加载失败: cityId=$cityId, error=$e');
      }
    }
    cities.refresh();
    log('📊 评分异步加载完成');
  }

  City _convertSearchDocToCity(CitySearchDocument doc) {
    return City(
      id: doc.id,
      name: doc.name,
      nameEn: doc.nameEn,
      country: doc.country,
      region: doc.region,
      description: doc.description,
      latitude: doc.latitude ?? 0,
      longitude: doc.longitude ?? 0,
      imageUrl: doc.imageUrl,
      portraitImageUrl: doc.portraitImageUrl,
      timezone: doc.timeZone,
      currency: doc.currency,
      overallScore: doc.overallScore,
      internetScore: doc.internetQualityScore,
      safetyScore: doc.safetyScore,
      costScore: doc.costScore,
      communityScore: doc.communityScore,
      weatherScore: doc.weatherScore,
      tags: doc.tags,
      averageCost: doc.averageCost,
      meetupCount: doc.meetupCount,
      coworkingCount: doc.coworkingCount,
      reviewCount: doc.reviewCount,
      moderatorId: doc.moderatorId,
    );
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    if (currentScroll >= maxScroll - 300) {
      loadMore();
    }
  }

  // ==================== 城市查询 ====================

  /// 根据 ID 获取城市（从响应式列表中获取，确保数据更新时自动刷新）
  City? getCityById(String cityId) {
    return cities.firstWhereOrNull((city) => city.id == cityId);
  }

  // ==================== 关注功能 ====================

  bool isCityFollowed(String cityId) {
    return followedCities[cityId] ?? false;
  }

  Future<void> toggleFollow(City city) async {
    final cityId = city.id;
    if (_isLoadingFollowedCities) return;

    final previousState = followedCities[cityId] ?? false;

    // 乐观更新
    followedCities[cityId] = !previousState;

    try {
      final result = await _cityStateController.toggleCityFavorite(cityId);

      result.fold(
        onSuccess: (_) {
          final isNowFollowed = followedCities[cityId] ?? false;
          AppToast.success(isNowFollowed ? '已关注该城市' : '已取消关注');
          log('✅ 城市关注状态切换成功: cityId=$cityId, followed=$isNowFollowed');
        },
        onFailure: (error) {
          followedCities[cityId] = previousState;
          AppToast.error('操作失败，请重试');
          log('❌ 切换关注状态失败: $error');
        },
      );
    } catch (e) {
      log('❌ 切换关注状态失败: $e');
      followedCities[cityId] = previousState;
      AppToast.error('操作失败: $e');
    }
  }

  Future<void> _loadFollowedCities() async {
    if (_isLoadingFollowedCities) return;

    _isLoadingFollowedCities = true;
    try {
      final result = await _cityStateController.loadUserFavoriteCityIds();

      result.fold(
        onSuccess: (cityIds) {
          followedCities.clear();
          for (var cityId in cityIds) {
            followedCities[cityId] = true;
          }
          log('✅ 已加载 ${cityIds.length} 个关注的城市');
        },
        onFailure: (error) {
          log('❌ 加载关注城市列表失败: $error');
        },
      );
    } catch (e) {
      log('❌ 加载关注城市列表失败: $e');
    } finally {
      _isLoadingFollowedCities = false;
    }
  }

  // ==================== 图片生成 ====================

  /// 检查城市是否正在生成图片（使用本地响应式状态）
  bool isGeneratingImages(String cityId) {
    return generatingImageCityIds.contains(cityId);
  }

  Future<void> generateCityImages(String cityId, String cityName) async {
    if (generatingImageCityIds.contains(cityId)) return;

    final authController = Get.find<AuthStateController>();
    if (!authController.isAuthenticated.value) {
      AppToast.warning('Please login to generate images', title: 'Login Required');
      Get.toNamed(AppRoutes.login);
      return;
    }

    final user = authController.currentUser.value;
    final userRole = user?.role.toLowerCase() ?? '';
    if (userRole != 'admin') {
      AppToast.warning('Only administrators can generate images', title: 'Permission Denied');
      return;
    }

    // 标记为正在生成（使用本地状态）
    generatingImageCityIds.add(cityId);
    log('🖼️ [CityListController] 开始生成图片: $cityId, 当前生成中: ${generatingImageCityIds.length}');

    AppToast.info(
      'AI image generation task created for $cityName.\nYou will be notified when complete.',
      title: 'Task Created',
    );

    final result = await _cityStateController.generateCityImages(cityId);

    result.fold(
      onSuccess: (data) {
        final taskData = data['data'] as Map<String, dynamic>?;
        final taskId = taskData?['taskId'] as String? ?? '';
        log('🖼️ Image generation task created: taskId=$taskId');
        // 注意：不在这里移除 cityId，等待 SignalR 通知时再移除
      },
      onFailure: (exception) {
        // 失败时移除生成状态
        generatingImageCityIds.remove(cityId);
        AppToast.error(exception.message, title: 'Task Creation Failed');
      },
    );
  }
}
