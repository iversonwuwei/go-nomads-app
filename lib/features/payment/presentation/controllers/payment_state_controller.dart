import 'package:get/get.dart';
import 'package:go_nomads_app/features/payment/domain/entities/order.dart';
import 'package:go_nomads_app/features/payment/domain/repositories/i_payment_repository.dart';

/// 支付状态控制器
class PaymentStateController extends GetxController {
  final IPaymentRepository _paymentRepository;

  PaymentStateController(this._paymentRepository);

  // 状态
  final Rx<Order?> currentOrder = Rx<Order?>(null);
  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<PaymentResult?> lastPaymentResult = Rx<PaymentResult?>(null);

  /// 创建订单并返回支付链接
  Future<Order?> createMembershipOrder({
    required int membershipLevel,
    int durationDays = 365,
    bool isRenewal = false,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final order = await _paymentRepository.createOrder(
        orderType: isRenewal ? 'membership_renew' : 'membership_upgrade',
        membershipLevel: membershipLevel,
        durationDays: durationDays,
      );

      currentOrder.value = order;
      return order;
    } catch (e) {
      errorMessage.value = '创建订单失败: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 创建版主保证金订单
  Future<Order?> createDepositOrder({required double amount}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final order = await _paymentRepository.createOrder(
        orderType: 'moderator_deposit',
        depositAmount: amount,
      );

      currentOrder.value = order;
      return order;
    } catch (e) {
      errorMessage.value = '创建订单失败: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 确认支付
  Future<PaymentResult?> capturePayment({
    required String paypalOrderId,
    String? payerId,
  }) async {
    if (currentOrder.value == null) {
      errorMessage.value = '订单不存在';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _paymentRepository.capturePayment(
        orderId: currentOrder.value!.id,
        paypalOrderId: paypalOrderId,
        payerId: payerId,
      );

      lastPaymentResult.value = result;

      if (result.success) {
        // 刷新订单状态
        await refreshCurrentOrder();
      }

      return result;
    } catch (e) {
      errorMessage.value = '确认支付失败: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 刷新当前订单状态
  Future<void> refreshCurrentOrder() async {
    if (currentOrder.value == null) return;

    try {
      final order = await _paymentRepository.getOrder(currentOrder.value!.id);
      if (order != null) {
        currentOrder.value = order;
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 加载订单列表
  Future<void> loadOrders({int page = 1, bool refresh = false}) async {
    if (refresh) {
      orders.clear();
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _paymentRepository.getOrders(page: page);
      if (refresh) {
        orders.value = result;
      } else {
        orders.addAll(result);
      }
    } catch (e) {
      errorMessage.value = '加载订单失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 取消订单
  Future<bool> cancelOrder() async {
    if (currentOrder.value == null) return false;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final success = await _paymentRepository.cancelOrder(currentOrder.value!.id);
      if (success) {
        await refreshCurrentOrder();
      }
      return success;
    } catch (e) {
      errorMessage.value = '取消订单失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 清除当前订单
  void clearCurrentOrder() {
    currentOrder.value = null;
    lastPaymentResult.value = null;
    errorMessage.value = '';
  }

  /// 创建微信支付订单
  Future<Map<String, dynamic>?> createWeChatPayOrder({
    required int membershipLevel,
    int durationDays = 365,
    bool isRenewal = false,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _paymentRepository.createWeChatPayOrder(
        orderType: isRenewal ? 'membership_renew' : 'membership_upgrade',
        membershipLevel: membershipLevel,
        durationDays: durationDays,
      );
      return result;
    } catch (e) {
      errorMessage.value = '创建微信支付订单失败: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 确认微信支付结果（SDK 回调后调用）
  Future<PaymentResult?> confirmWeChatPayment({
    required String orderId,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _paymentRepository.confirmWeChatPayment(
        orderId: orderId,
      );

      lastPaymentResult.value = result;

      if (result.success) {
        await refreshCurrentOrder();
      }

      return result;
    } catch (e) {
      errorMessage.value = '确认微信支付失败: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 完成 Apple IAP 购买并同步服务端状态
  Future<PaymentResult?> completeAppleIapPurchase({
    required String productId,
    required String transactionId,
    String? originalTransactionId,
    String? verificationData,
    bool isRestore = false,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _paymentRepository.completeAppleIapPurchase(
        productId: productId,
        transactionId: transactionId,
        originalTransactionId: originalTransactionId,
        verificationData: verificationData,
        isRestore: isRestore,
      );

      lastPaymentResult.value = result;
      return result;
    } catch (e) {
      errorMessage.value = '同步 Apple IAP 购买失败: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
