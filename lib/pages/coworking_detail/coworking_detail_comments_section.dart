import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/controllers/coworking_detail_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.coworkingDetailUserComments,
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: 12.w),
              TextButton.icon(
                onPressed: () => _navigateToAddComment(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.cityPrimary,
                  backgroundColor: AppColors.cityPrimaryLight,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                icon: Icon(FontAwesomeIcons.commentMedical, size: 16.r),
                label: Text(l10n.coworkingDetailPostComment),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (_c.isLoadingComments.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0.w),
                  child: CircularProgressIndicator(color: AppColors.cityPrimary),
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
                    style: TextButton.styleFrom(foregroundColor: AppColors.cityPrimary),
                    onPressed: () {
                      Get.to(() => CoworkingReviewsPage(
                            coworkingId: _c.space.value.id,
                            coworkingName: _c.space.value.name,
                          ))?.then((_) {
                        _c.loadComments();
                        _c.reloadCoworkingDetail();
                      });
                    },
                    child: Text(l10n.coworkingDetailViewMoreComments),
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
    final l10n = AppLocalizations.of(Get.context!)!;
    return Container(
      padding: EdgeInsets.all(32.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(FontAwesomeIcons.comment, size: 48.r, color: AppColors.textTertiary),
          SizedBox(height: 16.h),
          Text(
            l10n.coworkingDetailNoComments,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.coworkingDetailBeFirstCommenter,
            style: TextStyle(color: AppColors.textTertiary, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return Obx(() => Column(
          children: _c.comments.map((comment) {
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: AppUiTokens.softFloatingShadow,
              ),
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
                          backgroundColor: AppColors.cityPrimaryLight,
                          placeholder: Text(
                            comment.username.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: AppColors.cityPrimary, fontWeight: FontWeight.bold),
                          ),
                          errorWidget: Text(
                            comment.username.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: AppColors.cityPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment.username,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _c.formatDate(comment.createdAt),
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
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
                                color = AppColors.travelAmber;
                              } else if (rating > starValue - 1 && rating < starValue) {
                                iconData = FontAwesomeIcons.starHalfStroke;
                                color = AppColors.travelAmber;
                              } else {
                                iconData = FontAwesomeIcons.star;
                                color = AppColors.border;
                              }

                              return Icon(iconData, color: color, size: 16.r);
                            }),
                            SizedBox(width: 8.w),
                            Text(
                              comment.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (comment.title.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(
                          comment.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    Text(
                      comment.content,
                      style: TextStyle(fontSize: 15.sp, height: 1.5, color: AppColors.textSecondary),
                    ),
                    if (comment.photoUrls.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: Wrap(
                          spacing: 8.w,
                          runSpacing: 8.w,
                          children: comment.photoUrls.take(3).map((imageUrl) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(
                                imageUrl,
                                width: 100.w,
                                height: 100.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100.w,
                                    height: 100.h,
                                    color: AppColors.backgroundSecondary,
                                    child: Icon(FontAwesomeIcons.image, color: AppColors.textTertiary, size: 18.r),
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
