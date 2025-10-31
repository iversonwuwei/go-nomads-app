/// 用户城市照片模型
class UserCityPhoto {
  final String id;
  final String userId;
  final String cityId;
  final String imageUrl;
  final String? caption;
  final String? location;
  final DateTime? takenAt;
  final DateTime createdAt;

  UserCityPhoto({
    required this.id,
    required this.userId,
    required this.cityId,
    required this.imageUrl,
    this.caption,
    this.location,
    this.takenAt,
    required this.createdAt,
  });

  factory UserCityPhoto.fromJson(Map<String, dynamic> json) {
    return UserCityPhoto(
      id: json['id'],
      userId: json['userId'],
      cityId: json['cityId'],
      imageUrl: json['imageUrl'],
      caption: json['caption'],
      location: json['location'],
      takenAt: json['takenAt'] != null ? DateTime.parse(json['takenAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'cityId': cityId,
      'imageUrl': imageUrl,
      'caption': caption,
      'location': location,
      'takenAt': takenAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 用户城市费用模型
class UserCityExpense {
  final String id;
  final String userId;
  final String cityId;
  final ExpenseCategory category;
  final double amount;
  final String currency;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  UserCityExpense({
    required this.id,
    required this.userId,
    required this.cityId,
    required this.category,
    required this.amount,
    this.currency = 'USD',
    this.description,
    required this.date,
    required this.createdAt,
  });

  factory UserCityExpense.fromJson(Map<String, dynamic> json) {
    return UserCityExpense(
      id: json['id'],
      userId: json['userId'],
      cityId: json['cityId'],
      category: ExpenseCategoryExtension.fromString(json['category']),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      description: json['description'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'cityId': cityId,
      'category': category.value,
      'amount': amount,
      'currency': currency,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 费用分类枚举
enum ExpenseCategory {
  food,
  transport,
  accommodation,
  activity,
  shopping,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get value {
    return toString().split('.').last;
  }

  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.transport:
        return 'Transportation';
      case ExpenseCategory.accommodation:
        return 'Accommodation';
      case ExpenseCategory.activity:
        return 'Activities';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}

/// 用户城市评论模型
class UserCityReview {
  final String id;
  final String userId;
  final String cityId;
  final int rating;
  final String title;
  final String content;
  final DateTime? visitDate;

  // 详细评分字段(可选)
  final int? internetQualityScore;
  final int? safetyScore;
  final int? costScore;
  final int? communityScore;
  final int? weatherScore;

  final String? reviewText;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 该用户在该城市上传的照片URL列表
  final List<String> photoUrls;

  UserCityReview({
    required this.id,
    required this.userId,
    required this.cityId,
    required this.rating,
    required this.title,
    required this.content,
    this.visitDate,
    this.internetQualityScore,
    this.safetyScore,
    this.costScore,
    this.communityScore,
    this.weatherScore,
    this.reviewText,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrls = const [],
  });

  factory UserCityReview.fromJson(Map<String, dynamic> json) {
    return UserCityReview(
      id: json['id'],
      userId: json['userId'],
      cityId: json['cityId'],
      rating: json['rating'],
      title: json['title'],
      content: json['content'],
      visitDate:
          json['visitDate'] != null ? DateTime.parse(json['visitDate']) : null,
      internetQualityScore: json['internetQualityScore'],
      safetyScore: json['safetyScore'],
      costScore: json['costScore'],
      communityScore: json['communityScore'],
      weatherScore: json['weatherScore'],
      reviewText: json['reviewText'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'cityId': cityId,
      'rating': rating,
      'title': title,
      'content': content,
      'visitDate': visitDate?.toIso8601String(),
      'internetQualityScore': internetQualityScore,
      'safetyScore': safetyScore,
      'costScore': costScore,
      'communityScore': communityScore,
      'weatherScore': weatherScore,
      'reviewText': reviewText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// 城市用户内容统计模型
class CityUserContentStats {
  final String cityId;
  final int photoCount;
  final int expenseCount;
  final int reviewCount;
  final double averageRating;
  final int photoContributors;
  final int expenseContributors;
  final int reviewContributors;

  CityUserContentStats({
    required this.cityId,
    this.photoCount = 0,
    this.expenseCount = 0,
    this.reviewCount = 0,
    this.averageRating = 0.0,
    this.photoContributors = 0,
    this.expenseContributors = 0,
    this.reviewContributors = 0,
  });

  factory CityUserContentStats.fromJson(Map<String, dynamic> json) {
    return CityUserContentStats(
      cityId: json['cityId'],
      photoCount: json['photoCount'] ?? 0,
      expenseCount: json['expenseCount'] ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      photoContributors: json['photoContributors'] ?? 0,
      expenseContributors: json['expenseContributors'] ?? 0,
      reviewContributors: json['reviewContributors'] ?? 0,
    );
  }
}

/// 城市综合费用统计模型 - 基于用户提交的实际费用计算
class CityCostSummary {
  final String cityId;
  final double total;
  final double accommodation;
  final double food;
  final double transportation;
  final double activity;
  final double shopping;
  final double other;
  final int contributorCount;
  final int totalExpenseCount;
  final String currency;
  final DateTime updatedAt;

  CityCostSummary({
    required this.cityId,
    required this.total,
    required this.accommodation,
    required this.food,
    required this.transportation,
    required this.activity,
    required this.shopping,
    required this.other,
    required this.contributorCount,
    required this.totalExpenseCount,
    this.currency = 'USD',
    required this.updatedAt,
  });

  factory CityCostSummary.fromJson(Map<String, dynamic> json) {
    return CityCostSummary(
      cityId: json['cityId'] ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      accommodation: (json['accommodation'] as num?)?.toDouble() ?? 0.0,
      food: (json['food'] as num?)?.toDouble() ?? 0.0,
      transportation: (json['transportation'] as num?)?.toDouble() ?? 0.0,
      activity: (json['activity'] as num?)?.toDouble() ?? 0.0,
      shopping: (json['shopping'] as num?)?.toDouble() ?? 0.0,
      other: (json['other'] as num?)?.toDouble() ?? 0.0,
      contributorCount: json['contributorCount'] ?? 0,
      totalExpenseCount: json['totalExpenseCount'] ?? 0,
      currency: json['currency'] ?? 'USD',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}
