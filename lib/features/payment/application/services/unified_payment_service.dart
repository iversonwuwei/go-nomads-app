import 'dart:developer';

import 'package:df_admin_mobile/features/payment/application/services/alipay_service.dart';
import 'package:df_admin_mobile/features/payment/application/services/paypal_service.dart';
import 'package:df_admin_mobile/features/payment/application/services/wechat_pay_service.dart';
import 'package:df_admin_mobile/features/payment/domain/entities/payment_method.dart';
import 'package:df_admin_mobile/features/payment/presentation/controllers/payment_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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

  AlipayService? get _alipayService {
    if (Get.isRegistered<AlipayService>()) {
      return Get.find<AlipayService>();
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
      case PaymentMethod.alipay:
        return await _payWithAlipay(
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
      final result = await wechatService.pay(
        appId: wechatPayInfo['appId'],
        partnerId: wechatPayInfo['partnerId'],
        prepayId: wechatPayInfo['prepayId'],
        packageValue: wechatPayInfo['package'],
        nonceStr: wechatPayInfo['nonceStr'],
        timestamp: wechatPayInfo['timestamp'],
        sign: wechatPayInfo['sign'],
      );

      return UnifiedPaymentResult(
        success: result.success,
        method: PaymentMethod.wechat,
        orderId: wechatPayInfo['orderId'],
        errorMessage: result.success ? null : result.errorMessage,
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

  /// 支付宝支付
  Future<UnifiedPaymentResult> _payWithAlipay({
    required PaymentStateController controller,
    required int membershipLevel,
    int durationDays = 365,
    bool isRenewal = false,
  }) async {
    final alipayService = _alipayService;
    if (alipayService == null) {
      return UnifiedPaymentResult(
        success: false,
        method: PaymentMethod.alipay,
        errorMessage: '支付宝服务未初始化',
      );
    }

    // 检查支付宝是否已安装
    if (!await alipayService.isAlipayInstalled) {
      return UnifiedPaymentResult(
        success: false,
        method: PaymentMethod.alipay,
        errorMessage: '请先安装支付宝 App',
      );
    }

    try {
      // 1. 创建支付宝订单（调用后端接口获取签名后的订单信息）
      log('📤 正在创建支付宝订单...');
      final orderInfo = await controller.createAlipayOrder(
        membershipLevel: membershipLevel,
        durationDays: durationDays,
        isRenewal: isRenewal,
      );

      if (orderInfo == null) {
        log('❌ 创建支付宝订单失败: orderInfo 为 null');
        return UnifiedPaymentResult(
          success: false,
          method: PaymentMethod.alipay,
          errorMessage: '创建支付宝订单失败',
        );
      }

      // 检查 orderString 是否有效
      final orderString = orderInfo['orderString'] as String?;
      final orderId = orderInfo['orderId'] as String?;

      log('📦 订单信息: orderId=$orderId, orderString长度=${orderString?.length ?? 0}');

      if (orderString == null || orderString.isEmpty) {
        log('❌ orderString 为空');
        return UnifiedPaymentResult(
          success: false,
          method: PaymentMethod.alipay,
          errorMessage: '订单签名信息无效',
        );
      }

      // 2. 调用支付宝 SDK 发起支付
      log('📱 正在调起支付宝...');
      final result = await alipayService.pay(orderString);

      log('💰 支付宝返回: success=${result.success}, status=${result.resultStatus}, memo=${result.memo}');

      return UnifiedPaymentResult(
        success: result.success,
        method: PaymentMethod.alipay,
        orderId: orderId,
        errorMessage: result.success ? null : result.displayMessage,
      );
    } catch (e) {
      log('❌ 支付宝支付失败: $e');
      return UnifiedPaymentResult(
        success: false,
        method: PaymentMethod.alipay,
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
      case PaymentMethod.alipay:
        final alipayService = _alipayService;
        if (alipayService == null) return false;
        return await alipayService.isAlipayInstalled;
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
            const SizedBox(width: 8),
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
