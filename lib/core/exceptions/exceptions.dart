/// 应用异常基类
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    if (code != null) {
      return '[$code] $message';
    }
    return message;
  }
}

/// 网络异常
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});
}

/// 服务器异常
class ServerException extends AppException {
  final int? statusCode;

  ServerException(super.message,
      {this.statusCode, super.code, super.originalError});

  @override
  String toString() {
    if (statusCode != null) {
      return '[$statusCode] $message';
    }
    return super.toString();
  }
}

/// 数据库异常
class DatabaseException extends AppException {
  DatabaseException(super.message, {super.code, super.originalError});
}

/// 认证异常
class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.code, super.originalError});
}

/// 验证异常
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  ValidationException(super.message,
      {this.errors, super.code, super.originalError});
}

/// 未找到异常
class NotFoundException extends AppException {
  NotFoundException(super.message, {super.code, super.originalError});
}

/// 缓存异常
class CacheException extends AppException {
  CacheException(super.message, {super.code, super.originalError});
}
