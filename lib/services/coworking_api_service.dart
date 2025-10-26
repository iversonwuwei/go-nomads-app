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
  final String? description;
  final String address;
  final double? latitude;
  final double? longitude;
  final double? pricePerDay;
  final List<String>? amenities;
  final String? imageUrl;
  final String? phone;
  final String? email;
  final String? openingHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  CoworkingSpaceDto({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    this.latitude,
    this.longitude,
    this.pricePerDay,
    this.amenities,
    this.imageUrl,
    this.phone,
    this.email,
    this.openingHours,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CoworkingSpaceDto.fromJson(Map<String, dynamic> json) {
    return CoworkingSpaceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble(),
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      openingHours: json['openingHours'] as String?,
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
  final double? latitude;
  final double? longitude;
  final double? pricePerDay;
  final List<String>? amenities;
  final String? imageUrl;
  final String? phone;
  final String? email;
  final String? openingHours;

  CreateCoworkingRequest({
    required this.name,
    this.description,
    required this.address,
    this.latitude,
    this.longitude,
    this.pricePerDay,
    this.amenities,
    this.imageUrl,
    this.phone,
    this.email,
    this.openingHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'pricePerDay': pricePerDay,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'phone': phone,
      'email': email,
      'openingHours': openingHours,
    };
  }
}
