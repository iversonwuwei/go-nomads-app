import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city_list/city_list_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 城市搜索栏组件
class CitySearchBar extends GetView<CityListController> {
  const CitySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.magnifyingGlass,
            color: AppColors.textSecondary,
            size: 20.r,
          ),
          SizedBox(width: 12.w),
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
          SizedBox(width: 12.w),
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
                  size: 18.r,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }),
          // 搜索按钮
          InkWell(
            onTap: () {
              final searchText = controller.searchTextController.text.trim();
              if (searchText.isNotEmpty) {
                controller.search(searchText);
              } else {
                controller.clearSearch();
              }
            },
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                l10n.search,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
