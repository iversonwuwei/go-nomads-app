import 'package:get/get.dart';

import '../../../../core/domain/result.dart';
import '../../../../services/http_service.dart';
import '../../domain/entities/coworking_space.dart' as entity;
import '../../domain/repositories/icoworking_repository.dart';
import '../models/coworking_space_dto.dart';

/// Coworking Repository 实现
/// 负责从 API 获取 Coworking 数据并转换为领域实体
class CoworkingRepository implements ICoworkingRepository {
  final HttpService _httpService = Get.find();

  @override
  Future<Result<List<entity.CoworkingSpace>>> getCoworkingSpacesByCity(
    String cityId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      print('📡 Repository 调用 API:');
      print('   路径: /coworking');
      print('   参数: cityId=$cityId, page=$page, pageSize=$pageSize');
      
      final response = await _httpService.get(
        '/coworking',
        queryParameters: {
          'cityId': cityId,
          'page': page,
          'pageSize': pageSize,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      print('✅ API 返回 ${items.length} 个 Coworking 空间');

      final spaces = items
          .map((item) =>
              CoworkingSpaceDto.fromJson(item as Map<String, dynamic>))
          .map((dto) => dto.toDomain())
          .toList();

      return Result.success(spaces);
    } catch (e, stackTrace) {
      print('❌ Repository 错误: $e');
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
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (cityId != null) {
        queryParams['cityId'] = cityId;
      }

      final response = await _httpService.get(
        '/coworking-spaces',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

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
      final response = await _httpService.get('/coworking/$id');

      if (response.data['success'] == true && response.data['data'] != null) {
        final dto = CoworkingSpaceDto.fromJson(
            response.data['data'] as Map<String, dynamic>);
        final space = dto.toDomain();

        return Result.success(space);
      }

      throw NotFoundException('Coworking space not found');
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
      final response =
          await _httpService.get('/coworking/cities/$cityId/count');

      if (response.data['success'] == true && response.data['data'] != null) {
        final count = response.data['data'] as int;
        return Result.success(count);
      }

      throw ServerException('Failed to get coworking count');
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
      final response = await _httpService.post(
        '/coworking/cities/counts',
        data: {'cityIds': cityIds},
      );
      
      if (response.data['success'] == true && response.data['data'] != null) {
        final counts = response.data['data'] as Map<String, dynamic>;
        return Result.success(counts.map((k, v) => MapEntry(k, v as int)));
      }

      throw ServerException('Failed to get coworking counts');
    } catch (e, stackTrace) {
      return Result.failure(
        UnknownException(
          '批量获取城市 Coworking 数量失败: ${e.toString()}',
          code: 'COWORKING_COUNTS_ERROR',
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<entity.CoworkingSpace>> createCoworkingSpace(
    entity.CoworkingSpace space,
  ) async {
    try {
      final dto = _convertEntityToDto(space);
      final requestData = dto.toJson();

      print('Creating coworking space with data: $requestData');

      final response = await _httpService.post(
        '/coworking',
        data: requestData,
      );

      // 解析响应数据
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // 检查是否有包装的 success/data 结构
        if (responseData['success'] == true && responseData['data'] != null) {
          final createdDto = CoworkingSpaceDto.fromJson(
              responseData['data'] as Map<String, dynamic>);
          final createdSpace = createdDto.toDomain();
          return Result.success(createdSpace);
        } else {
          // 直接使用 response.data 作为 DTO
          final createdDto = CoworkingSpaceDto.fromJson(responseData);
          final createdSpace = createdDto.toDomain();
          return Result.success(createdSpace);
        }
      }

      throw ServerException('Invalid response format');
    } on HttpException catch (e) {
      // 保留 HttpException 的详细错误信息
      return Result.failure(
        UnknownException(
          e.message,
          code: 'HTTP_ERROR_${e.statusCode}',
          details: e.errors.isEmpty ? null : e.errors.join('\n'),
        ),
      );
    } catch (e, stackTrace) {
      // 处理其他未预期的异常
      return Result.failure(
        UnknownException(
          '创建 Coworking 空间失败: ${e.toString()}',
          code: 'COWORKING_CREATE_ERROR',
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<entity.CoworkingSpace>> updateCoworkingSpace(
    String id,
    entity.CoworkingSpace space,
  ) async {
    try {
      final dto = _convertEntityToDto(space);
      final requestData = dto.toJson();

      final response =
          await _httpService.put('/coworking/$id', data: requestData);

      if (response.data['success'] == true && response.data['data'] != null) {
        final updatedDto =
            CoworkingSpaceDto.fromJson(
            response.data['data'] as Map<String, dynamic>);
        final updatedSpace = updatedDto.toDomain();

        return Result.success(updatedSpace);
      }

      throw ServerException('Failed to update coworking space');
    } catch (e, stackTrace) {
      return Result.failure(
        UnknownException(
          '更新 Coworking 空间失败: ${e.toString()}',
          code: 'COWORKING_UPDATE_ERROR',
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteCoworkingSpace(String id) async {
    try {
      await _httpService.delete('/coworking/$id');
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(
        UnknownException(
          '删除 Coworking 空间失败: ${e.toString()}',
          code: 'COWORKING_DELETE_ERROR',
          details: stackTrace.toString(),
        ),
      );
    }
  }

  /// 将领域实体转换为 DTO
  /// 私有辅助方法,用于创建和更新操作
  CoworkingSpaceDto _convertEntityToDto(entity.CoworkingSpace space) {
    return CoworkingSpaceDto(
      id: space.id,
      name: space.name,
      cityId: space.location.cityId, // 添加 cityId
      address: space.location.address,
      city: space.location.city,
      country: space.location.country,
      latitude: space.location.latitude,
      longitude: space.location.longitude,
      imageUrl: space.spaceInfo.imageUrl,
      images: space.spaceInfo.images,
      rating: space.spaceInfo.rating,
      reviewCount: space.spaceInfo.reviewCount,
      description: space.spaceInfo.description,
      pricing: CoworkingPricingDto(
        hourlyRate: space.pricing.hourlyRate,
        dailyRate: space.pricing.dailyRate,
        weeklyRate: space.pricing.weeklyRate,
        monthlyRate: space.pricing.monthlyRate,
        currency: space.pricing.currency,
        hasFreeTrial: space.pricing.hasFreeTrial,
        trialDuration: space.pricing.trialDuration,
      ),
      amenities: CoworkingAmenitiesDto(
        hasWifi: space.amenities.hasWifi,
        hasCoffee: space.amenities.hasCoffee,
        hasPrinter: space.amenities.hasPrinter,
        hasMeetingRoom: space.amenities.hasMeetingRoom,
        hasPhoneBooth: space.amenities.hasPhoneBooth,
        hasKitchen: space.amenities.hasKitchen,
        hasParking: space.amenities.hasParking,
        hasLocker: space.amenities.hasLocker,
        has24HourAccess: space.amenities.has24HourAccess,
        hasAirConditioning: space.amenities.hasAirConditioning,
        hasStandingDesk: space.amenities.hasStandingDesk,
        hasShower: space.amenities.hasShower,
        hasBike: space.amenities.hasBike,
        hasEventSpace: space.amenities.hasEventSpace,
        hasPetFriendly: space.amenities.hasPetFriendly,
        additionalAmenities: space.amenities.additionalAmenities,
      ),
      specs: CoworkingSpecsDto(
        wifiSpeed: space.specs.wifiSpeed,
        numberOfDesks: space.specs.numberOfDesks,
        numberOfMeetingRooms: space.specs.numberOfMeetingRooms,
        capacity: space.specs.capacity,
        noiseLevel: space.specs.noiseLevel?.toString(),
        hasNaturalLight: space.specs.hasNaturalLight,
        spaceType: space.specs.spaceType?.toString(),
      ),
      openingHours: space.operationHours.hours,
      phone: space.contactInfo.phone,
      email: space.contactInfo.email,
      website: space.contactInfo.website,
      isVerified: space.isVerified,
      lastUpdated: space.lastUpdated?.toIso8601String(),
    );
  }
}
