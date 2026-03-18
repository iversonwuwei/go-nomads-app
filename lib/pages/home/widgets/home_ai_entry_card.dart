import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/membership/presentation/services/ai_quota_service.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

/// 首页 AI 双入口模块
/// 用整条分段按钮承载 AI 智能助手与 AI 旅行规划师
class HomeAiEntryCard extends StatelessWidget {
  final bool isMobile;

  const HomeAiEntryCard({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Row(
        children: [
          Expanded(
            child: _buildAssistantAction(context, l10n, isChinese),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildPlannerAction(context, isChinese),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantAction(
    BuildContext context,
    AppLocalizations l10n,
    bool isChinese,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.aiChat),
        borderRadius: BorderRadius.circular(10.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF0EA5E9),
              ],
              stops: [0.0, 0.58, 1.0],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.wandMagicSparkles,
                  color: Colors.white,
                  size: 13.r,
                ),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    isChinese ? 'AI 助手' : l10n.homeAiCopilotTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: isMobile ? 12.sp : 12.5.sp,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                FaIcon(
                  FontAwesomeIcons.arrowRight,
                  color: Colors.white.withValues(alpha: 0.82),
                  size: 10.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlannerAction(BuildContext context, bool isChinese) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openTravelPlanner(context),
        borderRadius: BorderRadius.circular(10.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: const Color(0xFFFFFFFF),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.route,
                  color: const Color(0xFFBE123C),
                  size: 13.r,
                ),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    isChinese ? 'AI 规划师' : 'AI Planner',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w800,
                      fontSize: isMobile ? 12.sp : 12.5.sp,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                FaIcon(
                  FontAwesomeIcons.arrowRight,
                  color: const Color(0xFFBE123C),
                  size: 10.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openTravelPlanner(BuildContext context) async {
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';

    try {
      final check = await AiQuotaService().checkQuota();
      if (!check.canUse) {
        AiQuotaService().showQuotaExhaustedDialog(
          check,
          isChinese ? 'AI 旅行规划师' : 'AI Travel Planner',
        );
        return;
      }
    } catch (_) {
      // 配额检查失败时允许继续进入，实际生成时再兜底。
    }

    Get.toNamed(
      AppRoutes.createTravelPlan,
      arguments: const {
        'cityId': '',
        'cityName': '',
      },
    );
  }
}
