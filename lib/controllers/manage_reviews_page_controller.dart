import 'dart:developer';

import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/user_city_content/application/use_cases/user_city_content_use_cases.dart';
import 'package:go_nomads_app/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ManageReviewsPage 控制器 - 使用独立数据集
class ManageReviewsPageController extends GetxController {
  final String cityId;
  final String cityName;

  ManageReviewsPageController({
    required this.cityId,
    required this.cityName,
  });

  // ========== 独立数据集 ==========
  final RxList<UserCityReview> reviews = <UserCityReview>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalCount = 0.obs;
  static const int _pageSize = 10;

  final RxBool canDelete = false.obs;

  late final ScrollController scrollController;
  static const double _scrollThreshold = 200.0;

  // UseCase 依赖
  late final GetCityReviewsPagedUseCase _getCityReviewsPagedUseCase;
  late final DeleteCityReviewUseCase _deleteCityReviewUseCase;

  @override
  void onInit() {
    super.onInit();
    // 获取 UseCase
    _getCityReviewsPagedUseCase = Get.find<GetCityReviewsPagedUseCase>();
    _deleteCityReviewUseCase = Get.find<DeleteCityReviewUseCase>();

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    _checkPermissions();
    _loadData();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (_isNearBottom && !isLoadingMore.value && hasMore.value) {
      loadMore();
    }
  }

  bool get _isNearBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    return maxScroll - currentScroll <= _scrollThreshold;
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await TokenStorageService().isAdminOrModerator();
    canDelete.value = hasPermission;
  }

  Future<void> loadData() async {
    await _loadData();
  }

  Future<void> _loadData() async {
    log('📋 [ManageReviewsPage] 开始加载数据...');
    isLoading.value = true;

    // 重置分页状态
    currentPage.value = 1;
    hasMore.value = true;

    try {
      final result = await _getCityReviewsPagedUseCase.execute(
        GetCityReviewsPagedUseCaseParams(
          cityId: cityId,
          page: 1,
          pageSize: _pageSize,
        ),
      );

      result.fold(
        onSuccess: (pagedResult) {
          reviews.value = pagedResult.items;
          totalCount.value = pagedResult.totalCount;
          hasMore.value = pagedResult.hasMore;
          currentPage.value = 1;
          log('📋 [ManageReviewsPage] 加载完成, reviews.length=${reviews.length}, total=$totalCount');
        },
        onFailure: (error) {
          log('❌ [ManageReviewsPage] 加载失败: $error');
          AppToast.error('加载评论失败');
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    log('📋 [ManageReviewsPage] 加载更多...');
    isLoadingMore.value = true;

    try {
      final nextPage = currentPage.value + 1;
      final result = await _getCityReviewsPagedUseCase.execute(
        GetCityReviewsPagedUseCaseParams(
          cityId: cityId,
          page: nextPage,
          pageSize: _pageSize,
        ),
      );

      result.fold(
        onSuccess: (pagedResult) {
          reviews.addAll(pagedResult.items);
          hasMore.value = pagedResult.hasMore;
          currentPage.value = nextPage;
          log('📋 [ManageReviewsPage] 加载更多完成, reviews.length=${reviews.length}');
        },
        onFailure: (error) {
          log('❌ [ManageReviewsPage] 加载更多失败: $error');
        },
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      final result = await _deleteCityReviewUseCase.execute(
        DeleteCityReviewUseCaseParams(cityId: cityId, reviewId: reviewId),
      );

      result.fold(
        onSuccess: (_) {
          // 从本地列表中移除
          reviews.removeWhere((r) => r.id == reviewId);
          totalCount.value = totalCount.value - 1;
          AppToast.success('评论已删除');
        },
        onFailure: (error) {
          log('❌ [ManageReviewsPage] 删除失败: $error');
          AppToast.error('删除失败,请重试');
        },
      );
    } catch (e) {
      AppToast.error('删除失败: $e');
    }
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
