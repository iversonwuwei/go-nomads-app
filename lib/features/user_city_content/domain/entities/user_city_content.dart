/// UserCityPhoto Domain Entity - 用户城市照片
class UserCityPhoto {
  final String id;
  final String userId;
  final String cityId;
  final String imageUrl;
  final String? caption;
  final String? location;
  final String? placeName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final DateTime? takenAt;
  final DateTime createdAt;

  UserCityPhoto({
    required this.id,
    required this.userId,
    required this.cityId,
    required this.imageUrl,
    this.caption,
    this.location,
    this.placeName,
    this.address,
    this.latitude,
    this.longitude,
    this.takenAt,
    required this.createdAt,
  });

  // Business logic methods
  bool get hasCaption => caption != null && caption!.isNotEmpty;

  bool get hasLocation => location != null && location!.isNotEmpty;

  bool get hasPoiName => placeName != null && placeName!.isNotEmpty;

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get hasTakenDate => takenAt != null;

  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inDays < 7;
  }
}

/// UserCityExpense Domain Entity - 用户城市费用
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
    required this.currency,
    this.description,
    required this.date,
    required this.createdAt,
  });

  // Business logic methods
  bool get hasDescription => description != null && description!.isNotEmpty;

  bool get isRecent {
    final now = DateTime.now();
    return now.difference(date).inDays < 30;
  }

  bool get isExpensive => amount > 100;
}

/// ExpenseCategory Enum
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

/// UserCityReview Domain Entity - 用户城市评论
class UserCityReview {
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String cityId;
  final int rating;
  final String title;
  final String content;
  final DateTime? visitDate;
  final int? internetQualityScore;
  final int? safetyScore;
  final int? costScore;
  final int? communityScore;
  final int? weatherScore;
  final String? reviewText;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> photoUrls;

  UserCityReview({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
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
    this.updatedAt,
    required this.photoUrls,
  });

  // Business logic methods
  bool get hasPhotos => photoUrls.isNotEmpty;

  bool get hasDetailedScores =>
      internetQualityScore != null ||
      safetyScore != null ||
      costScore != null ||
      communityScore != null ||
      weatherScore != null;

  bool get isHighRating => rating >= 4;

  bool get hasVisitDate => visitDate != null;

  bool get wasUpdated => updatedAt != null;

  double get averageDetailScore {
    final scores = [
      internetQualityScore,
      safetyScore,
      costScore,
      communityScore,
      weatherScore,
    ].whereType<int>();

    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }
}

/// CityUserContentStats Domain Entity - 城市用户内容统计
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
    required this.photoCount,
    required this.expenseCount,
    required this.reviewCount,
    required this.averageRating,
    required this.photoContributors,
    required this.expenseContributors,
    required this.reviewContributors,
  });

  // Business logic methods
  int get totalContributions => photoCount + expenseCount + reviewCount;

  int get totalContributors =>
      {photoContributors, expenseContributors, reviewContributors}.length;

  bool get hasPhotos => photoCount > 0;
  bool get hasExpenses => expenseCount > 0;
  bool get hasReviews => reviewCount > 0;

  bool get isActive => totalContributions > 10;
}

/// CityCostSummary Domain Entity - 城市综合费用统计
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
    required this.currency,
    required this.updatedAt,
  });

  // Business logic methods
  bool get hasData => totalExpenseCount > 0;

  bool get isReliable => contributorCount >= 5 && totalExpenseCount >= 20;

  double getCategoryPercentage(String category) {
    if (total == 0) return 0.0;
    switch (category.toLowerCase()) {
      case 'accommodation':
        return (accommodation / total) * 100;
      case 'food':
        return (food / total) * 100;
      case 'transportation':
        return (transportation / total) * 100;
      case 'activity':
        return (activity / total) * 100;
      case 'shopping':
        return (shopping / total) * 100;
      case 'other':
        return (other / total) * 100;
      default:
        return 0.0;
    }
  }

  double get averageExpensePerContributor {
    if (contributorCount == 0) return 0.0;
    return total / contributorCount;
  }
}
