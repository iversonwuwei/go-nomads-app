import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:df_admin_mobile/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/add_review_page.dart';
import 'package:df_admin_mobile/pages/city_detail/city_detail_controller.dart';
import 'package:df_admin_mobile/pages/manage_reviews_page.dart';
import 'package:df_admin_mobile/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Reviews Tab - 评论标签页
/// 使用 GetView 绑定 CityDetailController
class ReviewsTab extends GetView<CityDetailController> {
  @override
  final String? tag;

  const ReviewsTab({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contentController = Get.find<UserCityContentStateController>();

    return Obx(() {
      final reviews = contentController.reviews;

      // 首次加载
      if (contentController.isLoadingReviews.value && reviews.isEmpty && !controller.isRefreshingReviews.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // 空状态
      if (reviews.isEmpty) {
        return _ReviewsEmptyState(
          onRefresh: () => _handleRefresh(contentController),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _handleRefresh(contentController),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) => _ReviewCard(
            review: reviews[index],
            l10n: l10n,
          ),
        ),
      );
    });
  }

  Future<void> _handleRefresh(UserCityContentStateController contentController) async {
    controller.isRefreshingReviews.value = true;
    await contentController.loadCityReviews(controller.cityId);
    controller.isRefreshingReviews.value = false;
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
    } else {
      await Get.to(() => AddReviewPage(
            cityId: cityId,
            cityName: cityName,
          ));
    }
    contentController.loadCityReviews(cityId);
  }
}

/// 评论卡片
class _ReviewCard extends StatelessWidget {
  final UserCityReview review;
  final AppLocalizations l10n;

  const _ReviewCard({
    required this.review,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息行
            _UserInfoRow(review: review, l10n: l10n),
            const SizedBox(height: 12),

            // 标题
            Text(
              review.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 内容
            Text(
              review.content,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),

            // 图片 - 只有当有图片时才显示
            if (review.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ReviewPhotos(photoUrls: review.photoUrls),
            ],
            const SizedBox(height: 8),

            // 发布时间
            Text(
              '${l10n.posted} ${_formatDate(review.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
        const SizedBox(width: 12),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        Row(
          children: [
            const Icon(FontAwesomeIcons.star, color: Colors.amber, size: 16),
            Text(' ${review.rating}'),
          ],
        ),
      ],
    );
  }
}

/// 评论图片
class _ReviewPhotos extends StatelessWidget {
  final List<String> photoUrls;

  const _ReviewPhotos({required this.photoUrls});

  @override
  Widget build(BuildContext context) {
    // 如果没有图片，不渲染任何内容
    if (photoUrls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photoUrls.length,
        itemBuilder: (context, index) => Container(
          width: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(photoUrls[index]),
              fit: BoxFit.cover,
            ),
          ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.commentDots, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No reviews yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to write a review!',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
