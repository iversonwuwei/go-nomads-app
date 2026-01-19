import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:go_nomads_app/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:go_nomads_app/features/payment/application/services/payment_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Deep Link 处理器
/// 处理应用的 deep link，包括支付回调
class DeepLinkHandler {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;

  /// 初始化 Deep Link 监听
  static Future<void> init() async {
    // 处理应用启动时的 deep link (冷启动)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        log('📱 初始 Deep Link: $initialUri');
        await _handleUri(initialUri);
      }
    } catch (e) {
      log('❌ 获取初始 Deep Link 失败: $e');
    }

    // 监听应用运行时的 deep link (热启动)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) async {
        log('📱 收到 Deep Link: $uri');
        await _handleUri(uri);
      },
      onError: (e) {
        log('❌ Deep Link 监听错误: $e');
      },
    );

    log('✅ Deep Link 处理器已初始化');
  }

  /// 销毁监听
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    log('🛑 Deep Link 处理器已销毁');
  }

  /// 处理 URI
  static Future<void> _handleUri(Uri uri) async {
    log('🔗 处理 URI: $uri');
    log('   Scheme: ${uri.scheme}');
    log('   Host: ${uri.host}');
    log('   Path: ${uri.path}');
    log('   Query: ${uri.queryParameters}');

    // 检查是否是我们的 app scheme
    if (uri.scheme != 'gonomads') {
      log('⚠️ 未知的 scheme: ${uri.scheme}');
      return;
    }

    // 根据 host 或 path 处理不同的 deep link
    switch (uri.host) {
      case 'payment':
        await _handlePaymentCallback(uri);
        break;
      case 'city':
        await _handleCityDeepLink(uri);
        break;
      case 'meetup':
        await _handleMeetupDeepLink(uri);
        break;
      case 'coworking':
        await _handleCoworkingDeepLink(uri);
        break;
      default:
        // 处理路径格式的深链 (如 gonomads:///city/detail?id=123)
        await _handlePathBasedDeepLink(uri);
    }
  }

  /// 处理城市详情深链
  static Future<void> _handleCityDeepLink(Uri uri) async {
    log('🏙️ 处理城市深链: ${uri.path}');
    final queryParams = uri.queryParameters;
    final cityId = queryParams['id'];
    if (cityId != null) {
      Get.toNamed('/city/detail', arguments: {'cityId': int.tryParse(cityId)});
    }
  }

  /// 处理 Meetup 详情深链
  static Future<void> _handleMeetupDeepLink(Uri uri) async {
    log('🤝 处理 Meetup 深链: ${uri.path}');
    final queryParams = uri.queryParameters;
    final meetupId = queryParams['id'];
    if (meetupId != null) {
      Get.toNamed('/meetup/detail', arguments: {'meetupId': int.tryParse(meetupId)});
    }
  }

  /// 处理 Coworking 详情深链
  static Future<void> _handleCoworkingDeepLink(Uri uri) async {
    log('💼 处理 Coworking 深链: ${uri.path}');
    final queryParams = uri.queryParameters;
    final coworkingId = queryParams['id'];
    if (coworkingId != null) {
      Get.toNamed('/coworking/detail', arguments: {'coworkingId': int.tryParse(coworkingId)});
    }
  }

  /// 处理路径格式的深链 (如 gonomads:///city/detail?id=123)
  static Future<void> _handlePathBasedDeepLink(Uri uri) async {
    final path = uri.path;
    final queryParams = uri.queryParameters;
    
    if (path.startsWith('/city/detail')) {
      final cityId = queryParams['id'];
      if (cityId != null) {
        Get.toNamed('/city/detail', arguments: {'cityId': int.tryParse(cityId)});
      }
    } else if (path.startsWith('/meetup/detail')) {
      final meetupId = queryParams['id'];
      if (meetupId != null) {
        Get.toNamed('/meetup/detail', arguments: {'meetupId': int.tryParse(meetupId)});
      }
    } else if (path.startsWith('/coworking/detail')) {
      final coworkingId = queryParams['id'];
      if (coworkingId != null) {
        Get.toNamed('/coworking/detail', arguments: {'coworkingId': int.tryParse(coworkingId)});
      }
    } else {
      log('⚠️ 未知的 deep link 路径: $path');
    }
  }

  /// 处理支付回调
  static Future<void> _handlePaymentCallback(Uri uri) async {
    log('💳 处理支付回调: ${uri.path}');

    // 解析路径: /success 或 /cancel
    final path = uri.path;
    final queryParams = uri.queryParameters;

    if (path.contains('success')) {
      // 支付成功回调
      final token = queryParams['token']; // PayPal order ID
      final payerId = queryParams['PayerID'];

      if (token == null) {
        log('❌ 缺少 token 参数');
        AppToast.error('Payment callback missing required parameters');
        return;
      }

      log('✅ 支付成功回调: token=$token, payerId=$payerId');

      // 调用支付服务完成支付
      try {
        final paymentService = Get.find<PaymentService>();

        // 显示处理中对话框
        _showProcessingDialog();

        final result = await paymentService.handlePaymentCallback(
          token: token,
          payerId: payerId,
        );

        // 关闭处理中对话框
        Get.back();

        if (result != null && result.success) {
          // 刷新会员状态
          if (Get.isRegistered<MembershipStateController>()) {
            final membershipController = Get.find<MembershipStateController>();
            await membershipController.loadMembership();
          }

          // 显示成功对话框
          _showSuccessDialog(result.membershipType);
        } else {
          AppToast.error(result?.message ?? 'Payment confirmation failed');
        }
      } catch (e) {
        log('❌ 处理支付回调失败: $e');
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        AppToast.error('Failed to process payment: $e');
      }
    } else if (path.contains('cancel')) {
      // 用户取消支付
      log('⚠️ 用户取消支付');
      AppToast.warning('Payment was cancelled');
    } else {
      log('⚠️ 未知的支付回调路径: $path');
    }
  }

  /// 显示处理中对话框
  static void _showProcessingDialog() {
    Get.dialog(
      const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Confirming payment...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// 显示成功对话框
  static void _showSuccessDialog(String? membershipType) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Payment Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (membershipType != null) Text('Your $membershipType membership is now active!'),
            const SizedBox(height: 8),
            const Text('Thank you for your support!'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              // 可以选择跳转到会员页面
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }
}
