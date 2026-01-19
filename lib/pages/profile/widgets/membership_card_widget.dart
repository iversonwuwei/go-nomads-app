import 'package:go_nomads_app/features/membership/domain/entities/membership_level.dart';
import 'package:go_nomads_app/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 会员卡片组件
///
/// 显示用户会员等级、有效期、AI使用次数等信息
/// 即使会员数据未加载也会显示默认的 Free 会员状态
class MembershipCardWidget extends StatelessWidget {
  const MembershipCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 检查会员控制器是否已注册，如果没有则显示默认卡片
    if (!Get.isRegistered<MembershipStateController>()) {
      return _buildDefaultCard();
    }

    final membershipController = Get.find<MembershipStateController>();

    return Obx(() {
      final level = membershipController.level;
      final membership = membershipController.membership;
      final isActive = membershipController.isActive;

      return _buildMembershipCard(
        level: level,
        membership: membership,
        isActive: isActive,
        aiUsageRemaining: membershipController.aiUsageRemaining,
        remainingDays: membershipController.remainingDays,
      );
    });
  }

  /// 构建默认卡片（Free 会员）
  Widget _buildDefaultCard() {
    return _buildMembershipCard(
      level: MembershipLevel.free,
      membership: null,
      isActive: false,
      aiUsageRemaining: 3,
      remainingDays: 0,
    );
  }

  /// 构建会员卡片
  Widget _buildMembershipCard({
    required MembershipLevel level,
    required dynamic membership,
    required bool isActive,
    required int aiUsageRemaining,
    required int remainingDays,
  }) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.membershipPlan),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(level.colorValue),
              Color(level.colorValue).withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(level.colorValue).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 会员图标
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(level.icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            // 会员信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        level.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level == MembershipLevel.free
                        ? 'Upgrade to unlock more features'
                        : isActive
                            ? '$remainingDays days remaining'
                            : 'Membership expired',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                  // AI 使用次数（所有用户都显示）
                  if (membership != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.wandMagicSparkles,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          level == MembershipLevel.premium
                              ? 'Unlimited AI'
                              : 'AI: $aiUsageRemaining/${level.aiUsageLimit} left',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // 箭头
            const Icon(
              FontAwesomeIcons.chevronRight,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
