/// 会员等级枚举
enum MembershipLevel {
  /// 免费用户
  free,

  /// 基础会员 - $49/年
  basic,

  /// 专业会员 - $99/年
  pro,

  /// 高级会员 - $149/年
  premium;

  /// 根据数值获取会员等级
  static MembershipLevel fromValue(int value) {
    switch (value) {
      case 0:
        return MembershipLevel.free;
      case 1:
        return MembershipLevel.basic;
      case 2:
        return MembershipLevel.pro;
      case 3:
        return MembershipLevel.premium;
      default:
        return MembershipLevel.free;
    }
  }
}

/// 会员等级扩展
extension MembershipLevelExtension on MembershipLevel {
  /// 获取等级名称
  String get name {
    switch (this) {
      case MembershipLevel.free:
        return 'Free';
      case MembershipLevel.basic:
        return 'Basic';
      case MembershipLevel.pro:
        return 'Pro';
      case MembershipLevel.premium:
        return 'Premium';
    }
  }

  /// 获取等级描述
  String get description {
    switch (this) {
      case MembershipLevel.free:
        return 'Basic access to the platform';
      case MembershipLevel.basic:
        return 'Essential features for digital nomads';
      case MembershipLevel.pro:
        return 'Advanced features for serious travelers';
      case MembershipLevel.premium:
        return 'Full access to all features';
    }
  }

  /// 获取年费价格
  int get price {
    switch (this) {
      case MembershipLevel.free:
        return 0;
      case MembershipLevel.basic:
        return 49;
      case MembershipLevel.pro:
        return 99;
      case MembershipLevel.premium:
        return 149;
    }
  }

  /// 获取月费价格（按年计算）
  double get monthlyPrice {
    return price / 12;
  }

  /// 获取等级数值（用于比较）
  int get levelValue {
    switch (this) {
      case MembershipLevel.free:
        return 0;
      case MembershipLevel.basic:
        return 1;
      case MembershipLevel.pro:
        return 2;
      case MembershipLevel.premium:
        return 3;
    }
  }

  /// 获取等级图标
  String get icon {
    switch (this) {
      case MembershipLevel.free:
        return '🆓';
      case MembershipLevel.basic:
        return '⭐';
      case MembershipLevel.pro:
        return '💎';
      case MembershipLevel.premium:
        return '👑';
    }
  }

  /// 获取等级颜色（十六进制）
  int get colorValue {
    switch (this) {
      case MembershipLevel.free:
        return 0xFF6B7280;
      case MembershipLevel.basic:
        return 0xFF3B82F6;
      case MembershipLevel.pro:
        return 0xFF8B5CF6;
      case MembershipLevel.premium:
        return 0xFFFF4458;
    }
  }

  /// 是否可以使用 AI 功能
  /// Free 用户也可以使用，但有次数限制
  bool get canUseAI {
    return true; // 所有用户都可以使用 AI，通过 aiUsageLimit 限制次数
  }

  /// 是否可以申请成为版主
  bool get canApplyModerator {
    return levelValue >= MembershipLevel.pro.levelValue;
  }

  /// AI 使用次数限制（每月）
  int get aiUsageLimit {
    switch (this) {
      case MembershipLevel.free:
        return 3; // 免费用户每月3次
      case MembershipLevel.basic:
        return 30; // 基础会员每月30次
      case MembershipLevel.pro:
        return 60; // 专业会员每月60次
      case MembershipLevel.premium:
        return -1; // 高级会员无限制
    }
  }

  /// 获取功能列表
  List<String> get features {
    switch (this) {
      case MembershipLevel.free:
        return [
          'Browse cities and reviews',
          'View coworking spaces',
          'Basic city search',
          'Limited AI features (3/month)',
        ];
      case MembershipLevel.basic:
        return [
          'Everything in Free',
          'AI travel plan generation (30/month)',
          'AI digital nomad guides',
          'Save favorite cities',
          'Create meetups',
          'Join city chats',
        ];
      case MembershipLevel.pro:
        return [
          'Everything in Basic',
          'Extended AI usage (60/month)',
          'Priority AI generation',
          'Apply to become a moderator',
          'Advanced city analytics',
          'Export travel plans',
        ];
      case MembershipLevel.premium:
        return [
          'Everything in Pro',
          'Unlimited AI usage',
          'Early access to new features',
          'Priority support',
          'Custom travel recommendations',
          'API access',
          'No ads',
        ];
    }
  }

  /// 版主保证金金额
  int get moderatorDeposit {
    switch (this) {
      case MembershipLevel.free:
        return 0; // 不能申请
      case MembershipLevel.basic:
        return 0; // 不能申请
      case MembershipLevel.pro:
        return 50; // $50 保证金
      case MembershipLevel.premium:
        return 30; // $30 保证金（优惠）
    }
  }
}
