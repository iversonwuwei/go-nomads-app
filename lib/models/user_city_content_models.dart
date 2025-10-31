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
  final DateTime createdAt;
  final DateTime updatedAt;

  UserCityReview({
    required this.id,
    required this.userId,
    required this.cityId,
    required this.rating,
    required this.title,
    required this.content,
    this.visitDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserCityReview.fromJson(Map<String, dynamic> json) {
    return UserCityReview(
      id: json['id'],
      userId: json['userId'],
      cityId: json['cityId'],
      rating: json['rating'],
      title: json['title'],
      content: json['content'],
      visitDate: json['visitDate'] != null ? DateTime.parse(json['visitDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
