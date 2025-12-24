/// Hotel Review Domain Entity - 酒店评论
class HotelReview {
  final String id;
  final String hotelId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String? title;
  final String content;
  final DateTime? visitDate;
  final List<String> photoUrls;
  final bool isVerified;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HotelReview({
    required this.id,
    required this.hotelId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.title,
    required this.content,
    this.visitDate,
    this.photoUrls = const [],
    this.isVerified = false,
    this.helpfulCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory HotelReview.fromJson(Map<String, dynamic> json) {
    return HotelReview(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? '匿名用户',
      userAvatar: json['userAvatar'] as String?,
      rating: json['rating'] as int,
      title: json['title'] as String?,
      content: json['content'] as String,
      visitDate: json['visitDate'] != null
          ? DateTime.parse(json['visitDate'] as String)
          : null,
      photoUrls: json['photoUrls'] != null
          ? List<String>.from(json['photoUrls'] as List)
          : [],
      isVerified: json['isVerified'] as bool? ?? false,
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotelId': hotelId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'title': title,
      'content': content,
      'visitDate': visitDate?.toIso8601String(),
      'photoUrls': photoUrls,
      'isVerified': isVerified,
      'helpfulCount': helpfulCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  HotelReview copyWith({
    String? id,
    String? hotelId,
    String? userId,
    String? userName,
    String? userAvatar,
    int? rating,
    String? title,
    String? content,
    DateTime? visitDate,
    List<String>? photoUrls,
    bool? isVerified,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HotelReview(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      content: content ?? this.content,
      visitDate: visitDate ?? this.visitDate,
      photoUrls: photoUrls ?? this.photoUrls,
      isVerified: isVerified ?? this.isVerified,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Hotel Review List Response - 酒店评论列表响应
class HotelReviewListResponse {
  final List<HotelReview> reviews;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final double averageRating;
  final Map<int, int> ratingDistribution;

  HotelReviewListResponse({
    required this.reviews,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.averageRating,
    required this.ratingDistribution,
  });

  factory HotelReviewListResponse.fromJson(Map<String, dynamic> json) {
    return HotelReviewListResponse(
      reviews: (json['reviews'] as List)
          .map((e) => HotelReview.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
      averageRating: (json['averageRating'] as num).toDouble(),
      ratingDistribution: (json['ratingDistribution'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(int.parse(key), value as int)),
    );
  }
}

/// Create Hotel Review Request - 创建酒店评论请求
class CreateHotelReviewRequest {
  final int rating;
  final String? title;
  final String content;
  final DateTime? visitDate;
  final List<String>? photoUrls;

  CreateHotelReviewRequest({
    required this.rating,
    this.title,
    required this.content,
    this.visitDate,
    this.photoUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      if (title != null) 'title': title,
      'content': content,
      if (visitDate != null) 'visitDate': visitDate!.toIso8601String(),
      if (photoUrls != null) 'photoUrls': photoUrls,
    };
  }
}

/// Update Hotel Review Request - 更新酒店评论请求
class UpdateHotelReviewRequest {
  final int? rating;
  final String? title;
  final String? content;
  final DateTime? visitDate;
  final List<String>? photoUrls;

  UpdateHotelReviewRequest({
    this.rating,
    this.title,
    this.content,
    this.visitDate,
    this.photoUrls,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (rating != null) map['rating'] = rating;
    if (title != null) map['title'] = title;
    if (content != null) map['content'] = content;
    if (visitDate != null) map['visitDate'] = visitDate!.toIso8601String();
    if (photoUrls != null) map['photoUrls'] = photoUrls;
    return map;
  }
}
