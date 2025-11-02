class UserModel {
  final String id;
  final String name;
  final String username;
  final String? email; // 添加 email 字段
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

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.email, // 添加 email 参数
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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String?, // 添加 email
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      currentCity: json['currentCity'] as String?,
      currentCountry: json['currentCountry'] as String?,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => UserSkillInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => UserInterestInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      socialLinks: (json['socialLinks'] as Map<String, dynamic>?)?.cast<String, String>() ?? {},
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => Badge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      stats: TravelStats.fromJson(json['stats'] as Map<String, dynamic>),
      travelHistory: (json['travelHistory'] as List<dynamic>?)
              ?.map((e) => TravelHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email, // 添加 email
      'bio': bio,
      'avatarUrl': avatarUrl,
      'currentCity': currentCity,
      'currentCountry': currentCountry,
      'skills': skills.map((e) => e.toJson()).toList(),
      'interests': interests.map((e) => e.toJson()).toList(),
      'socialLinks': socialLinks,
      'badges': badges.map((e) => e.toJson()).toList(),
      'stats': stats.toJson(),
      'travelHistory': travelHistory.map((e) => e.toJson()).toList(),
      'joinedDate': joinedDate.toIso8601String(),
      'isVerified': isVerified,
    };
  }
}

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

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      earnedDate: DateTime.parse(json['earnedDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'earnedDate': earnedDate.toIso8601String(),
    };
  }
}

class TravelStats {
  final int countriesVisited;
  final int citiesLived;
  final int daysNomading;
  final int meetupsAttended;
  final int tripsCompleted;
  final int favorites; // 收藏数量

  TravelStats({
    required this.countriesVisited,
    required this.citiesLived,
    required this.daysNomading,
    required this.meetupsAttended,
    required this.tripsCompleted,
    this.favorites = 0, // 默认值为 0
  });

  factory TravelStats.fromJson(Map<String, dynamic> json) {
    return TravelStats(
      countriesVisited: json['countriesVisited'] as int,
      citiesLived: json['citiesLived'] as int,
      daysNomading: json['daysNomading'] as int,
      meetupsAttended: json['meetupsAttended'] as int,
      tripsCompleted: json['tripsCompleted'] as int,
      favorites: json['favorites'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countriesVisited': countriesVisited,
      'citiesLived': citiesLived,
      'daysNomading': daysNomading,
      'meetupsAttended': meetupsAttended,
      'tripsCompleted': tripsCompleted,
      'favorites': favorites,
    };
  }
}

class TravelHistory {
  final String city;
  final String country;
  final DateTime startDate;
  final DateTime? endDate;
  final String? review;
  final double? rating;

  TravelHistory({
    required this.city,
    required this.country,
    required this.startDate,
    this.endDate,
    this.review,
    this.rating,
  });

  factory TravelHistory.fromJson(Map<String, dynamic> json) {
    return TravelHistory(
      city: json['city'] as String,
      country: json['country'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      review: json['review'] as String?,
      rating: json['rating'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'review': review,
      'rating': rating,
    };
  }
}

/// 用户技能信息(简化版,用于 UserModel)
class UserSkillInfo {
  final String id; // user_skill 记录的 ID
  final String skillId; // skill 的 ID
  final String skillName; // skill 名称
  final String? icon; // 图标
  final String? category; // 类别
  final String? proficiencyLevel; // 熟练度
  final int? yearsOfExperience; // 经验年限

  UserSkillInfo({
    required this.id,
    required this.skillId,
    required this.skillName,
    this.icon,
    this.category,
    this.proficiencyLevel,
    this.yearsOfExperience,
  });

  factory UserSkillInfo.fromJson(Map<String, dynamic> json) {
    return UserSkillInfo(
      id: json['id'] as String,
      skillId: json['skillId'] as String,
      skillName: json['skillName'] as String,
      icon: json['icon'] as String?,
      category: json['category'] as String?,
      proficiencyLevel: json['proficiencyLevel'] as String?,
      yearsOfExperience: json['yearsOfExperience'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skillId': skillId,
      'skillName': skillName,
      'icon': icon,
      'category': category,
      'proficiencyLevel': proficiencyLevel,
      'yearsOfExperience': yearsOfExperience,
    };
  }
}

/// 用户兴趣信息(简化版,用于 UserModel)
class UserInterestInfo {
  final String id; // user_interest 记录的 ID
  final String interestId; // interest 的 ID
  final String interestName; // interest 名称
  final String? icon; // 图标
  final String? category; // 类别
  final String? intensityLevel; // 强度

  UserInterestInfo({
    required this.id,
    required this.interestId,
    required this.interestName,
    this.icon,
    this.category,
    this.intensityLevel,
  });

  factory UserInterestInfo.fromJson(Map<String, dynamic> json) {
    return UserInterestInfo(
      id: json['id'] as String,
      interestId: json['interestId'] as String,
      interestName: json['interestName'] as String,
      icon: json['icon'] as String?,
      category: json['category'] as String?,
      intensityLevel: json['intensityLevel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'interestId': interestId,
      'interestName': interestName,
      'icon': icon,
      'category': category,
      'intensityLevel': intensityLevel,
    };
  }
}
