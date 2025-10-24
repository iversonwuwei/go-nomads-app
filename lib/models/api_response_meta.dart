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
