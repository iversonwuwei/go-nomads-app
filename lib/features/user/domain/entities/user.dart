import 'package:df_admin_mobile/features/membership/domain/entities/user_membership.dart';

/// User Domain Entity
///
/// 纯粹的领域对象,不包含序列化逻辑
class User {
  final String id;
  final String name;
  final String username;
  final String? email;
  final String? bio;
  final String? avatarUrl;
  final String? currentCity;
  final String? currentCountry;
  final List<UserSkillInfo> skills;
  final List<UserInterestInfo> interests;
  final Map<String, String> socialLinks;
  final List<Badge> badges;
  final TravelStats stats;
  final List<TravelHistory> travelHistory;
  final DateTime joinedDate;
  final bool isVerified;

  /// 用户会员信息（从 /users/me 接口获取）
  final UserMembership? membership;

  User({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    this.bio,
    this.avatarUrl,
    this.currentCity,
    this.currentCountry,
    this.skills = const [],
    this.interests = const [],
    this.socialLinks = const {},
    this.badges = const [],
    required this.stats,
    this.travelHistory = const [],
    required this.joinedDate,
    this.isVerified = false,
    this.membership,
  });

  // 业务逻辑方法
  bool get hasCompletedProfile => bio != null && avatarUrl != null && currentCity != null;

  bool get isActiveNomad => stats.citiesVisited > 0;

  int get experienceLevel {
    final visited = stats.citiesVisited;
    if (visited >= 50) return 5; // Expert
    if (visited >= 20) return 4; // Advanced
    if (visited >= 10) return 3; // Intermediate
    if (visited >= 5) return 2; // Beginner
    return 1; // Newbie
  }
}

/// User Skill Info Value Object
class UserSkillInfo {
  final String id;
  final String name;
  final String level;
  final String? icon;

  UserSkillInfo({
    required this.id,
    required this.name,
    required this.level,
    this.icon,
  });

  bool get hasIcon => icon != null && icon!.isNotEmpty;
}

/// User Interest Info Value Object
class UserInterestInfo {
  final String id;
  final String name;
  final String? icon;

  UserInterestInfo({
    required this.id,
    required this.name,
    this.icon,
  });

  bool get hasIcon => icon != null && icon!.isNotEmpty;
}

/// Badge Value Object
class Badge {
  final String id;
  final String name;
  final String icon;
  final String description;
  final DateTime earnedDate;

  Badge({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.earnedDate,
  });
}

/// Travel Stats Value Object
class TravelStats {
  final int citiesVisited;
  final int countriesVisited;
  final int reviewsWritten;
  final int photosShared;
  final double totalDistanceTraveled;

  TravelStats({
    required this.citiesVisited,
    required this.countriesVisited,
    required this.reviewsWritten,
    required this.photosShared,
    required this.totalDistanceTraveled,
  });
}

/// Travel History Value Object
class TravelHistory {
  final String cityId;
  final String cityName;
  final String? countryName;
  final DateTime visitDate;
  final int? durationDays;

  TravelHistory({
    required this.cityId,
    required this.cityName,
    this.countryName,
    required this.visitDate,
    this.durationDays,
  });
}
