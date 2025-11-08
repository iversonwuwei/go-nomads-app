/// Interest Domain Entity - 兴趣爱好
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

  // Business logic methods
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasIcon => icon != null && icon!.isNotEmpty;
}

/// UserInterest Domain Entity - 用户兴趣
class UserInterest {
  final String id;
  final String userId;
  final String interestId;
  final String interestName;
  final String category;
  final String? icon;
  final String? intensityLevel;
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

  // Business logic methods
  bool get isCasual => intensityLevel?.toLowerCase() == 'casual';
  bool get isModerate => intensityLevel?.toLowerCase() == 'moderate';
  bool get isPassionate => intensityLevel?.toLowerCase() == 'passionate';

  bool get hasHighIntensity => isPassionate;
}

/// InterestsByCategory Value Object - 按类别分组的兴趣
class InterestsByCategory {
  final String category;
  final List<Interest> interests;

  InterestsByCategory({
    required this.category,
    required this.interests,
  });

  // Business logic methods
  bool get hasInterests => interests.isNotEmpty;
  int get count => interests.length;
}

/// AddUserInterestRequest Value Object - 添加用户兴趣请求
class AddUserInterestRequest {
  final String interestId;
  final String? intensityLevel;

  AddUserInterestRequest({
    required this.interestId,
    this.intensityLevel,
  });
}
