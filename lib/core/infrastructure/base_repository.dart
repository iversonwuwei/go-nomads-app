import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:dio/dio.dart';

/// API异常处理工具类
class ApiExceptionHandler {
  /// 将Dio异常转换为领域异常
  static DomainException fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          '网络连接超时',
          code: 'TIMEOUT',
          details: e.message,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (statusCode == 401) {
          // 使用后端返回的 message（如"密码错误"）
          return UnauthorizedException(
            data?['message'] ?? '未授权访问',
            code: 'UNAUTHORIZED',
            details: data,
          );
        } else if (statusCode == 404) {
          // 使用后端返回的 message（如"该邮箱尚未注册，请先注册账号"）
          return NotFoundException(
            data?['message'] ?? '资源未找到',
            code: 'NOT_FOUND',
            details: data,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(
            '服务器错误',
            code: 'SERVER_ERROR',
            details: data,
          );
        } else if (statusCode != null && statusCode >= 400) {
          return BusinessLogicException(
            data?['message'] ?? '请求失败',
            code: data?['code'] ?? 'BAD_REQUEST',
            details: data,
          );
        }
        return ServerException(
          '未知服务器错误',
          code: 'UNKNOWN_SERVER_ERROR',
          details: data,
        );

      case DioExceptionType.cancel:
        return NetworkException(
          '请求已取消',
          code: 'CANCELLED',
          details: e.message,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          '网络连接失败',
          code: 'CONNECTION_ERROR',
          details: e.message,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          'SSL证书验证失败',
          code: 'BAD_CERTIFICATE',
          details: e.message,
        );

      case DioExceptionType.unknown:
        return UnknownException(
          '未知错误: ${e.message}',
          code: 'UNKNOWN',
          details: e.error,
        );
    }
  }

  /// 统一异常处理包装器
  static Future<Result<T>> handleApiCall<T>(
    Future<T> Function() apiCall,
  ) async {
    try {
      final data = await apiCall();
      return Success(data);
    } on DioException catch (e) {
      return Failure(fromDioException(e));
    } on DomainException catch (e) {
      return Failure(e);
    } catch (e, stackTrace) {
      log('Unexpected error: $e\n$stackTrace');
      return Failure(UnknownException(
        '发生未知错误: $e',
        code: 'UNEXPECTED',
        details: stackTrace.toString(),
      ));
    }
  }

  /// 同步方法的异常处理包装器
  static Result<T> handleSync<T>(T Function() operation) {
    try {
      final data = operation();
      return Success(data);
    } on DomainException catch (e) {
      return Failure(e);
    } catch (e, stackTrace) {
      log('Unexpected error: $e\n$stackTrace');
      return Failure(UnknownException(
        '发生未知错误: $e',
        code: 'UNEXPECTED',
        details: stackTrace.toString(),
      ));
    }
  }
}

/// Repository基类实现
///
/// 提供通用的异常处理和Result包装
abstract class BaseRepository {
  /// 异常处理包装
  Future<Result<T>> execute<T>(Future<T> Function() operation) {
    return ApiExceptionHandler.handleApiCall(operation);
  }

  /// 同步操作包装
  Result<T> executeSync<T>(T Function() operation) {
    return ApiExceptionHandler.handleSync(operation);
  }
}
