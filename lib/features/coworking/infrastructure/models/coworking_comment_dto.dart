import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_comment.dart';

/// Coworking 评论 DTO
class CoworkingCommentDto {
  final String id;
  final String coworkingId;
  final String userId;
  final String content;
  final int rating;
  final List<String>? images;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CoworkingCommentDto({
    required this.id,
    required this.coworkingId,
    required this.userId,
    required this.content,
    this.rating = 0,
    this.images,
    required this.createdAt,
    this.updatedAt,
  });

  factory CoworkingCommentDto.fromJson(Map<String, dynamic> json) {
    return CoworkingCommentDto(
      id: json['id'] as String,
      coworkingId: json['coworkingId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      rating: json['rating'] as int? ?? 0,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coworkingId': coworkingId,
      'userId': userId,
      'content': content,
      'rating': rating,
      if (images != null) 'images': images,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  CoworkingComment toEntity() {
    return CoworkingComment(
      id: id,
      coworkingId: coworkingId,
      userId: userId,
      content: content,
      rating: rating,
      images: images,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
