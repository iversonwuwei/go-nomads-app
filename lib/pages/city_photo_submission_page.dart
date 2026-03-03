import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/city_photo_submission_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(FontAwesomeIcons.images),
                title: const Text('从相册选择 (可多选)'),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.camera),
                title: const Text('拍照上传'),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.capturePhoto();
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.xmark),
                title: const Text('取消'),
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        title: Text('上传照片 · $cityName'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '为数字游民社区分享你在 $cityName 的真实体验',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.titleController,
                decoration: const InputDecoration(
                  labelText: '标题 / 地点',
                  hintText: '例：北戴河海边日出',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请填写一个标题或地点描述';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: controller.locationNoteController,
                decoration: InputDecoration(
                  labelText: '位置信息 (可选)',
                  hintText: '街道、地标或更多定位线索',
                  suffixIcon: IconButton(
                    icon: Icon(
                      FontAwesomeIcons.locationDot,
                      color: Color(0xFFFF4458),
                      size: 20.r,
                    ),
                    onPressed: controller.openMapPicker,
                    tooltip: '在地图上定位',
                  ),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: controller.descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述 (可选)',
                  hintText: '简单介绍照片内容、拍摄时间等',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '已选择 ${controller.photoUrls.length} / ${CityPhotoSubmissionPageController.maxPhotoCount}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.cityPrimary,
                        ),
                        onPressed:
                            controller.isUploadingImages.value ? null : () => _showAddPhotoSheet(context, controller),
                        icon: const Icon(FontAwesomeIcons.photoFilm),
                        label: const Text('添加照片'),
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
                    Text(controller.uploadStatus.value ?? '正在上传...'),
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
                        Text('还没有照片，点击上方"添加照片"按钮上传'),
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
                      label: Text(controller.isSubmitting.value ? '提交中...' : '提交'),
                    ),
                  )),
              SizedBox(height: 8.h),
              Text(
                '提交后后端会通过高德地图自动补齐坐标，成功后你将回到城市详情页，照片会在刷新后展示。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
