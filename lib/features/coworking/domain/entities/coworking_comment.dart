/// Coworking 评论领域实体
class CoworkingComment {
  final String id;
  final String coworkingId;
  final String userId;
  final String content;
  final int rating; // 0-5 星评分
  final List<String>? images;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const CoworkingComment({
    required this.id,
    required this.coworkingId,
    required this.userId,
    required this.content,
    this.rating = 0,
    this.images,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });
}
