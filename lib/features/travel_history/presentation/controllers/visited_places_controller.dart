import 'dart:developer';

import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../core/core.dart';
import '../../../../services/token_storage_service.dart';
import '../../data/models/travel_history_api_dto.dart';
import '../../data/models/visited_place_api_dto.dart';
import '../../data/repositories/travel_history_api_repository.dart';
import '../../data/repositories/visited_place_api_repository.dart';
import '../../domain/entities/visited_place.dart';

/// 访问地点控制器
/// 使用聚合 API 获取城市信息 + 访问地点（支持无限滚动分页）
class VisitedPlacesController extends GetxController {
  final String travelHistoryId;
  final String? cityId;
  final String? cityName;
  final String? countryName;

  late final VisitedPlaceApiRepository _visitedPlaceRepo;
  late final TravelHistoryApiRepository _travelHistoryRepo;

  // ==================== 旅行信息 ====================

  /// 旅行详情
  final Rx<TravelHistoryApiDto?> travelHistory = Rx<TravelHistoryApiDto?>(null);

  /// 旅行标题
  final tripTitle = ''.obs;

  // ==================== 城市摘要信息（来自聚合 API）====================

  /// 城市摘要数据
  final Rx<VisitedPlacesCitySummaryDto?> citySummary = Rx<VisitedPlacesCitySummaryDto?>(null);

  /// 城市图片 URL
  final cityImageUrl = ''.obs;

  /// 当前天气
  final Rx<CityWeatherDto?> weather = Rx<CityWeatherDto?>(null);

  /// 城市评分
  final Rx<double?> overallScore = Rx<double?>(null);

  /// 月均花费
  final Rx<double?> averageMonthlyCost = Rx<double?>(null);

  /// 共享办公数量
  final coworkingSpaceCount = 0.obs;

  /// 旅行日期
  final Rx<DateTime?> travelDate = Rx<DateTime?>(null);

  /// 最后访问日期
  final Rx<DateTime?> lastVisitDate = Rx<DateTime?>(null);

  /// 总停留天数
  final totalDurationDays = 0.obs;

  /// 城市信息加载状态
  final isCityLoading = true.obs;

  /// 城市信息错误
  final cityError = ''.obs;

  // ==================== 访问地点列表 ====================

  /// 访问地点列表
  final places = <VisitedPlace>[].obs;

  /// 原始 API DTO 列表（用于后端操作）
  final _placeDtos = <VisitedPlaceApiDto>[];

  /// 初次加载状态
  final isLoading = true.obs;

  /// 加载更多状态
  final isLoadingMore = false.obs;

  /// 是否还有更多数据
  final hasMore = true.obs;

  /// 错误信息
  final error = ''.obs;

  /// 当前页码
  int _currentPage = 1;

  /// 每页数量
  static const int _pageSize = 20;

  /// 总数量
  final totalCount = 0.obs;

  /// 实际的 cityId（可能从 travelHistory 获取）
  String? _resolvedCityId;

  // ==================== 统计信息 ====================

  /// 总停留时间（分钟）
  final totalDurationMinutes = 0.obs;

  /// 精选地点数量
  final highlightCount = 0.obs;

  VisitedPlacesController({
    required this.travelHistoryId,
    this.cityId,
    this.cityName,
    this.countryName,
  });

  @override
  void onInit() {
    super.onInit();
    _setTripTitle();
    _initialize();
  }

  Future<void> _initialize() async {
    _initRepositories();
    await _loadData();
  }

  void _initRepositories() {
    final dio = Get.find<Dio>();
    final tokenService = Get.find<TokenStorageService>();

    _visitedPlaceRepo = VisitedPlaceApiRepository(
      dio: dio,
      tokenService: tokenService,
    );

    _travelHistoryRepo = TravelHistoryApiRepository(
      dio: dio,
      tokenService: tokenService,
    );
  }

  void _setTripTitle() {
    if (cityName != null && countryName != null) {
      tripTitle.value = '$cityName, $countryName';
    } else if (cityName != null) {
      tripTitle.value = cityName!;
    }
  }

  // ==================== 数据加载（使用聚合 API）====================

  /// 加载所有数据
  Future<void> _loadData() async {
    isLoading.value = true;
    isCityLoading.value = true;
    error.value = '';
    _currentPage = 1;
    places.clear();
    _placeDtos.clear();

    // 先解析 cityId
    _resolvedCityId = cityId;

    if (_resolvedCityId == null || _resolvedCityId!.isEmpty) {
      // 从旅行历史获取 cityId
      final result = await _travelHistoryRepo.getTravelHistoryById(travelHistoryId);
      if (result is Success<TravelHistoryApiDto>) {
        travelHistory.value = result.data;
        _resolvedCityId = result.data.cityId;

        // 更新标题
        if (tripTitle.value.isEmpty) {
          tripTitle.value = '${result.data.city}, ${result.data.country}';
        }
      }
    }

    if (_resolvedCityId == null || _resolvedCityId!.isEmpty) {
      isCityLoading.value = false;
      isLoading.value = false;
      error.value = '无法获取城市信息';
      log('⚠️ 无法获取 cityId，无法加载数据');
      return;
    }

    // 使用聚合 API 加载城市摘要 + 访问地点
    await _loadCitySummary();
  }

  /// 加载城市摘要（包含城市信息 + 访问地点）
  Future<void> _loadCitySummary() async {
    try {
      log('🏙️ 加载城市摘要 - cityId: $_resolvedCityId, page: $_currentPage');

      final result = await _visitedPlaceRepo.getCitySummary(
        _resolvedCityId!,
        page: _currentPage,
        pageSize: _pageSize,
      );

      switch (result) {
        case Success(data: final summary):
          citySummary.value = summary;

          // 更新城市信息
          cityImageUrl.value = summary.imageUrl ?? '';
          weather.value = summary.weather;
          overallScore.value = summary.overallScore;
          averageMonthlyCost.value = summary.averageMonthlyCost;
          coworkingSpaceCount.value = summary.coworkingSpaceCount;
          travelDate.value = summary.travelDate;
          lastVisitDate.value = summary.lastVisitDate;
          totalDurationDays.value = summary.totalDurationDays;

          // 更新标题
          if (tripTitle.value.isEmpty) {
            tripTitle.value = '${summary.cityName}, ${summary.country}';
          }

          // 更新访问地点列表
          final visitedPlacesData = summary.visitedPlaces;
          totalCount.value = visitedPlacesData.totalCount;
          hasMore.value = visitedPlacesData.items.length < visitedPlacesData.totalCount;

          final loadedPlaces = visitedPlacesData.items.map(_apiDtoToLocal).toList();
          places.addAll(loadedPlaces);

          _updateStats();

          log('✅ 城市摘要加载成功: ${summary.cityName}');
          log('   - 天气: ${summary.weather?.condition ?? "无"}');
          log('   - 评分: ${summary.overallScore ?? "无"}');
          log('   - 花费: ${summary.averageMonthlyCost ?? "无"}');
          log('   - Coworking: ${summary.coworkingSpaceCount}');
          log('   - 访问地点: ${loadedPlaces.length}/${visitedPlacesData.totalCount}');

        case Failure(exception: final e):
          error.value = e.message;
          cityError.value = e.message;
          log('❌ 加载城市摘要失败: ${e.message}');
      }
    } catch (e, stackTrace) {
      log('❌ 加载城市摘要异常: $e');
      log('📍 堆栈: $stackTrace');
      error.value = 'Failed to load city summary';
      cityError.value = 'Failed to load city info';
    } finally {
      isLoading.value = false;
      isCityLoading.value = false;
    }
  }

  // ==================== 访问地点加载（保留旧方法用于兼容）====================

  /// 加载访问地点（首次加载）- 现在由 _loadCitySummary 处理
  Future<void> loadVisitedPlaces() async {
    // 如果已经通过 _loadCitySummary 加载了数据，直接返回
    if (citySummary.value != null) return;

    // 否则重新加载全部数据
    await _loadData();
  }

  /// 加载更多访问地点（无限滚动）
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || _resolvedCityId == null) return;

    isLoadingMore.value = true;
    _currentPage++;

    try {
      log('📍 加载更多访问地点 - cityId: $_resolvedCityId, page: $_currentPage');

      final result = await _visitedPlaceRepo.getCityVisitedPlaces(
        _resolvedCityId!,
        page: _currentPage,
        pageSize: _pageSize,
      );

      switch (result) {
        case Success(data: final paginatedResult):
          final loadedPlaces = paginatedResult.items.map(_apiDtoToLocal).toList();
          places.addAll(loadedPlaces);
          hasMore.value = places.length < paginatedResult.totalCount;
          _updateStats();
          log('✅ 加载更多 ${loadedPlaces.length} 个访问地点');
        case Failure(exception: final e):
          _currentPage--; // 回滚页码
          log('❌ 加载更多失败: ${e.message}');
      }
    } catch (e) {
      _currentPage--;
      log('❌ 加载更多异常: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 刷新数据
  @override
  Future<void> refresh() async {
    await _loadData();
  }

  // ==================== 地点操作 ====================

  /// 切换精选状态
  /// [index] 是 places 列表中的索引
  Future<void> toggleHighlightAtIndex(int index) async {
    if (index < 0 || index >= places.length) {
      return;
    }

    final place = places[index];

    try {
      final newHighlightStatus = !place.isHighlight;

      // 先更新 UI
      places[index] = place.copyWith(isHighlight: newHighlightStatus);
      places.refresh();
      _updateStats();

      // 需要获取对应的 API ID
      // 注意：这里需要使用 visitedPlaces 中的 ID
      final summary = citySummary.value;
      if (summary == null || index >= summary.visitedPlaces.items.length) {
        log('⚠️ 无法获取访问地点 ID');
        return;
      }

      final visitedPlaceId = summary.visitedPlaces.items[index].id;

      // 调用后端 API
      final result = await _visitedPlaceRepo.toggleHighlight(
        visitedPlaceId,
        newHighlightStatus,
      );

      switch (result) {
        case Success():
          log('✅ 切换精选状态成功 - ${place.placeName}: $newHighlightStatus');
        case Failure(exception: final e):
          // 回滚 UI 变更
          places[index] = place;
          places.refresh();
          _updateStats();
          AppToast.error('Failed to update: ${e.message}');
          log('❌ 切换精选状态失败: ${e.message}');
      }
    } catch (e) {
      log('❌ 切换精选状态异常: $e');
      AppToast.error('Failed to update highlight status');
    }
  }

  // ==================== 辅助方法 ====================

  /// 更新统计信息
  void _updateStats() {
    totalDurationMinutes.value = places.fold<int>(0, (sum, p) => sum + p.durationMinutes);
    highlightCount.value = places.where((p) => p.isHighlight).length;
  }

  /// API DTO 转换为本地实体
  VisitedPlace _apiDtoToLocal(VisitedPlaceApiDto dto) {
    return VisitedPlace(
      id: null, // 本地 ID，API 返回的没有
      tripId: dto.travelHistoryId,
      latitude: dto.latitude,
      longitude: dto.longitude,
      placeName: dto.placeName,
      placeType: dto.placeType,
      address: dto.address,
      arrivalTime: dto.arrivalTime,
      departureTime: dto.departureTime,
      photoUrl: dto.photoUrl,
      notes: dto.notes,
      isHighlight: dto.isHighlight,
    );
  }

  /// 格式化总时长
  String get formattedTotalDuration {
    final minutes = totalDurationMinutes.value;
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${mins}m';
  }
}
