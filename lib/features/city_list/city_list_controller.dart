import 'dart:developer';

import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';
import 'package:df_admin_mobile/features/city/domain/usecases/city_rating_usecases.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/services/search_service.dart';
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

  // 分页配置
  int _currentPage = 1;
  static const int _pageSize = 20;

  // 私有状态
  bool _isLoadingFollowedCities = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);

    // 监听城市列表变化同步关注状态
    ever(cities, (_) => _syncFollowedStatusFromController());

    // 初始加载
    loadCities(refresh: true);

    // 异步加载关注状态
    Future.microtask(() => _loadFollowedCities());
  }

  @override
  void onClose() {
    searchTextController.dispose();
    scrollController.dispose();
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

  void _syncFollowedStatusFromController() {
    for (final city in cities) {
      followedCities[city.id] = city.isFavorite;
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

  bool isGeneratingImages(String cityId) {
    return _cityStateController.isGeneratingImages(cityId);
  }

  Future<void> generateCityImages(String cityId, String cityName) async {
    if (_cityStateController.isGeneratingImages(cityId)) return;

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
      },
      onFailure: (exception) {
        AppToast.error(exception.message, title: 'Task Creation Failed');
      },
    );
  }
}
