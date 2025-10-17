/// 用户基本信息模型
class UserBasicInfo {
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

  UserBasicInfo({
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

  factory UserBasicInfo.fromMap(Map<String, dynamic> map) {
    return UserBasicInfo(
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
}

/// 游牧状态统计模型
class NomadStats {
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

  NomadStats({
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

  factory NomadStats.fromMap(Map<String, dynamic> map) {
    return NomadStats(
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

  NomadStats copyWith({
    int? countriesVisited,
    int? citiesLived,
    int? daysNomading,
    int? meetupsAttended,
    int? tripsCompleted,
    int? reviewsWritten,
  }) {
    return NomadStats(
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

/// 技能标签模型
class UserSkill {
  final int? id;
  final int accountId;
  final String skillName;
  final String createdAt;

  UserSkill({
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

  factory UserSkill.fromMap(Map<String, dynamic> map) {
    return UserSkill(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      skillName: map['skill_name'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}

/// 兴趣爱好标签模型
class UserInterest {
  final int? id;
  final int accountId;
  final String interestName;
  final String createdAt;

  UserInterest({
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

  factory UserInterest.fromMap(Map<String, dynamic> map) {
    return UserInterest(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      interestName: map['interest_name'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}

/// 社交联系方式模型
class UserSocialLink {
  final int? id;
  final int accountId;
  final String
      platform; // instagram, twitter, linkedin, github, facebook, youtube, tiktok, etc.
  final String url;
  final String createdAt;
  final String updatedAt;

  UserSocialLink({
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

  factory UserSocialLink.fromMap(Map<String, dynamic> map) {
    return UserSocialLink(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      platform: map['platform'] as String,
      url: map['url'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}

/// 旅行计划模型（AI生成后存储）
class TravelPlan {
  final int? id;
  final int accountId;
  final String title;
  final String destination;
  final String? startDate;
  final String? endDate;
  final String? description;
  final String? itinerary; // JSON格式存储详细行程
  final String? budget;
  final String? accommodation;
  final String? transportation;
  final String status; // planning, confirmed, completed, cancelled
  final String createdAt;
  final String updatedAt;

  TravelPlan({
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

  factory TravelPlan.fromMap(Map<String, dynamic> map) {
    return TravelPlan(
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

/// 徽章模型
class UserBadge {
  final int? id;
  final int accountId;
  final String badgeId; // 徽章唯一标识
  final String badgeName;
  final String? badgeIcon; // emoji或图标
  final String? description;
  final String earnedDate;
  final String createdAt;

  UserBadge({
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

  factory UserBadge.fromMap(Map<String, dynamic> map) {
    return UserBadge(
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
}

/// 旅行历史记录模型
class TravelHistory {
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

  TravelHistory({
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

  factory TravelHistory.fromMap(Map<String, dynamic> map) {
    return TravelHistory(
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
}

/// 预定义的技能标签
class PredefinedSkills {
  static const List<String> skills = [
    // 技术类
    'Web Development',
    'Mobile Development',
    'UI/UX Design',
    'Data Science',
    'Machine Learning',
    'DevOps',
    'Cloud Computing',
    'Cybersecurity',
    'Blockchain',
    'Game Development',

    // 商业类
    'Project Management',
    'Product Management',
    'Business Analysis',
    'Marketing',
    'Sales',
    'Customer Success',
    'Finance',
    'Accounting',
    'HR',
    'Consulting',

    // 创意类
    'Graphic Design',
    'Video Editing',
    'Photography',
    'Content Writing',
    'Copywriting',
    'Social Media',
    'Animation',
    'Illustration',
    'Music Production',
    '3D Modeling',

    // 其他
    'Teaching',
    'Translation',
    'Virtual Assistant',
    'Customer Support',
    'Data Entry',
  ];
}

/// 预定义的兴趣爱好标签
class PredefinedInterests {
  static const List<String> interests = [
    // 旅行相关
    'Travel',
    'Adventure',
    'Backpacking',
    'Road Trips',
    'City Exploring',
    'Beach Life',
    'Mountain Hiking',
    'Cultural Tours',

    // 运动健身
    'Fitness',
    'Yoga',
    'Running',
    'Cycling',
    'Swimming',
    'Surfing',
    'Rock Climbing',
    'Martial Arts',

    // 艺术文化
    'Photography',
    'Art',
    'Music',
    'Reading',
    'Writing',
    'Movies',
    'Theater',
    'Museums',

    // 美食
    'Food',
    'Cooking',
    'Coffee',
    'Wine Tasting',
    'Street Food',
    'Vegan',
    'Vegetarian',

    // 社交
    'Networking',
    'Language Exchange',
    'Volunteering',
    'Meetups',
    'Parties',
    'Nightlife',

    // 学习
    'Learning Languages',
    'Online Courses',
    'Podcasts',
    'Meditation',
    'Personal Development',

    // 科技
    'Technology',
    'Gaming',
    'Coding',
    'Startups',
    'Cryptocurrency',
  ];
}

/// 预定义的社交平台
class SocialPlatforms {
  static const Map<String, Map<String, String>> platforms = {
    'instagram': {
      'name': 'Instagram',
      'icon': '📷',
      'urlPattern': 'instagram.com/',
    },
    'twitter': {
      'name': 'Twitter',
      'icon': '🐦',
      'urlPattern': 'twitter.com/',
    },
    'x': {
      'name': 'X (Twitter)',
      'icon': '✖️',
      'urlPattern': 'x.com/',
    },
    'linkedin': {
      'name': 'LinkedIn',
      'icon': '💼',
      'urlPattern': 'linkedin.com/',
    },
    'facebook': {
      'name': 'Facebook',
      'icon': '👤',
      'urlPattern': 'facebook.com/',
    },
    'github': {
      'name': 'GitHub',
      'icon': '💻',
      'urlPattern': 'github.com/',
    },
    'youtube': {
      'name': 'YouTube',
      'icon': '📹',
      'urlPattern': 'youtube.com/',
    },
    'tiktok': {
      'name': 'TikTok',
      'icon': '🎵',
      'urlPattern': 'tiktok.com/',
    },
    'pinterest': {
      'name': 'Pinterest',
      'icon': '📌',
      'urlPattern': 'pinterest.com/',
    },
    'medium': {
      'name': 'Medium',
      'icon': '✍️',
      'urlPattern': 'medium.com/',
    },
    'behance': {
      'name': 'Behance',
      'icon': '🎨',
      'urlPattern': 'behance.net/',
    },
    'dribbble': {
      'name': 'Dribbble',
      'icon': '🏀',
      'urlPattern': 'dribbble.com/',
    },
    'spotify': {
      'name': 'Spotify',
      'icon': '🎧',
      'urlPattern': 'spotify.com/',
    },
    'twitch': {
      'name': 'Twitch',
      'icon': '🎮',
      'urlPattern': 'twitch.tv/',
    },
    'discord': {
      'name': 'Discord',
      'icon': '💬',
      'urlPattern': 'discord.gg/',
    },
    'telegram': {
      'name': 'Telegram',
      'icon': '✈️',
      'urlPattern': 't.me/',
    },
    'whatsapp': {
      'name': 'WhatsApp',
      'icon': '📱',
      'urlPattern': 'wa.me/',
    },
    'wechat': {
      'name': 'WeChat',
      'icon': '💚',
      'urlPattern': 'weixin://',
    },
    'website': {
      'name': 'Personal Website',
      'icon': '🌐',
      'urlPattern': 'https://',
    },
  };
}
