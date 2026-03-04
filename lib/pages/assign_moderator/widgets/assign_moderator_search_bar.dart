import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/assign_moderator/assign_moderator_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 指定版主页面的搜索栏
class AssignModeratorSearchBar extends StatelessWidget {
  final AssignModeratorController controller;

  const AssignModeratorSearchBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(l10n),
          SizedBox(height: 12.h),
          _buildSelectedCount(l10n),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return TextField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: l10n.search,
        prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass, size: 18.r),
        suffixIcon: Obx(() {
          if (!controller.hasSearchQuery) {
            return const SizedBox.shrink();
          }
          return IconButton(
            icon: Icon(FontAwesomeIcons.xmark, size: 16.r),
            onPressed: controller.clearSearch,
          );
        }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildSelectedCount(AppLocalizations l10n) {
    return Obx(() => Text(
          l10n.profileSelectedUsers(controller.selectedCount),
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ));
  }
}
