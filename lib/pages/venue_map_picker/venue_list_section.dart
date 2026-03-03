import 'package:go_nomads_app/controllers/venue_map_picker_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/amap_poi_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      final displayVenues = (controller.showOnlySelected.value && selectedVenue != null) ? [selectedVenue] : allVenues;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.r,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 6.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  if (controller.showOnlySelected.value && selectedVenue != null) ...[
                    // 显示"返回列表"按钮
                    GestureDetector(
                      onTap: controller.showAllVenues,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesomeIcons.chevronLeft, size: 12.r, color: Colors.grey[700]),
                            SizedBox(width: 6.w),
                            Text(
                              '${l10n.all} (${allVenues.length})',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      '${allVenues.length} ${l10n.venues}',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (controller.isLoadingPoi.value) ...[
                    SizedBox(width: 8.w),
                    SizedBox(width: 16.w, height: 16.h, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ],
              ),
            ),
            SizedBox(height: 8.h),
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
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4458).withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey[300]!,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                    blurRadius: 12.r,
                    spreadRadius: 1.r,
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
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? controller.markerColor(venue.type).withValues(alpha: 0.2)
                    : controller.markerColor(venue.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
                border: isSelected ? Border.all(color: controller.markerColor(venue.type), width: 2) : null,
              ),
              child: Icon(_markerIcon(venue.type), color: controller.markerColor(venue.type), size: 22.r),
            ),
            SizedBox(width: 12.w),
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
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: controller.markerColor(venue.type).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          venue.typeName,
                          style: TextStyle(
                              fontSize: 10.sp, fontWeight: FontWeight.w600, color: controller.markerColor(venue.type)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  // 第二行：完整地址（最多2行）
                  Text(
                    venue.address,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  // 第三行：评分和距离
                  Row(
                    children: [
                      if (venue.rating != null) ...[
                        Icon(FontAwesomeIcons.solidStar, size: 11.r, color: Colors.amber[700]),
                        SizedBox(width: 3.w),
                        Text(
                          venue.rating!.toStringAsFixed(1),
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      if (venue.formattedDistance.isNotEmpty) ...[
                        Icon(FontAwesomeIcons.locationArrow, size: 10.r, color: Colors.grey[500]),
                        SizedBox(width: 4.w),
                        Text(
                          venue.formattedDistance,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
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
