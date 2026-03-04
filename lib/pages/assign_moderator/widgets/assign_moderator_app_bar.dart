import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/assign_moderator/assign_moderator_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 指定版主页面的 AppBar
class AssignModeratorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AssignModeratorController controller;

  const AssignModeratorAppBar({
    super.key,
    required this.controller,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(l10n.assignModeratorPageTitle(controller.cityName)),
      backgroundColor: AppColors.cityPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        _buildSelectAllButton(),
      ],
    );
  }

  Widget _buildSelectAllButton() {
    final l10n = AppLocalizations.of(Get.context!)!;
    return Obx(() {
      if (controller.filteredUsers.isEmpty) {
        return const SizedBox.shrink();
      }

      return TextButton.icon(
        onPressed: controller.toggleSelectAll,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
        icon: Icon(
          controller.isAllSelected ? FontAwesomeIcons.squareCheck : FontAwesomeIcons.square,
          size: 20.r,
        ),
        label: Text(
          controller.isAllSelected ? l10n.deselectAll : l10n.selectAll,
        ),
      );
    });
  }
}
