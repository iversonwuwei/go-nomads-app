import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/assign_moderator/assign_moderator_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 用户列表项
class AssignModeratorUserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final AssignModeratorController controller;

  const AssignModeratorUserTile({
    super.key,
    required this.user,
    required this.controller,
  });

  String get userId => user['id'] as String;
  String get userName => user['name'] as String;
  String get userEmail => user['email'] as String;
  String get displayBadge => user['displayBadge'] as String? ?? '';
  bool get isAdmin => user['isAdmin'] as bool? ?? false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.isUserSelected(userId);
      final badgeColor = controller.getBadgeColor(displayBadge, isAdmin);

      return ListTile(
        leading: _buildAvatar(isSelected),
        title: _buildTitle(isSelected, badgeColor),
        subtitle: Text(userEmail),
        trailing: Checkbox(
          value: isSelected,
          activeColor: AppColors.accent,
          onChanged: (_) => controller.toggleUserSelection(userId),
        ),
        onTap: () => controller.toggleUserSelection(userId),
        selected: isSelected,
        selectedTileColor: AppColors.accent.withValues(alpha: 0.05),
      );
    });
  }

  Widget _buildAvatar(bool isSelected) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: isSelected ? AppColors.accent : Colors.grey[300],
          child: Text(
            userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : '?',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (isSelected)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.check,
                size: 10.r,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(bool isSelected, Color badgeColor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            userName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        if (displayBadge.isNotEmpty) _buildBadge(badgeColor),
      ],
    );
  }

  Widget _buildBadge(Color badgeColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        displayBadge,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
