import 'package:go_nomads_app/features/membership/domain/entities/user_membership.dart';

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

  /// 最新一条旅行历史（从后端返回，用于 Profile 页面显示）
  final LatestTravelHistory? latestTravelHistory;

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
    this.latestTravelHistory,
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

  /// 创建用户副本，支持部分字段更新
  /// 保留原有的 skills、interests 等字段
  User copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? bio,
    String? avatarUrl,
    String? currentCity,
    String? currentCountry,
    List<UserSkillInfo>? skills,
    List<UserInterestInfo>? interests,
    Map<String, String>? socialLinks,
    List<Badge>? badges,
    TravelStats? stats,
    List<TravelHistory>? travelHistory,
    DateTime? joinedDate,
    bool? isVerified,
    UserMembership? membership,
    LatestTravelHistory? latestTravelHistory,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentCity: currentCity ?? this.currentCity,
      currentCountry: currentCountry ?? this.currentCountry,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      socialLinks: socialLinks ?? this.socialLinks,
      badges: badges ?? this.badges,
      stats: stats ?? this.stats,
      travelHistory: travelHistory ?? this.travelHistory,
      joinedDate: joinedDate ?? this.joinedDate,
      isVerified: isVerified ?? this.isVerified,
      membership: membership ?? this.membership,
      latestTravelHistory: latestTravelHistory ?? this.latestTravelHistory,
    );
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

/// Latest Travel History Value Object
/// 最新旅行历史，用于 Profile 页面显示
class LatestTravelHistory {
  final String id;
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;
  final DateTime arrivalTime;
  final DateTime? departureTime;
  final bool isConfirmed;
  final String? cityId;
  final int? durationDays;
  final bool isOngoing;

  LatestTravelHistory({
    required this.id,
    required this.city,
    required this.country,
    this.latitude,
    this.longitude,
    required this.arrivalTime,
    this.departureTime,
    this.isConfirmed = true,
    this.cityId,
    this.durationDays,
    this.isOngoing = false,
  });

  /// 是否可以跳转到城市详情
  bool get canNavigateToCityDetail => cityId != null && cityId!.isNotEmpty;
}
