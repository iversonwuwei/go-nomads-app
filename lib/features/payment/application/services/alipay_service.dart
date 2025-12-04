import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:tobias/tobias.dart';

/// 支付宝支付服务
class AlipayService extends GetxService {
  final Tobias _tobias = Tobias();

  /// 检查支付宝是否已安装
  Future<bool> get isAlipayInstalled async {
    try {
      return await _tobias.isAliPayInstalled;
    } catch (e) {
      log('❌ 检查支付宝安装状态失败: $e');
      return false;
    }
  }

  /// 发起支付宝支付
  /// [orderInfo] 从后端获取的签名后的订单信息字符串
  Future<AlipayResult> pay(String orderInfo) async {
    try {
      log('📱 调起支付宝支付...');

      final result = await _tobias.pay(orderInfo);

      log('💰 支付宝返回结果: $result');

      return _parseResult(result);
    } catch (e) {
      log('❌ 支付宝支付异常: $e');
      return AlipayResult(
        success: false,
        resultStatus: '-1',
        memo: e.toString(),
      );
    }
  }

  /// 解析支付结果
  AlipayResult _parseResult(Map<dynamic, dynamic> result) {
    final resultStatus = result['resultStatus']?.toString() ?? '';
    final memo = result['memo']?.toString();
    final resultStr = result['result']?.toString();

    // 9000: 订单支付成功
    // 8000: 正在处理中
    // 4000: 订单支付失败
    // 5000: 重复请求
    // 6001: 用户中途取消
    // 6002: 网络连接出错
    // 6004: 支付结果未知

    final success = resultStatus == '9000';

    return AlipayResult(
      success: success,
      resultStatus: resultStatus,
      memo: memo,
      result: resultStr,
    );
  }

  /// 发起支付宝认证 (可选功能)
  Future<AlipayResult> auth(String authInfo) async {
    try {
      final result = await _tobias.auth(authInfo);
      return _parseResult(result);
    } catch (e) {
      log('❌ 支付宝认证异常: $e');
      return AlipayResult(
        success: false,
        resultStatus: '-1',
        memo: e.toString(),
      );
    }
  }
}

/// 支付宝支付结果
class AlipayResult {
  final bool success;
  final String resultStatus;
  final String? memo;
  final String? result;

  AlipayResult({
    required this.success,
    required this.resultStatus,
    this.memo,
    this.result,
  });

  /// 获取用户友好的错误信息
  String get displayMessage {
    switch (resultStatus) {
      case '9000':
        return '支付成功';
      case '8000':
        return '正在处理中，请稍后查询';
      case '4000':
        return '订单支付失败';
      case '5000':
        return '重复请求';
      case '6001':
        return '用户取消支付';
      case '6002':
        return '网络连接出错';
      case '6004':
        return '支付结果未知，请查询订单状态';
      default:
        return memo ?? '支付失败';
    }
  }

  @override
  String toString() =>
      'AlipayResult(success: $success, resultStatus: $resultStatus, memo: $memo)';
}
