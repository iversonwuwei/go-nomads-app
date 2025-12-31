import 'package:df_admin_mobile/pages/add_coworking_review/add_coworking_review_page.dart';
import 'package:df_admin_mobile/controllers/coworking_detail_page_controller.dart';
import 'package:df_admin_mobile/pages/coworking_reviews_page.dart';
import 'package:df_admin_mobile/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CoworkingDetailCommentsSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailCommentsSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('用户评论', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _navigateToAddComment(context),
                icon: const Icon(FontAwesomeIcons.commentMedical, size: 20),
                label: const Text('发表评论'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (_c.isLoadingComments.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
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
                padding: const EdgeInsets.only(top: 16),
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
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(FontAwesomeIcons.comment, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('暂无评论', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 8),
          Text('成为第一个发表评论的人', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return Obx(() => Column(
      children: _c.comments.map((comment) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment.username, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(_c.formatDate(comment.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 评分星级
                if (comment.rating > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
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

                          return Icon(iconData, color: color, size: 16);
                        }),
                        const SizedBox(width: 8),
                        Text(
                          comment.rating.toStringAsFixed(1),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                if (comment.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(comment.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                Text(comment.content, style: const TextStyle(fontSize: 15, height: 1.5)),
                if (comment.photoUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: comment.photoUrls.take(3).map((imageUrl) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
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
    final result = await Get.to<bool>(
      () => AddCoworkingReviewPage(
        coworkingId: _c.space.value.id,
        coworkingName: _c.space.value.name,
      ),
    );

    if (result == true) {
      _c.markDataChanged();
      await Future.wait([
        _c.loadComments(),
        _c.reloadCoworkingDetail(),
      ]);
    }
  }
}
