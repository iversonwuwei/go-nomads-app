import 'dart:io';

import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/create_meetup_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
        Text(l10n.venuePhotos, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        Obx(() => Text(
          l10n.addVenuePhotosCount(_c.existingImageUrls.length + _c.selectedImages.length),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        )),
        const SizedBox(height: 12),
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1),
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
          borderRadius: BorderRadius.circular(8),
          color: totalImages < 10 ? const Color(0xFFFF4458).withValues(alpha: 0.05) : Colors.grey.shade100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.photoFilm, size: 32, color: totalImages < 10 ? const Color(0xFFFF4458) : Colors.grey.shade400),
            const SizedBox(height: 4),
            Text(l10n.addPhoto, style: TextStyle(fontSize: 11, color: totalImages < 10 ? const Color(0xFFFF4458) : Colors.grey.shade400)),
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
          borderRadius: BorderRadius.circular(8),
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
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => isExistingImage ? _c.removeExistingImage(index) : _c.removeImage(index - _c.existingImageUrls.length),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(FontAwesomeIcons.xmark, size: 16, color: Colors.white),
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFFF4458), borderRadius: BorderRadius.circular(4)),
              child: Text(l10n.coverPhoto, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyImagePlaceholder(BuildContext context, AppLocalizations l10n) {
    return InkWell(
      onTap: () => _showImagePickerOptions(context, l10n),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.photoFilm, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(l10n.addVenuePhotos, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(l10n.tapToSelectPhoto, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Obx(() => Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: _c.uploadProgress.value > 0 ? _c.uploadProgress.value : null,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF4458)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Uploading venue photos... (${(_c.uploadProgress.value * 100).clamp(0, 100).toStringAsFixed(0)}%)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _c.uploadProgress.value > 0 ? _c.uploadProgress.value : null,
            minHeight: 4,
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
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text(l10n.addVenuePhotos, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFF4458).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(FontAwesomeIcons.images, color: Color(0xFFFF4458)),
                ),
                title: Text(l10n.chooseFromGallery, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                subtitle: Obx(() => Text(l10n.selectMultiplePhotos(_c.selectedImages.length), style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
                onTap: () { Get.back(); _c.pickImages(context); },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFF4458).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(FontAwesomeIcons.camera, color: Color(0xFFFF4458)),
                ),
                title: Text(l10n.takePhoto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                subtitle: Text(l10n.useCameraToTakePhoto, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                onTap: () { Get.back(); _c.takePhoto(context); },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
}
