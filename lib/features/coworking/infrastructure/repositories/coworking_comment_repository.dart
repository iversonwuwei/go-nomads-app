import 'package:get/get.dart';

import '../../../../services/http_service.dart';
import '../../domain/entities/coworking_comment.dart';
import '../../domain/repositories/icoworking_comment_repository.dart';
import '../models/coworking_comment_dto.dart';

/// Coworking 评论仓储实现
class CoworkingCommentRepository implements ICoworkingCommentRepository {
  final HttpService _httpService = Get.find();

  @override
  Future<CoworkingComment> createComment({
    required String coworkingId,
    required String content,
    int rating = 0,
    List<String>? images,
  }) async {
    try {
      final response = await _httpService.post(
        '/coworking/$coworkingId/comments',
        data: {
          'content': content,
          'rating': rating,
          if (images != null && images.isNotEmpty) 'images': images,
        },
      );

      final commentData = response.data as Map<String, dynamic>;
      final dto = CoworkingCommentDto.fromJson(commentData);
      return dto.toEntity();
    } catch (e) {
      throw Exception('创建评论失败: ${e.toString()}');
    }
  }

  @override
  Future<List<CoworkingComment>> getComments(
    String coworkingId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _httpService.get(
        '/coworking/$coworkingId/comments',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final data = response.data as List<dynamic>? ?? [];
      return data
          .map((item) =>
              CoworkingCommentDto.fromJson(item as Map<String, dynamic>))
          .map((dto) => dto.toEntity())
          .toList();
    } catch (e) {
      throw Exception('获取评论列表失败: ${e.toString()}');
    }
  }

  @override
  Future<int> getCommentCount(String coworkingId) async {
    try {
      final comments = await getComments(coworkingId, page: 1, pageSize: 1);
      // TODO: 后端应该提供单独的 count endpoint
      return comments.length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await _httpService.delete('/coworking/comments/$commentId');
    } catch (e) {
      throw Exception('删除评论失败: ${e.toString()}');
    }
  }
}
