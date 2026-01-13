import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/core/sync/data_sync_service.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller.dart';
import 'package:df_admin_mobile/services/search_service.dart';
import 'package:df_admin_mobile/services/signalr_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 城市列表页面控制器
/// 使用独立的本地数据列表，与首页数据完全独立
class CityListController extends GetxController {
  final ICityRepository _cityRepository = Get.find<ICityRepository>();
  final SearchService _searchService = Get.find<SearchService>();
  final CityStateController _cityStateController = Get.find<CityStateController>();

  // 文本控制器
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // 搜索状态
  final RxString searchQuery = ''.obs;

  // 城市数据状态
  final RxList<City> cities = <City>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  // 关注状态
  final RxMap<String, bool> followedCities = <String, bool>{}.obs;
  final RxBool isLoadingFollowedCities = false.obs;

  // 事件订阅
  StreamSubscription<DataChangedEvent>? _favoriteChangedSubscription;
  StreamSubscription<Map<String, dynamic>>? _cityImageUpdatedSubscription;

  // 分页
  int _currentPage = 1;
  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);

    // 监听收藏状态变更事件（来自其他页面，如详情页）
    _favoriteChangedSubscription = DataEventBus.instance.on('city_favorite', _handleFavoriteChanged);

    // 监听城市图片更新事件（来自 SignalR）
    _setupSignalRListeners();

    // 页面初始化时加载数据
    log('🏙️ CityListController 初始化，独立加载城市数据（不影响首页）');
    loadCities(refresh: true);

    // 异步加载关注状态
    _loadFollowedCities();

    // 监听城市列表变化，同步关注状态
    ever(cities, (_) => _syncFollowedStatusFromController());
  }

  @override
  void onClose() {
    _favoriteChangedSubscription?.cancel();
    _cityImageUpdatedSubscription?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
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

      if (!success) {
        log('❌ [CityListController] 城市图片生成失败，不更新列表');
        return;
      }

      // 更新城市图片
      _updateCityImages(cityId, data);
    });

    log('✅ [CityListController] SignalR 城市图片更新监听已设置');
  }

  /// 更新列表中指定城市的图片
  void _updateCityImages(String cityId, Map<String, dynamic> data) {
    final index = cities.indexWhere((c) => c.id == cityId);
    if (index == -1) {
      log('⚠️ [CityListController] 城市 $cityId 不在当前列表中');
      return;
    }

    final portraitUrl = data['portraitImageUrl'] as String?;
    final landscapeUrls = data['landscapeImageUrls'] as List?;

    // 获取第一张横向图片作为封面
    String? coverImageUrl;
    List<String>? landscapeImageList;
    if (landscapeUrls != null && landscapeUrls.isNotEmpty) {
      landscapeImageList = landscapeUrls.cast<String>();
      coverImageUrl = landscapeImageList.first;
    }

    // 更新城市对象
    final city = cities[index];
    cities[index] = city.copyWith(
      portraitImageUrl: portraitUrl ?? city.portraitImageUrl,
      imageUrl: coverImageUrl ?? city.imageUrl,
      landscapeImageUrls: landscapeImageList ?? city.landscapeImageUrls,
    );
    cities.refresh();

    log('✅ [CityListController] 已更新城市图片: ${city.name}');
  }

  /// 处理收藏状态变更事件（来自其他页面，如详情页）
  void _handleFavoriteChanged(DataChangedEvent event) {
    if (event.entityId == null) return;

    final cityId = event.entityId!;
    final isFavorite = event.changeType == DataChangeType.created;

    log('🔔 [CityListController] 收到收藏状态变更: $cityId -> $isFavorite');

    // 更新 followedCities map
    followedCities[cityId] = isFavorite;

    // 同时更新 cities 列表中的状态
    final index = cities.indexWhere((c) => c.id == cityId);
    if (index != -1) {
      cities[index] = cities[index].copyWith(isFavorite: isFavorite);
      cities.refresh();
      log('✅ [CityListController] 已更新城市收藏状态: ${cities[index].name}');
    }
  }

  /// 加载城市数据
  Future<void> loadCities({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    isLoading.value = true;
    errorMessage.value = null;
    _currentPage = 1;

    try {
      if (searchQuery.value.isNotEmpty) {
        // 有搜索词：先 Elasticsearch，失败再数据库
        await _searchCities(searchQuery.value);
      } else {
        // 无搜索词：直接从数据库加载
        await _loadFromDatabase();
      }
    } catch (e) {
      errorMessage.value = '加载失败: $e';
      log('❌ CityListController: 加载异常 - $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 搜索城市：先 Elasticsearch，失败再数据库
  Future<void> _searchCities(String query) async {
    log('🔍 搜索城市: $query');

    // 1. 先尝试 Elasticsearch
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

    // 2. Elasticsearch 失败，用数据库
    log('⚠️ 回退到数据库搜索');
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

  /// 从数据库加载城市（无搜索词时）
  /// 采用两阶段加载：先加载基础数据快速显示，然后异步加载聚合数据
  Future<void> _loadFromDatabase() async {
    // 阶段1：快速加载基础数据
    final result = await _cityRepository.getCitiesBasic(page: 1, pageSize: _pageSize);

    result.fold(
      onSuccess: (data) {
        cities.assignAll(data);
        hasMore.value = data.length >= _pageSize;
        log('✅ 快速加载了 ${data.length} 个城市基础数据');
        
        // 阶段2：异步加载聚合数据（不阻塞UI）
        if (data.isNotEmpty) {
          _loadCityCountsAsync(data.map((c) => c.id).toList());
        }
      },
      onFailure: (error) {
        // 降级：尝试使用完整API
        log('⚠️ 基础API失败，回退到完整API: ${error.message}');
        _loadFromDatabaseFull();
      },
    );
  }

  /// 异步加载城市聚合数据（meetupCount, coworkingCount 等）
  Future<void> _loadCityCountsAsync(List<String> cityIds) async {
    try {
      final result = await _cityRepository.getCityCountsBatch(cityIds);
      
      result.fold(
        onSuccess: (countsMap) {
          // 更新城市列表中的聚合数据
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
          log('✅ 异步加载了 ${countsMap.length} 个城市的聚合数据');
        },
        onFailure: (error) {
          log('⚠️ 异步加载聚合数据失败: ${error.message}');
          // 不显示错误，聚合数据加载失败不影响主流程
        },
      );
    } catch (e) {
      log('⚠️ 异步加载聚合数据异常: $e');
    }
  }

  /// 从数据库完整加载城市（降级方案）
  Future<void> _loadFromDatabaseFull() async {
    final result = await _cityRepository.getCities(page: 1, pageSize: _pageSize);

    result.fold(
      onSuccess: (data) {
        cities.assignAll(data);
        hasMore.value = data.length >= _pageSize;
        log('✅ 加载了 ${data.length} 个城市（完整数据）');
      },
      onFailure: (error) {
        errorMessage.value = error.message;
        log('❌ 加载失败: ${error.message}');
      },
    );
  }

  /// 将 CitySearchDocument 转换为 City 对象
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
      // 扩展字段 - 从 ES 同步
      averageCost: doc.averageCost,
      meetupCount: doc.meetupCount,
      coworkingCount: doc.coworkingCount,
      reviewCount: doc.reviewCount,
      moderatorId: doc.moderatorId,
    );
  }

  /// 加载更多城市
  Future<void> loadMoreCities() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;

    try {
      if (searchQuery.value.isNotEmpty) {
        // 有搜索词：尝试 ES 加载更多
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

        if (esSuccess) return;
      }

      // 无搜索词或 ES 失败：使用基础API加载更多
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
            
            // 异步加载新增城市的聚合数据
            _loadCityCountsAsync(data.map((c) => c.id).toList());
          }
        },
        onFailure: (error) {
          log('❌ 基础API加载更多失败: ${error.message}');
          // 降级到完整API
          _loadMoreFromDatabaseFull();
        },
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 从数据库完整加载更多城市（降级方案）
  Future<void> _loadMoreFromDatabaseFull() async {
    final result = await _cityRepository.getCities(
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
        }
      },
      onFailure: (error) {
        log('❌ 加载更多失败: ${error.message}');
      },
    );
  }

  /// 滚动监听
  void _onScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    // 当滚动到距离底部300像素时开始加载更多
    if (currentScroll >= maxScroll - 300) {
      loadMoreCities();
    }
  }

  /// 更新搜索关键词
  void updateSearchQuery(String value) {
    searchQuery.value = value;
  }

  /// 执行搜索
  void performSearch() {
    final searchText = searchController.text.trim();
    if (searchText.isNotEmpty) {
      loadCities(refresh: true);
    } else {
      clearFilters();
    }
  }

  /// 清除筛选
  void clearFilters() {
    searchQuery.value = '';
    searchController.clear();
    loadCities(refresh: true);
  }

  /// 页面返回时刷新数据
  Future<void> onRouteResume() async {
    log('🔄 CityListController: 页面返回，刷新数据');
    searchQuery.value = '';
    searchController.clear();
    await loadCities(refresh: true);
    _syncFollowedStatusFromController();
  }

  /// 判断城市是否已关注
  bool isCityFollowed(City city) {
    return followedCities[city.id] ?? city.isFavorite;
  }

  /// 切换关注状态
  Future<void> toggleFollow(City city) async {
    final cityId = city.id;
    if (isLoadingFollowedCities.value) return;

    final previousState = followedCities[cityId] ?? false;

    // 乐观更新 UI
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
          // 操作失败，恢复之前的状态
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

  /// 从控制器同步关注状态
  void _syncFollowedStatusFromController() {
    for (final city in cities) {
      followedCities[city.id] = city.isFavorite;
    }
  }

  /// 加载用户已关注的城市列表
  Future<void> _loadFollowedCities() async {
    if (isLoadingFollowedCities.value) return;

    isLoadingFollowedCities.value = true;
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
      isLoadingFollowedCities.value = false;
    }
  }

  /// 获取全局 CityStateController（用于复杂功能）
  CityStateController get cityStateController => _cityStateController;
}
