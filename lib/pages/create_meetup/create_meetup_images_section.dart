import 'dart:io';

import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/create_meetup_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateMeetupImagesSection extends StatelessWidget {
  final String controllerTag;

  const CreateMeetupImagesSection({super.key, required this.controllerTag});

  CreateMeetupPageController get _c => Get.find<CreateMeetupPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.venuePhotos, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 8.h),
        Obx(() => Text(
          l10n.addVenuePhotosCount(_c.existingImageUrls.length + _c.selectedImages.length),
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        )),
        SizedBox(height: 12.h),
        Obx(() => _c.existingImageUrls.isNotEmpty || _c.selectedImages.isNotEmpty
            ? _buildImageGrid(context, l10n)
            : _buildEmptyImagePlaceholder(context, l10n)),
        Obx(() => _c.isUploadingImages.value ? _buildUploadProgress() : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildImageGrid(BuildContext context, AppLocalizations l10n) {
    return Obx(() {
      final totalImages = _c.existingImageUrls.length + _c.selectedImages.length;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8.w, mainAxisSpacing: 8.w, childAspectRatio: 1),
        itemCount: totalImages + 1,
        itemBuilder: (context, index) {
          if (index == totalImages) {
            return _buildAddButton(context, l10n, totalImages);
          }

          final isExistingImage = index < _c.existingImageUrls.length;
          return _buildImageTile(context, l10n, index, isExistingImage);
        },
      );
    });
  }

  Widget _buildAddButton(BuildContext context, AppLocalizations l10n, int totalImages) {
    return InkWell(
      onTap: totalImages < 10 ? () => _showImagePickerOptions(context, l10n) : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: totalImages < 10 ? const Color(0xFFFF4458) : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(8.r),
          color: totalImages < 10 ? const Color(0xFFFF4458).withValues(alpha: 0.05) : Colors.grey.shade100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.photoFilm, size: 32.r, color: totalImages < 10 ? const Color(0xFFFF4458) : Colors.grey.shade400),
            SizedBox(height: 4.h),
            Text(l10n.addPhoto, style: TextStyle(fontSize: 11.sp, color: totalImages < 10 ? const Color(0xFFFF4458) : Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, AppLocalizations l10n, int index, bool isExistingImage) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: isExistingImage
              ? Image.network(
                  _c.existingImageUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200, child: Icon(FontAwesomeIcons.image, color: Colors.grey.shade400)),
                )
              : Image.file(File(_c.selectedImages[index - _c.existingImageUrls.length].path), fit: BoxFit.cover),
        ),
        Positioned(
          top: 4.h,
          right: 4.w,
          child: InkWell(
            onTap: () => isExistingImage ? _c.removeExistingImage(index) : _c.removeImage(index - _c.existingImageUrls.length),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: Icon(FontAwesomeIcons.xmark, size: 16.r, color: Colors.white),
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            bottom: 4.h,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(color: const Color(0xFFFF4458), borderRadius: BorderRadius.circular(4.r)),
              child: Text(l10n.coverPhoto, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyImagePlaceholder(BuildContext context, AppLocalizations l10n) {
    return InkWell(
      onTap: () => _showImagePickerOptions(context, l10n),
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.photoFilm, size: 48.r, color: Colors.grey.shade400),
            SizedBox(height: 8.h),
            Text(l10n.addVenuePhotos, style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            SizedBox(height: 4.h),
            Text(l10n.tapToSelectPhoto, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Obx(() => Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 18.w,
                height: 18.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: _c.uploadProgress.value > 0 ? _c.uploadProgress.value : null,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF4458)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Uploading venue photos... (${(_c.uploadProgress.value * 100).clamp(0, 100).toStringAsFixed(0)}%)',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: _c.uploadProgress.value > 0 ? _c.uploadProgress.value : null,
            minHeight: 4.h,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(Color(0xFFFF4458)),
          ),
        ],
      ),
    ));
  }

  void _showImagePickerOptions(BuildContext context, AppLocalizations l10n) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r))),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r))),
              SizedBox(height: 20.h),
              Text(l10n.addVenuePhotos, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
              SizedBox(height: 20.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(color: const Color(0xFFFF4458).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
                  child: const Icon(FontAwesomeIcons.images, color: Color(0xFFFF4458)),
                ),
                title: Text(l10n.chooseFromGallery, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
                subtitle: Obx(() => Text(l10n.selectMultiplePhotos(_c.selectedImages.length), style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600))),
                onTap: () { Get.back(); _c.pickImages(context); },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(color: const Color(0xFFFF4458).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
                  child: const Icon(FontAwesomeIcons.camera, color: Color(0xFFFF4458)),
                ),
                title: Text(l10n.takePhoto, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
                subtitle: Text(l10n.useCameraToTakePhoto, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
                onTap: () { Get.back(); _c.takePhoto(context); },
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
}
