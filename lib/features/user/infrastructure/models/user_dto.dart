// import 'package:df_admin_mobile/models/user_model.dart' as legacy; // Legacy model removed
import 'dart:developer';

import 'package:df_admin_mobile/features/membership/domain/entities/membership_level.dart';
import 'package:df_admin_mobile/features/membership/domain/entities/user_membership.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart' as entity;

/// User DTO - 基础设施层数据传输对象
class UserDto {
  final String id;
  final String? name;
  final String? username;
  final String? email;
  final String? bio;
  final String? avatarUrl;
  final String? currentCity;
  final String? currentCountry;
  final List<UserSkillInfoDto> skills;
  final List<UserInterestInfoDto> interests;
  final Map<String, String> socialLinks;
  final List<BadgeDto> badges;
  final TravelStatsDto? stats;
  final List<TravelHistoryDto> travelHistory;
  final DateTime? joinedDate;
  final bool isVerified;

  /// 用户会员信息
  final UserMembershipDto? membership;

  UserDto({
    required this.id,
    this.name,
    this.username,
    this.email,
    this.bio,
    this.avatarUrl,
    this.currentCity,
    this.currentCountry,
    this.skills = const [],
    this.interests = const [],
    this.socialLinks = const {},
    this.badges = const [],
    this.stats,
    this.travelHistory = const [],
    this.joinedDate,
    this.isVerified = false,
    this.membership,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      currentCity: json['currentCity'] as String?,
      currentCountry: json['currentCountry'] as String?,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => UserSkillInfoDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => UserInterestInfoDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      socialLinks: (json['socialLinks'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString())) ?? {},
      badges:
          (json['badges'] as List<dynamic>?)?.map((e) => BadgeDto.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      stats: json['stats'] != null ? TravelStatsDto.fromJson(json['stats'] as Map<String, dynamic>) : null,
      travelHistory: (json['travelHistory'] as List<dynamic>?)
              ?.map((e) => TravelHistoryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      joinedDate: json['joinedDate'] != null ? DateTime.parse(json['joinedDate'] as String) : null,
      isVerified: json['isVerified'] as bool? ?? false,
      membership:
          json['membership'] != null ? UserMembershipDto.fromJson(json['membership'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'currentCity': currentCity,
      'currentCountry': currentCountry,
      'skills': skills.map((e) => e.toJson()).toList(),
      'interests': interests.map((e) => e.toJson()).toList(),
      'socialLinks': socialLinks,
      'badges': badges.map((e) => e.toJson()).toList(),
      'stats': stats?.toJson(),
      'travelHistory': travelHistory.map((e) => e.toJson()).toList(),
      'joinedDate': joinedDate?.toIso8601String(),
      'isVerified': isVerified,
      if (membership != null) 'membership': membership!.toJson(),
    };
  }

  /// 转换为领域实体
  entity.User toDomain() {
    return entity.User(
      id: id,
      name: name ?? '',
      username: username ?? '', // 添加默认值
      email: email,
      bio: bio,
      avatarUrl: avatarUrl,
      currentCity: currentCity,
      currentCountry: currentCountry,
      skills: skills.map((e) => e.toDomain()).toList(),
      interests: interests.map((e) => e.toDomain()).toList(),
      socialLinks: socialLinks,
      badges: badges.map((e) => e.toDomain()).toList(),
      stats: stats?.toDomain() ??
          entity.TravelStats(
            citiesVisited: 0,
            countriesVisited: 0,
            reviewsWritten: 0,
            photosShared: 0,
            totalDistanceTraveled: 0.0,
          ), // 提供默认值
      travelHistory: travelHistory.map((e) => e.toDomain()).toList(),
      joinedDate: joinedDate ?? DateTime.now(),
      isVerified: isVerified,
      membership: membership?.toDomain(),
    );
  }

  /* Legacy model removed - fromLegacyModel method disabled
  /// 从旧模型转换
  factory UserDto.fromLegacyModel(legacy.UserModel model) {
    return UserDto(
      id: model.id,
      name: model.name,
      username: model.username,
      email: model.email,
      bio: model.bio,
      avatarUrl: model.avatarUrl,
      currentCity: model.currentCity,
      currentCountry: model.currentCountry,
      skills: model.skills
          .map((e) => UserSkillInfoDto.fromLegacyModel(e))
          .toList(),
      interests: model.interests
          .map((e) => UserInterestInfoDto.fromLegacyModel(e))
          .toList(),
      socialLinks: model.socialLinks,
      badges:
          model.badges.map((e) => BadgeDto.fromLegacyModel(e)).toList(),
      stats: model.stats != null
          ? TravelStatsDto.fromLegacyModel(model.stats!)
          : null,
      travelHistory: model.travelHistory
          .map((e) => TravelHistoryDto.fromLegacyModel(e))
          .toList(),
      joinedDate: model.joinedDate,
      isVerified: model.isVerified,
    );
  }
  */
}

class UserSkillInfoDto {
  final String id;
  final String name;
  final String level;
  final String? icon;

  UserSkillInfoDto({
    required this.id,
    required this.name,
    required this.level,
    this.icon,
  });

  factory UserSkillInfoDto.fromJson(Map<String, dynamic> json) {
    log('🔍 解析 UserSkillInfo: $json');
    // 优先使用 skillId（技能本身的ID），而不是 id（UserSkill关联记录的ID）
    final id = (json['skillId'] ?? json['SkillId'] ?? json['id']) as String? ?? '';
    final name = (json['name'] ?? json['skillName'] ?? json['SkillName']) as String? ?? '';
    final level = (json['level'] ?? json['proficiencyLevel'] ?? json['ProficiencyLevel']) as String? ?? '';
    final icon = (json['icon'] ?? json['Icon']) as String?;
    log('   ✅ 解析结果: id=$id, name=$name, level=$level, icon=$icon');
    return UserSkillInfoDto(
      id: id,
      name: name,
      level: level,
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      if (icon != null) 'icon': icon,
    };
  }

  entity.UserSkillInfo toDomain() {
    return entity.UserSkillInfo(
      id: id,
      name: name,
      level: level,
      icon: icon,
    );
  }
}

class UserInterestInfoDto {
  final String id;
  final String name;
  final String? icon;

  UserInterestInfoDto({
    required this.id,
    required this.name,
    this.icon,
  });

  factory UserInterestInfoDto.fromJson(Map<String, dynamic> json) {
    log('🔍 解析 UserInterestInfo: $json');
    // 优先使用 interestId（兴趣本身的ID），而不是 id（UserInterest关联记录的ID）
    final id = (json['interestId'] ?? json['InterestId'] ?? json['id']) as String? ?? '';
    final name = (json['name'] ?? json['interestName'] ?? json['InterestName']) as String? ?? '';
    final icon = (json['icon'] ?? json['Icon']) as String?;
    log('   ✅ 解析结果: id=$id, name=$name, icon=$icon');
    return UserInterestInfoDto(
      id: id,
      name: name,
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (icon != null) 'icon': icon,
    };
  }

  entity.UserInterestInfo toDomain() {
    return entity.UserInterestInfo(
      id: id,
      name: name,
      icon: icon,
    );
  }
}

class BadgeDto {
  final String id;
  final String name;
  final String icon;
  final DateTime earnedDate;

  BadgeDto({
    required this.id,
    required this.name,
    required this.icon,
    required this.earnedDate,
  });

  factory BadgeDto.fromJson(Map<String, dynamic> json) {
    return BadgeDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      earnedDate: json['earnedDate'] != null ? DateTime.parse(json['earnedDate'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'earnedDate': earnedDate.toIso8601String(),
    };
  }

  entity.Badge toDomain() {
    return entity.Badge(
      id: id,
      name: name,
      icon: icon,
      description: '', // DTO缺少description字段,使用空字符串
      earnedDate: earnedDate,
    );
  }
}

class TravelStatsDto {
  final int citiesVisited;
  final int countriesVisited;
  final int daysAbroad;
  final int meetupsAttended;

  TravelStatsDto({
    required this.citiesVisited,
    required this.countriesVisited,
    required this.daysAbroad,
    required this.meetupsAttended,
  });

  factory TravelStatsDto.fromJson(Map<String, dynamic> json) {
    return TravelStatsDto(
      citiesVisited: json['citiesVisited'] as int? ?? 0,
      countriesVisited: json['countriesVisited'] as int? ?? 0,
      daysAbroad: json['daysAbroad'] as int? ?? 0,
      meetupsAttended: json['meetupsAttended'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'citiesVisited': citiesVisited,
      'countriesVisited': countriesVisited,
      'daysAbroad': daysAbroad,
      'meetupsAttended': meetupsAttended,
    };
  }

  entity.TravelStats toDomain() {
    return entity.TravelStats(
      citiesVisited: citiesVisited,
      countriesVisited: countriesVisited,
      reviewsWritten: 0, // DTO缺少此字段,使用默认值
      photosShared: 0, // DTO缺少此字段,使用默认值
      totalDistanceTraveled: 0.0, // DTO缺少此字段,使用默认值
    );
  }
}

class TravelHistoryDto {
  final String city;
  final String country;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;

  TravelHistoryDto({
    required this.city,
    required this.country,
    required this.startDate,
    this.endDate,
    this.notes,
  });

  factory TravelHistoryDto.fromJson(Map<String, dynamic> json) {
    return TravelHistoryDto(
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
    };
  }

  entity.TravelHistory toDomain() {
    return entity.TravelHistory(
      cityId: '', // DTO缺少cityId,使用空字符串
      cityName: city, // DTO的city字段映射到cityName
      countryName: country, // DTO的country字段映射到countryName
      visitDate: startDate, // DTO的startDate映射到visitDate
      durationDays: endDate?.difference(startDate).inDays, // 计算持续天数
    );
  }
}

/// 用户会员信息 DTO
/// 用于解析后端 /users/me 接口返回的嵌套会员信息
class UserMembershipDto {
  final int level;
  final String levelName;
  final DateTime? startDate;
  final DateTime? expiryDate;
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

  UserMembershipDto({
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

  factory UserMembershipDto.fromJson(Map<String, dynamic> json) {
    return UserMembershipDto(
      level: json['level'] as int? ?? 0,
      levelName: json['levelName'] as String? ?? 'Free',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate'] as String) : null,
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
      'startDate': startDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
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

  /// 转换为领域实体
  UserMembership toDomain() {
    return UserMembership(
      userId: '', // 会在上层填充
      level: MembershipLevel.fromValue(level),
      startDate: startDate,
      expiryDate: expiryDate,
      autoRenew: autoRenew,
      aiUsageThisMonth: aiUsageThisMonth,
      moderatorDeposit: moderatorDeposit,
    );
  }
}
