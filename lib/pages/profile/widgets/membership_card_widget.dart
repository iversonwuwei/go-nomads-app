import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/membership/domain/entities/membership_level.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/profile/profile_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

/// 会员卡片组件
///
/// 显示用户会员等级、有效期、AI使用次数等信息
/// 即使会员数据未加载也会显示默认的 Free 会员状态
class MembershipCardWidget extends StatelessWidget {
  const MembershipCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileController = Get.find<ProfileController>();

    return Obx(() {
      final membership = profileController.currentUser?.membership;
      final level = membership?.level ?? MembershipLevel.free;
      final isActive = membership?.isActive ?? false;

      return _buildMembershipCard(
        l10n: l10n,
        level: level,
        membership: membership,
        isActive: isActive,
        aiUsageRemaining: membership?.aiUsageRemaining ?? MembershipLevel.free.aiUsageLimit,
        remainingDays: membership?.remainingDays ?? 0,
      );
    });
  }

  /// 构建会员卡片
  Widget _buildMembershipCard({
    required AppLocalizations l10n,
    required MembershipLevel level,
    required dynamic membership,
    required bool isActive,
    required int aiUsageRemaining,
    required int remainingDays,
  }) {
    final isMobile = Get.context != null ? MediaQuery.of(Get.context!).size.width < 768 : true;
    final summaryText = level == MembershipLevel.free
        ? l10n.upgradeToUnlock
        : isActive
            ? l10n.daysRemaining(remainingDays)
            : l10n.profileMembershipExpired;
    final aiSummary = membership == null
        ? l10n.profileAiUsageLeft(MembershipLevel.free.aiUsageLimit, MembershipLevel.free.aiUsageLimit)
        : level == MembershipLevel.premium
            ? l10n.profileUnlimitedAi
            : l10n.profileAiUsageLeft(aiUsageRemaining, level.aiUsageLimit);

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.membershipPlan),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(level.colorValue).withValues(alpha: 0.92),
              Color(level.colorValue).withValues(alpha: 0.72),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
          boxShadow: [
            BoxShadow(
              color: Color(level.colorValue).withValues(alpha: 0.3),
              blurRadius: 20.r,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52.w,
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                  ),
                  child: Center(
                    child: Text(level.icon, style: TextStyle(fontSize: 28.sp)),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              level.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                l10n.profileMembershipActive,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        summaryText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 13.sp,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    FontAwesomeIcons.chevronRight,
                    color: Colors.white70,
                    size: 14.r,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _MembershipInfoPill(
                    icon: FontAwesomeIcons.wandMagicSparkles,
                    label: aiSummary,
                    compact: isMobile,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _MembershipInfoPill(
                    icon: FontAwesomeIcons.bolt,
                    label: summaryText,
                    compact: isMobile,
                  ),
                ),
              ],
            ),
            if (level == MembershipLevel.free) ...[
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.arrowTrendUp,
                      size: 14.r,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        l10n.upgradeToUnlock,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      FontAwesomeIcons.chevronRight,
                      size: 12.r,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MembershipInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool compact;

  const _MembershipInfoPill({
    required this.icon,
    required this.label,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: compact ? 10.h : 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 12.r, color: Colors.white),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              label,
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
