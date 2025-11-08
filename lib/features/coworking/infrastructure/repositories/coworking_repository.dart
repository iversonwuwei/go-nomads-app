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
      final response = await _httpService.get(
        '/coworking-spaces',
        queryParameters: {
          'cityId': cityId,
          'page': page,
          'pageSize': pageSize,
        },
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
      final response = await _httpService.get('/coworking-spaces/$id');

      final dto =
          CoworkingSpaceDto.fromJson(response.data as Map<String, dynamic>);
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
      final response =
          await _httpService.get('/coworking-spaces/cities/$cityId/count');
      final count = response.data as int;
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
      final response = await _httpService.post(
        '/coworking-spaces/cities/counts',
        data: {'cityIds': cityIds},
      );
      final counts = response.data as Map<String, dynamic>;
      return Result.success(counts.map((k, v) => MapEntry(k, v as int)));
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
      // 将领域实体转换为 DTO 再转为 JSON
      final dto = _convertEntityToDto(space);
      final requestData = dto.toJson();

      final response =
          await _httpService.post('/coworking-spaces', data: requestData);

      final createdDto =
          CoworkingSpaceDto.fromJson(response.data as Map<String, dynamic>);
      final createdSpace = createdDto.toDomain();

      return Result.success(createdSpace);
    } catch (e, stackTrace) {
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
          await _httpService.put('/coworking-spaces/$id', data: requestData);

      final updatedDto =
          CoworkingSpaceDto.fromJson(response.data as Map<String, dynamic>);
      final updatedSpace = updatedDto.toDomain();

      return Result.success(updatedSpace);
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
      await _httpService.delete('/coworking-spaces/$id');
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
