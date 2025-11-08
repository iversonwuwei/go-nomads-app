/// ApiResponseMeta Value Object - API响应元数据
class ApiResponseMeta {
  const ApiResponseMeta({
    required this.success,
    required this.message,
    required this.errors,
    this.statusCode,
  });

  final bool success;
  final String message;
  final List<String> errors;
  final int? statusCode;

  // Business logic methods
  bool get hasErrors => errors.isNotEmpty;

  bool get isSuccessful => success && !hasErrors;

  ApiResponseMeta copyWith({
    bool? success,
    String? message,
    List<String>? errors,
    int? statusCode,
  }) {
    return ApiResponseMeta(
      success: success ?? this.success,
      message: message ?? this.message,
      errors: errors ?? this.errors,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}
