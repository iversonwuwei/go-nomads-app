import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/city_photo_submission_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';

/// 城市照片提交页面
class CityPhotoSubmissionPage extends StatelessWidget {
  final String cityId;
  final String cityName;

  const CityPhotoSubmissionPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  static String _generateTag(String cityId) => 'CityPhotoSubmissionPage_$cityId';

  CityPhotoSubmissionPageController _useController() {
    final tag = _generateTag(cityId);
    if (Get.isRegistered<CityPhotoSubmissionPageController>(tag: tag)) {
      return Get.find<CityPhotoSubmissionPageController>(tag: tag);
    }
    return Get.put(
      CityPhotoSubmissionPageController(cityId: cityId, cityName: cityName),
      tag: tag,
    );
  }

  Future<void> _showAddPhotoSheet(BuildContext context, CityPhotoSubmissionPageController controller) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(FontAwesomeIcons.images),
                title: Text(l10n.cityPhotoPickFromGalleryMulti),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.camera),
                title: Text(l10n.cityPhotoCaptureAndUpload),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.capturePhoto();
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.xmark),
                title: Text(l10n.cancel),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _useController();
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        title: Text(l10n.cityPhotoUploadTitle(cityName)),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cityPhotoShareExperience(cityName),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  labelText: l10n.cityPhotoTitleOrPlace,
                  hintText: l10n.cityPhotoTitleExample,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.cityPhotoTitleRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: controller.locationNoteController,
                decoration: InputDecoration(
                  labelText: l10n.cityPhotoLocationOptional,
                  hintText: l10n.cityPhotoLocationHint,
                  suffixIcon: IconButton(
                    icon: Icon(
                      FontAwesomeIcons.locationDot,
                      color: Color(0xFFFF4458),
                      size: 20.r,
                    ),
                    onPressed: controller.openMapPicker,
                    tooltip: l10n.cityPhotoLocateOnMap,
                  ),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: controller.descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.cityPhotoDescriptionOptional,
                  hintText: l10n.cityPhotoDescriptionHint,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.cityPhotoSelectedCount(
                            controller.photoUrls.length, CityPhotoSubmissionPageController.maxPhotoCount),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.cityPrimary,
                        ),
                        onPressed:
                            controller.isUploadingImages.value ? null : () => _showAddPhotoSheet(context, controller),
                        icon: const Icon(FontAwesomeIcons.photoFilm),
                        label: Text(l10n.cityPhotoAddPhoto),
                      ),
                    ],
                  )),
              SizedBox(height: 8.h),
              Obx(() {
                if (!controller.isUploadingImages.value) return const SizedBox.shrink();
                return Row(
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12.w),
                    Text(controller.uploadStatus.value ?? l10n.cityPhotoUploading),
                  ],
                );
              }),
              SizedBox(height: 12.h),
              Obx(() {
                if (controller.photoUrls.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Icon(FontAwesomeIcons.images, size: 48.r, color: Colors.grey),
                        SizedBox(height: 12.h),
                        Text(l10n.cityPhotoEmptyHint),
                      ],
                    ),
                  );
                }

                return Wrap(
                  spacing: 12.w,
                  runSpacing: 12.w,
                  children: controller.photoUrls
                      .asMap()
                      .entries
                      .map(
                        (entry) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(
                                entry.value,
                                width: 100.w,
                                height: 100.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4.h,
                              right: 4.w,
                              child: GestureDetector(
                                onTap: () => controller.removePhoto(entry.key),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(4.w),
                                  child: Icon(
                                    FontAwesomeIcons.xmark,
                                    color: Colors.white,
                                    size: 16.r,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                );
              }),
              SizedBox(height: 32.h),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.cityPrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.cityPrimary.withValues(alpha: 0.5),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: controller.isUploadingImages.value || controller.isSubmitting.value
                          ? null
                          : () async {
                              final success = await controller.submit(formKey);
                              if (success) {
                                Get.back(result: {'uploaded': true});
                              }
                            },
                      icon: controller.isSubmitting.value
                          ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(FontAwesomeIcons.cloudArrowUp),
                      label: Text(controller.isSubmitting.value ? l10n.cityPhotoSubmitting : l10n.submit),
                    ),
                  )),
              SizedBox(height: 8.h),
              Text(
                l10n.cityPhotoSubmitDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
