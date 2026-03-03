import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// PayPal 支付服务
class PayPalService extends GetxService {
  // PayPal App 的 URL Scheme
  // iOS: paypal://
  // Android: com.paypal.android.p2pmobile
  static const String _paypalSchemeIOS = 'paypal://';
  static const String _paypalSchemeAndroid = 'paypal://';

  /// 检查 PayPal 是否已安装
  Future<bool> get isPayPalInstalled async {
    try {
      log('🔍 正在检查 PayPal 是否安装...');

      final Uri paypalUri;
      if (Platform.isIOS) {
        paypalUri = Uri.parse(_paypalSchemeIOS);
      } else if (Platform.isAndroid) {
        paypalUri = Uri.parse(_paypalSchemeAndroid);
      } else {
        log('📱 当前平台不支持 PayPal App 检测');
        return false;
      }

      final installed = await canLaunchUrl(paypalUri);
      log('📱 PayPal 安装状态: $installed');
      return installed;
    } catch (e) {
      log('❌ 检查 PayPal 安装状态失败: $e');
      return false;
    }
  }

  /// 使用 PayPal App 打开支付链接
  /// [approvalUrl] PayPal 审批 URL
  /// 返回是否成功打开 App
  Future<bool> openPayPalApp(String approvalUrl) async {
    try {
      log('📱 尝试使用 PayPal App 打开支付...');

      // 从 approval URL 中提取 token
      final uri = Uri.parse(approvalUrl);
      final token = uri.queryParameters['token'];

      if (token == null) {
        log('❌ 无法从 URL 中提取 token');
        return false;
      }

      // 构建 PayPal App 的深度链接
      // PayPal App 支持的格式: paypal://checkout?token=xxx
      Uri paypalAppUri;
      if (Platform.isIOS) {
        paypalAppUri = Uri.parse('paypal://checkout?token=$token');
      } else if (Platform.isAndroid) {
        paypalAppUri = Uri.parse('paypal://checkout?token=$token');
      } else {
        return false;
      }

      log('📱 PayPal App URI: $paypalAppUri');

      final canLaunch = await canLaunchUrl(paypalAppUri);
      if (canLaunch) {
        await launchUrl(paypalAppUri, mode: LaunchMode.externalApplication);
        log('✅ 成功打开 PayPal App');
        return true;
      } else {
        log('⚠️ 无法打开 PayPal App');
        return false;
      }
    } catch (e) {
      log('❌ 打开 PayPal App 失败: $e');
      return false;
    }
  }

  /// 使用网页打开 PayPal 支付
  Future<bool> openPayPalWeb(String approvalUrl) async {
    try {
      log('🌐 使用网页打开 PayPal 支付...');
      final uri = Uri.parse(approvalUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        log('✅ 成功打开 PayPal 网页');
        return true;
      } else {
        log('❌ 无法打开 PayPal 网页');
        return false;
      }
    } catch (e) {
      log('❌ 打开 PayPal 网页失败: $e');
      return false;
    }
  }

  /// 智能打开 PayPal 支付
  /// 优先使用 App，如果未安装则使用网页
  Future<PayPalLaunchResult> smartLaunchPayPal(String approvalUrl) async {
    try {
      final isInstalled = await isPayPalInstalled;

      if (isInstalled) {
        log('📱 检测到 PayPal App 已安装，尝试使用 App 支付...');
        final success = await openPayPalApp(approvalUrl);
        if (success) {
          return PayPalLaunchResult(
            success: true,
            usedApp: true,
            message: '已打开 PayPal App',
          );
        }
        // 如果 App 打开失败，回退到网页
        log('⚠️ PayPal App 打开失败，回退到网页支付...');
      }

      log('🌐 使用网页方式进行 PayPal 支付...');
      final success = await openPayPalWeb(approvalUrl);
      return PayPalLaunchResult(
        success: success,
        usedApp: false,
        message: success ? '已打开 PayPal 网页' : '无法打开支付页面',
      );
    } catch (e) {
      log('❌ PayPal 支付启动失败: $e');
      return PayPalLaunchResult(
        success: false,
        usedApp: false,
        message: e.toString(),
      );
    }
  }
}

/// PayPal 启动结果
class PayPalLaunchResult {
  final bool success;
  final bool usedApp;
  final String message;

  PayPalLaunchResult({
    required this.success,
    required this.usedApp,
    required this.message,
  });
}
