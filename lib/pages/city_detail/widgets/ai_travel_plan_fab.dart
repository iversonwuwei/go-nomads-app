import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/membership/presentation/services/ai_quota_service.dart';
import 'package:go_nomads_app/pages/create_travel_plan/create_travel_plan_page.dart';

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
    // 使用统一的 AiQuotaService 检查配额（只检查不扣减，配额不足时显示升级对话框）
    try {
      final check = await AiQuotaService().checkQuota();

      if (!check.canUse) {
        // 通过 AiQuotaService 统一显示配额用尽对话框
        AiQuotaService().showQuotaExhaustedDialog(check, 'AI 旅行计划');
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
}
