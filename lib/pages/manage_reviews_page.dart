import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/manage_reviews_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/city_detail/widgets/tabs/reviews_tab.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

import 'add_review_page.dart';

/// Reviews 数据管理列表页面 - 使用独立数据集
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
  late final String _tag;
  late final ManageReviewsPageController _controller;

  @override
  void initState() {
    super.initState();
    _tag = 'ManageReviewsPage_${widget.cityId}';
    _controller = Get.put(
      ManageReviewsPageController(cityId: widget.cityId, cityName: widget.cityName),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<ManageReviewsPageController>(tag: _tag)) {
        Get.delete<ManageReviewsPageController>(tag: _tag);
      }
    });
    super.dispose();
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        title: Text('${widget.cityName} - 评论管理'),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus),
            onPressed: () async {
              await NavigationUtil.toWithCallback<Map<String, dynamic>>(
                page: () => AddReviewPage(
                  cityId: widget.cityId,
                  cityName: widget.cityName,
                ),
                onResult: (result) async {
                  if (result.needsRefresh) {
                    await _controller.loadData();
                  }
                },
              );
            },
            tooltip: '添加评论',
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const ManageListSkeleton();
        }

        if (_controller.reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.commentDots, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  '暂无评论数据',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    await NavigationUtil.toWithCallback<Map<String, dynamic>>(
                      page: () => AddReviewPage(
                        cityId: widget.cityId,
                        cityName: widget.cityName,
                      ),
                      onResult: (result) async {
                        if (result.needsRefresh) {
                          await _controller.loadData();
                        }
                      },
                    );
                  },
                  icon: const Icon(FontAwesomeIcons.plus),
                  label: const Text('添加第一条评论'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _controller.scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _controller.reviews.length + 1,
          itemBuilder: (context, index) {
            // 底部加载指示器
            if (index == _controller.reviews.length) {
              return Obx(() {
                if (_controller.isLoadingMore.value) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!_controller.hasMore.value) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        '已加载全部 ${_controller.reviews.length} 条评论',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              });
            }

            final review = _controller.reviews[index];
            return ReviewCard(
              review: review,
              l10n: l10n,
              onDelete: _controller.canDelete.value ? () => _deleteReview(review.id) : null,
            );
          },
        );
      }),
    );
  }
}
