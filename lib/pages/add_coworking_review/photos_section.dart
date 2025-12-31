import 'dart:io';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/add_coworking_review_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 照片区域组件
class PhotosSection extends StatelessWidget {
  final String controllerTag;

  const PhotosSection({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddCoworkingReviewPageController>(tag: controllerTag);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.photoFilm, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              l10n.photosOptional,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(() => Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                ...controller.selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;
                  return _buildImageItem(context, controller, index, image);
                }),
                if (controller.selectedImages.length < 5)
                  _buildAddPhotoButton(context, controller, l10n),
              ],
            )),
      ],
    );
  }

  Widget _buildImageItem(
    BuildContext context,
    AddCoworkingReviewPageController controller,
    int index,
    dynamic image,
  ) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(
            File(image.path),
            width: 100.w,
            height: 100.w,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4.h,
          right: 4.w,
          child: GestureDetector(
            onTap: () => controller.removeImage(index),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.xmark,
                size: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton(
    BuildContext context,
    AddCoworkingReviewPageController controller,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(FontAwesomeIcons.images),
                  title: Text(l10n.chooseFromGallery),
                  onTap: () {
                    Get.back();
                    controller.pickImages(l10n.maxPhotosWarning);
                  },
                ),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.camera),
                  title: Text(l10n.takeAPhoto),
                  onTap: () {
                    Get.back();
                    controller.takePhoto(l10n.maxPhotosWarning);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: 100.w,
        height: 100.w,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.borderLight,
            width: 2.w,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.photoFilm,
              size: 32.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 4.h),
            Text(
              l10n.addPhoto,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
