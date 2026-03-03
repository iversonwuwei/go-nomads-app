import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/application/use_case.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/core/sync/data_sync_service.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/user/application/use_cases/user_use_cases.dart' as user_use_cases;
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/features/user_city_content/application/use_cases/user_city_content_use_cases.dart';
import 'package:go_nomads_app/features/user_city_content/domain/entities/user_city_content.dart';

/// User City Content State Controller - DDD Presentation Layer
class UserCityContentStateController extends GetxController {
  /// 检查用户是否已登录
  bool _isUserLoggedIn() {
    try {
      final authController = Get.find<AuthStateController>();
      return authController.isAuthenticated.value;
    } catch (e) {
      return false;
    }
  }

  // Use Cases
  final AddCityPhotoUseCase _addCityPhotoUseCase;
  final SubmitCityPhotosUseCase _submitCityPhotosUseCase;
  final GetCityPhotosUseCase _getCityPhotosUseCase;
  final DeleteCityPhotoUseCase _deleteCityPhotoUseCase;
  final GetMyPhotosUseCase _getMyPhotosUseCase;
  final user_use_cases.BatchGetUsersUseCase _batchGetUsersUseCase;

  final AddCityExpenseUseCase _addCityExpenseUseCase;
  final GetCityExpensesUseCase _getCityExpensesUseCase;
  final DeleteCityExpenseUseCase _deleteCityExpenseUseCase;
  final GetMyExpensesUseCase _getMyExpensesUseCase;

  final UpsertCityReviewUseCase _upsertCityReviewUseCase;
  final GetCityReviewsPagedUseCase _getCityReviewsPagedUseCase;
  final GetMyCityReviewUseCase _getMyCityReviewUseCase;
  final DeleteMyCityReviewUseCase _deleteMyCityReviewUseCase;
  final DeleteCityReviewUseCase _deleteCityReviewUseCase;

  final GetCityStatsUseCase _getCityStatsUseCase;
  final GetCityCostSummaryUseCase _getCityCostSummaryUseCase;

  // Observable State
  final photos = <UserCityPhoto>[].obs;
  final expenses = <UserCityExpense>[].obs;
  final reviews = <UserCityReview>[].obs;
  final myReview = Rxn<UserCityReview>();
  final stats = Rxn<CityUserContentStats>();
  final costSummary = Rxn<CityCostSummary>();

  // Reviews pagination state
  final reviewsCurrentPage = 1.obs;
  final reviewsTotalCount = 0.obs;
  final reviewsHasMore = true.obs;
  final isLoadingMoreReviews = false.obs;
  String? _currentReviewsCityId;

  // 缓存标记，避免同一城市重复拉取
  String? _photosCityId;
  String? _expensesCityId;
  String? _statsCityId;
  String? _costSummaryCityId;

  final RxMap<String, String> photoUploaderNames = <String, String>{}.obs;
  final Set<String> _pendingUserNameFetches = <String>{};

  final isLoadingPhotos = false.obs;
  final isLoadingExpenses = false.obs;
  final isLoadingReviews = false.obs;
  final isLoadingStats = false.obs;
  final isLoadingCostSummary = false.obs;

  // 数据变更订阅
  StreamSubscription<DataChangedEvent>? _photoChangedSubscription;
  StreamSubscription<DataChangedEvent>? _expenseChangedSubscription;
  StreamSubscription<DataChangedEvent>? _reviewChangedSubscription;

  UserCityContentStateController({
    required AddCityPhotoUseCase addCityPhotoUseCase,
    required SubmitCityPhotosUseCase submitCityPhotosUseCase,
    required GetCityPhotosUseCase getCityPhotosUseCase,
    required DeleteCityPhotoUseCase deleteCityPhotoUseCase,
    required GetMyPhotosUseCase getMyPhotosUseCase,
    required user_use_cases.BatchGetUsersUseCase batchGetUsersUseCase,
    required AddCityExpenseUseCase addCityExpenseUseCase,
    required GetCityExpensesUseCase getCityExpensesUseCase,
    required DeleteCityExpenseUseCase deleteCityExpenseUseCase,
    required GetMyExpensesUseCase getMyExpensesUseCase,
    required UpsertCityReviewUseCase upsertCityReviewUseCase,
    required GetCityReviewsPagedUseCase getCityReviewsPagedUseCase,
    required GetMyCityReviewUseCase getMyCityReviewUseCase,
    required DeleteMyCityReviewUseCase deleteMyCityReviewUseCase,
    required DeleteCityReviewUseCase deleteCityReviewUseCase,
    required GetCityStatsUseCase getCityStatsUseCase,
    required GetCityCostSummaryUseCase getCityCostSummaryUseCase,
  })  : _addCityPhotoUseCase = addCityPhotoUseCase,
        _submitCityPhotosUseCase = submitCityPhotosUseCase,
        _getCityPhotosUseCase = getCityPhotosUseCase,
        _deleteCityPhotoUseCase = deleteCityPhotoUseCase,
        _getMyPhotosUseCase = getMyPhotosUseCase,
        _batchGetUsersUseCase = batchGetUsersUseCase,
        _addCityExpenseUseCase = addCityExpenseUseCase,
        _getCityExpensesUseCase = getCityExpensesUseCase,
        _deleteCityExpenseUseCase = deleteCityExpenseUseCase,
        _getMyExpensesUseCase = getMyExpensesUseCase,
        _upsertCityReviewUseCase = upsertCityReviewUseCase,
        _getCityReviewsPagedUseCase = getCityReviewsPagedUseCase,
        _getMyCityReviewUseCase = getMyCityReviewUseCase,
        _deleteMyCityReviewUseCase = deleteMyCityReviewUseCase,
        _deleteCityReviewUseCase = deleteCityReviewUseCase,
        _getCityStatsUseCase = getCityStatsUseCase,
        _getCityCostSummaryUseCase = getCityCostSummaryUseCase;

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    _setupDataChangeListeners();
  }

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    // 监听照片变更
    _photoChangedSubscription = DataEventBus.instance.on('city_photo', _handlePhotoChanged);
    // 监听费用变更
    _expenseChangedSubscription = DataEventBus.instance.on('city_expense', _handleExpenseChanged);
    // 监听评论变更
    _reviewChangedSubscription = DataEventBus.instance.on('city_review', _handleReviewChanged);
    log('✅ [UserCityContentStateController] 数据变更监听器已设置');
  }

  /// 处理照片变更事件
  void _handlePhotoChanged(DataChangedEvent event) {
    log('🔔 [UserCityContent] 收到照片变更通知: ${event.changeType}, cityId: ${event.entityId}');

    if (event.entityId == null) return;

    // 处理当前城市的变更，或者如果尚未加载任何城市则设置并加载
    if (event.entityId == _photosCityId) {
      switch (event.changeType) {
        case DataChangeType.created:
        case DataChangeType.updated:
        case DataChangeType.invalidated:
          // 重新加载照片列表
          loadCityPhotos(event.entityId!, forceRefresh: true);
          break;
        case DataChangeType.deleted:
          // 删除操作已在本地处理，通常无需额外操作
          break;
      }
    } else if (_photosCityId == null) {
      // 如果当前没有加载任何城市的照片，设置城市ID以便后续切换到tab时加载
      _photosCityId = event.entityId;
      // 直接加载，确保用户返回时能看到新数据
      loadCityPhotos(event.entityId!, forceRefresh: true);
    }
  }

  /// 处理费用变更事件
  void _handleExpenseChanged(DataChangedEvent event) {
    log('🔔 [UserCityContent] 收到费用变更通知: ${event.changeType}, cityId: ${event.entityId}');

    if (event.entityId == null) return;

    // 处理当前城市的变更
    if (event.entityId == _expensesCityId) {
      switch (event.changeType) {
        case DataChangeType.created:
        case DataChangeType.updated:
        case DataChangeType.invalidated:
          // 重新加载费用列表和费用汇总
          loadCityExpenses(event.entityId!, forceRefresh: true);
          loadCityCostSummary(event.entityId!, forceRefresh: true);
          break;
        case DataChangeType.deleted:
          // 删除操作已在本地处理，但需要更新汇总
          loadCityCostSummary(event.entityId!, forceRefresh: true);
          break;
      }
    } else if (_expensesCityId == null) {
      // 如果当前没有加载任何城市的费用，设置城市ID并加载
      _expensesCityId = event.entityId;
      loadCityExpenses(event.entityId!, forceRefresh: true);
      loadCityCostSummary(event.entityId!, forceRefresh: true);
    }
  }

  /// 处理评论变更事件
  void _handleReviewChanged(DataChangedEvent event) {
    log('🔔 [UserCityContent] 收到评论变更通知: ${event.changeType}, cityId: ${event.entityId}');

    if (event.entityId == null) return;

    // 处理当前城市的变更
    if (event.entityId == _currentReviewsCityId) {
      switch (event.changeType) {
        case DataChangeType.created:
        case DataChangeType.updated:
        case DataChangeType.invalidated:
          // 重新加载评论列表
          loadCityReviews(event.entityId!, forceRefresh: true);
          break;
        case DataChangeType.deleted:
          // 删除操作已在本地处理
          break;
      }
    } else if (_currentReviewsCityId == null) {
      // 如果当前没有加载任何城市的评论，设置城市ID并加载
      _currentReviewsCityId = event.entityId;
      loadCityReviews(event.entityId!, forceRefresh: true);
    }
  }

  // ==================== Photo Methods ====================

  Future<void> loadCityPhotos(String cityId, {bool onlyMine = false, bool forceRefresh = false}) async {
    if (!forceRefresh && !onlyMine && _photosCityId == cityId && photos.isNotEmpty) {
      return;
    }

    isLoadingPhotos.value = true;

    final result = await _getCityPhotosUseCase.execute(
      GetCityPhotosUseCaseParams(cityId: cityId, onlyMine: onlyMine),
    );

    await result.fold(
      onSuccess: (data) async {
        photos.value = data;
        _photosCityId = cityId;
        await _hydrateUploaderNamesFromPhotos(data);
      },
      onFailure: (exception) async {
        // log('Failed to load photos: ${exception.message}');
      },
    );

    isLoadingPhotos.value = false;
  }

  Future<bool> addPhoto({
    required String cityId,
    required String imageUrl,
    String? caption,
    String? location,
    DateTime? takenAt,
  }) async {
    final result = await _addCityPhotoUseCase.execute(
      AddCityPhotoUseCaseParams(
        cityId: cityId,
        imageUrl: imageUrl,
        caption: caption,
        location: location,
        takenAt: takenAt,
      ),
    );

    return await result.fold(
      onSuccess: (photo) async {
        photos.insert(0, photo);
        await _hydrateUploaderNamesFromPhotos([photo]);
        return true;
      },
      onFailure: (exception) async {
        // log('Failed to add photo: ${exception.message}');
        return false;
      },
    );
  }

  Future<bool> submitPhotoCollection({
    required String cityId,
    required String title,
    required List<String> imageUrls,
    String? description,
    String? locationNote,
    bool reloadAfterSubmit = true,
  }) async {
    if (imageUrls.isEmpty) {
      return false;
    }

    final result = await _submitCityPhotosUseCase.execute(
      SubmitCityPhotosParams(
        cityId: cityId,
        title: title,
        imageUrls: imageUrls,
        description: description,
        locationNote: locationNote,
      ),
    );

    return await result.fold(
      onSuccess: (createdPhotos) async {
        if (createdPhotos.isNotEmpty) {
          photos.insertAll(0, createdPhotos);
          await _hydrateUploaderNamesFromPhotos(createdPhotos);
        }
        if (reloadAfterSubmit) {
          loadCityPhotos(cityId);
        }
        return true;
      },
      onFailure: (_) async => false,
    );
  }

  Future<bool> deletePhoto(String cityId, String photoId) async {
    final result = await _deleteCityPhotoUseCase.execute(
      DeleteCityPhotoUseCaseParams(cityId: cityId, photoId: photoId),
    );

    return result.fold(
      onSuccess: (_) {
        photos.removeWhere((photo) => photo.id == photoId);
        return true;
      },
      onFailure: (exception) {
        // log('Failed to delete photo: ${exception.message}');
        return false;
      },
    );
  }

  Future<void> loadMyPhotos() async {
    isLoadingPhotos.value = true;

    final result = await _getMyPhotosUseCase.execute(NoParams());

    await result.fold(
      onSuccess: (data) async {
        photos.value = data;
        await _hydrateUploaderNamesFromPhotos(data);
      },
      onFailure: (exception) async {
        // log('Failed to load my photos: ${exception.message}');
      },
    );

    isLoadingPhotos.value = false;
  }

  Future<void> _hydrateUploaderNamesFromPhotos(Iterable<UserCityPhoto> source) async {
    final userIds = source.map((photo) => photo.userId.trim()).where((id) => id.isNotEmpty).toSet();

    final missing = userIds
        .where((id) => !photoUploaderNames.containsKey(id))
        .where((id) => !_pendingUserNameFetches.contains(id))
        .toList();

    if (missing.isEmpty) {
      return;
    }

    _pendingUserNameFetches.addAll(missing);

    final result = await _batchGetUsersUseCase.execute(
      user_use_cases.BatchGetUsersParams(userIds: missing),
    );

    result.fold(
      onSuccess: (users) {
        for (final user in users) {
          photoUploaderNames[user.id] = _resolveDisplayName(user);
        }
        photoUploaderNames.refresh();
      },
      onFailure: (_) {
        // Ignore failures and fall back to truncated IDs in the UI
      },
    );

    _pendingUserNameFetches.removeAll(missing);
  }

  String _resolveDisplayName(User user) {
    final name = user.name.trim();
    if (name.isNotEmpty) {
      return name;
    }

    final username = user.username.trim();
    if (username.isNotEmpty) {
      return username;
    }

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return user.id;
  }

  // ==================== Expense Methods ====================

  Future<void> loadCityExpenses(String cityId, {bool onlyMine = false, bool forceRefresh = false}) async {
    if (!forceRefresh && !onlyMine && _expensesCityId == cityId && expenses.isNotEmpty) {
      return;
    }

    isLoadingExpenses.value = true;

    final result = await _getCityExpensesUseCase.execute(
      GetCityExpensesUseCaseParams(cityId: cityId, onlyMine: onlyMine),
    );

    result.fold(
      onSuccess: (data) {
        expenses.value = data;
        _expensesCityId = cityId;
      },
      onFailure: (exception) {
        // log('Failed to load expenses: ${exception.message}');
      },
    );

    isLoadingExpenses.value = false;
  }

  Future<bool> addExpense({
    required String cityId,
    required ExpenseCategory category,
    required double amount,
    String currency = 'USD',
    String? description,
    required DateTime date,
  }) async {
    final result = await _addCityExpenseUseCase.execute(
      AddCityExpenseUseCaseParams(
        cityId: cityId,
        category: category,
        amount: amount,
        currency: currency,
        description: description,
        date: date,
      ),
    );

    return result.fold(
      onSuccess: (expense) {
        expenses.insert(0, expense);
        return true;
      },
      onFailure: (exception) {
        // log('Failed to add expense: ${exception.message}');
        return false;
      },
    );
  }

  Future<bool> deleteExpense(String cityId, String expenseId) async {
    final result = await _deleteCityExpenseUseCase.execute(
      DeleteCityExpenseUseCaseParams(cityId: cityId, expenseId: expenseId),
    );

    return result.fold(
      onSuccess: (_) {
        expenses.removeWhere((expense) => expense.id == expenseId);
        return true;
      },
      onFailure: (exception) {
        // log('Failed to delete expense: ${exception.message}');
        return false;
      },
    );
  }

  Future<void> loadMyExpenses() async {
    isLoadingExpenses.value = true;

    final result = await _getMyExpensesUseCase.execute(NoParams());

    result.fold(
      onSuccess: (data) {
        expenses.value = data;
      },
      onFailure: (exception) {
        // log('Failed to load my expenses: ${exception.message}');
      },
    );

    isLoadingExpenses.value = false;
  }

  // ==================== Review Methods ====================

  /// 加载城市评论（预览模式，只加载5条）
  Future<void> loadCityReviews(String cityId, {bool forceRefresh = false}) async {
    // 如果用户未登录,跳过加载
    if (!_isUserLoggedIn()) {
      log('⚠️ 用户未登录,跳过加载城市评论');
      return;
    }

    if (!forceRefresh && _currentReviewsCityId == cityId && reviews.isNotEmpty) {
      return;
    }

    isLoadingReviews.value = true;
    _currentReviewsCityId = cityId;
    reviewsCurrentPage.value = 1;

    final result = await _getCityReviewsPagedUseCase.execute(
      GetCityReviewsPagedUseCaseParams(cityId: cityId, page: 1, pageSize: 5),
    );

    result.fold(
      onSuccess: (pagedResult) {
        reviews.value = pagedResult.items;
        reviewsTotalCount.value = pagedResult.totalCount;
        reviewsHasMore.value = pagedResult.hasMore;
        log('✅ 加载评论成功: ${pagedResult.items.length}条, 总计${pagedResult.totalCount}, hasMore=${pagedResult.hasMore}');
      },
      onFailure: (exception) {
        log('Failed to load reviews: ${exception.message}');
      },
    );

    isLoadingReviews.value = false;
  }

  /// 加载城市评论（分页模式，每页10条，用于管理页面）
  Future<void> loadCityReviewsPaged(String cityId, {int pageSize = 10}) async {
    if (!_isUserLoggedIn()) {
      log('⚠️ 用户未登录,跳过加载城市评论');
      return;
    }

    log('📋 [loadCityReviewsPaged] 开始加载: cityId=$cityId, pageSize=$pageSize');
    isLoadingReviews.value = true;
    _currentReviewsCityId = cityId;
    reviewsCurrentPage.value = 1;

    final result = await _getCityReviewsPagedUseCase.execute(
      GetCityReviewsPagedUseCaseParams(cityId: cityId, page: 1, pageSize: pageSize),
    );

    result.fold(
      onSuccess: (pagedResult) {
        log('📋 [loadCityReviewsPaged] API返回: ${pagedResult.items.length}条, 总计${pagedResult.totalCount}');
        reviews.value = pagedResult.items;
        reviewsTotalCount.value = pagedResult.totalCount;
        reviewsHasMore.value = pagedResult.hasMore;
        log('✅ 分页加载评论成功: reviews.length=${reviews.length}, totalCount=${reviewsTotalCount.value}, hasMore=${reviewsHasMore.value}');
      },
      onFailure: (exception) {
        log('❌ Failed to load reviews paged: ${exception.message}');
      },
    );

    isLoadingReviews.value = false;
  }

  /// 加载更多评论（无限滚动）
  Future<void> loadMoreReviews() async {
    if (_currentReviewsCityId == null || !reviewsHasMore.value || isLoadingMoreReviews.value) {
      log('⚠️ 跳过加载更多: cityId=$_currentReviewsCityId, hasMore=${reviewsHasMore.value}, isLoading=${isLoadingMoreReviews.value}');
      return;
    }

    isLoadingMoreReviews.value = true;
    final nextPage = reviewsCurrentPage.value + 1;
    log('📜 开始加载第 $nextPage 页评论...');

    final result = await _getCityReviewsPagedUseCase.execute(
      GetCityReviewsPagedUseCaseParams(
        cityId: _currentReviewsCityId!,
        page: nextPage,
        pageSize: 10,
      ),
    );

    result.fold(
      onSuccess: (pagedResult) {
        reviews.addAll(pagedResult.items);
        reviewsCurrentPage.value = nextPage;
        reviewsHasMore.value = pagedResult.hasMore;
        log('✅ 加载更多成功: +${pagedResult.items.length}条, 当前共${reviews.length}条, hasMore=${pagedResult.hasMore}');
      },
      onFailure: (exception) {
        log('Failed to load more reviews: ${exception.message}');
      },
    );

    isLoadingMoreReviews.value = false;
  }

  Future<void> loadMyCityReview(String cityId) async {
    final result = await _getMyCityReviewUseCase.execute(
      GetMyCityReviewUseCaseParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (review) {
        myReview.value = review;
      },
      onFailure: (exception) {
        // log('Failed to load my review: ${exception.message}');
      },
    );
  }

  Future<bool> upsertReview({
    required String cityId,
    required int rating,
    required String title,
    required String content,
    DateTime? visitDate,
    int? internetQualityScore,
    int? safetyScore,
    int? costScore,
    int? communityScore,
    int? weatherScore,
    String? reviewText,
  }) async {
    final result = await _upsertCityReviewUseCase.execute(
      UpsertCityReviewUseCaseParams(
        cityId: cityId,
        rating: rating,
        title: title,
        content: content,
        visitDate: visitDate,
        internetQualityScore: internetQualityScore,
        safetyScore: safetyScore,
        costScore: costScore,
        communityScore: communityScore,
        weatherScore: weatherScore,
        reviewText: reviewText,
      ),
    );

    return result.fold(
      onSuccess: (review) {
        myReview.value = review;
        // Update reviews list if exists
        final index = reviews.indexWhere((r) => r.id == review.id);
        if (index != -1) {
          reviews[index] = review;
          reviews.refresh(); // 触发 Obx 更新
        } else {
          reviews.insert(0, review);
        }
        return true;
      },
      onFailure: (exception) {
        // log('Failed to upsert review: ${exception.message}');
        return false;
      },
    );
  }

  Future<bool> deleteMyReview(String cityId) async {
    final result = await _deleteMyCityReviewUseCase.execute(
      DeleteMyCityReviewUseCaseParams(cityId: cityId),
    );

    return result.fold(
      onSuccess: (_) {
        final reviewId = myReview.value?.id;
        myReview.value = null;
        if (reviewId != null) {
          reviews.removeWhere((review) => review.id == reviewId);
        }
        return true;
      },
      onFailure: (exception) {
        // log('Failed to delete my review: ${exception.message}');
        return false;
      },
    );
  }

  /// 删除评论（管理员/版主）
  Future<bool> deleteCityReview(String cityId, String reviewId) async {
    final result = await _deleteCityReviewUseCase.execute(
      DeleteCityReviewUseCaseParams(cityId: cityId, reviewId: reviewId),
    );

    return result.fold(
      onSuccess: (_) {
        reviews.removeWhere((review) => review.id == reviewId);
        reviewsTotalCount.value = reviewsTotalCount.value - 1;
        return true;
      },
      onFailure: (exception) {
        log('Failed to delete city review: ${exception.message}');
        return false;
      },
    );
  }

  // ==================== Statistics Methods ====================

  Future<void> loadCityStats(String cityId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _statsCityId == cityId && stats.value != null) {
      return;
    }

    isLoadingStats.value = true;

    final result = await _getCityStatsUseCase.execute(
      GetCityStatsUseCaseParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (data) {
        stats.value = data;
        _statsCityId = cityId;
      },
      onFailure: (exception) {
        // log('Failed to load city stats: ${exception.message}');
      },
    );

    isLoadingStats.value = false;
  }

  Future<void> loadCityCostSummary(String cityId, {bool forceRefresh = false}) async {
    // 如果用户未登录,跳过加载
    if (!_isUserLoggedIn()) {
      log('⚠️ 用户未登录,跳过加载城市费用汇总');
      return;
    }

    if (!forceRefresh && _costSummaryCityId == cityId && costSummary.value != null) {
      return;
    }

    isLoadingCostSummary.value = true;

    final result = await _getCityCostSummaryUseCase.execute(
      GetCityCostSummaryUseCaseParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (data) {
        costSummary.value = data;
        _costSummaryCityId = cityId;
      },
      onFailure: (exception) {
        // log('Failed to load cost summary: ${exception.message}');
      },
    );

    isLoadingCostSummary.value = false;
  }

  // Clear state
  void clearPhotos() => photos.clear();
  void clearExpenses() => expenses.clear();
  void clearReviews() => reviews.clear();
  void clearMyReview() => myReview.value = null;
  void clearStats() => stats.value = null;
  void clearCostSummary() => costSummary.value = null;

  void clearAll() {
    clearPhotos();
    clearExpenses();
    clearReviews();
    clearMyReview();
    clearStats();
    clearCostSummary();
  }

  @override
  void onClose() {
    // 取消数据变更订阅
    _photoChangedSubscription?.cancel();
    _expenseChangedSubscription?.cancel();
    _reviewChangedSubscription?.cancel();

    // 清空所有响应式变量
    photos.clear();
    expenses.clear();
    reviews.clear();
    myReview.value = null;
    stats.value = null;
    costSummary.value = null;

    // 重置加载状态
    isLoadingPhotos.value = false;
    isLoadingExpenses.value = false;
    isLoadingReviews.value = false;
    isLoadingStats.value = false;
    isLoadingCostSummary.value = false;

    super.onClose();
  }
}
