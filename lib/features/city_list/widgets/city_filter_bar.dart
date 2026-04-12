import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/city_list/city_list_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';

/// 城市筛选栏组件 - 包含搜索框和区域 Tab
class CityFilterBar extends GetView<CityListController> {
  final bool isMobile;

  const CityFilterBar({
    super.key,
    this.isMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 16 : 20,
              isMobile ? 12 : 16,
              isMobile ? 16 : 20,
              10,
            ),
            child: _buildSearchField(context, l10n),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _buildRegionTabs(l10n),
          ),
        ],
      ),
    );
  }

  /// 构建区域 Tab 栏
  Widget _buildRegionTabs(AppLocalizations l10n) {
    return Obx(() {
      final tabs = controller.regionTabs;

      return SizedBox(
        height: 40.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20),
          children: [
            // "全部" Tab
            _RegionTabChip(
              label: l10n.all,
              isSelected: controller.selectedRegion.value == null,
              onTap: () => controller.selectRegion(null),
            ),
            // 后端返回的区域 Tab
            for (final tab in tabs)
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: _RegionTabChip(
                  label: tab.label,
                  isSelected: controller.selectedRegion.value == tab.key,
                  onTap: () => controller.selectRegion(tab.key),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchField(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: AppUiTokens.softFloatingShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.magnifyingGlass,
            color: AppColors.textSecondary,
            size: 16.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller.searchTextController,
              decoration: InputDecoration(
                hintText: l10n.searchCityOrCountry,
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
              },
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  controller.search(value);
                } else {
                  controller.clearSearch();
                }
              },
            ),
          ),
          // 清除按钮
          Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return InkWell(
              onTap: controller.clearSearch,
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  FontAwesomeIcons.xmark,
                  size: 16.r,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 区域 Tab Chip 组件
class _RegionTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RegionTabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cityPrimary.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.cityPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
