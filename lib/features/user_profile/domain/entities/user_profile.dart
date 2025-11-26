/// 用户档案聚合根 - 完整的用户画像
/// 整合了用户基本信息、游牧统计、技能、兴趣等所有用户相关数据
class UserProfile {
  final int? id;
  final int accountId;
  final BasicInfo basicInfo;
  final NomadStatistics stats;
  final List<Skill> skills;
  final List<Interest> interests;
  final List<SocialLink> socialLinks;
  final List<UserBadge> badges;
  final List<TravelHistoryEntry> travelHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
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

  // === 业务逻辑方法 ===

  /// 检查档案是否完整
  bool get isProfileComplete {
    return basicInfo.hasBasicInfo &&
        basicInfo.hasLocation &&
        skills.isNotEmpty &&
        interests.isNotEmpty;
  }

  /// 获取档案完成度 (0-100)
  int get profileCompleteness {
    int score = 0;

    // 基本信息 (30分)
    if (basicInfo.name.isNotEmpty) score += 10;
    if (basicInfo.bio != null && basicInfo.bio!.isNotEmpty) score += 10;
    if (basicInfo.avatarUrl != null) score += 10;

    // 位置信息 (10分)
    if (basicInfo.hasLocation) score += 10;

    // 职业信息 (10分)
    if (basicInfo.occupation != null) score += 5;
    if (basicInfo.company != null) score += 5;

    // 技能和兴趣 (20分)
    if (skills.isNotEmpty) score += 10;
    if (interests.isNotEmpty) score += 10;

    // 社交链接 (10分)
    if (socialLinks.isNotEmpty) score += 10;

    // 旅行经历 (10分)
    if (travelHistory.isNotEmpty) score += 10;

    // 徽章 (10分)
    if (badges.isNotEmpty) score += 10;

    return score;
  }

  /// 是否是活跃的数字游民
  bool get isActiveNomad {
    return stats.daysNomading > 30 &&
        stats.citiesLived >= 2 &&
        travelHistory.isNotEmpty;
  }

  /// 获取游牧等级
  NomadLevel get nomadLevel {
    final citiesCount = stats.citiesLived;
    final countriesCount = stats.countriesVisited;
    final days = stats.daysNomading;

    if (citiesCount >= 20 || countriesCount >= 10 || days >= 365) {
      return NomadLevel.expert;
    } else if (citiesCount >= 10 || countriesCount >= 5 || days >= 180) {
      return NomadLevel.advanced;
    } else if (citiesCount >= 5 || countriesCount >= 3 || days >= 90) {
      return NomadLevel.intermediate;
    } else if (citiesCount >= 2 || countriesCount >= 1 || days >= 30) {
      return NomadLevel.beginner;
    } else {
      return NomadLevel.newbie;
    }
  }

  /// 检查是否有特定技能
  bool hasSkill(String skillName) {
    return skills.any((s) => s.name.toLowerCase() == skillName.toLowerCase());
  }

  /// 检查是否有特定兴趣
  bool hasInterest(String interestName) {
    return interests
        .any((i) => i.name.toLowerCase() == interestName.toLowerCase());
  }

  /// 获取特定平台的社交链接
  SocialLink? getSocialLink(String platform) {
    try {
      return socialLinks.firstWhere(
        (link) => link.platform.toLowerCase() == platform.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// 检查是否访问过特定城市
  bool hasVisitedCity(String cityName) {
    return travelHistory.any(
      (entry) => entry.city.toLowerCase() == cityName.toLowerCase(),
    );
  }

  /// 获取访问过的国家列表
  List<String> get visitedCountries {
    return travelHistory.map((entry) => entry.country).toSet().toList();
  }

  /// 获取访问过的城市列表
  List<String> get visitedCities {
    return travelHistory.map((entry) => entry.city).toSet().toList();
  }

  /// 检查是否获得特定徽章
  bool hasBadge(String badgeId) {
    return badges.any((badge) => badge.badgeId == badgeId);
  }

  /// 获取最近的旅行记录
  TravelHistoryEntry? get latestTravel {
    if (travelHistory.isEmpty) return null;
    final sorted = List<TravelHistoryEntry>.from(travelHistory)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return sorted.first;
  }
}

/// 基本信息值对象
class BasicInfo {
  final String name;
  final String? bio;
  final String? avatarUrl;
  final String? currentCity;
  final String? currentCountry;
  final DateTime? birthDate;
  final Gender? gender;
  final String? occupation;
  final String? company;
  final String? website;

  BasicInfo({
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
  });

  /// 是否有基本信息
  bool get hasBasicInfo => name.isNotEmpty && bio != null && avatarUrl != null;

  /// 是否有位置信息
  bool get hasLocation => currentCity != null && currentCountry != null;

  /// 是否有职业信息
  bool get hasOccupation => occupation != null || company != null;

  /// 获取年龄
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// 获取完整位置描述
  String? get fullLocation {
    if (!hasLocation) return null;
    return '$currentCity, $currentCountry';
  }
}

/// 性别枚举
enum Gender {
  male,
  female,
  other,
  preferNotToSay;

  static Gender? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'male':
      case 'm':
        return Gender.male;
      case 'female':
      case 'f':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.preferNotToSay;
    }
  }

  @override
  String toString() {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}

/// 游牧统计值对象
class NomadStatistics {
  final int countriesVisited;
  final int citiesLived;
  final int daysNomading;
  final int meetupsAttended;
  final int tripsCompleted;
  final int reviewsWritten;

  NomadStatistics({
    this.countriesVisited = 0,
    this.citiesLived = 0,
    this.daysNomading = 0,
    this.meetupsAttended = 0,
    this.tripsCompleted = 0,
    this.reviewsWritten = 0,
  });

  /// 是否有旅行经验
  bool get hasTravelExperience => countriesVisited > 0 || citiesLived > 0;

  /// 是否活跃参与社区
  bool get isActiveCommunityMember =>
      meetupsAttended >= 5 || reviewsWritten >= 3;

  /// 获取总活跃度分数
  int get activityScore {
    return (countriesVisited * 10) +
        (citiesLived * 15) +
        (daysNomading ~/ 7) + // 每周1分
        (meetupsAttended * 5) +
        (tripsCompleted * 20) +
        (reviewsWritten * 10);
  }

  /// 平均每次旅行天数
  double get averageTripDuration {
    if (tripsCompleted == 0) return 0;
    return daysNomading / tripsCompleted;
  }
}

/// 游牧等级枚举
enum NomadLevel {
  newbie, // 新手 (0-2城市)
  beginner, // 初学者 (2-5城市)
  intermediate, // 中级 (5-10城市)
  advanced, // 高级 (10-20城市)
  expert; // 专家 (20+城市)

  String get displayName {
    switch (this) {
      case NomadLevel.newbie:
        return 'Newbie Nomad';
      case NomadLevel.beginner:
        return 'Beginner Nomad';
      case NomadLevel.intermediate:
        return 'Intermediate Nomad';
      case NomadLevel.advanced:
        return 'Advanced Nomad';
      case NomadLevel.expert:
        return 'Expert Nomad';
    }
  }

  String get emoji {
    switch (this) {
      case NomadLevel.newbie:
        return '🌱';
      case NomadLevel.beginner:
        return '🎒';
      case NomadLevel.intermediate:
        return '✈️';
      case NomadLevel.advanced:
        return '🌍';
      case NomadLevel.expert:
        return '🏆';
    }
  }
}

/// 技能值对象
class Skill {
  final String name;
  final DateTime createdAt;

  Skill({
    required this.name,
    required this.createdAt,
  });
}

/// 兴趣值对象
class Interest {
  final String name;
  final DateTime createdAt;

  Interest({
    required this.name,
    required this.createdAt,
  });
}

/// 社交链接值对象
class SocialLink {
  final String platform;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;

  SocialLink({
    required this.platform,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 验证URL格式
  bool get isValidUrl {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 获取平台显示名称
  String get platformDisplayName {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return 'Instagram';
      case 'twitter':
      case 'x':
        return 'X (Twitter)';
      case 'linkedin':
        return 'LinkedIn';
      case 'github':
        return 'GitHub';
      case 'facebook':
        return 'Facebook';
      case 'youtube':
        return 'YouTube';
      case 'tiktok':
        return 'TikTok';
      default:
        return platform.substring(0, 1).toUpperCase() + platform.substring(1);
    }
  }

  /// 获取平台图标
  String get platformIcon {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return '📷';
      case 'twitter':
      case 'x':
        return '🐦';
      case 'linkedin':
        return '💼';
      case 'github':
        return '💻';
      case 'facebook':
        return '👤';
      case 'youtube':
        return '📹';
      case 'tiktok':
        return '🎵';
      case 'medium':
        return '✍️';
      case 'website':
        return '🌐';
      default:
        return '🔗';
    }
  }
}

/// 用户徽章值对象
class UserBadge {
  final String badgeId;
  final String name;
  final String? icon;
  final String? description;
  final DateTime earnedDate;

  UserBadge({
    required this.badgeId,
    required this.name,
    this.icon,
    this.description,
    required this.earnedDate,
  });

  /// 获取显示图标
  String get displayIcon => icon ?? '🏅';

  /// 是否是新获得的徽章 (7天内)
  bool get isNew {
    final diff = DateTime.now().difference(earnedDate);
    return diff.inDays <= 7;
  }
}

/// 旅行历史记录值对象
class TravelHistoryEntry {
  final String city;
  final String country;
  final DateTime startDate;
  final DateTime? endDate;
  final String? review;
  final double? rating;
  final List<String> photos;

  TravelHistoryEntry({
    required this.city,
    required this.country,
    required this.startDate,
    this.endDate,
    this.review,
    this.rating,
    this.photos = const [],
  });

  /// 获取停留天数
  int? get daysStayed {
    if (endDate == null) return null;
    return endDate!.difference(startDate).inDays;
  }

  /// 是否正在此地
  bool get isCurrentLocation => endDate == null;

  /// 是否有评价
  bool get hasReview => review != null && review!.isNotEmpty;

  /// 是否有评分
  bool get hasRating => rating != null;

  /// 是否有照片
  bool get hasPhotos => photos.isNotEmpty;

  /// 获取完整位置
  String get fullLocation => '$city, $country';

  /// 获取格式化的日期范围
  String get dateRange {
    final start = _formatDate(startDate);
    if (endDate == null) {
      return '$start - Present';
    }
    final end = _formatDate(endDate!);
    return '$start - $end';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
