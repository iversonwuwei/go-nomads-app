import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/map_picker/map_picker_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 底部信息卡片（显示当前选中地址 + 确认按钮）
/// Bottom card showing selected location info and confirm button
class MapPickerBottomCard extends GetView<MapPickerController> {
  const MapPickerBottomCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: 16.h,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 地址信息卡片
            _AddressInfoCard(l10n: l10n),
            SizedBox(height: 12.h),
            // 确认按钮
            _ConfirmButton(l10n: l10n),
          ],
        ),
      ),
    );
  }
}

/// 地址信息展示卡片
class _AddressInfoCard extends GetView<MapPickerController> {
  final AppLocalizations l10n;

  const _AddressInfoCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Obx(() {
        final isGeocoding = controller.isReverseGeocoding.value;
        final isMoving = controller.isMapMoving.value;
        final name = controller.currentName.value ?? '';
        final address = controller.currentAddress.value ?? '';
        final city = controller.currentCity.value ?? '';
        final province = controller.currentProvince.value ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.selectedLocation,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            // 加载状态
            if (isGeocoding || isMoving)
              Row(
                children: [
                  SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    isMoving
                        ? '移动地图选择位置... / Move map to select...'
                        : l10n.loading,
                  ),
                ],
              )
            // 名称
            else ...[
              Text(
                name.isNotEmpty
                    ? name
                    : (address.isNotEmpty
                        ? address
                        : l10n.pickLocationOnMap),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // 完整地址（与名称不同时显示）
              if (address.isNotEmpty && address != name)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    address,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              // 城市 · 省份
              if (city.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    [
                      if (city.isNotEmpty) city,
                      if (province.isNotEmpty) province,
                    ].join(' · '),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                  ),
                ),
            ],
          ],
        );
      }),
    );
  }
}

/// 确认按钮
class _ConfirmButton extends GetView<MapPickerController> {
  final AppLocalizations l10n;

  const _ConfirmButton({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canConfirm = controller.canConfirm;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canConfirm ? controller.confirmSelection : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            backgroundColor: const Color(0xFFFF4458),
            disabledBackgroundColor: Colors.grey[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            l10n.confirm,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }
}
