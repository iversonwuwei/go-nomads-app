// import 'package:df_admin_mobile/models/user_profile_models.dart' as legacy; // Legacy model removed
import 'package:df_admin_mobile/features/user_profile/domain/entities/user_profile.dart'
    as domain;

/// UserProfile DTO - 基础设施层数据传输对象
/// 完整的用户档案数据传输对象,包含所有数据库字段
class UserProfileDto {
  final int? id;
  final int accountId;
  final UserBasicInfoDto basicInfo;
  final NomadStatsDto stats;
  final List<UserSkillDto> skills;
  final List<UserInterestDto> interests;
  final List<SocialLinkDto> socialLinks;
  final List<UserBadgeDto> badges;
  final List<TravelHistoryEntryDto> travelHistory;
  final String createdAt;
  final String updatedAt;

  UserProfileDto({
    this.id,
    required this.accountId,
    required this.basicInfo,
    required this.stats,
    required this.skills,
    required this.interests,
    required this.socialLinks,
    required this.badges,
    required this.travelHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'basic_info': basicInfo.toMap(),
      'stats': stats.toMap(),
      'skills': skills.map((e) => e.toMap()).toList(),
      'interests': interests.map((e) => e.toMap()).toList(),
      'social_links': socialLinks.map((e) => e.toMap()).toList(),
      'badges': badges.map((e) => e.toMap()).toList(),
      'travel_history': travelHistory.map((e) => e.toMap()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory UserProfileDto.fromMap(Map<String, dynamic> map) {
    return UserProfileDto(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      basicInfo:
          UserBasicInfoDto.fromMap(map['basic_info'] as Map<String, dynamic>),
      stats: NomadStatsDto.fromMap(map['stats'] as Map<String, dynamic>),
      skills: (map['skills'] as List<dynamic>)
          .map((e) => UserSkillDto.fromMap(e as Map<String, dynamic>))
          .toList(),
      interests: (map['interests'] as List<dynamic>)
          .map((e) => UserInterestDto.fromMap(e as Map<String, dynamic>))
          .toList(),
      socialLinks: (map['social_links'] as List<dynamic>)
          .map((e) => SocialLinkDto.fromMap(e as Map<String, dynamic>))
          .toList(),
      badges: (map['badges'] as List<dynamic>)
          .map((e) => UserBadgeDto.fromMap(e as Map<String, dynamic>))
          .toList(),
      travelHistory: (map['travel_history'] as List<dynamic>)
          .map((e) => TravelHistoryEntryDto.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  /// 转换为领域实体
  domain.UserProfile toDomain() {
    return domain.UserProfile(
      id: id,
      accountId: accountId,
      basicInfo: basicInfo.toDomain(),
      stats: stats.toDomain(),
      skills: skills.map((e) => e.toDomain()).toList(),
      interests: interests.map((e) => e.toDomain()).toList(),
      socialLinks: socialLinks.map((e) => e.toDomain()).toList(),
      badges: badges.map((e) => e.toDomain()).toList(),
      travelHistory: travelHistory.map((e) => e.toDomain()).toList(),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}

/// UserBasicInfo DTO
class UserBasicInfoDto {
  final int? id;
  final int accountId;
  final String name;
  final String? bio;
  final String? avatarUrl;
  final String? currentCity;
  final String? currentCountry;
  final String? birthDate;
  final String? gender;
  final String? occupation;
  final String? company;
  final String? website;
  final String createdAt;
  final String updatedAt;

  UserBasicInfoDto({
    this.id,
    required this.accountId,
    required this.name,
    this.bio,
    this.avatarUrl,
    this.currentCity,
    this.currentCountry,
    this.birthDate,
    this.gender,
    this.occupation,
    this.company,
    this.website,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'name': name,
      'bio': bio,
      'avatar_url': avatarUrl,
      'current_city': currentCity,
      'current_country': currentCountry,
      'birth_date': birthDate,
      'gender': gender,
      'occupation': occupation,
      'company': company,
      'website': website,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory UserBasicInfoDto.fromMap(Map<String, dynamic> map) {
    return UserBasicInfoDto(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      name: map['name'] as String,
      bio: map['bio'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      currentCity: map['current_city'] as String?,
      currentCountry: map['current_country'] as String?,
      birthDate: map['birth_date'] as String?,
      gender: map['gender'] as String?,
      occupation: map['occupation'] as String?,
      company: map['company'] as String?,
      website: map['website'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  domain.BasicInfo toDomain() {
    return domain.BasicInfo(
      name: name,
      bio: bio,
      avatarUrl: avatarUrl,
      currentCity: currentCity,
      currentCountry: currentCountry,
      birthDate: birthDate != null ? DateTime.tryParse(birthDate!) : null,
      gender: domain.Gender.fromString(gender),
      occupation: occupation,
      company: company,
      website: website,
    );
  }
}

/// NomadStats DTO
class NomadStatsDto {
  final int? id;
  final int accountId;
  final int countriesVisited;
  final int citiesLived;
  final int daysNomading;
  final int meetupsAttended;
  final int tripsCompleted;
  final int reviewsWritten;
  final String createdAt;
  final String updatedAt;

  NomadStatsDto({
    this.id,
    required this.accountId,
    this.countriesVisited = 0,
    this.citiesLived = 0,
    this.daysNomading = 0,
    this.meetupsAttended = 0,
    this.tripsCompleted = 0,
    this.reviewsWritten = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'countries_visited': countriesVisited,
      'cities_lived': citiesLived,
      'days_nomading': daysNomading,
      'meetups_attended': meetupsAttended,
      'trips_completed': tripsCompleted,
      'reviews_written': reviewsWritten,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory NomadStatsDto.fromMap(Map<String, dynamic> map) {
    return NomadStatsDto(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      countriesVisited: map['countries_visited'] as int? ?? 0,
      citiesLived: map['cities_lived'] as int? ?? 0,
      daysNomading: map['days_nomading'] as int? ?? 0,
      meetupsAttended: map['meetups_attended'] as int? ?? 0,
      tripsCompleted: map['trips_completed'] as int? ?? 0,
      reviewsWritten: map['reviews_written'] as int? ?? 0,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  domain.NomadStatistics toDomain() {
    return domain.NomadStatistics(
      countriesVisited: countriesVisited,
      citiesLived: citiesLived,
      daysNomading: daysNomading,
      meetupsAttended: meetupsAttended,
      tripsCompleted: tripsCompleted,
      reviewsWritten: reviewsWritten,
    );
  }

  NomadStatsDto copyWith({
    int? countriesVisited,
    int? citiesLived,
    int? daysNomading,
    int? meetupsAttended,
    int? tripsCompleted,
    int? reviewsWritten,
  }) {
    return NomadStatsDto(
      id: id,
      accountId: accountId,
      countriesVisited: countriesVisited ?? this.countriesVisited,
      citiesLived: citiesLived ?? this.citiesLived,
      daysNomading: daysNomading ?? this.daysNomading,
      meetupsAttended: meetupsAttended ?? this.meetupsAttended,
      tripsCompleted: tripsCompleted ?? this.tripsCompleted,
      reviewsWritten: reviewsWritten ?? this.reviewsWritten,
      createdAt: createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }
}

/// UserSkill DTO
class UserSkillDto {
  final int? id;
  final int accountId;
  final String skillName;
  final String createdAt;

  UserSkillDto({
    this.id,
    required this.accountId,
    required this.skillName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'skill_name': skillName,
      'created_at': createdAt,
    };
  }

  factory UserSkillDto.fromMap(Map<String, dynamic> map) {
    return UserSkillDto(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      skillName: map['skill_name'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  domain.Skill toDomain() {
    return domain.Skill(
      name: skillName,
      createdAt: DateTime.parse(createdAt),
    );
  }
}

/// UserInterest DTO
class UserInterestDto {
  final int? id;
  final int accountId;
  final String interestName;
  final String createdAt;

  UserInterestDto({
    this.id,
    required this.accountId,
    required this.interestName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'interest_name': interestName,
      'created_at': createdAt,
    };
  }

  factory UserInterestDto.fromMap(Map<String, dynamic> map) {
    return UserInterestDto(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      interestName: map['interest_name'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  domain.Interest toDomain() {
    return domain.Interest(
      name: interestName,
      createdAt: DateTime.parse(createdAt),
    );
  }
}

/// SocialLink DTO
class SocialLinkDto {
  final int? id;
  final int accountId;
  final String platform;
  final String url;
  final String createdAt;
  final String updatedAt;

  SocialLinkDto({
    this.id,
    required this.accountId,
    required this.platform,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'platform': platform,
      'url': url,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory SocialLinkDto.fromMap(Map<String, dynamic> map) {
    return SocialLinkDto(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      platform: map['platform'] as String,
      url: map['url'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  domain.SocialLink toDomain() {
    return domain.SocialLink(
      platform: platform,
      url: url,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}

/// UserBadge DTO
class UserBadgeDto {
  final int? id;
  final int accountId;
  final String badgeId;
  final String badgeName;
  final String? badgeIcon;
  final String? description;
  final String earnedDate;
  final String createdAt;

  UserBadgeDto({
    this.id,
    required this.accountId,
    required this.badgeId,
    required this.badgeName,
    this.badgeIcon,
    this.description,
    required this.earnedDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'badge_id': badgeId,
      'badge_name': badgeName,
      'badge_icon': badgeIcon,
      'description': description,
      'earned_date': earnedDate,
      'created_at': createdAt,
    };
  }

  factory UserBadgeDto.fromMap(Map<String, dynamic> map) {
    return UserBadgeDto(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      badgeId: map['badge_id'] as String,
      badgeName: map['badge_name'] as String,
      badgeIcon: map['badge_icon'] as String?,
      description: map['description'] as String?,
      earnedDate: map['earned_date'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  domain.UserBadge toDomain() {
    return domain.UserBadge(
      badgeId: badgeId,
      name: badgeName,
      icon: badgeIcon,
      description: description,
      earnedDate: DateTime.parse(earnedDate),
    );
  }
}

/// TravelHistoryEntry DTO
class TravelHistoryEntryDto {
  final int? id;
  final int accountId;
  final String city;
  final String country;
  final String startDate;
  final String? endDate;
  final String? review;
  final double? rating;
  final String? photos; // JSON数组存储照片URLs
  final String createdAt;
  final String updatedAt;

  TravelHistoryEntryDto({
    this.id,
    required this.accountId,
    required this.city,
    required this.country,
    required this.startDate,
    this.endDate,
    this.review,
    this.rating,
    this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'city': city,
      'country': country,
      'start_date': startDate,
      'end_date': endDate,
      'review': review,
      'rating': rating,
      'photos': photos,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory TravelHistoryEntryDto.fromMap(Map<String, dynamic> map) {
    return TravelHistoryEntryDto(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      city: map['city'] as String,
      country: map['country'] as String,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String?,
      review: map['review'] as String?,
      rating: map['rating'] as double?,
      photos: map['photos'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  domain.TravelHistoryEntry toDomain() {
    // 解析photos JSON字符串为List
    List<String> photoList = [];
    // photos是JSON字符串,保持简单处理,实际应使用json.decode
    // 这里只是为了保持与legacy model的一致性

    return domain.TravelHistoryEntry(
      city: city,
      country: country,
      startDate: DateTime.parse(startDate),
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
      review: review,
      rating: rating,
      photos: photoList, // 简化处理,实际应解析photos字符串
    );
  }
}

/// TravelPlan DTO (用于user_profile_models.dart中的TravelPlan)
class UserTravelPlanDto {
  final int? id;
  final int accountId;
  final String title;
  final String destination;
  final String? startDate;
  final String? endDate;
  final String? description;
  final String? itinerary;
  final String? budget;
  final String? accommodation;
  final String? transportation;
  final String status;
  final String createdAt;
  final String updatedAt;

  UserTravelPlanDto({
    this.id,
    required this.accountId,
    required this.title,
    required this.destination,
    this.startDate,
    this.endDate,
    this.description,
    this.itinerary,
    this.budget,
    this.accommodation,
    this.transportation,
    this.status = 'planning',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'title': title,
      'destination': destination,
      'start_date': startDate,
      'end_date': endDate,
      'description': description,
      'itinerary': itinerary,
      'budget': budget,
      'accommodation': accommodation,
      'transportation': transportation,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory UserTravelPlanDto.fromMap(Map<String, dynamic> map) {
    return UserTravelPlanDto(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      title: map['title'] as String,
      destination: map['destination'] as String,
      startDate: map['start_date'] as String?,
      endDate: map['end_date'] as String?,
      description: map['description'] as String?,
      itinerary: map['itinerary'] as String?,
      budget: map['budget'] as String?,
      accommodation: map['accommodation'] as String?,
      transportation: map['transportation'] as String?,
      status: map['status'] as String? ?? 'planning',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}
