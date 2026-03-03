/// TripReport Domain Entity - 旅行报告
class TripReport {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String city;
  final String country;
  final DateTime startDate;
  final DateTime endDate;
  final double overallRating;
  final Map<String, double> ratings;
  final String title;
  final String content;
  final List<String> photos;
  final List<String> pros;
  final List<String> cons;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final bool isLiked;

  TripReport({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.city,
    required this.country,
    required this.startDate,
    required this.endDate,
    required this.overallRating,
    required this.ratings,
    required this.title,
    required this.content,
    required this.photos,
    required this.pros,
    required this.cons,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.isLiked,
  });

  // Business logic methods
  int get tripDuration => endDate.difference(startDate).inDays;

  bool get isLongTrip => tripDuration > 30;

  bool get isPopular => likes > 50 || comments > 20;

  bool get isHighlyRated => overallRating >= 4.0;

  bool get hasPhotos => photos.isNotEmpty;

  double? getRating(String category) => ratings[category];

  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inDays < 7;
  }

  String get tripType {
    if (tripDuration < 7) return 'short';
    if (tripDuration < 30) return 'medium';
    return 'long';
  }
}

/// CityRecommendation Domain Entity - 城市推荐
class CityRecommendation {
  final String id;
  final String city;
  final String name;
  final String category;
  final String? description;
  final double rating;
  final int reviewCount;
  final String? priceRange;
  final String? address;
  final List<String> photos;
  final String? website;
  final List<String> tags;
  final String userId;
  final String userName;
  final String? userAvatar;

  CityRecommendation({
    required this.id,
    required this.city,
    required this.name,
    required this.category,
    this.description,
    required this.rating,
    required this.reviewCount,
    this.priceRange,
    this.address,
    required this.photos,
    this.website,
    required this.tags,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  // Business logic methods
  bool get isHighlyRated => rating >= 4.0;

  bool get isPopular => reviewCount > 50;

  bool get hasPhotos => photos.isNotEmpty;

  bool get hasWebsite => website != null && website!.isNotEmpty;

  bool isCategory(String cat) => category.toLowerCase() == cat.toLowerCase();

  bool get isRestaurant => isCategory('restaurant');
  bool get isCafe => isCategory('cafe');
  bool get isCoworking => isCategory('coworking');
  bool get isActivity => isCategory('activity');

  String get priceLevel {
    if (priceRange == null) return 'unknown';
    switch (priceRange!.length) {
      case 1:
        return 'budget';
      case 2:
        return 'moderate';
      case 3:
        return 'expensive';
      default:
        return 'luxury';
    }
  }

  /// 获取完整地址（详细地址 + 城市）
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city.isNotEmpty) parts.add(city);
    return parts.isNotEmpty ? parts.join(', ') : city;
  }
}

/// Question Domain Entity - 问答问题
class Question {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String city;
  final String title;
  final String content;
  final List<String> tags;
  final int upvotes;
  final int answerCount;
  final bool hasAcceptedAnswer;
  final DateTime createdAt;
  final bool isUpvoted;

  Question({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.city,
    required this.title,
    required this.content,
    required this.tags,
    required this.upvotes,
    required this.answerCount,
    required this.hasAcceptedAnswer,
    required this.createdAt,
    required this.isUpvoted,
  });

  // Business logic methods
  bool get hasAnswers => answerCount > 0;

  bool get isResolved => hasAcceptedAnswer;

  bool get needsAnswer => !hasAnswers;

  bool get isPopular => upvotes > 10;

  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inDays < 7;
  }

  bool hasTag(String tag) => tags.any((t) => t.toLowerCase() == tag.toLowerCase());
}

/// Answer Domain Entity - 问答答案
class Answer {
  final String id;
  final String questionId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final int upvotes;
  final bool isAccepted;
  final DateTime createdAt;
  final bool isUpvoted;

  Answer({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.upvotes,
    required this.isAccepted,
    required this.createdAt,
    required this.isUpvoted,
  });

  // Business logic methods
  bool get isHelpful => upvotes > 5;

  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inDays < 7;
  }
}
