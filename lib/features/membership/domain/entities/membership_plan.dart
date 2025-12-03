/// 会员计划实体
/// 
/// 从后端 API 获取的会员计划配置信息
class MembershipPlan {
  final String id;
  final int level;
  final String name;
  final String? description;
  final double priceYearly;
  final double priceMonthly;
  final String currency;
  final String? icon;
  final String? color;
  final List<String> features;
  final int aiUsageLimit;
  final bool canUseAI;
  final bool canApplyModerator;
  final double moderatorDeposit;

  const MembershipPlan({
    required this.id,
    required this.level,
    required this.name,
    this.description,
    this.priceYearly = 0,
    this.priceMonthly = 0,
    this.currency = 'USD',
    this.icon,
    this.color,
    this.features = const [],
    this.aiUsageLimit = 0,
    this.canUseAI = false,
    this.canApplyModerator = false,
    this.moderatorDeposit = 0,
  });

  /// 是否为免费计划
  bool get isFree => level == 0;

  /// 是否为付费计划
  bool get isPaid => level > 0;

  /// 获取颜色值 (int)
  int get colorValue {
    if (color == null || color!.isEmpty) {
      return 0xFF6B7280; // 默认灰色
    }
    try {
      final hex = color!.replaceFirst('#', '');
      return int.parse('FF$hex', radix: 16);
    } catch (_) {
      return 0xFF6B7280;
    }
  }

  /// 是否有 AI 使用限制
  bool get hasAiLimit => aiUsageLimit > 0;

  /// AI 使用是否无限制
  bool get hasUnlimitedAi => aiUsageLimit == -1;

  @override
  String toString() => 'MembershipPlan($name, level: $level)';
}
