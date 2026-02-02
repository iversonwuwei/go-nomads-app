import 'dart:developer';

import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/hotel/domain/entities/hotel_review.dart';
import 'package:go_nomads_app/features/hotel/domain/repositories/i_hotel_review_repository.dart';
import 'package:go_nomads_app/services/http_service.dart';

/// Hotel Review Repository - 酒店评论数据仓储
/// 对接后端 AccommodationService API
class HotelReviewRepository implements IHotelReviewRepository {
  final HttpService _httpService;

  /// API 基础路径（通过 Gateway 路由到 AccommodationService）
  static const String _basePath = '/hotels';

  HotelReviewRepository(this._httpService);

  @override
  Future<Result<HotelReviewListResponse>> getHotelReviews({
    required String hotelId,
    int page = 1,
    int pageSize = 10,
    String sortBy = 'newest',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        'sortBy': sortBy,
      };

      final queryString = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      final url = '$_basePath/$hotelId/reviews?$queryString';

      log('📝 HotelReviewRepository.getHotelReviews: $url');

      final response = await _httpService.get(url);
      final reviewListResponse = HotelReviewListResponse.fromJson(response.data);

      log('📝 获取到 ${reviewListResponse.reviews.length} 条评论');
      return Success(reviewListResponse);
    } on HttpException catch (e) {
      log('❌ HotelReviewRepository.getHotelReviews 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelReviewRepository.getHotelReviews 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<HotelReview>> getReviewById(String reviewId) async {
    try {
      log('📝 HotelReviewRepository.getReviewById: $reviewId');
      final response = await _httpService.get('$_basePath/reviews/$reviewId');
      final review = HotelReview.fromJson(response.data);
      return Success(review);
    } on HttpException catch (e) {
      log('❌ HotelReviewRepository.getReviewById 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelReviewRepository.getReviewById 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<HotelReview?>> getMyReview(String hotelId) async {
    try {
      log('📝 HotelReviewRepository.getMyReview: $hotelId');
      final response = await _httpService.get('$_basePath/$hotelId/reviews/mine');

      // 如果没有评论，后端返回 null
      if (response.data == null) {
        return Success(null);
      }

      final review = HotelReview.fromJson(response.data);
      return Success(review);
    } on HttpException catch (e) {
      // 如果是 404，说明用户还没有评论过
      if (e.statusCode == 404) {
        return Success(null);
      }
      log('❌ HotelReviewRepository.getMyReview 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelReviewRepository.getMyReview 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<HotelReview>> createReview({
    required String hotelId,
    required CreateHotelReviewRequest request,
  }) async {
    try {
      log('📝 HotelReviewRepository.createReview: $hotelId');
      final requestData = request.toJson();
      log('📝 请求数据: $requestData');
      final response = await _httpService.post(
        '$_basePath/$hotelId/reviews',
        data: requestData,
      );
      final review = HotelReview.fromJson(response.data);
      log('📝 评论创建成功: ${review.id}');
      return Success(review);
    } on HttpException catch (e) {
      log('❌ HotelReviewRepository.createReview 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelReviewRepository.createReview 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<HotelReview>> updateReview({
    required String reviewId,
    required UpdateHotelReviewRequest request,
  }) async {
    try {
      log('📝 HotelReviewRepository.updateReview: $reviewId');
      final response = await _httpService.put(
        '$_basePath/reviews/$reviewId',
        data: request.toJson(),
      );
      final review = HotelReview.fromJson(response.data);
      log('📝 评论更新成功: ${review.id}');
      return Success(review);
    } on HttpException catch (e) {
      log('❌ HotelReviewRepository.updateReview 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelReviewRepository.updateReview 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteReview(String reviewId) async {
    try {
      log('📝 HotelReviewRepository.deleteReview: $reviewId');
      await _httpService.delete('$_basePath/reviews/$reviewId');
      log('📝 评论删除成功');
      return Success(null);
    } on HttpException catch (e) {
      log('❌ HotelReviewRepository.deleteReview 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelReviewRepository.deleteReview 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<void>> markReviewHelpful(String reviewId) async {
    try {
      log('📝 HotelReviewRepository.markReviewHelpful: $reviewId');
      await _httpService.post('$_basePath/reviews/$reviewId/helpful');
      log('📝 标记有帮助成功');
      return Success(null);
    } on HttpException catch (e) {
      log('❌ HotelReviewRepository.markReviewHelpful 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelReviewRepository.markReviewHelpful 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getRatingStats(String hotelId) async {
    try {
      log('📝 HotelReviewRepository.getRatingStats: $hotelId');
      final response = await _httpService.get('$_basePath/$hotelId/reviews/stats');
      return Success(response.data);
    } on HttpException catch (e) {
      log('❌ HotelReviewRepository.getRatingStats 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelReviewRepository.getRatingStats 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  /// 转换 HTTP 异常为领域异常
  DomainException _convertHttpException(HttpException e) {
    if (e.statusCode == null) {
      return NetworkException(e.message);
    }

    switch (e.statusCode!) {
      case 400:
        return ValidationException(e.message, details: e.errors);
      case 401:
      case 403:
        return UnauthorizedException(e.message);
      case 404:
        return NotFoundException(e.message);
      case >= 500:
        return ServerException(e.message);
      default:
        return NetworkException(e.message, code: e.statusCode.toString());
    }
  }
}
