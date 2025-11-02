/// 兴趣爱好模型
class Interest {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String? icon;
  final DateTime createdAt;

  Interest({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.icon,
    required this.createdAt,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 用户兴趣模型
class UserInterest {
  final String id;
  final String userId;
  final String interestId;
  final String interestName;
  final String category;
  final String? icon;
  final String? intensityLevel; // casual, moderate, passionate
  final DateTime createdAt;

  UserInterest({
    required this.id,
    required this.userId,
    required this.interestId,
    required this.interestName,
    required this.category,
    this.icon,
    this.intensityLevel,
    required this.createdAt,
  });

  factory UserInterest.fromJson(Map<String, dynamic> json) {
    return UserInterest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      interestId: json['interestId'] as String,
      interestName: json['interestName'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String?,
      intensityLevel: json['intensityLevel'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'interestId': interestId,
      'interestName': interestName,
      'category': category,
      'icon': icon,
      'intensityLevel': intensityLevel,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 按类别分组的兴趣
class InterestsByCategory {
  final String category;
  final List<Interest> interests;

  InterestsByCategory({
    required this.category,
    required this.interests,
  });

  factory InterestsByCategory.fromJson(Map<String, dynamic> json) {
    return InterestsByCategory(
      category: json['category'] as String,
      interests: (json['interests'] as List)
          .map((interest) => Interest.fromJson(interest as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'interests': interests.map((interest) => interest.toJson()).toList(),
    };
  }
}

/// 添加用户兴趣请求
class AddUserInterestRequest {
  final String interestId;
  final String? intensityLevel;

  AddUserInterestRequest({
    required this.interestId,
    this.intensityLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'interestId': interestId,
      'intensityLevel': intensityLevel,
    };
  }
}
