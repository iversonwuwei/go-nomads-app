import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/core.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/city/application/use_cases/city_use_cases.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/city/domain/repositories/i_city_repository.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/signalr_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 城市详情状态控制器 (Presentation Layer)
///
/// 负责管理城市详情的 UI 状态,通过 Use Cases 操作
///
/// 注意: 该控制器仅管理 City 基本信息和收藏状态
/// Weather, UserCityContent, Coworking 等使用独立的控制器/服务管理
class CityDetailStateController extends GetxController {
  // ==================== Dependencies ====================
  final GetCityByIdUseCase _getCityByIdUseCase;
  final ToggleCityFavoriteUseCase _toggleCityFavoriteUseCase;
  final ICityRepository _cityRepository;

  // ==================== Subscriptions ====================
  StreamSubscription<DataChangedEvent>? _dataChangedSubscription;
  StreamSubscription<DataChangedEvent>? _favoriteChangedSubscription;
  StreamSubscription<DataChangedEvent>? _reviewChangedSubscription;
  StreamSubscription<DataChangedEvent>? _ratingChangedSubscription;
  StreamSubscription<Map<String, dynamic>>? _signalRRatingSubscription;
  StreamSubscription<Map<String, dynamic>>? _signalRReviewSubscription;
  StreamSubscription<Map<String, dynamic>>? _signalRImageSubscription;
  StreamSubscription<Map<String, dynamic>>? _signalRModeratorSubscription;

  CityDetailStateController({
    required GetCityByIdUseCase getCityByIdUseCase,
    required ToggleCityFavoriteUseCase toggleCityFavoriteUseCase,
    required ICityRepository cityRepository,
  })  : _getCityByIdUseCase = getCityByIdUseCase,
        _toggleCityFavoriteUseCase = toggleCityFavoriteUseCase,
        _cityRepository = cityRepository;

  // ==================== State ====================

  // 城市数据
  final Rx<City?> currentCity = Rx<City?>(null);

  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  // 收藏状态
  final RxBool isFavorited = false.obs;
  final RxBool isTogglingFavorite = false.obs;

  // Tab 索引
  final RxInt currentTabIndex = 0.obs;

  // 缓存上一次加载的城市ID,避免重复加载
  String _lastLoadedCityId = '';

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    _setupDataChangeListeners();
    _setupSignalRListeners();
  }

  /// 设置 SignalR 监听器 (用于 Header 数据更新)
  void _setupSignalRListeners() {
    final signalRService = SignalRService();

    // 监听城市评分更新事件 (来自 SignalR)
    _signalRRatingSubscription = signalRService.cityRatingUpdatedStream.listen((data) {
      _handleSignalRRatingUpdated(data);
    });

    // 监听城市评论更新事件 (来自 SignalR)
    _signalRReviewSubscription = signalRService.cityReviewUpdatedStream.listen((data) {
      _handleSignalRReviewUpdated(data);
    });

    // 监听城市图片更新事件 (来自 SignalR)
    _signalRImageSubscription = signalRService.cityImageUpdatedStream.listen((data) {
      _handleSignalRImageUpdated(data);
    });

    // 监听城市版主变更事件 (来自 SignalR)
    _signalRModeratorSubscription = signalRService.cityModeratorUpdatedStream.listen((data) {
      _handleSignalRModeratorUpdated(data);
    });

    log('✅ [CityDetailStateController] SignalR 监听器已设置');
  }

  /// 处理 SignalR 城市评论更新事件 (用于 Header 数据同步)
  void _handleSignalRReviewUpdated(Map<String, dynamic> data) {
    final cityId = data['cityId'] as String?;

    log('📡 [城市详情] 收到 SignalR 评论更新: cityId=$cityId, currentCityId=${currentCity.value?.id}');

    if (currentCity.value == null || cityId != currentCity.value!.id) {
      return;
    }

    final rawScore = data['overallScore'];
    final newScore = rawScore is num ? rawScore.toDouble() : null;
    final reviewCount = data['reviewCount'] as int?;
    final changeType = data['changeType'] as String?;

    log('📝 [城市详情] SignalR 评论更新: changeType=$changeType, reviewCount=$reviewCount, overallScore=$newScore');

    // 更新城市数据
    var updatedCity = currentCity.value!;

    if (newScore != null) {
      final oldScore = updatedCity.overallScore;
      updatedCity = updatedCity.copyWith(overallScore: newScore);
      log('📊 [城市详情] 评论 overallScore: $oldScore -> $newScore');
    }

    if (reviewCount != null) {
      final oldCount = updatedCity.reviewCount;
      updatedCity = updatedCity.copyWith(reviewCount: reviewCount);
      log('📊 [城市详情] 评论 reviewCount: $oldCount -> $reviewCount');
    }

    // 强制触发 GetX 更新 (City 的 == 只比较 id)
    currentCity.value = null;
    currentCity.value = updatedCity;

    log('✅ [城市详情] SignalR 静默更新 Header 评论数据完成');
  }

  /// 处理 SignalR 城市图片更新事件 (用于详情页顶部图片实时更新)
  void _handleSignalRImageUpdated(Map<String, dynamic> data) {
    final cityId = data['cityId'] as String?;
    final success = data['success'] as bool? ?? false;

    log('📡 [城市详情] 收到 SignalR 图片更新: cityId=$cityId, success=$success, currentCityId=${currentCity.value?.id}');

    if (!success || currentCity.value == null || cityId != currentCity.value!.id) {
      return;
    }

    final cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();

    // 提取竖屏图片 URL
    String? portraitUrl = data['portraitImageUrl'] as String?;
    if (portraitUrl != null && portraitUrl.isNotEmpty) {
      portraitUrl = portraitUrl.contains('?') ? '$portraitUrl&v=$cacheBuster' : '$portraitUrl?v=$cacheBuster';
    }

    // 提取横屏图片 URL 列表
    List<String>? landscapeUrls;
    final landscapeImages = data['landscapeImageUrls'];
    if (landscapeImages is List && landscapeImages.isNotEmpty) {
      landscapeUrls = landscapeImages.cast<String>().map((url) {
        return url.contains('?') ? '$url&v=$cacheBuster' : '$url?v=$cacheBuster';
      }).toList();
    }

    if (portraitUrl == null && (landscapeUrls == null || landscapeUrls.isEmpty)) {
      log('⚠️ [城市详情] 未解析到图片URL，跳过更新');
      return;
    }

    var updatedCity = currentCity.value!.copyWith(
      portraitImageUrl: portraitUrl ?? currentCity.value!.portraitImageUrl,
      landscapeImageUrls: landscapeUrls ?? currentCity.value!.landscapeImageUrls,
      imageUrl: portraitUrl ?? currentCity.value!.imageUrl,
    );

    // 强制触发 GetX 更新
    currentCity.value = null;
    currentCity.value = updatedCity;

    log('✅ [城市详情] SignalR 城市图片已更新: portrait=${portraitUrl != null}, landscape=${landscapeUrls?.length ?? 0}');
  }

  /// 处理 SignalR 城市版主变更事件 (来自其他设备的审核操作)
  void _handleSignalRModeratorUpdated(Map<String, dynamic> data) {
    final cityId = data['cityId'] as String?;
    final changeType = data['changeType'] as String?;

    log('📡 [城市详情] 收到 SignalR 版主变更: cityId=$cityId, changeType=$changeType, currentCityId=${currentCity.value?.id}');

    if (currentCity.value == null || cityId != currentCity.value!.id) {
      return;
    }

    // 只 patch 版主字段，不全量刷新
    _cityRepository.getCityModeratorSummary(cityId!).then((result) {
      result.fold(
        onSuccess: (summary) {
          final updatedCity = currentCity.value!.copyWith(
            moderatorId: summary.moderatorId,
            moderator: summary.moderator,
            isCurrentUserModerator: summary.isCurrentUserModerator,
            isCurrentUserAdmin: summary.isCurrentUserAdmin,
          );
          currentCity.value = null;
          currentCity.value = updatedCity;
          log('✅ [城市详情] SignalR patch 版主字段完成: moderatorId=${summary.moderatorId}, moderator=${summary.moderator?.name}');
        },
        onFailure: (e) {
          log('❌ [城市详情] SignalR patch 版主字段失败: ${e.message}');
        },
      );
    });
  }

  /// 处理 SignalR 城市评分更新事件 (用于 Header 数据同步)
  void _handleSignalRRatingUpdated(Map<String, dynamic> data) {
    final cityId = data['cityId'] as String?;

    log('📡 [城市详情] 收到 SignalR 评分更新: cityId=$cityId, currentCityId=${currentCity.value?.id}');

    if (currentCity.value == null || cityId != currentCity.value!.id) {
      return;
    }

    final rawScore = data['overallScore'];
    final newScore = rawScore is num ? rawScore.toDouble() : null;
    final reviewCount = data['reviewCount'] as int?;

    if (newScore != null) {
      final oldScore = currentCity.value!.overallScore;

      // 使用 copyWith 更新城市数据
      var updatedCity = currentCity.value!.copyWith(overallScore: newScore);
      if (reviewCount != null) {
        updatedCity = updatedCity.copyWith(reviewCount: reviewCount);
      }

      // 强制触发 GetX 更新 (City 的 == 只比较 id)
      currentCity.value = null;
      currentCity.value = updatedCity;

      log('✅ [城市详情] SignalR 静默更新 Header: overallScore $oldScore -> $newScore, reviewCount: $reviewCount');
    }
  }

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    // 监听城市数据变更
    _dataChangedSubscription = DataEventBus.instance.on('city', _handleDataChanged);

    // 监听收藏状态变更（来自列表页面的变更）
    _favoriteChangedSubscription = DataEventBus.instance.on('city_favorite', _handleFavoriteChanged);

    // 监听评论变更（评论添加/删除会影响城市的评分和评论数）
    _reviewChangedSubscription = DataEventBus.instance.on('city_review', _handleReviewChanged);

    // 监听评分变更 (Tab 更新仍使用 DataEventBus)
    _ratingChangedSubscription = DataEventBus.instance.on('city_rating', _handleRatingChanged);

    log('✅ [CityDetailStateController] 数据变更监听器已设置');
  }

  /// 处理评论变更事件
  void _handleReviewChanged(DataChangedEvent event) {
    log('🔔 [城市详情] 收到 city_review 事件: entityId=${event.entityId}, currentCityId=${currentCity.value?.id}');

    // 只处理当前城市的评论变更
    if (currentCity.value == null) {
      log('⚠️ [城市详情] currentCity 为空，跳过处理');
      return;
    }

    if (event.entityId != currentCity.value!.id) {
      log('⚠️ [城市详情] entityId 不匹配，跳过处理: ${event.entityId} != ${currentCity.value!.id}');
      return;
    }

    log('🔔 [城市详情] 收到评论变更通知: ${event.entityId} (${event.changeType})');

    // 评论变更会影响城市的评分和评论数，需要刷新城市详情
    switch (event.changeType) {
      case DataChangeType.created:
      case DataChangeType.updated:
      case DataChangeType.deleted:
        // 重新加载城市详情以获取最新的评分和评论数
        loadCityDetail(event.entityId!, forceRefresh: true);
        break;
      case DataChangeType.invalidated:
        loadCityDetail(event.entityId!, forceRefresh: true);
        break;
    }
  }

  /// 处理评分变更事件（静默更新，不整页刷新）
  void _handleRatingChanged(DataChangedEvent event) {
    log('🔔 [城市详情] _handleRatingChanged 被调用: entityId=${event.entityId}, metadata=${event.metadata}');

    // 只处理当前城市的评分变更
    if (currentCity.value == null) {
      log('⚠️ [城市详情] currentCity 为 null，跳过');
      return;
    }

    if (event.entityId != currentCity.value!.id) {
      log('⚠️ [城市详情] entityId 不匹配: ${event.entityId} != ${currentCity.value!.id}');
      return;
    }

    // 从事件数据中获取新的 overallScore
    final rawScore = event.metadata?['overallScore'];
    log('🔍 [城市详情] rawScore=$rawScore, type=${rawScore.runtimeType}');

    final newScore = rawScore is num ? rawScore.toDouble() : null;
    if (newScore != null) {
      final oldScore = currentCity.value!.overallScore;
      // 静默更新 currentCity 的 overallScore
      // 注意：City 的 == 只比较 id，所以需要先设置为 null 再赋值新对象，强制触发 Obx 更新
      final updatedCity = currentCity.value!.copyWith(overallScore: newScore);
      currentCity.value = null; // 先置空
      currentCity.value = updatedCity; // 再赋值，强制触发更新
      log('✅ [城市详情] 静默更新 overallScore: $oldScore -> $newScore (强制刷新)');
    } else {
      log('⚠️ [城市详情] newScore 为 null，无法更新');
    }
  }

  /// 处理城市数据变更事件
  void _handleDataChanged(DataChangedEvent event) {
    // 只处理当前城市的变更
    if (currentCity.value == null || event.entityId != currentCity.value!.id) {
      return;
    }

    log('🔔 [城市详情] 收到数据变更通知: ${event.entityId} (${event.changeType})');

    switch (event.changeType) {
      case DataChangeType.updated:
        // 城市数据更新，重新加载详情
        loadCityDetail(event.entityId!, forceRefresh: true);
        break;
      case DataChangeType.deleted:
        // 城市被删除，清空当前数据
        currentCity.value = null;
        break;
      case DataChangeType.invalidated:
        // 缓存失效，重新加载
        loadCityDetail(event.entityId!, forceRefresh: true);
        break;
      case DataChangeType.created:
        // 新建城市通常不影响详情页
        break;
    }
  }

  /// 处理收藏状态变更事件（来自列表页面）
  void _handleFavoriteChanged(DataChangedEvent event) {
    // 只处理当前城市的收藏变更
    if (currentCity.value == null || event.entityId != currentCity.value!.id) {
      return;
    }

    // 如果正在切换收藏状态，忽略事件（避免与自己发出的事件冲突导致二次更新）
    if (isTogglingFavorite.value) {
      log('🔔 [城市详情] 正在切换收藏，忽略事件');
      return;
    }

    final isFavorite = event.changeType == DataChangeType.created;

    log('🔔 [城市详情] 收到收藏状态变更: ${event.entityId} -> $isFavorite');

    // 更新本地状态
    isFavorited.value = isFavorite;
    if (currentCity.value != null) {
      currentCity.value = currentCity.value!.copyWith(isFavorite: isFavorite);
    }
  }

  // ==================== Public Methods ====================

  /// 初始化城市详情 (从 cityId 加载完整数据)
  Future<void> initCity(String cityId, String cityName) async {
    // 加载城市详情
    await loadCityDetail(cityId);
  }

  /// 加载城市详情
  Future<void> loadCityDetail(String cityId, {bool forceRefresh = false}) async {
    if (cityId.isEmpty) {
      return;
    }

    // 如果不是强制刷新且是相同城市且已有数据，尝试同步列表状态后返回
    if (!forceRefresh && cityId == _lastLoadedCityId && currentCity.value != null) {
      // 尝试从列表控制器同步收藏状态
      log('🔄 [城市详情] 相同城市，尝试同步收藏状态');
      _syncFavoriteStateFromList(cityId);
      return;
    }

    // 如果切换到不同城市，立即清除旧数据，避免显示上一个城市的信息
    if (cityId != _lastLoadedCityId) {
      currentCity.value = null;
      isFavorited.value = false;
      log('🔄 [城市详情] 切换城市，清除旧数据');
    }

    _lastLoadedCityId = cityId;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = null;

    final result = await _getCityByIdUseCase.execute(
      GetCityByIdParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (city) {
        log('📦 [城市详情] 准备更新 currentCity: overallScore=${city.overallScore}, reviewCount=${city.reviewCount}, moderatorId=${city.moderatorId}');
        log('📦 [城市详情] 更新前 currentCity.value: overallScore=${currentCity.value?.overallScore}, moderatorId=${currentCity.value?.moderatorId}');
        // 强制触发 GetX 更新 (City 的 == 只比较 id，需先置空再赋值)
        currentCity.value = null;
        currentCity.value = city;
        log('📦 [城市详情] 更新后 currentCity.value: overallScore=${currentCity.value?.overallScore}, moderatorId=${currentCity.value?.moderatorId}');
        isFavorited.value = city.isFavorite;
        isLoading.value = false;
        log('✅ [城市详情] 加载成功: ${city.name}, isFavorite: ${city.isFavorite}, overallScore: ${city.overallScore}, reviewCount: ${city.reviewCount}, hasModerator: ${city.hasModerator}');
      },
      onFailure: (exception) {
        hasError.value = true;
        errorMessage.value = exception.message;
        isLoading.value = false;
        AppToast.error(exception.message, title: AppLocalizations.of(Get.context!)!.loadFailedTitle);
      },
    );
  }

  /// 从列表控制器同步收藏状态
  void _syncFavoriteStateFromList(String cityId) {
    try {
      // 尝试获取列表控制器中的最新状态
      if (!Get.isRegistered<CityStateController>()) {
        log('⚠️ [城市详情] CityStateController 未注册，无法同步');
        return;
      }

      final cityListController = Get.find<CityStateController>();
      final cityInList = cityListController.cities.firstWhereOrNull((c) => c.id == cityId);

      log('🔍 [城市详情] 同步检查 - 列表中城市: ${cityInList?.name ?? "未找到"}, 当前状态: ${isFavorited.value}');

      if (cityInList != null && currentCity.value != null) {
        // 如果列表中的收藏状态与详情不一致，同步更新
        if (cityInList.isFavorite != isFavorited.value) {
          log('🔄 [城市详情] 同步列表收藏状态: ${isFavorited.value} -> ${cityInList.isFavorite}');
          isFavorited.value = cityInList.isFavorite;
          currentCity.value = currentCity.value!.copyWith(isFavorite: cityInList.isFavorite);
        } else {
          log('✅ [城市详情] 收藏状态已同步，无需更新: ${isFavorited.value}');
        }
      } else if (cityInList == null) {
        // 城市不在列表中，可能需要检查收藏城市列表
        final favoriteCity = cityListController.favoriteCities.firstWhereOrNull((c) => c.id == cityId);
        if (favoriteCity != null && currentCity.value != null) {
          if (!isFavorited.value) {
            log('🔄 [城市详情] 从收藏列表同步状态: ${isFavorited.value} -> true');
            isFavorited.value = true;
            currentCity.value = currentCity.value!.copyWith(isFavorite: true);
          }
        }
      }
    } catch (e) {
      // 列表控制器可能不存在，忽略
      log('⚠️ [城市详情] 同步状态失败: $e');
    }
  }

  /// 切换收藏状态
  Future<void> toggleFavorite() async {
    if (currentCity.value == null) {
      return;
    }

    final cityId = currentCity.value!.id;

    if (isTogglingFavorite.value) {
      return;
    }

    isTogglingFavorite.value = true;
    final previousState = isFavorited.value;

    // 乐观更新 UI
    isFavorited.value = !previousState;

    final result = await _toggleCityFavoriteUseCase.execute(
      ToggleCityFavoriteParams(
        cityId: cityId,
        currentIsFavorited: previousState,
      ),
    );

    result.fold(
      onSuccess: (newState) {
        isFavorited.value = newState;

        // 更新 currentCity 的收藏状态
        if (currentCity.value != null) {
          currentCity.value = currentCity.value!.copyWith(isFavorite: newState);
        }

        // 通知其他组件收藏状态变更（如城市列表）
        DataEventBus.instance.emit(DataChangedEvent(
          entityType: 'city_favorite',
          entityId: cityId,
          version: DateTime.now().millisecondsSinceEpoch,
          changeType: newState ? DataChangeType.created : DataChangeType.deleted,
          metadata: {'isFavorite': newState},
        ));
        log('✅ [城市详情] 收藏状态已同步: $cityId -> $newState');

        AppToast.success(
          newState
              ? AppLocalizations.of(Get.context!)!.addedToFavorites
              : AppLocalizations.of(Get.context!)!.removedFromFavorites,
          title: AppLocalizations.of(Get.context!)!.successTitle,
        );
        isTogglingFavorite.value = false;
      },
      onFailure: (exception) {
        // 操作失败,恢复之前的状态
        isFavorited.value = previousState;

        AppToast.error(exception.message, title: AppLocalizations.of(Get.context!)!.operationFailed);
        isTogglingFavorite.value = false;
      },
    );
  }

  /// 切换 Tab
  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  /// 强制刷新城市详情
  Future<void> reload() async {
    if (currentCity.value != null) {
      await loadCityDetail(currentCity.value!.id);
    }
  }

  /// 删除城市（仅管理员）
  Future<bool> deleteCity(String cityId) async {
    log('🗑️ [CityDetailStateController] 删除城市: $cityId');

    final result = await _cityRepository.deleteCity(cityId);

    return result.fold(
      onSuccess: (_) {
        log('✅ [CityDetailStateController] 城市删除成功');
        // 通知城市列表刷新
        DataEventBus.instance.emit(DataChangedEvent(
          entityType: 'city',
          entityId: cityId,
          version: DateTime.now().millisecondsSinceEpoch,
          changeType: DataChangeType.deleted,
        ));
        return true;
      },
      onFailure: (error) {
        log('❌ [CityDetailStateController] 删除城市失败: ${error.message}');
        AppToast.error(AppLocalizations.of(Get.context!)!.deleteFailed(error.message));
        return false;
      },
    );
  }

  // ==================== Computed Properties ====================

  /// 当前城市ID
  String get currentCityId => currentCity.value?.id ?? '';

  /// 当前城市名称
  String get currentCityName => currentCity.value?.nameEn ?? '';

  /// 是否有城市数据
  bool get hasCity => currentCity.value != null;

  /// 是否正在加载
  bool get loading => isLoading.value;

  // ==================== Lifecycle ====================

  @override
  void onClose() {
    // 取消数据变更订阅
    _dataChangedSubscription?.cancel();
    _dataChangedSubscription = null;
    _favoriteChangedSubscription?.cancel();
    _favoriteChangedSubscription = null;
    _reviewChangedSubscription?.cancel();
    _reviewChangedSubscription = null;
    _ratingChangedSubscription?.cancel();
    _ratingChangedSubscription = null;

    // 取消 SignalR 订阅
    _signalRRatingSubscription?.cancel();
    _signalRRatingSubscription = null;
    _signalRReviewSubscription?.cancel();
    _signalRReviewSubscription = null;
    _signalRImageSubscription?.cancel();
    _signalRImageSubscription = null;
    _signalRModeratorSubscription?.cancel();
    _signalRModeratorSubscription = null;

    // 清理所有状态
    currentCity.value = null;
    isLoading.value = false;
    hasError.value = false;
    errorMessage.value = null;
    isFavorited.value = false;
    isTogglingFavorite.value = false;
    currentTabIndex.value = 0;

    // 清理缓存标记
    _lastLoadedCityId = '';

    super.onClose();
  }
}
