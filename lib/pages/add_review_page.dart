import 'dart:io';

import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/add_review_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// 添加 Review 页面 - 独立页面形式
class AddReviewPage extends StatelessWidget {
  final String cityId;
  final String cityName;

  const AddReviewPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  static String _generateTag(String cityId) => 'AddReviewPage_$cityId';

  AddReviewPageController _useController(BuildContext context) {
    final tag = _generateTag(cityId);

    // 验证 cityId
    if (cityId.isEmpty || !_isValidUuid(cityId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final l10n = AppLocalizations.of(context)!;
        AppToast.error(l10n.invalidCityId, title: l10n.error);
        Get.back();
      });
    }

    if (Get.isRegistered<AddReviewPageController>(tag: tag)) {
      return Get.find<AddReviewPageController>(tag: tag);
    }
    return Get.put(
      AddReviewPageController(cityId: cityId, cityName: cityName),
      tag: tag,
    );
  }

  bool _isValidUuid(String id) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(id);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _useController(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.xmark, color: Colors.white, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.writeAReview,
              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              cityName,
              style: TextStyle(color: Colors.white70, fontSize: 14.sp, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            _buildRatingSection(context, controller, l10n),
            SizedBox(height: 32.h),
            _buildTitleInput(context, controller, l10n),
            SizedBox(height: 24.h),
            _buildContentInput(context, controller, l10n),
            SizedBox(height: 24.h),
            _buildPhotosSection(context, controller, l10n),
            SizedBox(height: 32.h),
            _buildGuidelines(context, l10n),
            SizedBox(height: 96.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, controller, l10n),
    );
  }

  Widget _buildRatingSection(BuildContext context, AddReviewPageController controller, AppLocalizations l10n) {
    return Obx(() => Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                controller.getRatingColor(controller.rating.value).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: controller.getRatingColor(controller.rating.value).withValues(alpha: 0.15),
                blurRadius: 20.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.faceSmile,
                      color: controller.getRatingColor(controller.rating.value), size: 24.sp),
                  SizedBox(width: 12.w),
                  Text(
                    l10n.overallRating,
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Text(
                  controller.getRatingEmoji(controller.rating.value),
                  key: ValueKey<double>(controller.rating.value),
                  style: TextStyle(fontSize: 80.sp, height: 1.0),
                ),
              ),
              SizedBox(height: 24.h),
              Column(
                children: [
                  Text(
                    controller.rating.value == 0 ? l10n.tapStarsToRate : _getRatingLabel(controller.rating.value, l10n),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: controller.getRatingColor(controller.rating.value),
                    ),
                  ),
                  if (controller.rating.value > 0) ...[
                    SizedBox(height: 4.h),
                    Text(
                      '${controller.rating.value.toStringAsFixed(1)} / 5.0',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 32.h),
              Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 8.h,
                      activeTrackColor: controller.getRatingColor(controller.rating.value),
                      inactiveTrackColor: Colors.grey.shade200,
                      thumbColor: Colors.white,
                      overlayColor: controller.getRatingColor(controller.rating.value).withValues(alpha: 0.2),
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 16.r, elevation: 4),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 28.r),
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: controller.rating.value,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      onChanged: (value) => controller.rating.value = value,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final value = index.toDouble();
                        final isSelected = (controller.rating.value - value).abs() < 0.3;
                        return GestureDetector(
                          onTap: () => controller.rating.value = value,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(isSelected ? 8.w : 4.w),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? controller.getRatingColor(value).withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              controller.getRatingEmoji(value),
                              style: TextStyle(fontSize: isSelected ? 28.sp : 20.sp),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  String _getRatingLabel(double rating, AppLocalizations l10n) {
    if (rating >= 4.5) return l10n.excellent;
    if (rating >= 4.0) return l10n.veryGood;
    if (rating >= 3.0) return l10n.good;
    if (rating >= 2.0) return l10n.fair;
    if (rating >= 1.0) return l10n.poor;
    return l10n.veryPoor;
  }

  Widget _buildTitleInput(BuildContext context, AddReviewPageController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.heading, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(l10n.reviewTitle,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            SizedBox(width: 4.w),
            Text(l10n.required, style: TextStyle(color: const Color(0xFFFF4458), fontSize: 16.sp)),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: controller.titleController,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: l10n.reviewTitleHint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.borderLight)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: const Color(0xFFFF4458), width: 2)),
            counterStyle: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return l10n.pleaseEnterTitle;
            if (value.trim().length < 5) return l10n.titleMinLength;
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContentInput(BuildContext context, AddReviewPageController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.penToSquare, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(l10n.yourExperience,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            SizedBox(width: 4.w),
            Text(l10n.required, style: TextStyle(color: const Color(0xFFFF4458), fontSize: 16.sp)),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: controller.contentController,
          maxLength: 1000,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: l10n.experienceHint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.borderLight)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: const Color(0xFFFF4458), width: 2)),
            counterStyle: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return l10n.pleaseShareExperience;
            if (value.trim().length < 20) return l10n.experienceMinLength;
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhotosSection(BuildContext context, AddReviewPageController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.images, color: AppColors.textSecondary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(l10n.photos,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                SizedBox(width: 8.w),
                Text(l10n.optional, style: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary)),
              ],
            ),
            Obx(() => Text(
                  '${controller.selectedImages.length} / 5',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: controller.selectedImages.length >= 5 ? const Color(0xFFFF4458) : AppColors.textSecondary,
                  ),
                )),
          ],
        ),
        SizedBox(height: 12.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            
            return Obx(() {
              // 如果没有图片，显示占满宽度的添加按钮
              if (controller.selectedImages.isEmpty) {
                return _buildFullWidthAddButton(context, controller, l10n, availableWidth);
              }
              
              // 有图片时，固定每行显示5个图片
              const itemCount = 5;
              const spacing = 8.0;
              final itemWidth = (availableWidth - (itemCount - 1) * spacing) / itemCount;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(itemCount, (index) {
                  if (index < controller.selectedImages.length) {
                    // 显示已选择的图片
                    return _buildImageThumbnail(
                      controller.selectedImages[index], 
                      index, 
                      controller, 
                      itemWidth,
                    );
                  } else if (index == controller.selectedImages.length && controller.selectedImages.length < 5) {
                    // 显示添加按钮
                    return _buildAddImageButton(context, controller, l10n, itemWidth);
                  } else {
                    // 显示占位框
                    return _buildPlaceholder(itemWidth);
                  }
                }),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(XFile image, int index, AddReviewPageController controller, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(File(image.path), width: size, height: size, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4.h,
            right: 4.w,
            child: GestureDetector(
              onTap: () => controller.removeImage(index),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), shape: BoxShape.circle),
                child: Icon(FontAwesomeIcons.xmark, size: 16.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(BuildContext context, AddReviewPageController controller, AppLocalizations l10n, double size) {
    return GestureDetector(
      onTap: () => controller.pickImages(
        errorTitle: l10n.error,
        failedToPickImages: l10n.failedToPickImages,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFFF4458), width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.photoFilm, color: const Color(0xFFFF4458), size: 24.sp),
            SizedBox(height: 2.h),
            Text(l10n.addPhoto,
                style: TextStyle(fontSize: 10.sp, color: const Color(0xFFFF4458), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight, width: 1, style: BorderStyle.solid),
      ),
    );
  }

  Widget _buildFullWidthAddButton(BuildContext context, AddReviewPageController controller, AppLocalizations l10n, double width) {
    return GestureDetector(
      onTap: () => controller.pickImages(
        errorTitle: l10n.error,
        failedToPickImages: l10n.failedToPickImages,
      ),
      child: Container(
        width: width,
        height: 120.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFFF4458), width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.photoFilm, color: const Color(0xFFFF4458), size: 40.sp),
            SizedBox(height: 8.h),
            Text(l10n.addPhoto,
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFFFF4458), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelines(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.circleInfo, color: Colors.blue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(l10n.reviewGuidelines,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          SizedBox(height: 12.h),
          _buildGuidelineItem(l10n.guidelineHonest),
          _buildGuidelineItem(l10n.guidelineFacts),
          _buildGuidelineItem(l10n.guidelineRespect),
          _buildGuidelineItem(l10n.guidelinePhotos),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(text, style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.4)),
    );
  }

  Widget _buildBottomBar(BuildContext context, AddReviewPageController controller, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, -2.h))],
      ),
      child: SafeArea(
        child: Obx(() => ElevatedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () => controller.submitReview(
                        pleaseSelectRating: l10n.pleaseSelectRating,
                        missingRating: l10n.missingRating,
                        reviewSubmitted: l10n.reviewSubmitted,
                        successTitle: l10n.success,
                        errorTitle: l10n.error,
                        failedToSubmitReview: l10n.failedToSubmitReview,
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cityPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
                disabledBackgroundColor: AppColors.cityPrimary.withValues(alpha: 0.5),
              ),
              child: controller.isSubmitting.value
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.circleCheck, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(l10n.submitReview, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
            )),
      ),
    );
  }
}
