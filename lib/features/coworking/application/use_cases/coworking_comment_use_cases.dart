import 'package:go_nomads_app/features/coworking/domain/entities/coworking_comment.dart';
import 'package:go_nomads_app/features/coworking/domain/repositories/icoworking_comment_repository.dart';

/// Coworking 评论用例
class CoworkingCommentUseCases {
  final ICoworkingCommentRepository _repository;

  CoworkingCommentUseCases(this._repository);

  /// 创建评论
  Future<CoworkingComment> createComment({
    required String coworkingId,
    required String content,
    int rating = 0,
    List<String>? images,
  }) async {
    if (content.trim().isEmpty) {
      throw ArgumentError('评论内容不能为空');
    }
    if (rating < 0 || rating > 5) {
      throw ArgumentError('评分必须在 0-5 之间');
    }

    return await _repository.createComment(
      coworkingId: coworkingId,
      content: content.trim(),
      rating: rating,
      images: images,
    );
  }

  /// 获取评论列表
  Future<List<CoworkingComment>> getComments(
    String coworkingId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _repository.getComments(
      coworkingId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 获取评论数量
  Future<int> getCommentCount(String coworkingId) async {
    return await _repository.getCommentCount(coworkingId);
  }

  /// 删除评论
  Future<void> deleteComment(String commentId) async {
    return await _repository.deleteComment(commentId);
  }
}
