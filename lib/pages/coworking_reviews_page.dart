import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/coworking_reviews_page_controller.dart';
import 'package:go_nomads_app/features/coworking/domain/entities/coworking_review.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';

import 'add_coworking_review/add_coworking_review_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Coworking Review 列表页面 - 无限滚动
class CoworkingReviewsPage extends StatelessWidget {
  final String coworkingId;
  final String coworkingName;

  const CoworkingReviewsPage({
    super.key,
    required this.coworkingId,
    required this.coworkingName,
  });

  String get _tag => 'CoworkingReviewsPage_$coworkingId';

  CoworkingReviewsPageController get _controller {
    if (!Get.isRegistered<CoworkingReviewsPageController>(tag: _tag)) {
      Get.put(
        CoworkingReviewsPageController(
          coworkingId: coworkingId,
          coworkingName: coworkingName,
        ),
        tag: _tag,
      );
    }
    return Get.find<CoworkingReviewsPageController>(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = _controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const AppBackButton(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reviews,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              coworkingName,
              style: TextStyle(
                fontSize: 12.sp,
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.circlePlus, size: 24.r),
            onPressed: () async {
              await NavigationUtil.toWithCallback<bool>(
                page: () => AddCoworkingReviewPage(
                  coworkingId: coworkingId,
                  coworkingName: coworkingName,
                ),
                onResult: (result) {
                  if (result.needsRefresh) {
                    controller.refresh();
                  }
                },
              );
            },
            tooltip: '添加评论',
          ),
        ],
      ),
      body: Obx(() {
        // 首次加载时显示中间加载指示器
        if (controller.isLoading.value && controller.reviews.isEmpty) {
          return const AppSceneLoading(scene: AppLoadingScene.reviews, fullScreen: true);
        }

        if (controller.reviews.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refresh,
            color: const Color(0xFF007AFF),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: _buildEmptyState(l10n, controller),
                  ),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: const Color(0xFF007AFF),
          child: ListView.builder(
            controller: controller.scrollController,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: controller.reviews.length + (controller.hasMore.value || controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.reviews.length) {
                return _buildLoadingIndicator();
              }

              final review = controller.reviews[index];
              return _buildReviewCard(review, index, l10n, controller);
            },
          ),
        );
      }),
    );
  }

  /// 空状态
  Widget _buildEmptyState(AppLocalizations l10n, CoworkingReviewsPageController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(60.r),
            ),
            child: Icon(
              FontAwesomeIcons.commentDots,
              size: 56.r,
              color: Color(0xFFC7C7CC),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Be the first to write a review',
            style: TextStyle(
              fontSize: 15.sp,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 32.h),
          TextButton(
            onPressed: () async {
              await NavigationUtil.toWithCallback<bool>(
                page: () => AddCoworkingReviewPage(
                  coworkingId: coworkingId,
                  coworkingName: coworkingName,
                ),
                onResult: (result) {
                  if (result.needsRefresh) {
                    controller.refresh();
                  }
                },
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Write a Review',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 加载指示器
  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: const Center(child: AppLoadingWidget(fullScreen: false)),
    );
  }

  /// 评论卡片 - 扁平化设计
  Widget _buildReviewCard(
    CoworkingReview review,
    int index,
    AppLocalizations l10n,
    CoworkingReviewsPageController controller,
  ) {
    return Obx(() {
      // 只有管理员才能滑动删除
      if (controller.isAdmin.value) {
        return Dismissible(
          key: Key(review.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await Get.dialog<bool>(
                  AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    title: Text(
                      'Delete Review',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to delete this review? This action cannot be undone.',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Color(0xFF3C3C43),
                        height: 1.4,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: Color(0xFFFF3B30),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (direction) => controller.deleteReview(review.id, index),
          background: Container(
            color: const Color(0xFFFF3B30),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.w),
            child: Icon(
              FontAwesomeIcons.trash,
              color: Colors.white,
              size: 28.r,
            ),
          ),
          child: _buildReviewCardContent(review, l10n, controller),
        );
      }

      // 非管理员直接显示卡片
      return _buildReviewCardContent(review, l10n, controller);
    });
  }

  /// 评论卡片内容
  Widget _buildReviewCardContent(
    CoworkingReview review,
    AppLocalizations l10n,
    CoworkingReviewsPageController controller,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            // 可选：点击查看详情
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部：用户信息和评分
                Row(
                  children: [
                    // 用户头像
                    SafeCircleAvatar(
                      imageUrl: review.userAvatar,
                      radius: 20,
                      backgroundColor: const Color(0xFFF2F2F7),
                      placeholder: Text(
                        review.username.isNotEmpty ? review.username.substring(0, 1).toUpperCase() : '?',
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      errorWidget: Text(
                        review.username.isNotEmpty ? review.username.substring(0, 1).toUpperCase() : '?',
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // 用户名和访问日期
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.username,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (review.visitDate != null)
                            Text(
                              'Visited ${controller.formatDate(review.visitDate!)}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Color(0xFF8E8E93),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 评分
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.star,
                            color: Color(0xFFFFCC00),
                            size: 16.r,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            review.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // 标题
                Text(
                  review.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.3,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),
                // 内容
                Text(
                  review.content,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Color(0xFF3C3C43),
                    height: 1.4,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                // 图片
                if (review.hasPhotos) ...[
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 80.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: review.photoUrls.length,
                      itemBuilder: (context, photoIndex) {
                        return Container(
                          width: 80.w,
                          margin: EdgeInsets.only(right: 8.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: const Color(0xFFF2F2F7),
                            image: DecorationImage(
                              image: NetworkImage(review.photoUrls[photoIndex]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                SizedBox(height: 12.h),
                // 底部：状态和时间
                Row(
                  children: [
                    // 验证状态
                    if (review.isVerified)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.circleCheck,
                              size: 12.r,
                              color: Color(0xFF34C759),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Color(0xFF34C759),
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E5),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.clock,
                              size: 12.r,
                              color: Color(0xFFFF9500),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Color(0xFFFF9500),
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    // 发布时间
                    Text(
                      controller.formatDate(review.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFFAEAEB2),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
