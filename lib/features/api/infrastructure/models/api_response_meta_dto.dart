import '../../../../models/api_response_meta.dart' as legacy;
import '../../domain/entities/api_response_meta.dart' as domain;

/// ApiResponseMeta DTO
class ApiResponseMetaDto {
  const ApiResponseMetaDto({
    required this.success,
    required this.message,
    required this.errors,
    this.statusCode,
  });

  final bool success;
  final String message;
  final List<String> errors;
  final int? statusCode;

  factory ApiResponseMetaDto.fromJson(Map<String, dynamic> json) {
    return ApiResponseMetaDto(
      success: json['success'] as bool,
      message: json['message'] as String,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>() ?? [],
      statusCode: json['statusCode'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'errors': errors,
      'statusCode': statusCode,
    };
  }

  domain.ApiResponseMeta toDomain() {
    return domain.ApiResponseMeta(
      success: success,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }

  factory ApiResponseMetaDto.fromLegacyModel(legacy.ApiResponseMeta model) {
    return ApiResponseMetaDto(
      success: model.success,
      message: model.message,
      errors: model.errors,
      statusCode: model.statusCode,
    );
  }

  ApiResponseMetaDto copyWith({
    bool? success,
    String? message,
    List<String>? errors,
    int? statusCode,
  }) {
    return ApiResponseMetaDto(
      success: success ?? this.success,
      message: message ?? this.message,
      errors: errors ?? this.errors,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}
