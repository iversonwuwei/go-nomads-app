import 'package:df_admin_mobile/features/payment/domain/entities/order.dart';

/// 支付仓储接口
abstract class IPaymentRepository {
  /// 创建订单
  Future<Order> createOrder({
    required String orderType,
    int? membershipLevel,
    int? durationDays,
    double? depositAmount,
  });

  /// 确认支付
  Future<PaymentResult> capturePayment({
    required String orderId,
    required String paypalOrderId,
    String? payerId,
  });

  /// 获取订单详情
  Future<Order?> getOrder(String orderId);

  /// 获取用户订单列表
  Future<List<Order>> getOrders({int page = 1, int pageSize = 20});

  /// 取消订单
  Future<bool> cancelOrder(String orderId);

  /// 创建微信支付订单
  Future<Map<String, dynamic>> createWeChatPayOrder({
    required String orderType,
    int? membershipLevel,
    int? durationDays,
    double? depositAmount,
  });

  /// 创建支付宝订单
  Future<Map<String, dynamic>> createAlipayOrder({
    required String orderType,
    int? membershipLevel,
    int? durationDays,
    double? depositAmount,
  });
}
