import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/venue_map_picker_page_controller.dart';
import 'package:df_admin_mobile/services/amap_poi_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 场地列表区域组件
class VenueListSection extends StatelessWidget {
  final String controllerTag;

  const VenueListSection({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VenueMapPickerPageController>(tag: controllerTag);
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final allVenues = controller.filteredVenues;
      final selectedName = controller.selectedVenueName.value;

      // 获取选中的场地
      final selectedVenue = selectedName != null ? allVenues.firstWhereOrNull((v) => v.name == selectedName) : null;

      // 如果只显示选中项且有选中的场地
      final displayVenues =
          (controller.showOnlySelected.value && selectedVenue != null) ? [selectedVenue] : allVenues;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (controller.showOnlySelected.value && selectedVenue != null) ...[
                    // 显示"返回列表"按钮
                    GestureDetector(
                      onTap: controller.showAllVenues,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesomeIcons.chevronLeft, size: 12, color: Colors.grey[700]),
                            const SizedBox(width: 6),
                            Text(
                              '${l10n.all} (${allVenues.length})',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      '${allVenues.length} ${l10n.venues}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (controller.isLoadingPoi.value) ...[
                    const SizedBox(width: 8),
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: displayVenues.isEmpty
                  ? Center(child: Text(controller.isLoadingPoi.value ? l10n.loading : l10n.noData))
                  : ListView.builder(
                      controller: controller.listScrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: displayVenues.length,
                      itemBuilder: (context, index) {
                        final venue = displayVenues[index];
                        final isSelected = selectedName == venue.name;
                        return _VenueCard(
                          controllerTag: controllerTag,
                          venue: venue,
                          isSelected: isSelected,
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }
}

/// 场地卡片组件
class _VenueCard extends StatelessWidget {
  final String controllerTag;
  final PoiResult venue;
  final bool isSelected;

  const _VenueCard({
    required this.controllerTag,
    required this.venue,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VenueMapPickerPageController>(tag: controllerTag);

    return GestureDetector(
      onTap: () => controller.selectVenue(venue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4458).withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey[300]!,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图标 - 选中时添加边框
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? controller.markerColor(venue.type).withValues(alpha: 0.2)
                    : controller.markerColor(venue.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: isSelected ? Border.all(color: controller.markerColor(venue.type), width: 2) : null,
              ),
              child: Icon(_markerIcon(venue.type), color: controller.markerColor(venue.type), size: 22),
            ),
            const SizedBox(width: 12),
            // 内容区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 第一行：名称 + 类型标签
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          venue.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: controller.markerColor(venue.type).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          venue.typeName,
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600, color: controller.markerColor(venue.type)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 第二行：完整地址（最多2行）
                  Text(
                    venue.address,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // 第三行：评分和距离
                  Row(
                    children: [
                      if (venue.rating != null) ...[
                        Icon(FontAwesomeIcons.solidStar, size: 11, color: Colors.amber[700]),
                        const SizedBox(width: 3),
                        Text(
                          venue.rating!.toStringAsFixed(1),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (venue.formattedDistance.isNotEmpty) ...[
                        Icon(FontAwesomeIcons.locationArrow, size: 10, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          venue.formattedDistance,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _markerIcon(String type) {
    switch (type) {
      case 'restaurant':
        return FontAwesomeIcons.utensils;
      case 'cafe':
        return FontAwesomeIcons.mugHot;
      case 'hotel':
        return FontAwesomeIcons.hotel;
      case 'shopping':
        return FontAwesomeIcons.bagShopping;
      case 'attraction':
        return FontAwesomeIcons.mountain;
      default:
        return FontAwesomeIcons.locationDot;
    }
  }
}
