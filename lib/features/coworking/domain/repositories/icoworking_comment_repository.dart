import '../entities/coworking_comment.dart';

/// Coworking 评论仓储接口
abstract class ICoworkingCommentRepository {
  /// 创建评论
  Future<CoworkingComment> createComment({
    required String coworkingId,
    required String content,
    int rating = 0,
    List<String>? images,
  });

  /// 获取评论列表
  Future<List<CoworkingComment>> getComments(
    String coworkingId, {
    int page = 1,
    int pageSize = 20,
  });

  /// 获取评论数量
  Future<int> getCommentCount(String coworkingId);

  /// 删除评论
  Future<void> deleteComment(String commentId);
}
