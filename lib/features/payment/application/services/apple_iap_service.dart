import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/membership/domain/entities/membership_level.dart';
import 'package:go_nomads_app/features/membership/domain/entities/user_membership.dart';
import 'package:go_nomads_app/features/payment/domain/entities/apple_iap_product.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum AppleIapPurchaseState {
  success,
  restored,
  pending,
  cancelled,
  error,
  unavailable,
}

class AppleIapPurchaseResult {
  final AppleIapPurchaseState state;
  final String? productId;
  final MembershipLevel? level;
  final BillingCycle? billingCycle;
  final String? message;
  final PurchaseDetails? purchaseDetails;

  const AppleIapPurchaseResult({
    required this.state,
    this.productId,
    this.level,
    this.billingCycle,
    this.message,
    this.purchaseDetails,
  });

  bool get isSuccess => state == AppleIapPurchaseState.success || state == AppleIapPurchaseState.restored;
}

class AppleIapService extends GetxService {
  AppleIapService({InAppPurchase? inAppPurchase}) : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;

  final RxBool isStoreAvailable = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isPurchaseInProgress = false.obs;
  final RxBool isRestoreInProgress = false.obs;
  final RxMap<String, ProductDetails> products = <String, ProductDetails>{}.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<AppleIapPurchaseResult> lastPurchaseResult = Rxn<AppleIapPurchaseResult>();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Completer<AppleIapPurchaseResult>? _purchaseCompleter;
  String? _pendingProductId;
  bool _initialized = false;

  bool get isSupportedPlatform => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    await initialize();
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    if (!isSupportedPlatform) {
      log('ℹ️ AppleIapService: 当前平台不是 iOS，跳过初始化');
      return;
    }

    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () {
        _purchaseSubscription?.cancel();
      },
      onError: (Object error, StackTrace stackTrace) {
        log('❌ AppleIapService: 购买流异常: $error');
        errorMessage.value = error.toString();
        _completePendingPurchase(
          AppleIapPurchaseResult(
            state: AppleIapPurchaseState.error,
            productId: _pendingProductId,
            message: error.toString(),
          ),
        );
      },
    );

    await refreshProducts();
  }

  Future<void> refreshProducts() async {
    if (!isSupportedPlatform) {
      return;
    }

    isLoadingProducts.value = true;
    errorMessage.value = null;

    try {
      isStoreAvailable.value = await _inAppPurchase.isAvailable();
      if (!isStoreAvailable.value) {
        errorMessage.value = 'App Store 当前不可用';
        products.clear();
        return;
      }

      final response = await _inAppPurchase.queryProductDetails(AppleIapProductCatalog.productIds);

      if (response.error != null) {
        errorMessage.value = response.error!.message;
      }

      if (response.notFoundIDs.isNotEmpty) {
        log('⚠️ AppleIapService: 未找到商品 ${response.notFoundIDs.join(', ')}');
      }

      products
        ..clear()
        ..addEntries(response.productDetails.map((item) => MapEntry(item.id, item)));

      if (products.isEmpty && errorMessage.value == null) {
        errorMessage.value = '未加载到任何 App Store 商品，请检查 App Store Connect 配置或稍后重试';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      log('❌ AppleIapService: 拉取商品失败: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  ProductDetails? getProductForPlan(MembershipLevel level, BillingCycle billingCycle) {
    final mapping = AppleIapProductCatalog.forPlan(level, billingCycle);
    if (mapping == null) {
      return null;
    }
    return products[mapping.productId];
  }

  bool hasProductForPlan(MembershipLevel level, BillingCycle billingCycle) {
    return getProductForPlan(level, billingCycle) != null;
  }

  bool get hasAvailableProducts => products.isNotEmpty;

  String? getDisplayPrice(MembershipLevel level, BillingCycle billingCycle) {
    final product = getProductForPlan(level, billingCycle);
    return product?.price;
  }

  Future<AppleIapPurchaseResult> purchaseMembership({
    required MembershipLevel level,
    required BillingCycle billingCycle,
  }) async {
    await ensureInitialized();

    if (!isSupportedPlatform) {
      return const AppleIapPurchaseResult(
        state: AppleIapPurchaseState.unavailable,
        message: '当前平台不支持 Apple 应用内购买',
      );
    }

    if (!isStoreAvailable.value) {
      await refreshProducts();
    }

    if (!isStoreAvailable.value) {
      return AppleIapPurchaseResult(
        state: AppleIapPurchaseState.unavailable,
        message: errorMessage.value ?? 'App Store 当前不可用',
      );
    }

    final mapping = AppleIapProductCatalog.forPlan(level, billingCycle);
    if (mapping == null) {
      return const AppleIapPurchaseResult(
        state: AppleIapPurchaseState.error,
        message: '未配置对应的 Apple IAP 商品',
      );
    }

    var product = products[mapping.productId];
    if (product == null) {
      await refreshProducts();
      product = products[mapping.productId];
    }

    if (product == null) {
      return AppleIapPurchaseResult(
        state: AppleIapPurchaseState.error,
        productId: mapping.productId,
        level: level,
        billingCycle: billingCycle,
        message: 'App Store 中未找到对应订阅商品: ${mapping.productId}',
      );
    }

    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      return AppleIapPurchaseResult(
        state: AppleIapPurchaseState.pending,
        productId: _pendingProductId,
        message: '已有购买流程正在进行中',
      );
    }

    isPurchaseInProgress.value = true;
    _pendingProductId = mapping.productId;
    _purchaseCompleter = Completer<AppleIapPurchaseResult>();

    try {
      final launched = await _inAppPurchase.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );

      if (!launched) {
        final result = AppleIapPurchaseResult(
          state: AppleIapPurchaseState.error,
          productId: mapping.productId,
          level: level,
          billingCycle: billingCycle,
          message: '未能拉起 App Store 购买流程',
        );
        _completePendingPurchase(result);
        return result;
      }

      return await _purchaseCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          final result = AppleIapPurchaseResult(
            state: AppleIapPurchaseState.error,
            productId: mapping.productId,
            level: level,
            billingCycle: billingCycle,
            message: '购买结果等待超时，请稍后在 App Store 中检查订单状态',
          );
          _completePendingPurchase(result);
          return result;
        },
      );
    } catch (e) {
      final result = AppleIapPurchaseResult(
        state: AppleIapPurchaseState.error,
        productId: mapping.productId,
        level: level,
        billingCycle: billingCycle,
        message: e.toString(),
      );
      _completePendingPurchase(result);
      return result;
    }
  }

  Future<List<AppleIapPurchaseResult>> restoreMembershipPurchases() async {
    await ensureInitialized();

    if (!isSupportedPlatform || !isStoreAvailable.value) {
      return [];
    }

    isRestoreInProgress.value = true;

    try {
      await _inAppPurchase.restorePurchases();
      await Future.delayed(const Duration(seconds: 3));
      final result = <AppleIapPurchaseResult>[];
      final lastResult = lastPurchaseResult.value;
      if (lastResult != null && lastResult.state == AppleIapPurchaseState.restored) {
        result.add(lastResult);
      }
      return result;
    } finally {
      isRestoreInProgress.value = false;
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      final mapping = AppleIapProductCatalog.fromProductId(purchaseDetails.productID);

      AppleIapPurchaseResult? result;

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          log('⏳ AppleIapService: 购买处理中 ${purchaseDetails.productID}');
          break;
        case PurchaseStatus.purchased:
          result = AppleIapPurchaseResult(
            state: AppleIapPurchaseState.success,
            productId: purchaseDetails.productID,
            level: mapping?.level,
            billingCycle: mapping?.billingCycle,
            purchaseDetails: purchaseDetails,
            message: '购买成功，等待会员状态同步',
          );
          break;
        case PurchaseStatus.restored:
          result = AppleIapPurchaseResult(
            state: AppleIapPurchaseState.restored,
            productId: purchaseDetails.productID,
            level: mapping?.level,
            billingCycle: mapping?.billingCycle,
            purchaseDetails: purchaseDetails,
            message: '已恢复购买，等待会员状态同步',
          );
          break;
        case PurchaseStatus.error:
          result = AppleIapPurchaseResult(
            state: AppleIapPurchaseState.error,
            productId: purchaseDetails.productID,
            level: mapping?.level,
            billingCycle: mapping?.billingCycle,
            purchaseDetails: purchaseDetails,
            message: purchaseDetails.error?.message ?? '购买失败',
          );
          break;
        case PurchaseStatus.canceled:
          result = AppleIapPurchaseResult(
            state: AppleIapPurchaseState.cancelled,
            productId: purchaseDetails.productID,
            level: mapping?.level,
            billingCycle: mapping?.billingCycle,
            purchaseDetails: purchaseDetails,
            message: '用户已取消购买',
          );
          break;
      }

      if (result != null) {
        lastPurchaseResult.value = result;
        if (purchaseDetails.productID == _pendingProductId) {
          _completePendingPurchase(result);
        }
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  void _completePendingPurchase(AppleIapPurchaseResult result) {
    lastPurchaseResult.value = result;
    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      _purchaseCompleter!.complete(result);
    }
    _purchaseCompleter = null;
    _pendingProductId = null;
    isPurchaseInProgress.value = false;
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    super.onClose();
  }
}