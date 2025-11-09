import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/services/http_service.dart';

import '../../domain/entities/interest.dart';
import '../../domain/repositories/i_interest_repository.dart';
import '../models/interest_dto.dart';

/// Interest Repository Implementation - 兴趣仓储实现
class InterestRepository implements IInterestRepository {
  final HttpService _httpService;

  InterestRepository(this._httpService);

  @override
  Future<Result<List<Interest>>> getInterests() async {
    try {
      final response = await _httpService.get('/interests');
      final List<dynamic> data = response.data as List<dynamic>;
      final interests = data
          .map((json) =>
              InterestDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
      return Success(interests);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取兴趣列表失败: $e'));
    }
  }

  @override
  Future<Result<Interest>> getInterestById(String id) async {
    try {
      final response = await _httpService.get('/interests/$id');
      final interest =
          InterestDto.fromJson(response.data as Map<String, dynamic>)
              .toDomain();
      return Success(interest);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取兴趣详情失败: $e'));
    }
  }

  @override
  Future<Result<List<Interest>>> getInterestsByCategory(String category) async {
    try {
      final response = await _httpService.get('/interests/category/$category');
      final List<dynamic> data = response.data as List<dynamic>;
      final interests = data
          .map((json) =>
              InterestDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
      return Success(interests);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('按类别获取兴趣列表失败: $e'));
    }
  }

  @override
  Future<Result<List<UserInterest>>> getUserInterests(String userId) async {
    try {
      final response = await _httpService.get('/interests/users/$userId');
      final List<dynamic> data = response.data as List<dynamic>;
      final userInterests = data
          .map((json) =>
              UserInterestDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
      return Success(userInterests);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取用户兴趣列表失败: $e'));
    }
  }

  @override
  Future<Result<UserInterest>> addUserInterest(
    String userId,
    AddUserInterestRequest request,
  ) async {
    try {
      final response = await _httpService.post(
        '/interests/users/$userId',
        data: {
          'interestId': request.interestId,
          'intensityLevel': request.intensityLevel,
        },
      );
      final userInterest =
          UserInterestDto.fromJson(response.data as Map<String, dynamic>)
              .toDomain();
      return Success(userInterest);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('添加用户兴趣失败: $e'));
    }
  }

  @override
  Future<Result<UserInterest>> updateUserInterestIntensity(
    String userId,
    String interestId,
    String intensityLevel,
  ) async {
    try {
      final response = await _httpService.put(
        '/interests/users/$userId/$interestId',
        data: {'intensityLevel': intensityLevel},
      );
      final userInterest =
          UserInterestDto.fromJson(response.data as Map<String, dynamic>)
              .toDomain();
      return Success(userInterest);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('更新用户兴趣强度失败: $e'));
    }
  }

  @override
  Future<Result<void>> removeUserInterest(
    String userId,
    String interestId,
  ) async {
    try {
      await _httpService.delete('/interests/users/$userId/$interestId');
      return const Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('删除用户兴趣失败: $e'));
    }
  }

  @override
  Future<Result<List<Interest>>> searchInterests(String query) async {
    try {
      final response = await _httpService
          .get('/interests/search', queryParameters: {'q': query});
      final List<dynamic> data = response.data as List<dynamic>;
      final interests = data
          .map((json) =>
              InterestDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
      return Success(interests);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('搜索兴趣失败: $e'));
    }
  }

  /// Convert HTTP exception to domain exception
  DomainException _convertHttpException(HttpException e) {
    switch (e.statusCode) {
      case 400:
        return ValidationException(e.message);
      case 401:
      case 403:
        return UnauthorizedException(e.message);
      case 404:
        return NotFoundException(e.message);
      case 500:
      case 502:
      case 503:
        return ServerException(e.message);
      case null:
        return NetworkException(e.message);
      default:
        return UnknownException(e.message);
    }
  }
}
