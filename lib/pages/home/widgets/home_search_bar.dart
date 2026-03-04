import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 首页搜索栏组件
class HomeSearchBar extends GetView<HomePageController> {
  final bool isMobile;

  const HomeSearchBar({super.key, required this.isMobile});

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
          Icon(FontAwesomeIcons.magnifyingGlass, color: AppColors.textSecondary, size: 20.r),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller.searchController,
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
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  controller.performSearch(value.trim());
                }
              },
            ),
          ),
          SizedBox(width: 12.w),
          // 搜索按钮
          _SearchButton(controller: controller),
          // 清除按钮
          _ClearButton(controller: controller),
        ],
      ),
    );
  }
}

/// 搜索按钮
class _SearchButton extends StatelessWidget {
  final HomePageController controller;

  const _SearchButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final searchText = controller.searchController.text.trim();
        if (searchText.isNotEmpty) {
          controller.performSearch(searchText);
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
          'Search',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 清除按钮
class _ClearButton extends StatefulWidget {
  final HomePageController controller;

  const _ClearButton({required this.controller});

  @override
  State<_ClearButton> createState() => _ClearButtonState();
}

class _ClearButtonState extends State<_ClearButton> {
  @override
  void initState() {
    super.initState();
    widget.controller.searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.searchController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.searchController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 8.w),
        InkWell(
          onTap: () => widget.controller.clearSearch(),
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(6.w),
            child: Icon(
              FontAwesomeIcons.xmark,
              color: AppColors.textSecondary,
              size: 18.r,
            ),
          ),
        ),
      ],
    );
  }
}

/// 搜索结果提示
class HomeSearchResultHint extends GetView<HomePageController> {
  final bool isMobile;

  const HomeSearchResultHint({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final query = controller.localSearchQuery.value;
      if (query.isEmpty) return const SizedBox.shrink();

      final cityCount = controller.localCities.length;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4458).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: const Color(0xFFFF4458).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              FontAwesomeIcons.magnifyingGlass,
              color: Color(0xFFFF4458),
              size: 20.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: 'Search results for ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextSpan(
                      text: '"$query"',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF4458),
                      ),
                    ),
                    TextSpan(
                      text: ': ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextSpan(
                      text: '$cityCount ${cityCount == 1 ? "city" : "cities"} found',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            InkWell(
              onTap: () => controller.clearSearch(),
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  FontAwesomeIcons.xmark,
                  color: AppColors.textSecondary,
                  size: 18.r,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// 工具栏 - 只保留地图功能
class HomeToolbar extends StatelessWidget {
  const HomeToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Popular',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.mapLocationDot,
            color: AppColors.textSecondary,
            size: 20.r,
          ),
          onPressed: () => Get.toNamed('/global-map'),
        ),
      ],
    );
  }
}
