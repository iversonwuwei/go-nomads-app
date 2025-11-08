// import '../../../../models/user_model.dart' as legacy; // Legacy model removed
import '../../domain/entities/user.dart';

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
              ?.map((e) =>
                  UserInterestInfoDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      socialLinks: (json['socialLinks'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => BadgeDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      stats: json['stats'] != null
          ? TravelStatsDto.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      travelHistory: (json['travelHistory'] as List<dynamic>?)
              ?.map((e) => TravelHistoryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      joinedDate: json['joinedDate'] != null
          ? DateTime.parse(json['joinedDate'] as String)
          : null,
      isVerified: json['isVerified'] as bool? ?? false,
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
    };
  }

  /// 转换为领域实体
  User toDomain() {
    return User(
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
          TravelStats(
            citiesVisited: 0,
            countriesVisited: 0,
            reviewsWritten: 0,
            photosShared: 0,
            totalDistanceTraveled: 0.0,
          ), // 提供默认值
      travelHistory: travelHistory.map((e) => e.toDomain()).toList(),
      joinedDate: joinedDate ?? DateTime.now(),
      isVerified: isVerified,
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
  final String name;
  final String level;

  UserSkillInfoDto({
    required this.name,
    required this.level,
  });

  factory UserSkillInfoDto.fromJson(Map<String, dynamic> json) {
    return UserSkillInfoDto(
      name: json['name'] as String? ?? '',
      level: json['level'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
    };
  }

  UserSkillInfo toDomain() {
    return UserSkillInfo(
      id: '', // DTO缺少id字段,使用空字符串
      name: name,
      level: level,
    );
  }
}

class UserInterestInfoDto {
  final String name;

  UserInterestInfoDto({
    required this.name,
  });

  factory UserInterestInfoDto.fromJson(Map<String, dynamic> json) {
    return UserInterestInfoDto(
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  UserInterestInfo toDomain() {
    return UserInterestInfo(
      id: '', // DTO缺少id字段,使用空字符串
      name: name,
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
      earnedDate: json['earnedDate'] != null
          ? DateTime.parse(json['earnedDate'] as String)
          : DateTime.now(),
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

  Badge toDomain() {
    return Badge(
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

  TravelStats toDomain() {
    return TravelStats(
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
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
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

  TravelHistory toDomain() {
    return TravelHistory(
      cityId: '', // DTO缺少cityId,使用空字符串
      cityName: city, // DTO的city字段映射到cityName
      countryName: country, // DTO的country字段映射到countryName
      visitDate: startDate, // DTO的startDate映射到visitDate
      durationDays: endDate?.difference(startDate).inDays, // 计算持续天数
    );
  }
}
