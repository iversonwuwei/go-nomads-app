import 'dart:developer';

import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/coworking/domain/entities/coworking_space.dart'
    as entity;
import 'package:go_nomads_app/features/coworking/domain/entities/verification_eligibility.dart';
import 'package:go_nomads_app/features/coworking/domain/repositories/icoworking_repository.dart';
import 'package:go_nomads_app/features/coworking/infrastructure/models/coworking_space_dto.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:get/get.dart';

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
      log('📡 Repository 调用 API:');
      log('   路径: /coworking');
      log('   参数: cityId=$cityId, page=$page, pageSize=$pageSize');

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

      log('✅ API 返回 ${items.length} 个 Coworking 空间');

      final spaces = items
          .map((item) =>
              CoworkingSpaceDto.fromJson(item as Map<String, dynamic>))
          .map((dto) => dto.toDomain())
          .toList();

      return Result.success(spaces);
    } catch (e, stackTrace) {
      log('❌ Repository 错误: $e');
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

      // HTTP 拦截器已自动解包响应，response.data 直接就是数据
      if (response.data is Map<String, dynamic>) {
        final dto = CoworkingSpaceDto.fromJson(
            response.data as Map<String, dynamic>);
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

      // HTTP 拦截器已自动解包响应，response.data 直接就是 count 数值
      if (response.data is int) {
        return Result.success(response.data as int);
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
        data: cityIds, // 直接发送 cityIds 数组
      );

      // 后端返回格式: { counts: [{ cityId, count }, ...] }
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final countsList = data['counts'] as List<dynamic>? ?? [];
        
        final counts = <String, int>{};
        for (final item in countsList) {
          if (item is Map<String, dynamic>) {
            final cityId = item['cityId'] as String?;
            final count = item['count'] as int? ?? 0;
            if (cityId != null) {
              counts[cityId] = count;
            }
          }
        }
        return Result.success(counts);
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

      log('📤 [CoworkingRepository] 创建 Coworking 空间: $requestData');

      final response = await _httpService.post(
        '/coworking',
        data: requestData,
      );

      // HTTP 拦截器已自动解包响应，response.data 直接就是 Coworking 数据
      log('📥 [CoworkingRepository] 响应类型: ${response.data.runtimeType}');
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final createdDto = CoworkingSpaceDto.fromJson(responseData);
        final createdSpace = createdDto.toDomain();
        log('✅ [CoworkingRepository] 创建成功: ${createdSpace.id}');
        return Result.success(createdSpace);
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

      log('📤 [CoworkingRepository] 发送更新请求: id=$id');
      final response =
          await _httpService.put('/coworking/$id', data: requestData);

      // HTTP 拦截器已自动解包响应，response.data 直接就是 Coworking 数据
      log('📥 [CoworkingRepository] 响应类型: ${response.data.runtimeType}');

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        try {
          // 直接解析 response.data，因为拦截器已经解包了
          final updatedDto = CoworkingSpaceDto.fromJson(responseData);
          final updatedSpace = updatedDto.toDomain();
          log('✅ [CoworkingRepository] 更新成功: ${updatedSpace.id}');
          return Result.success(updatedSpace);
        } catch (parseError, parseStack) {
          log('❌ [CoworkingRepository] 解析响应数据失败: $parseError');
          log('   堆栈: $parseStack');
          return Result.failure(
            UnknownException(
              '解析更新响应失败: ${parseError.toString()}',
              code: 'COWORKING_PARSE_ERROR',
              details: parseStack.toString(),
            ),
          );
        }
      }

      log('❌ [CoworkingRepository] 响应格式不正确: $responseData');
      throw ServerException('Failed to update coworking space');
    } catch (e, stackTrace) {
      log('❌ [CoworkingRepository] 更新失败: $e');
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

  @override
  Future<Result<VerificationEligibility>> checkVerificationEligibility(String id) async {
    try {
      final response = await _httpService.get('/coworking/$id/verification-eligibility');

      // HTTP 拦截器已自动解包响应，response.data 直接就是数据
      if (response.data is Map<String, dynamic>) {
        final eligibility = VerificationEligibility.fromJson(response.data as Map<String, dynamic>);
        return Result.success(eligibility);
      }

      throw ServerException('验证资格检查接口返回格式无效');
    } on HttpException catch (e) {
      return Result.failure(
        UnknownException(
          e.message,
          code: 'VERIFICATION_ELIGIBILITY_HTTP_${e.statusCode}',
          details: e.errors.isEmpty ? null : e.errors.join('\n'),
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(
        UnknownException(
          '检查验证资格失败: ${e.toString()}',
          code: 'VERIFICATION_ELIGIBILITY_ERROR',
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<entity.CoworkingSpace>> submitVerification(String id) async {
    try {
      final response = await _httpService.post('/coworking/$id/verifications');

      // HTTP 拦截器已自动解包响应，response.data 直接就是数据
      if (response.data is Map<String, dynamic>) {
        final dto = CoworkingSpaceDto.fromJson(response.data as Map<String, dynamic>);
        return Result.success(dto.toDomain());
      }

      throw ServerException('认证接口返回格式无效');
    } on HttpException catch (e) {
      return Result.failure(
        UnknownException(
          e.message,
          code: 'COWORKING_VERIFY_HTTP_${e.statusCode}',
          details: e.errors.isEmpty ? null : e.errors.join('\n'),
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(
        UnknownException(
          '提交认证失败: ${e.toString()}',
          code: 'COWORKING_VERIFY_ERROR',
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
