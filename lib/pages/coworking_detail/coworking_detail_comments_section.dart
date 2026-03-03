import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/coworking_detail_page_controller.dart';
import 'package:go_nomads_app/pages/add_coworking_review/add_coworking_review_page.dart';
import 'package:go_nomads_app/pages/coworking_reviews_page.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoworkingDetailCommentsSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailCommentsSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('用户评论', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _navigateToAddComment(context),
                icon: Icon(FontAwesomeIcons.commentMedical, size: 20.r),
                label: const Text('发表评论'),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (_c.isLoadingComments.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0.w),
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (_c.comments.isEmpty) {
              return _buildEmptyComments();
            } else {
              return _buildCommentsList();
            }
          }),
          Obx(() {
            if (_c.comments.isNotEmpty && _c.comments.length >= 3) {
              return Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      Get.to(() => CoworkingReviewsPage(
                            coworkingId: _c.space.value.id,
                            coworkingName: _c.space.value.name,
                          ))?.then((_) {
                        _c.loadComments();
                        _c.reloadCoworkingDetail();
                      });
                    },
                    child: const Text('查看更多评论'),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Container(
      padding: EdgeInsets.all(32.w),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(FontAwesomeIcons.comment, size: 48.r, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text('暂无评论', style: TextStyle(color: Colors.grey[600], fontSize: 16.sp)),
          SizedBox(height: 8.h),
          Text('成为第一个发表评论的人', style: TextStyle(color: Colors.grey[500], fontSize: 14.sp)),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return Obx(() => Column(
          children: _c.comments.map((comment) {
            return Card(
              margin: EdgeInsets.only(bottom: 12.h),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SafeCircleAvatar(
                          imageUrl: comment.userAvatar,
                          radius: 20,
                          backgroundColor: Colors.blue[100],
                          placeholder: Text(
                            comment.username.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                          ),
                          errorWidget: Text(
                            comment.username.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment.username, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                              Text(_c.formatDate(comment.createdAt),
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // 评分星级
                    if (comment.rating > 0)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          children: [
                            ...List.generate(5, (index) {
                              final starValue = index + 1;
                              final rating = comment.rating;
                              IconData iconData;
                              Color color;

                              if (rating >= starValue) {
                                iconData = FontAwesomeIcons.solidStar;
                                color = Colors.amber;
                              } else if (rating > starValue - 1 && rating < starValue) {
                                iconData = FontAwesomeIcons.starHalfStroke;
                                color = Colors.amber;
                              } else {
                                iconData = FontAwesomeIcons.star;
                                color = Colors.grey.shade300;
                              }

                              return Icon(iconData, color: color, size: 16.r);
                            }),
                            SizedBox(width: 8.w),
                            Text(
                              comment.rating.toStringAsFixed(1),
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    if (comment.title.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(comment.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
                      ),
                    Text(comment.content, style: TextStyle(fontSize: 15.sp, height: 1.5)),
                    if (comment.photoUrls.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: Wrap(
                          spacing: 8.w,
                          runSpacing: 8.w,
                          children: comment.photoUrls.take(3).map((imageUrl) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.network(
                                imageUrl,
                                width: 100.w,
                                height: 100.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100.w,
                                    height: 100.h,
                                    color: Colors.grey[300],
                                    child: const Icon(FontAwesomeIcons.image),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ));
  }

  Future<void> _navigateToAddComment(BuildContext context) async {
    await NavigationUtil.toWithCallback<bool>(
      page: () => AddCoworkingReviewPage(
        coworkingId: _c.space.value.id,
        coworkingName: _c.space.value.name,
      ),
      onResult: (result) async {
        if (result.needsRefresh) {
          _c.markDataChanged();
          await Future.wait([
            _c.loadComments(),
            _c.reloadCoworkingDetail(),
          ]);
        }
      },
    );
  }
}
