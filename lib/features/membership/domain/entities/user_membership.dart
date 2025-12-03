import 'package:df_admin_mobile/features/membership/domain/entities/membership_level.dart';

/// 用户会员信息实体
class UserMembership {
  /// 用户ID
  final String userId;

  /// 会员等级
  final MembershipLevel level;

  /// 会员开始日期
  final DateTime? startDate;

  /// 会员到期日期
  final DateTime? expiryDate;

  /// 是否自动续费
  final bool autoRenew;

  /// AI 本月已使用次数
  final int aiUsageThisMonth;

  /// 是否为版主
  final bool isModerator;

  /// 版主保证金已缴纳金额
  final double? moderatorDeposit;

  /// 支付订单号（最近一次）
  final String? lastPaymentId;

  UserMembership({
    required this.userId,
    required this.level,
    this.startDate,
    this.expiryDate,
    this.autoRenew = false,
    this.aiUsageThisMonth = 0,
    this.isModerator = false,
    this.moderatorDeposit,
    this.lastPaymentId,
  });

  /// 是否为付费会员
  bool get isPaidMember => level != MembershipLevel.free;

  /// 会员是否已过期
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// 会员是否有效（付费且未过期）
  bool get isActive => isPaidMember && !isExpired;

  /// 剩余天数
  int get remainingDays {
    if (expiryDate == null) return 0;
    final diff = expiryDate!.difference(DateTime.now());
    return diff.inDays > 0 ? diff.inDays : 0;
  }

  /// 是否即将过期（7天内）
  bool get isExpiringSoon => remainingDays > 0 && remainingDays <= 7;

  /// 是否可以使用 AI
  bool get canUseAI {
    if (!level.canUseAI) return false;
    if (isExpired) return false;
    // 检查使用次数限制
    if (level.aiUsageLimit > 0 && aiUsageThisMonth >= level.aiUsageLimit) {
      return false;
    }
    return true;
  }

  /// 获取 AI 剩余使用次数
  int get aiUsageRemaining {
    if (level.aiUsageLimit < 0) return -1; // 无限制
    return (level.aiUsageLimit - aiUsageThisMonth).clamp(0, level.aiUsageLimit);
  }

  /// 是否可以申请版主
  bool get canApplyModerator {
    if (!level.canApplyModerator) return false;
    if (isExpired) return false;
    return true;
  }

  /// 创建免费会员
  factory UserMembership.free(String userId) {
    return UserMembership(
      userId: userId,
      level: MembershipLevel.free,
    );
  }

  /// 复制并更新
  UserMembership copyWith({
    String? userId,
    MembershipLevel? level,
    DateTime? startDate,
    DateTime? expiryDate,
    bool? autoRenew,
    int? aiUsageThisMonth,
    bool? isModerator,
    double? moderatorDeposit,
    String? lastPaymentId,
  }) {
    return UserMembership(
      userId: userId ?? this.userId,
      level: level ?? this.level,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      autoRenew: autoRenew ?? this.autoRenew,
      aiUsageThisMonth: aiUsageThisMonth ?? this.aiUsageThisMonth,
      isModerator: isModerator ?? this.isModerator,
      moderatorDeposit: moderatorDeposit ?? this.moderatorDeposit,
      lastPaymentId: lastPaymentId ?? this.lastPaymentId,
    );
  }
}
