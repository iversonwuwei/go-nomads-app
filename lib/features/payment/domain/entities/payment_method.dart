import 'package:flutter/foundation.dart';

/// 支付方式枚举
enum PaymentMethod {
  paypal,
  wechat,
}

/// PaymentMethod 扩展方法
extension PaymentMethodExtension on PaymentMethod {
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.wechat:
        return 'WeChat Pay';
    }
  }

  /// 获取图标资源路径
  String get iconPath {
    switch (this) {
      case PaymentMethod.paypal:
        return 'assets/icons/paypal.png';
      case PaymentMethod.wechat:
        return 'assets/icons/wechat_pay.png';
    }
  }

  /// 获取服务端 API 值
  String get apiValue {
    switch (this) {
      case PaymentMethod.paypal:
        return 'paypal';
      case PaymentMethod.wechat:
        return 'wechat';
    }
  }

  /// 是否当前平台可用
  bool get isAvailable {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return false;
    }

    switch (this) {
      case PaymentMethod.paypal:
        return true;
      case PaymentMethod.wechat:
        return true; // 需要配置后才可用
    }
  }
}
