import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:df_admin_mobile/pages/create_travel_plan/create_travel_plan_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// AI 旅行计划浮动按钮
class AiTravelPlanFab extends StatelessWidget {
  final String cityId;
  final String cityName;

  const AiTravelPlanFab({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Material(
        elevation: 6,
        shadowColor: AppColors.cityPrimary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: () => _onTap(context),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.cityPrimary, Color(0xFFFF6B7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cityPrimary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FontAwesomeIcons.wandMagicSparkles,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AI Travel Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  FontAwesomeIcons.arrowRight,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) async {
    // 检查会员权限
    try {
      final membershipController = Get.find<MembershipStateController>();
      final accessCheck = membershipController.checkAIAccess();

      if (accessCheck != null) {
        _showMembershipRequiredDialog(context, accessCheck);
        return;
      }
    } catch (e) {
      log('⚠️ 会员检查异常: $e');
      // 如果会员控制器未注册，暂时跳过会员检查
    }

    // 跳转到创建旅行计划页面
    Get.to(() => CreateTravelPlanPage(
          cityId: cityId,
          cityName: cityName,
        ));
  }

  void _showMembershipRequiredDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('会员功能'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 跳转到会员页面
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cityPrimary,
            ),
            child: const Text('升级会员'),
          ),
        ],
      ),
    );
  }
}
