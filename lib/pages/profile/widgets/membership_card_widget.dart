import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/membership/domain/entities/membership_level.dart';
import 'package:go_nomads_app/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
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

    // 检查会员控制器是否已注册，如果没有则显示默认卡片
    if (!Get.isRegistered<MembershipStateController>()) {
      return _buildDefaultCard(l10n);
    }

    final membershipController = Get.find<MembershipStateController>();

    return Obx(() {
      final level = membershipController.level;
      final membership = membershipController.membership;
      final isActive = membershipController.isActive;

      return _buildMembershipCard(
        l10n: l10n,
        level: level,
        membership: membership,
        isActive: isActive,
        aiUsageRemaining: membershipController.aiUsageRemaining,
        remainingDays: membershipController.remainingDays,
      );
    });
  }

  /// 构建默认卡片（Free 会员）
  Widget _buildDefaultCard(AppLocalizations l10n) {
    return _buildMembershipCard(
      l10n: l10n,
      level: MembershipLevel.free,
      membership: null,
      isActive: false,
      aiUsageRemaining: 3,
      remainingDays: 0,
    );
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
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.membershipPlan),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(level.colorValue),
              Color(level.colorValue).withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Color(level.colorValue).withValues(alpha: 0.3),
              blurRadius: 12.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 会员图标
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(level.icon, style: TextStyle(fontSize: 28.sp)),
              ),
            ),
            SizedBox(width: 14.w),
            // 会员信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        level.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isActive) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
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
                    level == MembershipLevel.free
                        ? l10n.upgradeToUnlock
                        : isActive
                            ? l10n.daysRemaining(remainingDays)
                            : l10n.profileMembershipExpired,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13.sp,
                    ),
                  ),
                  // AI 使用次数（所有用户都显示）
                  if (membership != null) ...[
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.wandMagicSparkles,
                          size: 12.r,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          level == MembershipLevel.premium
                              ? l10n.profileUnlimitedAi
                              : l10n.profileAiUsageLeft(aiUsageRemaining, level.aiUsageLimit),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // 箭头
            Icon(
              FontAwesomeIcons.chevronRight,
              color: Colors.white70,
              size: 16.r,
            ),
          ],
        ),
      ),
    );
  }
}
