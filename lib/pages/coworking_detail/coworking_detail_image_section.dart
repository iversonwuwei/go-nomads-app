import 'package:df_admin_mobile/controllers/coworking_detail_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CoworkingDetailImageSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailImageSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final allImages = _c.allImages;
      final hasMultipleImages = _c.hasMultipleImages;

      return Stack(
        fit: StackFit.expand,
        children: [
          // 图片轮播
          hasMultipleImages
              ? PageView.builder(
                  controller: _c.pageController,
                  onPageChanged: _c.onPageChanged,
                  itemCount: allImages.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      allImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(FontAwesomeIcons.building, size: 100),
                        );
                      },
                    );
                  },
                )
              : Image.network(
                  _c.space.value.spaceInfo.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(FontAwesomeIcons.building, size: 100),
                    );
                  },
                ),
          // 渐变遮罩
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(128),
                  ],
                ),
              ),
            ),
          ),
          // 图片指示器
          if (hasMultipleImages)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  allImages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _c.currentImageIndex.value == index ? Colors.white : Colors.white.withAlpha(128),
                    ),
                  ),
                ),
              )),
            ),
        ],
      );
    });
  }
}

class CoworkingDetailImageCounterBadge extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailImageCounterBadge({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_c.hasMultipleImages) return const SizedBox.shrink();

      final allImages = _c.allImages;
      return Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(128),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Obx(() => Text(
          '${_c.currentImageIndex.value + 1}/${allImages.length}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        )),
      );
    });
  }
}
