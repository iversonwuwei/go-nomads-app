import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/payment/application/services/paypal_service.dart';
import 'package:go_nomads_app/features/payment/application/services/wechat_pay_service.dart';
import 'package:go_nomads_app/features/payment/domain/entities/payment_method.dart';
import 'package:go_nomads_app/features/payment/presentation/controllers/payment_state_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 统一支付结果
class UnifiedPaymentResult {
  final bool success;
  final PaymentMethod method;
  final String? orderId;
  final String? errorMessage;

  UnifiedPaymentResult({
    required this.success,
    required this.method,
    this.orderId,
    this.errorMessage,
  });
}

/// 统一支付服务 - 管理多种支付方式
class UnifiedPaymentService extends GetxService {
  WeChatPayService? get _wechatService {
    if (Get.isRegistered<WeChatPayService>()) {
      return Get.find<WeChatPayService>();
    }
    return null;
  }

  PayPalService? get _paypalService {
    if (Get.isRegistered<PayPalService>()) {
      return Get.find<PayPalService>();
    }
    return null;
  }

  PaymentStateController? get _paymentController {
    if (Get.isRegistered<PaymentStateController>()) {
      return Get.find<PaymentStateController>();
    }
    return null;
  }

  /// 发起会员支付
  Future<UnifiedPaymentResult> payForMembership({
    required PaymentMethod method,
    required int membershipLevel,
    int durationDays = 365,
    bool isRenewal = false,
  }) async {
    final controller = _paymentController;
    if (controller == null) {
      return UnifiedPaymentResult(
        success: false,
        method: method,
        errorMessage: '支付服务未初始化',
      );
    }

    switch (method) {
      case PaymentMethod.paypal:
        return await _payWithPayPal(
          controller: controller,
          membershipLevel: membershipLevel,
          durationDays: durationDays,
          isRenewal: isRenewal,
        );
      case PaymentMethod.wechat:
        return await _payWithWeChat(
          controller: controller,
          membershipLevel: membershipLevel,
          durationDays: durationDays,
          isRenewal: isRenewal,
        );
    }
  }

  /// PayPal 支付
  Future<UnifiedPaymentResult> _payWithPayPal({
    required PaymentStateController controller,
    required int membershipLevel,
    int durationDays = 365,
    bool isRenewal = false,
  }) async {
    try {
      final order = await controller.createMembershipOrder(
        membershipLevel: membershipLevel,
        durationDays: durationDays,
        isRenewal: isRenewal,
      );

      if (order == null || order.approvalUrl == null) {
        return UnifiedPaymentResult(
          success: false,
          method: PaymentMethod.paypal,
          errorMessage: '创建订单失败',
        );
      }

      // 使用 PayPalService 智能启动支付
      final paypalService = _paypalService;
      if (paypalService != null) {
        final result = await paypalService.smartLaunchPayPal(order.approvalUrl!);
        if (result.success) {
          log('✅ PayPal 支付启动成功: ${result.usedApp ? "App" : "网页"}');
          return UnifiedPaymentResult(
            success: true,
            method: PaymentMethod.paypal,
            orderId: order.id,
          );
        } else {
          return UnifiedPaymentResult(
            success: false,
            method: PaymentMethod.paypal,
            errorMessage: result.message,
          );
        }
      }

      // 回退：直接使用 url_launcher
      final uri = Uri.parse(order.approvalUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return UnifiedPaymentResult(
          success: true,
          method: PaymentMethod.paypal,
          orderId: order.id,
        );
      } else {
        return UnifiedPaymentResult(
          success: false,
          method: PaymentMethod.paypal,
          errorMessage: '无法打开支付页面',
        );
      }
    } catch (e) {
      log('❌ PayPal 支付失败: $e');
      return UnifiedPaymentResult(
        success: false,
        method: PaymentMethod.paypal,
        errorMessage: e.toString(),
      );
    }
  }

  /// 微信支付
  Future<UnifiedPaymentResult> _payWithWeChat({
    required PaymentStateController controller,
    required int membershipLevel,
    int durationDays = 365,
    bool isRenewal = false,
  }) async {
    final wechatService = _wechatService;
    if (wechatService == null) {
      return UnifiedPaymentResult(
        success: false,
        method: PaymentMethod.wechat,
        errorMessage: '微信支付服务未初始化',
      );
    }

    // 检查微信是否安装
    if (!await wechatService.isWeChatInstalled) {
      return UnifiedPaymentResult(
        success: false,
        method: PaymentMethod.wechat,
        errorMessage: '请先安装微信',
      );
    }

    try {
      // 1. 创建微信支付订单（调用后端接口）
      final wechatPayInfo = await controller.createWeChatPayOrder(
        membershipLevel: membershipLevel,
        durationDays: durationDays,
        isRenewal: isRenewal,
      );

      if (wechatPayInfo == null) {
        return UnifiedPaymentResult(
          success: false,
          method: PaymentMethod.wechat,
          errorMessage: '创建微信支付订单失败',
        );
      }

      // 2. 调用微信 SDK 发起支付
      final sdkResult = await wechatService.pay(
        appId: wechatPayInfo['appId'],
        partnerId: wechatPayInfo['partnerId'],
        prepayId: wechatPayInfo['prepayId'],
        packageValue: wechatPayInfo['package'],
        nonceStr: wechatPayInfo['nonceStr'],
        timestamp: wechatPayInfo['timestamp'],
        sign: wechatPayInfo['sign'],
      );

      if (!sdkResult.success) {
        return UnifiedPaymentResult(
          success: false,
          method: PaymentMethod.wechat,
          orderId: wechatPayInfo['orderId'],
          errorMessage: sdkResult.errorMessage,
        );
      }

      // 3. SDK 回调成功后，调用后端确认支付结果
      final orderId = wechatPayInfo['orderId'] as String?;
      if (orderId != null) {
        log('🔄 微信 SDK 支付成功，正在确认支付结果...');
        final confirmResult = await controller.confirmWeChatPayment(
          orderId: orderId,
        );

        if (confirmResult != null && confirmResult.success) {
          log('✅ 微信支付确认成功');
          return UnifiedPaymentResult(
            success: true,
            method: PaymentMethod.wechat,
            orderId: orderId,
          );
        } else {
          // 确认失败但 SDK 已返回成功，可能 webhook 尚未到达
          log('⚠️ 微信支付确认暂未完成，可能稍后通过 webhook 完成');
          return UnifiedPaymentResult(
            success: true,
            method: PaymentMethod.wechat,
            orderId: orderId,
            errorMessage: '支付已提交，正在确认中...',
          );
        }
      }

      return UnifiedPaymentResult(
        success: true,
        method: PaymentMethod.wechat,
        orderId: wechatPayInfo['orderId'],
      );
    } catch (e) {
      log('❌ 微信支付失败: $e');
      return UnifiedPaymentResult(
        success: false,
        method: PaymentMethod.wechat,
        errorMessage: e.toString(),
      );
    }
  }

  /// 检查支付方式是否可用
  Future<bool> isPaymentMethodAvailable(PaymentMethod method) async {
    switch (method) {
      case PaymentMethod.paypal:
        return true; // PayPal 支持 App 和网页，始终可用
      case PaymentMethod.wechat:
        final wechatService = _wechatService;
        if (wechatService == null) return false;
        return await wechatService.isWeChatInstalled;
    }
  }

  /// 显示支付结果对话框
  void showPaymentResultDialog(
    BuildContext context, {
    required UnifiedPaymentResult result,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.success ? Icons.check_circle : Icons.error,
              color: result.success ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8.w),
            Text(result.success ? '支付成功' : '支付失败'),
          ],
        ),
        content: Text(
          result.success ? '您的会员已激活！' : (result.errorMessage ?? '支付未完成，请重试。'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
