import '../../../../core/domain/result.dart';
import '../../../../services/coworking_api_service.dart';
import '../../domain/entities/coworking_space.dart' as entity;
import '../../domain/repositories/icoworking_repository.dart';
import '../models/coworking_space_dto.dart';

/// Coworking Repository 实现
/// 负责从 API 获取 Coworking 数据并转换为领域实体
class CoworkingRepository implements ICoworkingRepository {
  final CoworkingApiService _apiService;

  CoworkingRepository({CoworkingApiService? apiService})
      : _apiService = apiService ?? CoworkingApiService();

  @override
  Future<Result<List<entity.CoworkingSpace>>> getCoworkingSpacesByCity(
    String cityId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.getCoworkingSpacesByCity(
        cityId,
        page: page,
        pageSize: pageSize,
      );

      final items = response['items'] as List<dynamic>? ?? [];

      final spaces = items
          .map((item) =>
              CoworkingSpaceDto.fromJson(item as Map<String, dynamic>))
          .map((dto) => dto.toDomain())
          .toList();

      return Result.success(spaces);
    } catch (e, stackTrace) {
      return Result.failure(
        UnknownException(
          '获取城市 Coworking 列表失败: ${e.toString()}',
          code: 'COWORKING_FETCH_ERROR',
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<List<entity.CoworkingSpace>>> getCoworkingSpaces({
    int page = 1,
    int pageSize = 20,
    String? cityId,
  }) async {
    try {
      final response = await _apiService.getCoworkingSpaces(
        page: page,
        pageSize: pageSize,
        cityId: cityId,
      );

      final items = response['items'] as List<dynamic>? ?? [];

      final spaces = items
          .map((item) =>
              CoworkingSpaceDto.fromJson(item as Map<String, dynamic>))
          .map((dto) => dto.toDomain())
          .toList();

      return Result.success(spaces);
    } catch (e, stackTrace) {
      return Result.failure(
        UnknownException(
          '获取 Coworking 列表失败: ${e.toString()}',
          code: 'COWORKING_FETCH_ERROR',
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<entity.CoworkingSpace>> getCoworkingById(String id) async {
    try {
      final response = await _apiService.getCoworkingById(id);

      final dto = CoworkingSpaceDto.fromJson(response);
      final space = dto.toDomain();

      return Result.success(space);
    } catch (e, stackTrace) {
      return Result.failure(
        UnknownException(
          '获取 Coworking 详情失败: ${e.toString()}',
          code: 'COWORKING_DETAIL_ERROR',
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<int>> getCityCoworkingCount(String cityId) async {
    try {
      final count = await _apiService.getCityCoworkingCount(cityId);
      return Result.success(count);
    } catch (e, stackTrace) {
      return Result.failure(
        UnknownException(
          '获取城市 Coworking 数量失败: ${e.toString()}',
          code: 'COWORKING_COUNT_ERROR',
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, int>>> getCoworkingCountByCities(
    List<String> cityIds,
  ) async {
    try {
      final counts = await _apiService.getCoworkingCountByCities(cityIds);
      return Result.success(counts);
    } catch (e, stackTrace) {
      return Result.failure(
        UnknownException(
          '批量获取 Coworking 数量失败: ${e.toString()}',
          code: 'COWORKING_BATCH_COUNT_ERROR',
          details: stackTrace.toString(),
        ),
      );
    }
  }
}
