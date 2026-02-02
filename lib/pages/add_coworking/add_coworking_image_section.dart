import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/add_coworking_page_controller.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AddCoworkingImageSection extends StatelessWidget {
  final String controllerTag;

  const AddCoworkingImageSection({super.key, required this.controllerTag});

  AddCoworkingPageController get _c => Get.find<AddCoworkingPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final canAddMore = _c.remainingImageSlots > 0;
      final hasImages = _c.coworkingImageUrls.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.addCoverPhoto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text('${_c.coworkingImageUrls.length}/${AddCoworkingPageController.maxCoworkingImages}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          if (hasImages)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._c.coworkingImageUrls.asMap().entries.map((e) => _buildImageTile(e.value, e.key)),
                if (canAddMore) _buildAddTile(l10n),
              ],
            )
          else
            _buildAddTile(l10n, fullWidth: true),
          if (_c.isUploadingImages.value) ...[
            const SizedBox(height: 12),
            Row(children: [
              const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 8),
              Text(_c.imageUploadStatus.value ?? 'Uploading...'),
            ]),
          ],
        ],
      );
    });
  }

  Widget _buildImageTile(String url, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 120,
            height: 120,
            color: Colors.grey[200],
            child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(FontAwesomeIcons.image)),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: IconButton(
            onPressed: () => _c.removeImageAt(index),
            icon: const Icon(FontAwesomeIcons.xmark, size: 18, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.black45, padding: const EdgeInsets.all(4)),
          ),
        ),
      ],
    );
  }

  Widget _buildAddTile(AppLocalizations l10n, {bool fullWidth = false}) {
    return GestureDetector(
      onTap: () => _showImageOptions(l10n),
      child: Container(
        width: fullWidth ? double.infinity : 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.photoFilm, size: 32, color: Colors.grey[500]),
            const SizedBox(height: 8),
            Text(l10n.tapToChoosePhoto, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  void _showImageOptions(AppLocalizations l10n) {
    if (_c.remainingImageSlots <= 0) {
      AppToast.info('最多上传 ${AddCoworkingPageController.maxCoworkingImages} 张图片');
      return;
    }
    showModalBottomSheet(
      context: Get.context!,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(FontAwesomeIcons.images), title: Text(l10n.photoLibrary), onTap: () { Navigator.pop(ctx); _c.addImagesFromGallery(); }),
          ListTile(leading: const Icon(FontAwesomeIcons.camera), title: Text(l10n.camera), onTap: () { Navigator.pop(ctx); _c.addImageFromCamera(); }),
          ListTile(leading: const Icon(FontAwesomeIcons.xmark), title: Text(l10n.cancel), onTap: () => Navigator.pop(ctx)),
        ]),
      ),
    );
  }
}
