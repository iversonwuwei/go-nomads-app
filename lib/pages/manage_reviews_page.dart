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
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.manageReviewsDeleteConfirmTitle),
        content: Text(l10n.manageReviewsDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.cityPrimary),
            child: Text(l10n.delete),
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
        title: Text(l10n.manageReviewsPageTitle(widget.cityName)),
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
            tooltip: l10n.addReview,
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
                Icon(FontAwesomeIcons.commentDots, size: 80.r, color: Colors.grey[300]),
                SizedBox(height: 16.h),
                Text(
                  l10n.manageReviewsNoData,
                  style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 24.h),
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
                  label: Text(l10n.manageReviewsAddFirstReview),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _controller.scrollController,
          padding: EdgeInsets.all(16.w),
          itemCount: _controller.reviews.length + 1,
          itemBuilder: (context, index) {
            // 底部加载指示器
            if (index == _controller.reviews.length) {
              return Obx(() {
                if (_controller.isLoadingMore.value) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!_controller.hasMore.value) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: Text(
                        l10n.manageReviewsLoadedAll(_controller.reviews.length),
                        style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
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
