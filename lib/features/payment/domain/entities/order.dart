/// 订单实体
class Order {
  final String id;
  final String orderNumber;
  final String userId;
  final String orderType;
  final String status;
  final double amount;
  final String currency;
  final int? membershipLevel;
  final int? durationDays;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? expiredAt;
  final String? approvalUrl;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.orderType,
    required this.status,
    required this.amount,
    required this.currency,
    this.membershipLevel,
    this.durationDays,
    required this.createdAt,
    this.completedAt,
    this.expiredAt,
    this.approvalUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      userId: json['userId'] as String,
      orderType: json['orderType'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      membershipLevel: json['membershipLevel'] as int?,
      durationDays: json['durationDays'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      expiredAt: json['expiredAt'] != null ? DateTime.parse(json['expiredAt'] as String) : null,
      approvalUrl: json['approvalUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'orderType': orderType,
      'status': status,
      'amount': amount,
      'currency': currency,
      'membershipLevel': membershipLevel,
      'durationDays': durationDays,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'expiredAt': expiredAt?.toIso8601String(),
      'approvalUrl': approvalUrl,
    };
  }

  /// 是否待支付
  bool get isPending => status == 'pending';

  /// 是否处理中
  bool get isProcessing => status == 'processing';

  /// 是否已完成
  bool get isCompleted => status == 'completed';

  /// 是否失败
  bool get isFailed => status == 'failed';

  /// 是否已取消
  bool get isCancelled => status == 'cancelled';

  /// 是否已过期
  bool get isExpired => expiredAt != null && DateTime.now().isAfter(expiredAt!);

  /// 获取状态显示文本
  String get statusText {
    switch (status) {
      case 'pending':
        return '待支付';
      case 'processing':
        return '处理中';
      case 'completed':
        return '已完成';
      case 'failed':
        return '失败';
      case 'cancelled':
        return '已取消';
      case 'refunded':
        return '已退款';
      default:
        return status;
    }
  }
}

/// 支付结果
class PaymentResult {
  final bool success;
  final String orderId;
  final String orderNumber;
  final String status;
  final String? message;
  final String? membershipType;
  final Map<String, dynamic>? membership;

  PaymentResult({
    required this.success,
    required this.orderId,
    required this.orderNumber,
    required this.status,
    this.message,
    this.membershipType,
    this.membership,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    // 从 membership 对象中提取 membershipType
    String? membershipType;
    if (json['membership'] != null) {
      final membership = json['membership'] as Map<String, dynamic>;
      membershipType = _getMembershipTypeName(membership['level'] as int?);
    }

    return PaymentResult(
      success: json['success'] as bool,
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String,
      message: json['message'] as String?,
      membershipType: membershipType,
      membership: json['membership'] as Map<String, dynamic>?,
    );
  }

  /// 根据等级获取会员类型名称
  static String? _getMembershipTypeName(int? level) {
    switch (level) {
      case 1:
        return 'Basic';
      case 2:
        return 'Pro';
      case 3:
        return 'Premium';
      default:
        return null;
    }
  }
}
