import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/features/payment/domain/entities/order.dart';
import 'package:go_nomads_app/features/payment/domain/repositories/i_payment_repository.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';

/// 支付仓储实现
class PaymentRepository implements IPaymentRepository {
  final Dio _dio;
  final TokenStorageService _tokenService;

  PaymentRepository({
    required Dio dio,
    required TokenStorageService tokenService,
  })  : _dio = dio,
        _tokenService = tokenService;

  @override
  Future<Order> createOrder({
    required String orderType,
    int? membershipLevel,
    int? durationDays,
    double? depositAmount,
  }) async {
    log('📤 创建订单: orderType=$orderType, level=$membershipLevel');

    try {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.post(
        '${ApiConfig.currentApiBaseUrl}/payments/orders',
        data: {
          'orderType': orderType,
          if (membershipLevel != null) 'membershipLevel': membershipLevel,
          if (durationDays != null) 'durationDays': durationDays,
          if (depositAmount != null) 'depositAmount': depositAmount,
        },
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final order = Order.fromJson(response.data['data'] as Map<String, dynamic>);
        log('✅ 订单创建成功: ${order.orderNumber}');
        return order;
      }

      throw Exception(response.data['message'] ?? '创建订单失败');
    } catch (e) {
      log('❌ 创建订单失败: $e');
      rethrow;
    }
  }

  @override
  Future<PaymentResult> capturePayment({
    required String orderId,
    required String paypalOrderId,
    String? payerId,
  }) async {
    log('💳 确认支付: orderId=$orderId, paypalOrderId=$paypalOrderId');

    try {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.post(
        '${ApiConfig.currentApiBaseUrl}/payments/orders/$orderId/capture',
        data: {
          'payPalOrderId': paypalOrderId,
          if (payerId != null) 'payerId': payerId,
        },
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['data'] != null) {
        final result = PaymentResult.fromJson(response.data['data'] as Map<String, dynamic>);
        log('✅ 支付确认完成: success=${result.success}');
        return result;
      }

      throw Exception(response.data['message'] ?? '确认支付失败');
    } catch (e) {
      log('❌ 确认支付失败: $e');
      rethrow;
    }
  }

  @override
  Future<Order?> getOrder(String orderId) async {
    log('🔍 获取订单详情: $orderId');

    try {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}/payments/orders/$orderId',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return Order.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      log('❌ 获取订单详情失败: $e');
      return null;
    }
  }

  @override
  Future<List<Order>> getOrders({int page = 1, int pageSize = 20}) async {
    log('📋 获取订单列表: page=$page');

    try {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}/payments/orders',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      log('❌ 获取订单列表失败: $e');
      return [];
    }
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    log('❌ 取消订单: $orderId');

    try {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.post(
        '${ApiConfig.currentApiBaseUrl}/payments/orders/$orderId/cancel',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data['success'] == true;
    } catch (e) {
      log('❌ 取消订单失败: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> createWeChatPayOrder({
    required String orderType,
    int? membershipLevel,
    int? durationDays,
    double? depositAmount,
  }) async {
    log('📤 创建微信支付订单: orderType=$orderType, level=$membershipLevel');

    try {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.post(
        '${ApiConfig.currentApiBaseUrl}/payments/orders/wechat',
        data: {
          'orderType': orderType,
          if (membershipLevel != null) 'membershipLevel': membershipLevel,
          if (durationDays != null) 'durationDays': durationDays,
          if (depositAmount != null) 'depositAmount': depositAmount,
        },
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        log('✅ 微信支付订单创建成功');
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception(response.data['message'] ?? '创建微信支付订单失败');
    } catch (e) {
      log('❌ 创建微信支付订单失败: $e');
      rethrow;
    }
  }

  @override
  Future<PaymentResult> confirmWeChatPayment({
    required String orderId,
  }) async {
    log('🔍 确认微信支付结果: orderId=$orderId');

    try {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.post(
        '${ApiConfig.currentApiBaseUrl}/payments/orders/$orderId/wechat-confirm',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['data'] != null) {
        final result = PaymentResult.fromJson(response.data['data'] as Map<String, dynamic>);
        log('✅ 微信支付确认完成: success=${result.success}');
        return result;
      }

      throw Exception(response.data['message'] ?? '确认微信支付失败');
    } catch (e) {
      log('❌ 确认微信支付失败: $e');
      rethrow;
    }
  }
}
