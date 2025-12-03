import 'package:df_admin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/membership_level.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/user_membership.dart';

/// 认证用户DTO
class AuthUserDto {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final String role; // 用户角色
  final String? emailVerifiedAt;
  final UserMembershipEmbeddedDto? membership; // 嵌套的会员信息

  AuthUserDto({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    this.role = 'user',
    this.emailVerifiedAt,
    this.membership,
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String? ?? json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'user',
      emailVerifiedAt: json['emailVerifiedAt'] as String?,
      membership: json['membership'] != null 
          ? UserMembershipEmbeddedDto.fromJson(json['membership'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (phone != null) 'phone': phone,
      if (avatar != null) 'avatar': avatar,
      'role': role,
      if (emailVerifiedAt != null) 'emailVerifiedAt': emailVerifiedAt,
      if (membership != null) 'membership': membership!.toJson(),
    };
  }

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      email: email,
      name: name,
      phone: phone,
      avatar: avatar,
      role: role,
      emailVerifiedAt:
          emailVerifiedAt != null ? DateTime.tryParse(emailVerifiedAt!) : null,
      membership: membership?.toDomain(id),
    );
  }

  factory AuthUserDto.fromDomain(AuthUser user) {
    return AuthUserDto(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      avatar: user.avatar,
      role: user.role,
      emailVerifiedAt: user.emailVerifiedAt?.toIso8601String(),
      membership: user.membership != null 
          ? UserMembershipEmbeddedDto.fromDomain(user.membership!)
          : null,
    );
  }
}

/// 嵌套在用户信息中的会员信息 DTO
class UserMembershipEmbeddedDto {
  final int level;
  final String levelName;
  final String? startDate;
  final String? expiryDate;
  final bool autoRenew;
  final int aiUsageThisMonth;
  final int aiUsageLimit;
  final double? moderatorDeposit;
  final bool isActive;
  final bool isExpired;
  final int remainingDays;
  final bool isExpiringSoon;
  final bool canUseAI;
  final bool canApplyModerator;

  UserMembershipEmbeddedDto({
    required this.level,
    required this.levelName,
    this.startDate,
    this.expiryDate,
    this.autoRenew = false,
    this.aiUsageThisMonth = 0,
    this.aiUsageLimit = 0,
    this.moderatorDeposit,
    this.isActive = false,
    this.isExpired = false,
    this.remainingDays = 0,
    this.isExpiringSoon = false,
    this.canUseAI = false,
    this.canApplyModerator = false,
  });

  factory UserMembershipEmbeddedDto.fromJson(Map<String, dynamic> json) {
    return UserMembershipEmbeddedDto(
      level: json['level'] as int? ?? 0,
      levelName: json['levelName'] as String? ?? 'Free',
      startDate: json['startDate'] as String?,
      expiryDate: json['expiryDate'] as String?,
      autoRenew: json['autoRenew'] as bool? ?? false,
      aiUsageThisMonth: json['aiUsageThisMonth'] as int? ?? 0,
      aiUsageLimit: json['aiUsageLimit'] as int? ?? 0,
      moderatorDeposit: (json['moderatorDeposit'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? false,
      isExpired: json['isExpired'] as bool? ?? false,
      remainingDays: json['remainingDays'] as int? ?? 0,
      isExpiringSoon: json['isExpiringSoon'] as bool? ?? false,
      canUseAI: json['canUseAI'] as bool? ?? false,
      canApplyModerator: json['canApplyModerator'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'levelName': levelName,
      'startDate': startDate,
      'expiryDate': expiryDate,
      'autoRenew': autoRenew,
      'aiUsageThisMonth': aiUsageThisMonth,
      'aiUsageLimit': aiUsageLimit,
      'moderatorDeposit': moderatorDeposit,
      'isActive': isActive,
      'isExpired': isExpired,
      'remainingDays': remainingDays,
      'isExpiringSoon': isExpiringSoon,
      'canUseAI': canUseAI,
      'canApplyModerator': canApplyModerator,
    };
  }

  UserMembership toDomain(String userId) {
    return UserMembership(
      userId: userId,
      level: MembershipLevel.fromValue(level),
      startDate: startDate != null ? DateTime.tryParse(startDate!) : null,
      expiryDate: expiryDate != null ? DateTime.tryParse(expiryDate!) : null,
      autoRenew: autoRenew,
      aiUsageThisMonth: aiUsageThisMonth,
      isModerator: false, // 这个字段后端没有直接返回，默认为 false
      moderatorDeposit: moderatorDeposit,
    );
  }

  factory UserMembershipEmbeddedDto.fromDomain(UserMembership membership) {
    return UserMembershipEmbeddedDto(
      level: membership.level.levelValue,
      levelName: membership.level.name,
      startDate: membership.startDate?.toIso8601String(),
      expiryDate: membership.expiryDate?.toIso8601String(),
      autoRenew: membership.autoRenew,
      aiUsageThisMonth: membership.aiUsageThisMonth,
      aiUsageLimit: membership.level.aiUsageLimit,
      moderatorDeposit: membership.moderatorDeposit,
      isActive: membership.isActive,
      isExpired: membership.isExpired,
      remainingDays: membership.remainingDays,
      isExpiringSoon: membership.isExpiringSoon,
      canUseAI: membership.canUseAI,
      canApplyModerator: membership.canApplyModerator,
    );
  }
}
