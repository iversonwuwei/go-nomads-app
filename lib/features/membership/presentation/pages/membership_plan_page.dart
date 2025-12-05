import 'package:df_admin_mobile/features/membership/domain/entities/membership_level.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/membership_plan.dart';
import 'package:df_admin_mobile/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:df_admin_mobile/features/payment/application/services/alipay_service.dart';
import 'package:df_admin_mobile/features/payment/application/services/payment_service.dart';
import 'package:df_admin_mobile/features/payment/application/services/unified_payment_service.dart';
import 'package:df_admin_mobile/features/payment/application/services/wechat_pay_service.dart';
import 'package:df_admin_mobile/features/payment/domain/entities/payment_method.dart' as payment_entities;
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 支付方式枚举
enum PaymentMethod {
  paypal,
  wechat,
  alipay,
}

/// 支付方式扩展
extension PaymentMethodExtension on PaymentMethod {
  String get name {
    switch (this) {
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.wechat:
        return 'WeChat Pay';
      case PaymentMethod.alipay:
        return 'Alipay';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.paypal:
        return 'paypal';
      case PaymentMethod.wechat:
        return 'wechat';
      case PaymentMethod.alipay:
        return 'alipay';
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethod.paypal:
        return const Color(0xFF0070BA);
      case PaymentMethod.wechat:
        return const Color(0xFF07C160);
      case PaymentMethod.alipay:
        return const Color(0xFF1677FF);
    }
  }

  IconData get iconData {
    switch (this) {
      case PaymentMethod.paypal:
        return FontAwesomeIcons.paypal;
      case PaymentMethod.wechat:
        return FontAwesomeIcons.weixin;
      case PaymentMethod.alipay:
        return FontAwesomeIcons.alipay;
    }
  }
}

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

    // 显示支付方式选择底部弹窗
    final selectedMethod = await _showPaymentMethodSheet(plan);

    if (selectedMethod != null) {
      await _processPayment(controller, plan, targetLevel, selectedMethod);
    }
  }

  /// 显示支付方式选择底部弹窗
  Future<PaymentMethod?> _showPaymentMethodSheet(MembershipPlan plan) {
    return Get.bottomSheet<PaymentMethod>(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖动指示器
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 标题
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upgrade to ${plan.name} - \$${plan.priceYearly.toStringAsFixed(0)}/year',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 支付方式列表
              _buildPaymentMethodTile(
                PaymentMethod.paypal,
                'Fast & Secure international payment',
              ),
              _buildPaymentMethodTile(
                PaymentMethod.wechat,
                'Pay with WeChat (微信支付)',
              ),
              _buildPaymentMethodTile(
                PaymentMethod.alipay,
                'Pay with Alipay (支付宝)',
              ),

              const SizedBox(height: 8),

              // 安全提示
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.shieldHalved,
                      size: 14,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'All payments are secure and encrypted',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// 构建支付方式选项
  Widget _buildPaymentMethodTile(PaymentMethod method, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: method.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          method.iconData,
          color: method.color,
          size: 24,
        ),
      ),
      title: Text(
        method.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        FontAwesomeIcons.chevronRight,
        size: 14,
        color: Colors.grey.shade400,
      ),
      onTap: () => Get.back(result: method),
    );
  }

  /// 处理支付
  Future<void> _processPayment(
    MembershipStateController controller,
    MembershipPlan plan,
    MembershipLevel targetLevel,
    PaymentMethod method,
  ) async {
    switch (method) {
      case PaymentMethod.paypal:
        await _processPayPalPayment(controller, plan, targetLevel);
        break;
      case PaymentMethod.wechat:
        await _processWeChatPayment(controller, plan, targetLevel);
        break;
      case PaymentMethod.alipay:
        await _processAlipayPayment(controller, plan, targetLevel);
        break;
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
      // 如果服务未注册，提示并重新选择支付方式
      AppToast.warning('Payment service not available');
      _retryPaymentMethodSelection(controller, plan, targetLevel);
      return;
    }

    // 显示加载对话框
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Creating PayPal order...'),
                const SizedBox(height: 4),
                Text(
                  '\$${plan.priceYearly.toStringAsFixed(0)} for ${plan.name}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
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
        // 支付失败，重新显示支付方式选择
        _retryPaymentMethodSelection(controller, plan, targetLevel);
      }
    } catch (e) {
      Get.back(); // 关闭加载对话框
      AppToast.error('Payment error: $e');
      // 发生异常，重新显示支付方式选择
      _retryPaymentMethodSelection(controller, plan, targetLevel);
    }
  }

  /// 处理微信支付
  Future<void> _processWeChatPayment(
    MembershipStateController controller,
    MembershipPlan plan,
    MembershipLevel targetLevel,
  ) async {
    // 检查微信支付服务
    UnifiedPaymentService? unifiedPaymentService;
    WeChatPayService? wechatService;
    try {
      unifiedPaymentService = Get.find<UnifiedPaymentService>();
      wechatService = Get.find<WeChatPayService>();
    } catch (e) {
      AppToast.warning('WeChat Pay service not available');
      _retryPaymentMethodSelection(controller, plan, targetLevel);
      return;
    }

    // 检查微信是否已安装
    if (!await wechatService.isWeChatInstalled) {
      AppToast.error('Please install WeChat to use WeChat Pay');
      _retryPaymentMethodSelection(controller, plan, targetLevel);
      return;
    }

    // 显示加载对话框
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Creating WeChat Pay order...'),
                const SizedBox(height: 4),
                Text(
                  '¥${(plan.priceYearly * 7.2).toStringAsFixed(0)} for ${plan.name}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final isRenewal = controller.membership?.isActive == true && controller.level.levelValue == plan.level;

      final result = await unifiedPaymentService.payForMembership(
        method: payment_entities.PaymentMethod.wechat,
        membershipLevel: plan.level,
        durationDays: 365,
        isRenewal: isRenewal,
      );

      Get.back(); // 关闭加载对话框

      if (result.success) {
        AppToast.success('Payment successful!');
        // 刷新会员状态
        await controller.loadMembership();
      } else {
        AppToast.error(result.errorMessage ?? 'WeChat Pay failed');
        // 支付失败，重新显示支付方式选择
        _retryPaymentMethodSelection(controller, plan, targetLevel);
      }
    } catch (e) {
      Get.back(); // 关闭加载对话框
      AppToast.error('WeChat Pay error: $e');
      // 发生异常，重新显示支付方式选择
      _retryPaymentMethodSelection(controller, plan, targetLevel);
    }
  }

  /// 处理支付宝支付
  Future<void> _processAlipayPayment(
    MembershipStateController controller,
    MembershipPlan plan,
    MembershipLevel targetLevel,
  ) async {
    // 检查支付宝服务
    UnifiedPaymentService? unifiedPaymentService;
    AlipayService? alipayService;
    try {
      unifiedPaymentService = Get.find<UnifiedPaymentService>();
      alipayService = Get.find<AlipayService>();
    } catch (e) {
      AppToast.warning('Alipay service not available');
      // 重新显示支付方式选择
      _retryPaymentMethodSelection(controller, plan, targetLevel);
      return;
    }

    // 检查支付宝是否已安装
    if (!await alipayService.isAlipayInstalled) {
      AppToast.error('Please install Alipay to use Alipay Pay');
      // 重新显示支付方式选择
      _retryPaymentMethodSelection(controller, plan, targetLevel);
      return;
    }

    // 显示加载对话框
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Creating Alipay order...'),
                const SizedBox(height: 4),
                Text(
                  '¥${(plan.priceYearly * 7.2).toStringAsFixed(0)} for ${plan.name}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final isRenewal = controller.membership?.isActive == true && controller.level.levelValue == plan.level;

      // 添加超时处理，防止无限等待
      final result = await unifiedPaymentService
          .payForMembership(
        method: payment_entities.PaymentMethod.alipay,
        membershipLevel: plan.level,
        durationDays: 365,
        isRenewal: isRenewal,
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          return UnifiedPaymentResult(
            success: false,
            method: payment_entities.PaymentMethod.alipay,
            errorMessage: 'Request timeout, please try again',
          );
        },
      );

      Get.back(); // 关闭加载对话框

      if (result.success) {
        AppToast.success('Payment successful!');
        // 刷新会员状态
        await controller.loadMembership();
      } else {
        AppToast.error(result.errorMessage ?? 'Alipay payment failed');
        // 支付失败，重新显示支付方式选择
        _retryPaymentMethodSelection(controller, plan, targetLevel);
      }
    } catch (e) {
      Get.back(); // 关闭加载对话框
      AppToast.error('Alipay error: $e');
      // 发生异常，重新显示支付方式选择
      _retryPaymentMethodSelection(controller, plan, targetLevel);
    }
  }

  /// 重新显示支付方式选择
  void _retryPaymentMethodSelection(
    MembershipStateController controller,
    MembershipPlan plan,
    MembershipLevel targetLevel,
  ) async {
    // 稍微延迟一下，让用户看清错误提示
    await Future.delayed(const Duration(milliseconds: 500));

    // 重新显示支付方式选择底部弹窗
    final selectedMethod = await _showPaymentMethodSheet(plan);
    if (selectedMethod != null) {
      await _processPayment(controller, plan, targetLevel, selectedMethod);
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
