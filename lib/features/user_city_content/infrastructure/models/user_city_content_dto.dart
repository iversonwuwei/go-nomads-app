// import 'package:go_nomads_app/models/user_city_content_models.dart' as legacy;
import 'package:go_nomads_app/features/user_city_content/domain/entities/user_city_content.dart' as domain;

/// 分页结果 DTO
class PagedResultDto<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasMore;

  PagedResultDto({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasMore,
  });

  factory PagedResultDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResultDto(
      items: (json['items'] as List<dynamic>).map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      hasMore: json['hasMore'] ?? false,
    );
  }

  domain.PagedResult<R> toDomain<R>(R Function(T) mapper) {
    return domain.PagedResult(
      items: items.map(mapper).toList(),
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
    );
  }
}

/// UserCityPhoto DTO
class UserCityPhotoDto {
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

  UserCityPhotoDto({
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

  factory UserCityPhotoDto.fromJson(Map<String, dynamic> json) {
    return UserCityPhotoDto(
      id: json['id'],
      userId: json['userId'],
      cityId: json['cityId'],
      imageUrl: json['imageUrl'],
      caption: json['caption'],
      location: json['location'],
      placeName: json['placeName'],
      address: json['address'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
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
      'placeName': placeName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'takenAt': takenAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  domain.UserCityPhoto toDomain() {
    return domain.UserCityPhoto(
      id: id,
      userId: userId,
      cityId: cityId,
      imageUrl: imageUrl,
      caption: caption,
      location: location,
      placeName: placeName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      takenAt: takenAt,
      createdAt: createdAt,
    );
  }

  // factory UserCityPhotoDto.fromLegacyModel(legacy.UserCityPhoto model) {
  //   return UserCityPhotoDto(
  //     id: model.id,
  //     userId: model.userId,
  //     cityId: model.cityId,
  //     imageUrl: model.imageUrl,
  //     caption: model.caption,
  //     location: model.location,
  //     takenAt: model.takenAt,
  //     createdAt: model.createdAt,
  //   );
  // }
}

/// UserCityExpense DTO
class UserCityExpenseDto {
  final String id;
  final String userId;
  final String cityId;
  final domain.ExpenseCategory category;
  final double amount;
  final String currency;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  UserCityExpenseDto({
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

  factory UserCityExpenseDto.fromJson(Map<String, dynamic> json) {
    return UserCityExpenseDto(
      id: json['id'],
      userId: json['userId'],
      cityId: json['cityId'],
      category: domain.ExpenseCategoryExtension.fromString(json['category']),
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

  domain.UserCityExpense toDomain() {
    return domain.UserCityExpense(
      id: id,
      userId: userId,
      cityId: cityId,
      category: category,
      amount: amount,
      currency: currency,
      description: description,
      date: date,
      createdAt: createdAt,
    );
  }

  // factory UserCityExpenseDto.fromLegacyModel(legacy.UserCityExpense model) {
  //   // Convert legacy enum to domain enum
  //   domain.ExpenseCategory domainCategory;
  //   switch (model.category) {
  //     case legacy.ExpenseCategory.food:
  //       domainCategory = domain.ExpenseCategory.food;
  //       break;
  //     case legacy.ExpenseCategory.transport:
  //       domainCategory = domain.ExpenseCategory.transport;
  //       break;
  //     case legacy.ExpenseCategory.accommodation:
  //       domainCategory = domain.ExpenseCategory.accommodation;
  //       break;
  //     case legacy.ExpenseCategory.activity:
  //       domainCategory = domain.ExpenseCategory.activity;
  //       break;
  //     case legacy.ExpenseCategory.shopping:
  //       domainCategory = domain.ExpenseCategory.shopping;
  //       break;
  //     case legacy.ExpenseCategory.other:
  //       domainCategory = domain.ExpenseCategory.other;
  //       break;
  //   }

  //   return UserCityExpenseDto(
  //     id: model.id,
  //     userId: model.userId,
  //     cityId: model.cityId,
  //     category: domainCategory,
  //     amount: model.amount,
  //     currency: model.currency,
  //     description: model.description,
  //     date: model.date,
  //     createdAt: model.createdAt,
  //   );
  // }
}

/// UserCityReview DTO
class UserCityReviewDto {
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

  UserCityReviewDto({
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
    this.photoUrls = const [],
  });

  factory UserCityReviewDto.fromJson(Map<String, dynamic> json) {
    return UserCityReviewDto(
      id: json['id'],
      userId: json['userId'],
      username: json['username'] ?? 'User ${json['userId'].toString().substring(0, 8)}',
      userAvatar: json['userAvatar'],
      cityId: json['cityId'],
      rating: json['rating'],
      title: json['title'],
      content: json['content'],
      visitDate: json['visitDate'] != null ? DateTime.parse(json['visitDate']) : null,
      internetQualityScore: json['internetQualityScore'],
      safetyScore: json['safetyScore'],
      costScore: json['costScore'],
      communityScore: json['communityScore'],
      weatherScore: json['weatherScore'],
      reviewText: json['reviewText'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      photoUrls: (json['photoUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
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
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  domain.UserCityReview toDomain() {
    return domain.UserCityReview(
      id: id,
      userId: userId,
      username: username,
      userAvatar: userAvatar,
      cityId: cityId,
      rating: rating,
      title: title,
      content: content,
      visitDate: visitDate,
      internetQualityScore: internetQualityScore,
      safetyScore: safetyScore,
      costScore: costScore,
      communityScore: communityScore,
      weatherScore: weatherScore,
      reviewText: reviewText,
      createdAt: createdAt,
      updatedAt: updatedAt,
      photoUrls: photoUrls,
    );
  }

  // factory UserCityReviewDto.fromLegacyModel(legacy.UserCityReview model) {
  //   return UserCityReviewDto(
  //     id: model.id,
  //     userId: model.userId,
  //     username: model.username,
  //     userAvatar: model.userAvatar,
  //     cityId: model.cityId,
  //     rating: model.rating,
  //     title: model.title,
  //     content: model.content,
  //     visitDate: model.visitDate,
  //     internetQualityScore: model.internetQualityScore,
  //     safetyScore: model.safetyScore,
  //     costScore: model.costScore,
  //     communityScore: model.communityScore,
  //     weatherScore: model.weatherScore,
  //     reviewText: model.reviewText,
  //     createdAt: model.createdAt,
  //     updatedAt: model.updatedAt,
  //     photoUrls: model.photoUrls,
  //   );
  // }
}

/// CityUserContentStats DTO
class CityUserContentStatsDto {
  final String cityId;
  final int photoCount;
  final int expenseCount;
  final int reviewCount;
  final double averageRating;
  final int photoContributors;
  final int expenseContributors;
  final int reviewContributors;

  CityUserContentStatsDto({
    required this.cityId,
    this.photoCount = 0,
    this.expenseCount = 0,
    this.reviewCount = 0,
    this.averageRating = 0.0,
    this.photoContributors = 0,
    this.expenseContributors = 0,
    this.reviewContributors = 0,
  });

  factory CityUserContentStatsDto.fromJson(Map<String, dynamic> json) {
    return CityUserContentStatsDto(
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

  Map<String, dynamic> toJson() {
    return {
      'cityId': cityId,
      'photoCount': photoCount,
      'expenseCount': expenseCount,
      'reviewCount': reviewCount,
      'averageRating': averageRating,
      'photoContributors': photoContributors,
      'expenseContributors': expenseContributors,
      'reviewContributors': reviewContributors,
    };
  }

  domain.CityUserContentStats toDomain() {
    return domain.CityUserContentStats(
      cityId: cityId,
      photoCount: photoCount,
      expenseCount: expenseCount,
      reviewCount: reviewCount,
      averageRating: averageRating,
      photoContributors: photoContributors,
      expenseContributors: expenseContributors,
      reviewContributors: reviewContributors,
    );
  }

  // factory CityUserContentStatsDto.fromLegacyModel(
  //     legacy.CityUserContentStats model) {
  //   return CityUserContentStatsDto(
  //     cityId: model.cityId,
  //     photoCount: model.photoCount,
  //     expenseCount: model.expenseCount,
  //     reviewCount: model.reviewCount,
  //     averageRating: model.averageRating,
  //     photoContributors: model.photoContributors,
  //     expenseContributors: model.expenseContributors,
  //     reviewContributors: model.reviewContributors,
  //   );
  // }
}

/// CityCostSummary DTO
class CityCostSummaryDto {
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

  CityCostSummaryDto({
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

  factory CityCostSummaryDto.fromJson(Map<String, dynamic> json) {
    return CityCostSummaryDto(
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
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityId': cityId,
      'total': total,
      'accommodation': accommodation,
      'food': food,
      'transportation': transportation,
      'activity': activity,
      'shopping': shopping,
      'other': other,
      'contributorCount': contributorCount,
      'totalExpenseCount': totalExpenseCount,
      'currency': currency,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  domain.CityCostSummary toDomain() {
    return domain.CityCostSummary(
      cityId: cityId,
      total: total,
      accommodation: accommodation,
      food: food,
      transportation: transportation,
      activity: activity,
      shopping: shopping,
      other: other,
      contributorCount: contributorCount,
      totalExpenseCount: totalExpenseCount,
      currency: currency,
      updatedAt: updatedAt,
    );
  }

  // factory CityCostSummaryDto.fromLegacyModel(legacy.CityCostSummary model) {
  //   return CityCostSummaryDto(
  //     cityId: model.cityId,
  //     total: model.total,
  //     accommodation: model.accommodation,
  //     food: model.food,
  //     transportation: model.transportation,
  //     activity: model.activity,
  //     shopping: model.shopping,
  //     other: model.other,
  //     contributorCount: model.contributorCount,
  //     totalExpenseCount: model.totalExpenseCount,
  //     currency: model.currency,
  //     updatedAt: model.updatedAt,
  //   );
  // }
}
