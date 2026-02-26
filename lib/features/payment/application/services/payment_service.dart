import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/payment/application/services/paypal_service.dart';
import 'package:go_nomads_app/features/payment/domain/entities/order.dart';
import 'package:go_nomads_app/features/payment/presentation/controllers/payment_state_controller.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 支付服务 - 处理支付流程
class PaymentService extends GetxService {
  PaymentStateController? get _paymentController {
    if (Get.isRegistered<PaymentStateController>()) {
      return Get.find<PaymentStateController>();
    }
    return null;
  }

  PayPalService? get _paypalService {
    if (Get.isRegistered<PayPalService>()) {
      return Get.find<PayPalService>();
    }
    return null;
  }

  /// 发起会员支付
  /// 返回 true 表示成功打开支付页面
  Future<bool> startMembershipPayment({
    required int membershipLevel,
    int durationDays = 365,
    bool isRenewal = false,
  }) async {
    final controller = _paymentController;
    if (controller == null) {
      log('❌ PaymentStateController 未注册');
      return false;
    }

    // 创建订单
    final order = await controller.createMembershipOrder(
      membershipLevel: membershipLevel,
      durationDays: durationDays,
      isRenewal: isRenewal,
    );

    if (order == null) {
      log('❌ 创建订单失败');
      return false;
    }

    // 打开支付页面
    return await _openPaymentPage(order);
  }

  /// 发起版主保证金支付
  Future<bool> startDepositPayment({required double amount}) async {
    final controller = _paymentController;
    if (controller == null) {
      log('❌ PaymentStateController 未注册');
      return false;
    }

    // 创建订单
    final order = await controller.createDepositOrder(amount: amount);

    if (order == null) {
      log('❌ 创建订单失败');
      return false;
    }

    // 打开支付页面
    return await _openPaymentPage(order);
  }

  /// 打开支付页面
  Future<bool> _openPaymentPage(Order order) async {
    if (order.approvalUrl == null || order.approvalUrl!.isEmpty) {
      log('❌ 支付链接为空');
      return false;
    }

    try {
      final approvalUrl = order.approvalUrl!;
      final paypalService = _paypalService;

      // 优先尝试使用 PayPal App，如果未安装则提示并跳转网页支付
      if (paypalService != null) {
        final isInstalled = await paypalService.isPayPalInstalled;

        if (isInstalled) {
          final result = await paypalService.smartLaunchPayPal(approvalUrl);

          if (result.success) {
            return true;
          }

          log('⚠️ PayPal App 打开失败，尝试网页支付: ${result.message}');
          AppToast.info('PayPal App 打开失败，已为你打开网页支付');

          final webOpened = await paypalService.openPayPalWeb(approvalUrl);
          if (webOpened) {
            return true;
          }
        } else {
          AppToast.info('未检测到 PayPal App，已为你打开网页支付');

          final webOpened = await paypalService.openPayPalWeb(approvalUrl);
          if (webOpened) {
            return true;
          }
        }
      }

      // 回退：直接使用 url_launcher 打开网页
      final uri = Uri.parse(approvalUrl);

      log('🌐 使用浏览器打开支付页面: $approvalUrl');

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return true;
      }

      log('❌ 无法打开支付链接');
      return false;
    } catch (e) {
      log('❌ 打开支付页面失败: $e');
      return false;
    }
  }

  /// 处理支付回调 (从 deep link 调用)
  Future<PaymentResult?> handlePaymentCallback({
    required String token,
    String? payerId,
  }) async {
    final controller = _paymentController;
    if (controller == null) {
      log('❌ PaymentStateController 未注册');
      return null;
    }

    log('💳 处理支付回调: token=$token, payerId=$payerId');

    // token 就是 PayPal 的 order ID
    final result = await controller.capturePayment(
      paypalOrderId: token,
      payerId: payerId,
    );

    return result;
  }

  /// 显示支付结果对话框
  void showPaymentResultDialog(
    BuildContext context, {
    required bool success,
    String? message,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8.w),
            Text(success ? '支付成功' : '支付失败'),
          ],
        ),
        content: Text(message ?? (success ? '您的会员已激活！' : '支付未完成，请重试。')),
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
