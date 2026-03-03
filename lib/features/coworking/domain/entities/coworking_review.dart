/// CoworkingReview Domain Entity - Coworking 空间评论
class CoworkingReview {
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String coworkingId;
  final double rating; // 1.0 - 5.0
  final String title;
  final String content;
  final DateTime? visitDate;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified; // 是否已验证

  CoworkingReview({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.coworkingId,
    required this.rating,
    required this.title,
    required this.content,
    this.visitDate,
    required this.photoUrls,
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
  });

  // Business logic methods
  bool get hasPhotos => photoUrls.isNotEmpty;

  bool get hasVisitDate => visitDate != null;

  bool get wasUpdated => updatedAt != null;

  bool get isHighRating => rating >= 4.0;

  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inDays < 30;
  }

  // Copy with method
  CoworkingReview copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? coworkingId,
    double? rating,
    String? title,
    String? content,
    DateTime? visitDate,
    List<String>? photoUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
  }) {
    return CoworkingReview(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      coworkingId: coworkingId ?? this.coworkingId,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      content: content ?? this.content,
      visitDate: visitDate ?? this.visitDate,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
