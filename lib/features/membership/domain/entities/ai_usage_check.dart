import 'package:df_admin_mobile/features/membership/domain/entities/membership_level.dart';

/// AI 使用配额检查结果
class AiUsageCheck {
  /// 是否可以使用 AI
  final bool canUse;

  /// 会员等级
  final MembershipLevel level;

  /// 每月限制次数（-1 表示无限制）
  final int limit;

  /// 本月已使用次数
  final int used;

  /// 剩余可用次数（-1 表示无限制）
  final int remaining;

  /// 是否无限制
  final bool isUnlimited;

  /// 配额重置日期
  final DateTime? resetDate;

  const AiUsageCheck({
    required this.canUse,
    required this.level,
    required this.limit,
    required this.used,
    required this.remaining,
    required this.isUnlimited,
    this.resetDate,
  });

  /// 创建默认（免费用户）
  factory AiUsageCheck.free() {
    return const AiUsageCheck(
      canUse: true,
      level: MembershipLevel.free,
      limit: 3,
      used: 0,
      remaining: 3,
      isUnlimited: false,
    );
  }

  /// 获取使用提示消息
  String get usageMessage {
    if (isUnlimited) {
      return 'Unlimited AI usage';
    }
    if (remaining <= 0) {
      return 'AI usage limit reached ($used/$limit)';
    }
    return '$remaining/$limit AI uses remaining';
  }

  /// 获取升级提示消息
  String get upgradeMessage {
    switch (level) {
      case MembershipLevel.free:
        return 'Upgrade to Basic for 30 AI uses/month';
      case MembershipLevel.basic:
        return 'Upgrade to Pro for 60 AI uses/month';
      case MembershipLevel.pro:
        return 'Upgrade to Premium for unlimited AI';
      case MembershipLevel.premium:
        return 'You have unlimited AI access';
    }
  }

  /// 是否需要显示升级提示（剩余次数少于3次或已用完）
  bool get shouldShowUpgradeHint {
    if (isUnlimited) return false;
    return remaining <= 3;
  }

  @override
  String toString() {
    return 'AiUsageCheck(canUse: $canUse, level: ${level.name}, remaining: $remaining, limit: $limit)';
  }
}
