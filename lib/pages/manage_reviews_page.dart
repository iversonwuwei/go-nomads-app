import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:df_admin_mobile/controllers/manage_reviews_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'add_review_page.dart';

/// Reviews 数据管理列表页面
class ManageReviewsPage extends StatelessWidget {
  final String cityId;
  final String cityName;

  const ManageReviewsPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  String get _tag => 'ManageReviewsPage_$cityId';

  ManageReviewsPageController get _controller {
    if (!Get.isRegistered<ManageReviewsPageController>(tag: _tag)) {
      Get.put(
        ManageReviewsPageController(cityId: cityId, cityName: cityName),
        tag: _tag,
      );
    }
    return Get.find<ManageReviewsPageController>(tag: _tag);
  }

  Future<void> _deleteReview(String reviewId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条评论吗？此操作可以恢复。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.cityPrimary),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _controller.deleteReview(reviewId);
  }

  @override
  Widget build(BuildContext context) {
    // 确保控制器已初始化
    final controller = _controller;
    final contentController = Get.find<UserCityContentStateController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        title: Text('$cityName - 评论管理'),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus),
            onPressed: () async {
              final result = await Get.to(() => AddReviewPage(
                    cityId: cityId,
                    cityName: cityName,
                  ));
              if (result != null && result['success'] == true) {
                await controller.loadData();
              }
            },
            tooltip: '添加评论',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (contentController.reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.commentDots,
                    size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  '暂无评论数据',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Get.to(() => AddReviewPage(
                          cityId: cityId,
                          cityName: cityName,
                        ));
                    if (result != null && result['success'] == true) {
                      await controller.loadData();
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.plus),
                  label: const Text('添加第一条评论'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contentController.reviews.length,
          itemBuilder: (context, index) {
            final review = contentController.reviews[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(
                    '${review.rating}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  review.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      review.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.star,
                            size: 14, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        Text(
                          '${review.rating}/5',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(FontAwesomeIcons.calendar,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          controller.formatDate(review.createdAt),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: Obx(() => controller.canDelete.value
                    ? IconButton(
                        icon: const Icon(FontAwesomeIcons.trash,
                            color: Colors.red),
                        onPressed: () => _deleteReview(review.id),
                        tooltip: '删除',
                      )
                    : const SizedBox.shrink()),
              ),
            );
          },
        );
      }),
    );
  }
}
