import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/membership/presentation/services/ai_quota_service.dart';
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
    return Material(
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
    );
  }

  void _onTap(BuildContext context) async {
    // 在进入创建页面前先检查配额是否足够（只检查不扣减）
    try {
      final check = await AiQuotaService().checkQuota();

      if (!check.canUse) {
        // 显示配额用尽提示对话框
        _showQuotaExhaustedDialog(context, check);
        return;
      }
    } catch (e) {
      log('⚠️ AI 配额检查异常: $e');
      // 出错时继续，让后续实际调用时再检查
    }

    // 跳转到创建旅行计划页面
    Get.to(() => CreateTravelPlanPage(
          cityId: cityId,
          cityName: cityName,
        ));
  }

  /// 显示配额用尽对话框
  void _showQuotaExhaustedDialog(BuildContext context, dynamic check) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('AI 配额已用完'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '您本月的 AI 使用次数已达上限 (${check.used}/${check.limit})。',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                check.upgradeMessage ?? '升级会员获得更多 AI 使用次数',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('稍后再说'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Get.toNamed('/membership-plans');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cityPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('升级会员'),
          ),
        ],
      ),
    );
  }
}
