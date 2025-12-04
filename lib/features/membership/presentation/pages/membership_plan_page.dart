import 'package:df_admin_mobile/features/membership/domain/entities/membership_level.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/membership_plan.dart';
import 'package:df_admin_mobile/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:df_admin_mobile/features/payment/application/services/payment_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 会员计划页面
class MembershipPlanPage extends StatelessWidget {
  const MembershipPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MembershipStateController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(color: Colors.black87),
        title: const Text(
          'Membership Plans',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final currentLevel = controller.level;
        final isLoading = controller.isUpgrading;
        final isLoadingPlans = controller.isLoadingPlans;
        final paidPlans = controller.paidPlans;
        final hasError = controller.hasPlansError;

        // 加载中状态
        if (isLoadingPlans && paidPlans.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 错误状态
        if (hasError) {
          return _buildErrorState(controller);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 当前会员状态
              _buildCurrentStatus(controller),
              const SizedBox(height: 24),

              // 动态生成会员计划卡片
              ...paidPlans.asMap().entries.map((entry) {
                final index = entry.key;
                final plan = entry.value;
                final isPopular = plan.level == 2; // Pro 计划标记为热门

                return Padding(
                  padding: EdgeInsets.only(bottom: index < paidPlans.length - 1 ? 16 : 0),
                  child: _MembershipPlanCard(
                    plan: plan,
                    isCurrentPlan: currentLevel.levelValue == plan.level,
                    isLoading: isLoading,
                    isPopular: isPopular,
                    onSelect: () => _handleUpgrade(controller, plan),
                  ),
                );
              }),

              const SizedBox(height: 32),

              // 底部说明
              _buildFooterNote(),
            ],
          ),
        );
      }),
    );
  }

  /// 错误状态视图
  Widget _buildErrorState(MembershipStateController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.triangleExclamation,
              size: 64,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to load membership plans',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.plansError ?? 'Please check your network connection',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.isLoadingPlans ? null : () => controller.loadPlans(),
              icon: controller.isLoadingPlans
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(FontAwesomeIcons.arrowsRotate, size: 16),
              label: Text(controller.isLoadingPlans ? 'Loading...' : 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatus(MembershipStateController controller) {
    final membership = controller.membership;
    final level = controller.level;

    return Container(
      padding: const EdgeInsets.all(20),
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
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                level.icon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current: ${level.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (membership?.isActive == true)
                  Text(
                    '${controller.remainingDays} days remaining',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  )
                else if (level == MembershipLevel.free)
                  Text(
                    'Upgrade to unlock more features',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.shield, size: 16, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text(
                'Secure Payment',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'All payments are processed securely. Cancel anytime.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpgrade(MembershipStateController controller, MembershipPlan plan) async {
    final targetLevel = MembershipLevel.fromValue(plan.level);

    if (controller.level.levelValue >= plan.level) {
      AppToast.info('You already have this or higher plan');
      return;
    }

    // 显示确认对话框
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Upgrade to ${plan.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You will be charged \$${plan.priceYearly.toStringAsFixed(0)}/year.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Image.asset(
                  'assets/images/paypal_logo.png',
                  width: 80,
                  height: 24,
                  errorBuilder: (_, __, ___) => Row(
                    children: [
                      Icon(FontAwesomeIcons.paypal, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 4),
                      Text('PayPal', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Secure Payment',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Get.back(result: true),
            icon: const Icon(FontAwesomeIcons.paypal, size: 16),
            label: const Text('Pay with PayPal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0070BA), // PayPal blue
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 使用 PayPal 支付
      await _processPayPalPayment(controller, plan, targetLevel);
    }
  }

  /// 处理 PayPal 支付
  Future<void> _processPayPalPayment(
    MembershipStateController controller,
    MembershipPlan plan,
    MembershipLevel targetLevel,
  ) async {
    // 获取支付服务
    PaymentService? paymentService;
    try {
      paymentService = Get.find<PaymentService>();
    } catch (e) {
      // 如果服务未注册，使用临时模拟升级
      AppToast.warning('Payment service not available, using demo mode');
      final success = await controller.upgradeMembership(targetLevel);
      if (success) {
        AppToast.success('Upgraded to ${plan.name} successfully!');
      } else {
        AppToast.error(controller.errorMessage ?? 'Upgrade failed');
      }
      return;
    }

    // 显示加载对话框
    Get.dialog(
      const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Creating payment order...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // 判断是升级还是续费
      final isRenewal = controller.membership?.isActive == true && controller.level.levelValue == plan.level;

      // 发起支付
      final success = await paymentService.startMembershipPayment(
        membershipLevel: plan.level,
        durationDays: 365, // 年度订阅
        isRenewal: isRenewal,
      );

      // 关闭加载对话框
      Get.back();

      if (success) {
        AppToast.info('Opening PayPal for payment...');
        // 支付页面已在外部浏览器中打开
        // 用户完成支付后会通过 deep link 返回
      } else {
        AppToast.error('Failed to create payment order');
      }
    } catch (e) {
      Get.back(); // 关闭加载对话框
      AppToast.error('Payment error: $e');
    }
  }
}

/// 会员计划卡片组件
class _MembershipPlanCard extends StatelessWidget {
  final MembershipPlan plan;
  final bool isCurrentPlan;
  final bool isLoading;
  final bool isPopular;
  final VoidCallback onSelect;

  const _MembershipPlanCard({
    required this.plan,
    required this.isCurrentPlan,
    required this.isLoading,
    this.isPopular = false,
    required this.onSelect,
  });

  /// 根据计划等级获取颜色
  Color get planColor {
    switch (plan.level) {
      case 1:
        return const Color(0xFF4CAF50); // Basic - Green
      case 2:
        return const Color(0xFF2196F3); // Pro - Blue
      case 3:
        return const Color(0xFFFFD700); // Premium - Gold
      default:
        return Colors.grey;
    }
  }

  /// 根据计划等级获取图标
  String get planIcon {
    switch (plan.level) {
      case 1:
        return '🌱'; // Basic
      case 2:
        return '⭐'; // Pro
      case 3:
        return '👑'; // Premium
      default:
        return '🆓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentPlan
                  ? planColor
                  : isPopular
                      ? planColor.withValues(alpha: 0.5)
                      : Colors.grey.shade200,
              width: isCurrentPlan || isPopular ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部：图标、名称、价格
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: planColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(planIcon, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: planColor,
                            ),
                          ),
                          if (plan.description != null)
                            Text(
                              plan.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${plan.priceYearly.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: planColor,
                          ),
                        ),
                        Text(
                          '/year',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // 功能列表
                ...plan.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.circleCheck,
                            size: 14,
                            color: planColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 16),

                // 选择按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan || isLoading ? null : onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan ? Colors.grey.shade300 : planColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isCurrentPlan ? 'Current Plan' : 'Select Plan',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Popular 标签
        if (isPopular)
          Positioned(
            top: -1,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: planColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              child: const Text(
                'POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
