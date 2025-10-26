import 'package:dio/dio.dart';

/// Coworking API Service
/// 负责与后端 CoworkingService 交互
class CoworkingApiService {
  final Dio _dio;
  final String baseUrl;

  CoworkingApiService({
    Dio? dio,
    String? baseUrl,
  })  : _dio = dio ?? Dio(),
        baseUrl = baseUrl ?? 'http://localhost:8006/api/v1/coworking';

  /// 创建 Coworking 空间
  Future<ApiResponse<CoworkingSpaceDto>> createCoworkingSpace(
    CreateCoworkingRequest request,
  ) async {
    try {
      final response = await _dio.post(
        baseUrl,
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      return ApiResponse<CoworkingSpaceDto>.fromJson(
        response.data,
        (json) => CoworkingSpaceDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse<CoworkingSpaceDto>.fromJson(
          e.response!.data,
          (json) => CoworkingSpaceDto.fromJson(json as Map<String, dynamic>),
        );
      }
      throw Exception('创建失败: ${e.message}');
    }
  }

  /// 获取 Coworking 空间列表（分页）
  Future<ApiResponse<PaginatedResponse<CoworkingSpaceDto>>>
      getCoworkingSpaces({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      return ApiResponse<PaginatedResponse<CoworkingSpaceDto>>.fromJson(
        response.data,
        (json) => PaginatedResponse<CoworkingSpaceDto>.fromJson(
          json as Map<String, dynamic>,
          (item) => CoworkingSpaceDto.fromJson(item as Map<String, dynamic>),
        ),
      );
    } on DioException catch (e) {
      throw Exception('获取列表失败: ${e.message}');
    }
  }

  /// 根据 ID 获取单个 Coworking 空间
  Future<ApiResponse<CoworkingSpaceDto>> getCoworkingById(String id) async {
    try {
      final response = await _dio.get('$baseUrl/$id');

      return ApiResponse<CoworkingSpaceDto>.fromJson(
        response.data,
        (json) => CoworkingSpaceDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception('获取详情失败: ${e.message}');
    }
  }

  /// 更新 Coworking 空间
  Future<ApiResponse<CoworkingSpaceDto>> updateCoworkingSpace(
    String id,
    CreateCoworkingRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '$baseUrl/$id',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      return ApiResponse<CoworkingSpaceDto>.fromJson(
        response.data,
        (json) => CoworkingSpaceDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception('更新失败: ${e.message}');
    }
  }

  /// 删除 Coworking 空间
  Future<ApiResponse<String>> deleteCoworkingSpace(String id) async {
    try {
      final response = await _dio.delete('$baseUrl/$id');

      return ApiResponse<String>.fromJson(
        response.data,
        (json) => json.toString(),
      );
    } on DioException catch (e) {
      throw Exception('删除失败: ${e.message}');
    }
  }
}

/// API 统一响应格式
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String> errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors = const [],
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

/// 分页响应格式
class PaginatedResponse<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List<dynamic>)
          .map((item) => fromJsonT(item))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

/// Coworking 空间 DTO（与后端对应）
class CoworkingSpaceDto {
  final String id;
  final String name;
  final String? cityId;
  final String? description;
  final String address;
  final double? latitude;
  final double? longitude;
  final double? pricePerDay;
  final double? pricePerMonth;
  final double? pricePerHour;
  final String currency;
  final double rating;
  final int reviewCount;
  final double? wifiSpeed;
  final bool hasMeetingRoom;
  final bool hasCoffee;
  final bool hasParking;
  final bool has247Access;
  final List<String>? amenities;
  final int? capacity;
  final String? imageUrl;
  final List<String>? images;
  final String? phone;
  final String? email;
  final String? website;
  final String? openingHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CoworkingSpaceDto({
    required this.id,
    required this.name,
    this.cityId,
    this.description,
    required this.address,
    this.latitude,
    this.longitude,
    this.pricePerDay,
    this.pricePerMonth,
    this.pricePerHour,
    this.currency = 'USD',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.wifiSpeed,
    this.hasMeetingRoom = false,
    this.hasCoffee = false,
    this.hasParking = false,
    this.has247Access = false,
    this.amenities,
    this.capacity,
    this.imageUrl,
    this.images,
    this.phone,
    this.email,
    this.website,
    this.openingHours,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CoworkingSpaceDto.fromJson(Map<String, dynamic> json) {
    return CoworkingSpaceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      cityId: json['cityId'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble(),
      pricePerMonth: (json['pricePerMonth'] as num?)?.toDouble(),
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      wifiSpeed: (json['wifiSpeed'] as num?)?.toDouble(),
      hasMeetingRoom: json['hasMeetingRoom'] as bool? ?? false,
      hasCoffee: json['hasCoffee'] as bool? ?? false,
      hasParking: json['hasParking'] as bool? ?? false,
      has247Access: json['has247Access'] as bool? ?? false,
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      capacity: json['capacity'] as int?,
      imageUrl: json['imageUrl'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      openingHours: json['openingHours'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// 创建 Coworking 空间请求
class CreateCoworkingRequest {
  final String name;
  final String? description;
  final String address;
  final String? cityId;
  final double? latitude;
  final double? longitude;
  final double? pricePerDay;
  final double? pricePerMonth;
  final double? pricePerHour;
  final String? currency;
  final double? wifiSpeed;
  final bool? hasMeetingRoom;
  final bool? hasCoffee;
  final bool? hasParking;
  final bool? has247Access;
  final List<String>? amenities;
  final int? capacity;
  final String? imageUrl;
  final List<String>? images;
  final String? phone;
  final String? email;
  final String? website;
  final String? openingHours;

  CreateCoworkingRequest({
    required this.name,
    this.description,
    required this.address,
    this.cityId,
    this.latitude,
    this.longitude,
    this.pricePerDay,
    this.pricePerMonth,
    this.pricePerHour,
    this.currency,
    this.wifiSpeed,
    this.hasMeetingRoom,
    this.hasCoffee,
    this.hasParking,
    this.has247Access,
    this.amenities,
    this.capacity,
    this.imageUrl,
    this.images,
    this.phone,
    this.email,
    this.website,
    this.openingHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'address': address,
      if (cityId != null) 'cityId': cityId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (pricePerDay != null) 'pricePerDay': pricePerDay,
      if (pricePerMonth != null) 'pricePerMonth': pricePerMonth,
      if (pricePerHour != null) 'pricePerHour': pricePerHour,
      if (currency != null) 'currency': currency,
      if (wifiSpeed != null) 'wifiSpeed': wifiSpeed,
      if (hasMeetingRoom != null) 'hasMeetingRoom': hasMeetingRoom,
      if (hasCoffee != null) 'hasCoffee': hasCoffee,
      if (hasParking != null) 'hasParking': hasParking,
      if (has247Access != null) 'has247Access': has247Access,
      if (amenities != null) 'amenities': amenities,
      if (capacity != null) 'capacity': capacity,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (images != null) 'images': images,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (openingHours != null) 'openingHours': openingHours,
    };
  }
}
