import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_review.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_review_repository.dart';

/// Coworking Review Repository Implementation
class CoworkingReviewRepository implements ICoworkingReviewRepository {
  final HttpService _httpService = Get.find();

  String _buildUrl(String path) => '${ApiConfig.apiBaseUrl}$path';

  @override
  Future<List<CoworkingReview>> getCoworkingReviews({
    required String coworkingId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _httpService.get(
        _buildUrl('/coworking/$coworkingId/reviews'),
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final data = response.data;
      if (data != null && data['items'] != null) {
        final items = data['items'] as List;
        return items.map((json) => _fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      log('❌ 获取 Coworking 评论失败: $e');
      rethrow;
    }
  }

  @override
  Future<CoworkingReview> addReview({
    required String coworkingId,
    required double rating,
    required String title,
    required String content,
    DateTime? visitDate,
    List<String>? photoUrls,
  }) async {
    try {
      final response = await _httpService.post(
        _buildUrl('/coworking/$coworkingId/reviews'),
        data: {
          'rating': rating,
          'title': title,
          'content': content,
          if (visitDate != null) 'visitDate': visitDate.toIso8601String(),
          if (photoUrls != null && photoUrls.isNotEmpty) 'photoUrls': photoUrls,
        },
      );

      // HttpService 拦截器已自动解包 ApiResponse
      // response.data 直接就是 data 字段的内容
      return _fromJson(response.data);
    } catch (e) {
      log('❌ 添加 Coworking 评论失败: $e');
      rethrow;
    }
  }

  @override
  Future<CoworkingReview> updateReview({
    required String reviewId,
    double? rating,
    String? title,
    String? content,
    DateTime? visitDate,
    List<String>? photoUrls,
  }) async {
    try {
      final response = await _httpService.put(
        _buildUrl('/coworking/reviews/$reviewId'),
        data: {
          if (rating != null) 'rating': rating,
          if (title != null) 'title': title,
          if (content != null) 'content': content,
          if (visitDate != null) 'visitDate': visitDate.toIso8601String(),
          if (photoUrls != null) 'photoUrls': photoUrls,
        },
      );

      return _fromJson(response.data);
    } catch (e) {
      log('❌ 更新 Coworking 评论失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await _httpService.delete(_buildUrl('/coworking/reviews/$reviewId'));
    } catch (e) {
      log('❌ 删除 Coworking 评论失败: $e');
      rethrow;
    }
  }

  @override
  Future<CoworkingReview?> getReviewById(String reviewId) async {
    try {
      final response = await _httpService.get(
        _buildUrl('/coworking/reviews/$reviewId'),
      );

      return _fromJson(response.data);
    } catch (e) {
      log('❌ 获取评论详情失败: $e');
      return null;
    }
  }

  @override
  Future<CoworkingReview?> getUserReviewForCoworking(String coworkingId) async {
    try {
      final response = await _httpService.get(
        _buildUrl('/coworking/$coworkingId/reviews/my-review'),
      );

      return _fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null; // 用户还没有评论
      }
      log('❌ 获取用户评论失败: $e');
      rethrow;
    }
  }

  /// JSON 转换为 CoworkingReview 实体
  CoworkingReview _fromJson(Map<String, dynamic> json) {
    return CoworkingReview(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? 'Anonymous',
      userAvatar: json['userAvatar'],
      coworkingId: json['coworkingId'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      visitDate:
          json['visitDate'] != null ? DateTime.parse(json['visitDate']) : null,
      photoUrls:
          json['photoUrls'] != null ? List<String>.from(json['photoUrls']) : [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isVerified: json['isVerified'] ?? false,
    );
  }
}
