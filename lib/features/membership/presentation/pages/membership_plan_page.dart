import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/membership/domain/entities/membership_level.dart';
import 'package:go_nomads_app/features/membership/domain/entities/membership_plan.dart';
import 'package:go_nomads_app/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:go_nomads_app/features/payment/application/services/payment_service.dart';
import 'package:go_nomads_app/features/payment/application/services/unified_payment_service.dart';
import 'package:go_nomads_app/features/payment/application/services/wechat_pay_service.dart';
import 'package:go_nomads_app/features/payment/domain/entities/payment_method.dart' as payment_entities;
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/skeletons/base_skeleton.dart';

/// 支付方式枚举
enum PaymentMethod {
  paypal,
  wechat,
}

/// 支付方式扩展
extension PaymentMethodExtension on PaymentMethod {
  String get name {
    switch (this) {
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.wechat:
        return 'WeChat Pay';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.paypal:
        return 'paypal';
      case PaymentMethod.wechat:
        return 'wechat';
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethod.paypal:
        return const Color(0xFF0070BA);
      case PaymentMethod.wechat:
        return const Color(0xFF07C160);
    }
  }

  IconData get iconData {
    switch (this) {
      case PaymentMethod.paypal:
        return FontAwesomeIcons.paypal;
      case PaymentMethod.wechat:
        return FontAwesomeIcons.weixin;
    }
  }
}

/// 会员计划页面
/// 使用 GetView 模式，符合 GetX 标准
class MembershipPlanPage extends GetView<MembershipStateController> {
  const MembershipPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 页面首次构建时确保加载数据
    _ensureDataLoaded();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(color: Colors.black87),
        title: Text(
          l10n.membershipPlans,
          style: const TextStyle(
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
          return _buildLoadingSkeleton();
        }

        // 错误状态
        if (hasError) {
          return _buildErrorState();
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // 当前会员状态
              _buildCurrentStatus(context),
              SizedBox(height: 20.h),

              // 计费周期切换
              _buildBillingCycleToggle(context),
              SizedBox(height: 20.h),

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
                    isMonthly: controller.isMonthlyBilling,
                    onSelect: () => _handleUpgrade(context, plan),
                  ),
                );
              }),

              SizedBox(height: 32.h),

              // 底部说明
              _buildFooterNote(context),
            ],
          ),
        );
      }),
    );
  }

  /// 确保数据已加载
  void _ensureDataLoaded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensurePlansLoaded();
    });
  }

  /// 加载中骨架屏
  Widget _buildLoadingSkeleton() {
    return SafeShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            const _CurrentStatusSkeleton(),
            SizedBox(height: 24.h),
            ...List.generate(3, (index) {
              final hasSpacing = index < 2;
              return Padding(
                padding: EdgeInsets.only(bottom: hasSpacing ? 16 : 0),
                child: const _MembershipPlanSkeleton(),
              );
            }),
            SizedBox(height: 32.h),
            const _FooterSkeleton(),
          ],
        ),
      ),
    );
  }

  /// 错误状态视图
  Widget _buildErrorState() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.triangleExclamation,
                  size: 64.r,
                  color: Colors.orange.shade400,
                ),
                SizedBox(height: 24.h),
                Text(
                  l10n.unableToLoadPlans,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  controller.plansError ?? l10n.checkNetworkConnection,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: controller.isLoadingPlans ? null : () => controller.loadPlans(),
                  icon: controller.isLoadingPlans
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(strokeWidth: 2.r, color: Colors.white),
                        )
                      : Icon(FontAwesomeIcons.arrowsRotate, size: 16.r),
                  label: Text(controller.isLoadingPlans ? l10n.loading : l10n.retry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentStatus(BuildContext context) {
    final membership = controller.membership;
    final level = controller.level;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(20.w),
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
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                level.icon,
                style: TextStyle(fontSize: 32.sp),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentPlan(level.name),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                if (membership?.isActive == true)
                  Text(
                    l10n.daysRemaining(controller.remainingDays),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14.sp,
                    ),
                  )
                else if (level == MembershipLevel.free)
                  Text(
                    l10n.upgradeToUnlock,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14.sp,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 计费周期切换组件
  Widget _buildBillingCycleToggle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMonthly = controller.isMonthlyBilling;
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setMonthlyBilling(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isMonthly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: isMonthly
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4.r,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    l10n.billingMonthly,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: isMonthly ? FontWeight.bold : FontWeight.w500,
                      color: isMonthly ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setMonthlyBilling(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: !isMonthly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: !isMonthly
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4.r,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.billingYearly,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: !isMonthly ? FontWeight.bold : FontWeight.w500,
                          color: !isMonthly ? Colors.black87 : Colors.grey.shade600,
                        ),
                      ),
                      if (!isMonthly) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '优惠',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.shield, size: 16.r, color: Colors.green.shade600),
              SizedBox(width: 8.w),
              Text(
                l10n.securePayment,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.allPaymentsSecure,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpgrade(BuildContext context, MembershipPlan plan) async {
    final targetLevel = MembershipLevel.fromValue(plan.level);
    final l10n = AppLocalizations.of(context)!;

    if (controller.level.levelValue >= plan.level) {
      AppToast.info(l10n.alreadyHavePlan);
      return;
    }

    // 显示支付方式选择底部弹窗
    final selectedMethod = await _showPaymentMethodSheet(context, plan);

    if (selectedMethod != null && context.mounted) {
      await _processPayment(context, plan, targetLevel, selectedMethod);
    }
  }

  /// 显示支付方式选择底部弹窗
  Future<PaymentMethod?> _showPaymentMethodSheet(BuildContext context, MembershipPlan plan) {
    final l10n = AppLocalizations.of(context)!;
    return Get.bottomSheet<PaymentMethod>(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖动指示器
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // 标题
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Text(
                      l10n.selectPaymentMethod,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.upgradeTo(
                        plan.name,
                        controller.isMonthlyBilling
                            ? plan.priceMonthly.toStringAsFixed(0)
                            : plan.priceYearly.toStringAsFixed(0),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1.h),

              // 支付方式列表
              _buildPaymentMethodTile(
                context,
                PaymentMethod.paypal,
                l10n.paypalDescription,
              ),
              _buildPaymentMethodTile(
                context,
                PaymentMethod.wechat,
                l10n.wechatDescription,
              ),

              SizedBox(height: 8.h),

              // 安全提示
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.shieldHalved,
                      size: 14.r,
                      color: Colors.green.shade600,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      l10n.allPaymentsEncrypted,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// 构建支付方式选项
  Widget _buildPaymentMethodTile(BuildContext context, PaymentMethod method, String subtitle) {
    final l10n = AppLocalizations.of(context)!;
    String title;
    switch (method) {
      case PaymentMethod.paypal:
        title = l10n.paypalPayment;
        break;
      case PaymentMethod.wechat:
        title = l10n.wechatPayment;
        break;
    }
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      leading: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: method.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          method.iconData,
          color: method.color,
          size: 24.r,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        FontAwesomeIcons.chevronRight,
        size: 14.r,
        color: Colors.grey.shade400,
      ),
      onTap: () => Get.back(result: method),
    );
  }

  /// 处理支付
  Future<void> _processPayment(
    BuildContext context,
    MembershipPlan plan,
    MembershipLevel targetLevel,
    PaymentMethod method,
  ) async {
    switch (method) {
      case PaymentMethod.paypal:
        await _processPayPalPayment(context, plan, targetLevel);
        break;
      case PaymentMethod.wechat:
        await _processWeChatPayment(context, plan, targetLevel);
        break;
    }
  }

  /// 处理 PayPal 支付
  Future<void> _processPayPalPayment(
    BuildContext context,
    MembershipPlan plan,
    MembershipLevel targetLevel,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    // 获取支付服务
    PaymentService? paymentService;
    try {
      paymentService = Get.find<PaymentService>();
    } catch (e) {
      // 如果服务未注册，提示并重新选择支付方式
      AppToast.warning(l10n.paymentServiceNotAvailable);
      _retryPaymentMethodSelection(context, plan, targetLevel);
      return;
    }

    // 显示加载对话框
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.creatingPaypalOrder,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10n.priceForPlan(
                      controller.isMonthlyBilling
                          ? plan.priceMonthly.toStringAsFixed(0)
                          : plan.priceYearly.toStringAsFixed(0),
                      plan.name,
                    ),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    // 等待对话框完全显示
    await Future.delayed(const Duration(milliseconds: 100));

    bool success = false;
    String? errorMessage;

    try {
      // 判断是升级还是续费
      final isRenewal = controller.membership?.isActive == true && controller.level.levelValue == plan.level;

      // 发起支付
      success = await paymentService.startMembershipPayment(
        membershipLevel: plan.level,
        durationDays: controller.billingDurationDays,
        isRenewal: isRenewal,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      // 无论成功与否都关闭加载对话框
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }

    // 处理结果
    if (errorMessage != null) {
      AppToast.error(l10n.paymentError(errorMessage));
      if (!context.mounted) return;
      _retryPaymentMethodSelection(context, plan, targetLevel);
    } else if (success) {
      AppToast.info(l10n.openingPaypal);
      // 支付页面已在外部浏览器中打开
      // 用户完成支付后会通过 deep link 返回
    } else {
      AppToast.error(l10n.failedToCreateOrder);
      if (!context.mounted) return;
      _retryPaymentMethodSelection(context, plan, targetLevel);
    }
  }

  /// 处理微信支付
  Future<void> _processWeChatPayment(
    BuildContext context,
    MembershipPlan plan,
    MembershipLevel targetLevel,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    // 检查微信支付服务
    UnifiedPaymentService? unifiedPaymentService;
    WeChatPayService? wechatService;
    try {
      unifiedPaymentService = Get.find<UnifiedPaymentService>();
      wechatService = Get.find<WeChatPayService>();
    } catch (e) {
      AppToast.warning(l10n.paymentServiceNotAvailable);
      _retryPaymentMethodSelection(context, plan, targetLevel);
      return;
    }

    // 检查微信是否已安装
    if (!await wechatService.isWeChatInstalled) {
      AppToast.error(l10n.wechatNotInstalled);
      if (!context.mounted) return;
      _retryPaymentMethodSelection(context, plan, targetLevel);
      return;
    }

    // 显示加载对话框
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.creatingWechatOrder,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10n.cnyPriceForPlan(
                      controller.isMonthlyBilling
                          ? plan.priceMonthly.toStringAsFixed(0)
                          : plan.priceYearly.toStringAsFixed(0),
                      plan.name,
                    ),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    // 等待对话框完全显示
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final isRenewal = controller.membership?.isActive == true && controller.level.levelValue == plan.level;

      // 异步调用支付，不等待结果
      unifiedPaymentService
          .payForMembership(
        method: payment_entities.PaymentMethod.wechat,
        membershipLevel: plan.level,
        durationDays: controller.billingDurationDays,
        isRenewal: isRenewal,
      )
          .then((result) {
        // 支付结果回调
        if (result.success) {
          AppToast.success(l10n.paymentSuccessful);
          // 刷新会员状态
          controller.loadMembership();
          // 强制刷新用户 profile（跳过缓存，确保获取最新会员级别）
          if (Get.isRegistered<UserStateController>()) {
            Get.find<UserStateController>().refresh();
          }
        } else {
          AppToast.error(result.errorMessage ?? l10n.wechatPayFailed);
        }
      }).catchError((e) {
        AppToast.error(l10n.wechatPayError(e.toString()));
      });

      // 等待一下确保SDK已经开始调用
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      AppToast.error(l10n.wechatPayError(e.toString()));
    } finally {
      // 无论成功与否都关闭加载对话框
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }

  /// 重新显示支付方式选择
  void _retryPaymentMethodSelection(
    BuildContext context,
    MembershipPlan plan,
    MembershipLevel targetLevel,
  ) async {
    // 稍微延迟一下，让用户看清错误提示
    await Future.delayed(const Duration(milliseconds: 500));

    if (!context.mounted) return;
    // 重新显示支付方式选择底部弹窗
    final selectedMethod = await _showPaymentMethodSheet(context, plan);
    if (selectedMethod != null && context.mounted) {
      await _processPayment(context, plan, targetLevel, selectedMethod);
    }
  }
}

/// 会员计划骨架卡片
class _MembershipPlanSkeleton extends StatelessWidget {
  const _MembershipPlanSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 48.w, height: 48.h, borderRadius: 12),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 140.w, height: 18.h),
                      SizedBox(height: 6.h),
                      SkeletonBox(width: 200.w, height: 14.h),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SkeletonBox(width: 80.w, height: 22.h),
                    SizedBox(height: 6.h),
                    SkeletonBox(width: 50.w, height: 14.h),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Column(
              children: [
                _PlanBenefitSkeleton(),
                SizedBox(height: 8.h),
                _PlanBenefitSkeleton(),
                SizedBox(height: 8.h),
                _PlanBenefitSkeleton(),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanBenefitSkeleton extends StatelessWidget {
  const _PlanBenefitSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SkeletonCircle(size: 12.r),
        SizedBox(width: 8.w),
        Expanded(child: SkeletonBox(height: 14.h)),
      ],
    );
  }
}

/// 当前状态骨架
class _CurrentStatusSkeleton extends StatelessWidget {
  const _CurrentStatusSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 160.w, height: 18.h),
            SizedBox(height: 12.h),
            SkeletonBox(width: 220.w, height: 16.h),
            SizedBox(height: 12.h),
            SkeletonBox(width: 120.w, height: 14.h),
          ],
        ),
      ),
    );
  }
}

/// 底部说明骨架
class _FooterSkeleton extends StatelessWidget {
  const _FooterSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 180.w, height: 16.h),
        SizedBox(height: 8.h),
        SkeletonBox(width: double.infinity, height: 14.h),
        SizedBox(height: 6.h),
        SkeletonBox(width: double.infinity, height: 14.h),
      ],
    );
  }
}

/// 会员计划卡片组件
class _MembershipPlanCard extends StatelessWidget {
  final MembershipPlan plan;
  final bool isCurrentPlan;
  final bool isLoading;
  final bool isPopular;
  final bool isMonthly;
  final VoidCallback onSelect;

  const _MembershipPlanCard({
    required this.plan,
    required this.isCurrentPlan,
    required this.isLoading,
    this.isPopular = false,
    this.isMonthly = false,
    required this.onSelect,
  });

  String get currencySymbol {
    switch (plan.currency.toUpperCase()) {
      case 'CNY':
        return '¥';
      case 'USD':
      default:
        return r'$';
    }
  }

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
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
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
                blurRadius: 10.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部：图标、名称、价格
                Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: planColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(planIcon, style: TextStyle(fontSize: 24.sp)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: planColor,
                            ),
                          ),
                          if (plan.description != null)
                            Text(
                              plan.description!,
                              style: TextStyle(
                                fontSize: 13.sp,
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
                          '$currencySymbol${isMonthly ? plan.priceMonthly.toStringAsFixed(0) : plan.priceYearly.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: planColor,
                          ),
                        ),
                        Text(
                          isMonthly ? l10n.perMonth : l10n.perYear,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (!isMonthly) ...[
                          SizedBox(height: 2.h),
                          Text(
                            l10n.saveAmount((plan.priceMonthly * 12 - plan.priceYearly).toStringAsFixed(0)),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                const Divider(),
                SizedBox(height: 12.h),

                // 功能列表
                ...plan.features.map((feature) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.circleCheck,
                            size: 14.r,
                            color: planColor,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ),
                    )),

                SizedBox(height: 16.h),

                // 选择按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan || isLoading ? null : onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan ? Colors.grey.shade300 : planColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.r,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isCurrentPlan ? l10n.currentPlanLabel : l10n.selectPlanLabel,
                            style: TextStyle(
                              fontSize: 16.sp,
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
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: planColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(8.r),
                ),
              ),
              child: Text(
                l10n.popular,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
