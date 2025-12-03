import 'package:df_admin_mobile/features/membership/domain/entities/membership_level.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/user_membership.dart';

/// 用户会员信息 DTO
class UserMembershipDto {
  final String userId;
  final String level;
  final String? startDate;
  final String? expiryDate;
  final bool autoRenew;
  final int aiUsageThisMonth;
  final bool isModerator;
  final double? moderatorDeposit;
  final String? lastPaymentId;

  UserMembershipDto({
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

  factory UserMembershipDto.fromJson(Map<String, dynamic> json) {
    return UserMembershipDto(
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      level: json['level'] as String? ?? 'free',
      startDate: json['startDate'] as String? ?? json['start_date'] as String?,
      expiryDate: json['expiryDate'] as String? ?? json['expiry_date'] as String?,
      autoRenew: json['autoRenew'] as bool? ?? json['auto_renew'] as bool? ?? false,
      aiUsageThisMonth: json['aiUsageThisMonth'] as int? ?? json['ai_usage_this_month'] as int? ?? 0,
      isModerator: json['isModerator'] as bool? ?? json['is_moderator'] as bool? ?? false,
      moderatorDeposit: (json['moderatorDeposit'] ?? json['moderator_deposit'])?.toDouble(),
      lastPaymentId: json['lastPaymentId'] as String? ?? json['last_payment_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'level': level,
      'startDate': startDate,
      'expiryDate': expiryDate,
      'autoRenew': autoRenew,
      'aiUsageThisMonth': aiUsageThisMonth,
      'isModerator': isModerator,
      'moderatorDeposit': moderatorDeposit,
      'lastPaymentId': lastPaymentId,
    };
  }

  /// 转换为领域实体
  UserMembership toDomain() {
    return UserMembership(
      userId: userId,
      level: _parseLevel(level),
      startDate: startDate != null ? DateTime.tryParse(startDate!) : null,
      expiryDate: expiryDate != null ? DateTime.tryParse(expiryDate!) : null,
      autoRenew: autoRenew,
      aiUsageThisMonth: aiUsageThisMonth,
      isModerator: isModerator,
      moderatorDeposit: moderatorDeposit,
      lastPaymentId: lastPaymentId,
    );
  }

  /// 从领域实体创建 DTO
  factory UserMembershipDto.fromDomain(UserMembership membership) {
    return UserMembershipDto(
      userId: membership.userId,
      level: membership.level.name,
      startDate: membership.startDate?.toIso8601String(),
      expiryDate: membership.expiryDate?.toIso8601String(),
      autoRenew: membership.autoRenew,
      aiUsageThisMonth: membership.aiUsageThisMonth,
      isModerator: membership.isModerator,
      moderatorDeposit: membership.moderatorDeposit,
      lastPaymentId: membership.lastPaymentId,
    );
  }

  static MembershipLevel _parseLevel(String level) {
    switch (level.toLowerCase()) {
      case 'basic':
        return MembershipLevel.basic;
      case 'pro':
        return MembershipLevel.pro;
      case 'premium':
        return MembershipLevel.premium;
      default:
        return MembershipLevel.free;
    }
  }
}
