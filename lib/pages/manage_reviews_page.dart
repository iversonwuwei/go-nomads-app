import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import '../services/token_storage_service.dart';
import 'add_review_page.dart';

/// Reviews 数据管理列表页面
class ManageReviewsPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const ManageReviewsPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<ManageReviewsPage> createState() => _ManageReviewsPageState();
}

class _ManageReviewsPageState extends State<ManageReviewsPage> {
  final RxBool canDelete = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    // 异步加载数据,不阻塞页面显示
    Future.microtask(() {
      _checkPermissions();
      _loadData();
    });
  }

  Future<void> _checkPermissions() async {
    final isAdmin = await TokenStorageService().isAdmin();
    canDelete.value = isAdmin;
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      final controller = Get.find<UserCityContentStateController>();
      await controller.loadCityReviews(widget.cityId);
    } finally {
      isLoading.value = false;
    }
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final controller = Get.find<UserCityContentStateController>();
      // 注意: 当前API只能删除自己的review,需要后端添加admin删除接口
      final success = await controller.deleteMyReview(widget.cityId);

      if (success) {
        Get.snackbar(
          '成功',
          '评论已删除',
          backgroundColor: Colors.green[100],
          duration: const Duration(seconds: 2),
        );
        await _loadData();
      } else {
        Get.snackbar('失败', '删除失败,请重试');
      }
    } catch (e) {
      Get.snackbar('错误', '删除失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserCityContentStateController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cityName} - 评论管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Get.to(() => AddReviewPage(
                    cityId: widget.cityId,
                    cityName: widget.cityName,
                  ));
              if (result != null && result['success'] == true) {
                await _loadData();
              }
            },
            tooltip: '添加评论',
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  '暂无评论数据',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Get.to(() => AddReviewPage(
                          cityId: widget.cityId,
                          cityName: widget.cityName,
                        ));
                    if (result != null && result['success'] == true) {
                      await _loadData();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('添加第一条评论'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.reviews.length,
          itemBuilder: (context, index) {
            final review = controller.reviews[index];
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
                        Icon(Icons.star, size: 14, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        Text(
                          '${review.rating}/5',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(review.createdAt),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: canDelete.value
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteReview(review.id),
                        tooltip: '删除',
                      )
                    : null,
              ),
            );
          },
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
