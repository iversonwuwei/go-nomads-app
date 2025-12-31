import 'dart:developer';

import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_review.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_review_repository.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// CoworkingReviewsPage 控制器
class CoworkingReviewsPageController extends GetxController {
  final String coworkingId;
  final String coworkingName;

  CoworkingReviewsPageController({
    required this.coworkingId,
    required this.coworkingName,
  });

  final ScrollController scrollController = ScrollController();
  final RxList<CoworkingReview> reviews = <CoworkingReview>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool isAdmin = false.obs;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _checkAdminStatus();
    loadReviews();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  /// 检查当前用户是否是管理员
  Future<void> _checkAdminStatus() async {
    final tokenService = Get.find<TokenStorageService>();
    final role = await tokenService.getUserRole();
    isAdmin.value = role == 'admin';
  }

  /// 滚动监听
  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
        !isLoading.value &&
        !isLoadingMore.value &&
        hasMore.value) {
      loadMore();
    }
  }

  /// 首次加载评论
  Future<void> loadReviews() async {
    if (isLoading.value) return;

    isLoading.value = true;
    _currentPage = 1;
    hasMore.value = true;

    try {
      final repository = Get.find<ICoworkingReviewRepository>();
      final loadedReviews = await repository.getCoworkingReviews(
        coworkingId: coworkingId,
        page: _currentPage,
        pageSize: _pageSize,
      );

      reviews.assignAll(loadedReviews);
      hasMore.value = loadedReviews.length >= _pageSize;
    } catch (e) {
      log('❌ 加载评论失败: $e');
      AppToast.error('加载评论失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    _currentPage++;

    try {
      final repository = Get.find<ICoworkingReviewRepository>();
      final loadedReviews = await repository.getCoworkingReviews(
        coworkingId: coworkingId,
        page: _currentPage,
        pageSize: _pageSize,
      );

      reviews.addAll(loadedReviews);
      hasMore.value = loadedReviews.length >= _pageSize;
    } catch (e) {
      log('❌ 加载更多评论失败: $e');
      // 加载失败时回退页码
      _currentPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 刷新
  Future<void> refresh() async {
    await loadReviews();
  }

  /// 删除评论
  Future<void> deleteReview(String reviewId, int index) async {
    try {
      final repository = Get.find<ICoworkingReviewRepository>();
      await repository.deleteReview(reviewId);
      reviews.removeAt(index);
      AppToast.success('Review deleted');
    } catch (e) {
      AppToast.error('Failed to delete: $e');
      // 删除失败，刷新列表恢复
      refresh();
    }
  }

  /// 格式化日期
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
