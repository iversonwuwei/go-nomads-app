import 'dart:async';
import 'dart:developer';

import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';

/// 微信支付配置
class WeChatPayConfig {
  final String appId;
  final String? universalLink; // iOS Universal Link

  const WeChatPayConfig({
    required this.appId,
    this.universalLink,
  });
}

/// 微信支付服务
class WeChatPayService extends GetxService {
  final _fluwx = Fluwx();
  
  Function(dynamic)? _paymentListener;
  Completer<WeChatPayResult>? _paymentCompleter;

  /// 初始化微信 SDK
  Future<WeChatPayService> init(WeChatPayConfig config) async {
    try {
      await _fluwx.registerApi(
        appId: config.appId,
        universalLink: config.universalLink ?? '',
      );
      
      // 监听支付结果
      _paymentListener = (response) {
        if (response is WeChatPaymentResponse) {
          _onPaymentResponse(response);
        }
      };
      _fluwx.addSubscriber(_paymentListener!);
      
      log('✅ 微信 SDK 初始化成功');
    } catch (e) {
      log('❌ 微信 SDK 初始化失败: $e');
    }
    
    return this;
  }

  /// 检查微信是否已安装
  Future<bool> get isWeChatInstalled async {
    try {
      return await _fluwx.isWeChatInstalled;
    } catch (e) {
      log('❌ 检查微信安装状态失败: $e');
      return false;
    }
  }

  /// 发起微信支付
  /// 参数来自后端返回的预支付信息
  Future<WeChatPayResult> pay({
    required String appId,
    required String partnerId,
    required String prepayId,
    required String packageValue,
    required String nonceStr,
    required int timestamp,
    required String sign,
  }) async {
    // 检查微信是否安装
    if (!await isWeChatInstalled) {
      return WeChatPayResult(
        success: false,
        errorCode: -1,
        errorMessage: '未安装微信',
      );
    }

    _paymentCompleter = Completer<WeChatPayResult>();

    try {
      final result = await _fluwx.pay(
        which: Payment(
          appId: appId,
          partnerId: partnerId,
          prepayId: prepayId,
          packageValue: packageValue,
          nonceStr: nonceStr,
          timestamp: timestamp,
          sign: sign,
        ),
      );

      log('📱 调起微信支付: $result');

      // 等待支付结果回调
      return await _paymentCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => WeChatPayResult(
          success: false,
          errorCode: -2,
          errorMessage: '支付超时',
        ),
      );
    } catch (e) {
      log('❌ 微信支付失败: $e');
      _paymentCompleter?.complete(WeChatPayResult(
        success: false,
        errorCode: -1,
        errorMessage: e.toString(),
      ));
      return _paymentCompleter!.future;
    }
  }

  /// 处理支付结果回调
  void _onPaymentResponse(WeChatPaymentResponse response) {
    log('💰 微信支付结果: errCode=${response.errCode}, errStr=${response.errStr}');

    final result = WeChatPayResult(
      success: response.errCode == 0,
      errorCode: response.errCode ?? -1,
      errorMessage: response.errStr,
    );

    _paymentCompleter?.complete(result);
    _paymentCompleter = null;
  }

  @override
  void onClose() {
    if (_paymentListener != null) {
      _fluwx.removeSubscriber(_paymentListener!);
    }
    super.onClose();
  }
}

/// 微信支付结果
class WeChatPayResult {
  final bool success;
  final int errorCode;
  final String? errorMessage;

  WeChatPayResult({
    required this.success,
    required this.errorCode,
    this.errorMessage,
  });

  @override
  String toString() => 
    'WeChatPayResult(success: $success, errorCode: $errorCode, errorMessage: $errorMessage)';
}
