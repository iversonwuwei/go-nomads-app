import 'package:df_admin_mobile/features/community/domain/entities/trip_report.dart'
    as domain;

/// TripReport DTO
class TripReportDto {
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

  TripReportDto({
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
    this.photos = const [],
    this.pros = const [],
    this.cons = const [],
    required this.likes,
    required this.comments,
    required this.createdAt,
    this.isLiked = false,
  });

  factory TripReportDto.fromJson(Map<String, dynamic> json) {
    return TripReportDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      city: json['city'] as String,
      country: json['country'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      overallRating: (json['overallRating'] as num).toDouble(),
      ratings: (json['ratings'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
      title: json['title'] as String,
      content: json['content'] as String,
      photos: (json['photos'] as List<dynamic>?)?.cast<String>() ?? [],
      pros: (json['pros'] as List<dynamic>?)?.cast<String>() ?? [],
      cons: (json['cons'] as List<dynamic>?)?.cast<String>() ?? [],
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'city': city,
      'country': country,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'overallRating': overallRating,
      'ratings': ratings,
      'title': title,
      'content': content,
      'photos': photos,
      'pros': pros,
      'cons': cons,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt.toIso8601String(),
      'isLiked': isLiked,
    };
  }

  domain.TripReport toDomain() {
    return domain.TripReport(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      city: city,
      country: country,
      startDate: startDate,
      endDate: endDate,
      overallRating: overallRating,
      ratings: ratings,
      title: title,
      content: content,
      photos: photos,
      pros: pros,
      cons: cons,
      likes: likes,
      comments: comments,
      createdAt: createdAt,
      isLiked: isLiked,
    );
  }
}

/// CityRecommendation DTO
class CityRecommendationDto {
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

  CityRecommendationDto({
    required this.id,
    required this.city,
    required this.name,
    required this.category,
    this.description,
    required this.rating,
    required this.reviewCount,
    this.priceRange,
    this.address,
    this.photos = const [],
    this.website,
    this.tags = const [],
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  factory CityRecommendationDto.fromJson(Map<String, dynamic> json) {
    return CityRecommendationDto(
      id: json['id'] as String,
      city: json['city'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      priceRange: json['priceRange'] as String?,
      address: json['address'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.cast<String>() ?? [],
      website: json['website'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'name': name,
      'category': category,
      'description': description,
      'rating': rating,
      'reviewCount': reviewCount,
      'priceRange': priceRange,
      'address': address,
      'photos': photos,
      'website': website,
      'tags': tags,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
    };
  }

  domain.CityRecommendation toDomain() {
    return domain.CityRecommendation(
      id: id,
      city: city,
      name: name,
      category: category,
      description: description,
      rating: rating,
      reviewCount: reviewCount,
      priceRange: priceRange,
      address: address,
      photos: photos,
      website: website,
      tags: tags,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
    );
  }
}

/// Question DTO
class QuestionDto {
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

  QuestionDto({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.city,
    required this.title,
    required this.content,
    this.tags = const [],
    required this.upvotes,
    required this.answerCount,
    this.hasAcceptedAnswer = false,
    required this.createdAt,
    this.isUpvoted = false,
  });

  factory QuestionDto.fromJson(Map<String, dynamic> json) {
    return QuestionDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      city: json['city'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      upvotes: json['upvotes'] as int,
      answerCount: json['answerCount'] as int,
      hasAcceptedAnswer: json['hasAcceptedAnswer'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isUpvoted: json['isUpvoted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'city': city,
      'title': title,
      'content': content,
      'tags': tags,
      'upvotes': upvotes,
      'answerCount': answerCount,
      'hasAcceptedAnswer': hasAcceptedAnswer,
      'createdAt': createdAt.toIso8601String(),
      'isUpvoted': isUpvoted,
    };
  }

  domain.Question toDomain() {
    return domain.Question(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      city: city,
      title: title,
      content: content,
      tags: tags,
      upvotes: upvotes,
      answerCount: answerCount,
      hasAcceptedAnswer: hasAcceptedAnswer,
      createdAt: createdAt,
      isUpvoted: isUpvoted,
    );
  }
}

/// Answer DTO
class AnswerDto {
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

  AnswerDto({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.upvotes,
    this.isAccepted = false,
    required this.createdAt,
    this.isUpvoted = false,
  });

  factory AnswerDto.fromJson(Map<String, dynamic> json) {
    return AnswerDto(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String,
      upvotes: json['upvotes'] as int,
      isAccepted: json['isAccepted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isUpvoted: json['isUpvoted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'upvotes': upvotes,
      'isAccepted': isAccepted,
      'createdAt': createdAt.toIso8601String(),
      'isUpvoted': isUpvoted,
    };
  }

  domain.Answer toDomain() {
    return domain.Answer(
      id: id,
      questionId: questionId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      content: content,
      upvotes: upvotes,
      isAccepted: isAccepted,
      createdAt: createdAt,
      isUpvoted: isUpvoted,
    );
  }
}
