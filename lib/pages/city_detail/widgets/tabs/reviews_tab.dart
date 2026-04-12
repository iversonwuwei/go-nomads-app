import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:go_nomads_app/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/add_review_page.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail_controller.dart';
import 'package:go_nomads_app/pages/manage_reviews_page.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:intl/intl.dart';

/// Reviews Tab - 评论标签页
/// 只加载5条评论预览，header有跳转icon可查看全部
class ReviewsTab extends GetView<CityDetailController> {
  final String? _tag;

  const ReviewsTab({
    super.key,
    required String? tag,
  }) : _tag = tag;

  @override
  String? get tag => _tag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contentController = Get.find<UserCityContentStateController>();

    return Obx(() {
      final reviews = contentController.reviews;
      final totalCount = contentController.reviewsTotalCount.value;
      final showInitialLoading =
          contentController.isLoadingReviews.value && reviews.isEmpty && !controller.isRefreshingReviews.value;

      Widget content;
      if (reviews.isEmpty) {
        content = _ReviewsEmptyState(
          onRefresh: () => _handleRefresh(contentController),
        );
      } else {
        content = RefreshIndicator(
          onRefresh: () => _handleRefresh(contentController),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.reviews,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        if (totalCount > 0)
                          Text(
                            '$totalCount ${l10n.reviews.toLowerCase()}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => _navigateToReviewList(),
                          child: Icon(
                            FontAwesomeIcons.chevronRight,
                            size: 16.r,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ...reviews.map((review) => ReviewCard(
                      review: review,
                      l10n: l10n,
                    )),
              ],
            ),
          ),
        );
      }

      return AppLoadingSwitcher(
        isLoading: showInitialLoading,
        loading: const ReviewsTabSkeleton(),
        child: content,
      );
    });
  }

  Future<void> _handleRefresh(UserCityContentStateController contentController) async {
    controller.isRefreshingReviews.value = true;
    await contentController.loadCityReviews(controller.cityId);
    controller.isRefreshingReviews.value = false;
  }

  /// 跳转到评论列表页面
  void _navigateToReviewList() async {
    final contentController = Get.find<UserCityContentStateController>();
    await Get.to(() => ManageReviewsPage(
          cityId: controller.cityId,
          cityName: controller.cityName,
        ));
    // 返回后重新加载预览数据（5条）
    contentController.loadCityReviews(controller.cityId);
  }

  /// 跳转到添加/管理评论页面
  static Future<void> navigateToAddReview({
    required String cityId,
    required String cityName,
    required bool isAdminOrModerator,
  }) async {
    final contentController = Get.find<UserCityContentStateController>();

    if (isAdminOrModerator) {
      await Get.to(() => ManageReviewsPage(
            cityId: cityId,
            cityName: cityName,
          ));
      // 从管理页面返回后，重新加载预览数据（5条）
      contentController.loadCityReviews(cityId);
    } else {
      await Get.to(() => AddReviewPage(
            cityId: cityId,
            cityName: cityName,
          ));
      contentController.loadCityReviews(cityId);
    }
  }
}

/// 评论卡片（公开类，可在其他页面复用）
class ReviewCard extends StatelessWidget {
  final UserCityReview review;
  final AppLocalizations l10n;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    required this.l10n,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息行（带删除按钮）
            Row(
              children: [
                Expanded(child: _UserInfoRow(review: review, l10n: l10n)),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(FontAwesomeIcons.trash, color: Colors.red[300], size: 16.r),
                    onPressed: onDelete,
                    tooltip: '删除',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            // 标题
            Text(
              review.title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),

            // 内容
            Text(
              review.content,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),

            // 图片
            if (review.photoUrls.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.w,
                  children: review.photoUrls
                      .map(
                        (url) => ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: SafeNetworkImage(
                            imageUrl: url,
                            width: 80.w,
                            height: 80.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

            // 评分与时间
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.solidStar, size: 14.r, color: Colors.amber[600]),
                      SizedBox(width: 6.w),
                      Text(
                        review.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(review.createdAt),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

/// 用户信息行
class _UserInfoRow extends StatelessWidget {
  final UserCityReview review;
  final AppLocalizations l10n;

  const _UserInfoRow({
    required this.review,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SafeCircleAvatar(
          imageUrl: review.userAvatar,
          radius: 20,
          backgroundColor: AppColors.cityPrimary,
          placeholder: Text(
            review.username.isNotEmpty ? review.username.substring(0, 1).toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
          errorWidget: Text(
            review.username.isNotEmpty ? review.username.substring(0, 1).toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (review.visitDate != null)
                Text(
                  '${l10n.visited} ${DateFormat('yyyy-MM-dd').format(review.visitDate!)}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        Row(
          children: [
            Icon(FontAwesomeIcons.star, color: Colors.amber, size: 16.r),
            Text(review.rating.toString()),
          ],
        ),
      ],
    );
  }
}

/// 全屏图片画廊
class _FullscreenGalleryPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullscreenGalleryPage({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullscreenGalleryPage> createState() => _FullscreenGalleryPageState();
}

class _FullscreenGalleryPageState extends State<_FullscreenGalleryPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0F141A),
      child: SafeArea(
        child: Stack(
          children: [
            // 图片轮播
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            // 顶部栏
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GalleryActionButton(
                      icon: Icons.close,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.imageUrls.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 48.w), // 占位保持居中
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryActionButton extends StatelessWidget {
  const _GalleryActionButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Icon(icon, color: Colors.white, size: 20.r),
        ),
      ),
    );
  }
}

/// 空状态
class _ReviewsEmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _ReviewsEmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: AppUiTokens.softFloatingShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72.w,
                        height: 72.w,
                        decoration: BoxDecoration(
                          color: AppColors.cityPrimaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(FontAwesomeIcons.commentDots, size: 30.r, color: AppColors.cityPrimary),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No reviews yet',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Be the first to write a review!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
