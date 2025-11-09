import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;

import '../config/api_config.dart';
import '../routes/app_routes.dart';
import 'token_storage_service.dart';

/// API 响应元数据
class ApiResponseMeta {
  final bool success;
  final String message;
  final List<String> errors;
  final int? statusCode;

  ApiResponseMeta({
    required this.success,
    required this.message,
    required this.errors,
    this.statusCode,
  });
}

/// HTTP 服务类
/// 基于 Dio 封装的 HTTP 请求服务
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;

  late Dio _dio;
  String? _authToken;
  String? _userId;
  
  // Token 刷新回调
  Future<String?> Function()? _onTokenRefreshCallback;

  // 用于防止重复刷新
  bool _isRefreshing = false;

  static const String apiResponseMetaKey = '__apiResponseMeta';
  static const String apiResponseRawKey = '__apiResponseRaw';
  static const String disableApiResponseUnwrapKey =
      '__disableApiResponseUnwrap';

  HttpService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.currentApiBaseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  /// 设置拦截器
  void _setupInterceptors() {
    // 请求拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 从 SQLite/SharedPreferences 动态获取 token
          final tokenService = TokenStorageService();
          final token = await tokenService.getAccessToken();
          
          // 添加认证 token
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            // 同步更新内存中的 token（用于向后兼容）
            _authToken = token;
          }

          // 添加用户ID header
          if (_userId != null && _userId!.isNotEmpty) {
            options.headers['X-User-Id'] = _userId;
          }

          // 打印请求日志 (仅开发环境)
          if (kDebugMode) {
            print('🚀 REQUEST[${options.method}] => ${options.uri}');
            print('Headers: ${options.headers}');
            if (options.data != null) {
              print('Data: ${options.data}');
            }
            if (options.queryParameters.isNotEmpty) {
              print('Query: ${options.queryParameters}');
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 打印响应日志 (仅开发环境)
          if (kDebugMode) {
            print(
                '✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
            print('Data: ${response.data}');
          }

          final disableUnwrap =
              response.requestOptions.extra[disableApiResponseUnwrapKey] ==
                  true;
          if (!disableUnwrap) {
            final envelope = _unwrapApiResponse(response);

            if (envelope != null) {
              if (envelope.meta.success) {
                response.data = envelope.data;
              } else {
                return handler.reject(
                  DioException(
                    requestOptions: response.requestOptions,
                    response: response,
                    type: DioExceptionType.badResponse,
                    error: HttpException(
                      envelope.meta.message.isNotEmpty
                          ? envelope.meta.message
                          : _handleStatusCode(response.statusCode),
                      response.statusCode,
                      envelope.meta.errors.isEmpty
                          ? null
                          : envelope.meta.errors,
                    ),
                  ),
                );
              }
            }
          }

          return handler.next(response);
        },
        onError: (error, handler) async {
          // 打印错误日志
          if (kDebugMode) {
            print(
                '❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
            print('Message: ${error.message}');
            if (error.response?.data != null) {
              print('Response: ${error.response?.data}');
            }
          }

          final response = error.response;
          if (response != null) {
            final envelope = _unwrapApiResponse(response);
            if (envelope != null) {
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  response: response,
                  type: error.type,
                  error: HttpException(
                    envelope.meta.message.isNotEmpty
                        ? envelope.meta.message
                        : _handleStatusCode(response.statusCode),
                    response.statusCode,
                    envelope.meta.errors.isEmpty ? null : envelope.meta.errors,
                  ),
                  stackTrace: error.stackTrace,
                ),
              );
            }
          }

          // 401 未授权 - token 过期或无效
          if (error.response?.statusCode == 401) {
            if (kDebugMode) {
              print('⚠️ 401 Unauthorized - 认证失败');
            }

            // 检查是否有 refresh token
            final tokenService = TokenStorageService();
            final refreshToken = await tokenService.getRefreshToken();

            // 如果没有 refresh token，说明用户未登录，直接跳转登录页
            if (refreshToken == null || refreshToken.isEmpty) {
              if (kDebugMode) {
                print('❌ 无 refresh token，跳转登录页面');
              }
              
              // 🔥 清除所有认证信息
              await tokenService.clearTokens();
              _authToken = null;
              _userId = null;
              
              // 🔥 跳转到登录页面
              getx.Get.offAllNamed(AppRoutes.login);
              
              return handler.next(error);
            }

            // 有 refresh token 且有刷新回调，尝试自动刷新
            if (_onTokenRefreshCallback != null && !_isRefreshing) {
              try {
                _isRefreshing = true;
                if (kDebugMode) {
                  print('🔄 检测到 refresh token，尝试自动刷新...');
                }

                final newToken = await _onTokenRefreshCallback!();

                if (newToken != null && newToken.isNotEmpty) {
                  if (kDebugMode) {
                    print('✅ Token 刷新成功，重试请求');
                  }

                  // 更新请求头
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newToken';
                  _authToken = newToken;

                  // 重试原始请求
                  final opts = Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  );

                  final response = await _dio.request(
                    error.requestOptions.path,
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                    options: opts,
                  );

                  _isRefreshing = false;
                  return handler.resolve(response);
                } else {
                  if (kDebugMode) {
                    print('❌ Token 刷新失败，清除认证信息并跳转登录页');
                  }
                  
                  // 🔥 刷新失败，清除所有认证信息
                  await tokenService.clearTokens();
                  _authToken = null;
                  _userId = null;
                  
                  // 🔥 跳转到登录页面
                  getx.Get.offAllNamed(AppRoutes.login);
                }
              } catch (refreshError) {
                if (kDebugMode) {
                  print('❌ Token 刷新异常: $refreshError');
                }
                
                // 🔥 刷新异常，清除所有认证信息
                await tokenService.clearTokens();
                _authToken = null;
                _userId = null;
                
                // 🔥 跳转到登录页面
                getx.Get.offAllNamed(AppRoutes.login);
              } finally {
                _isRefreshing = false;
              }
            } else if (_onTokenRefreshCallback == null) {
              // 没有刷新回调，直接跳转登录
              if (kDebugMode) {
                print('❌ 无 Token 刷新回调，跳转登录页面');
              }
              
              // 🔥 清除所有认证信息
              await tokenService.clearTokens();
              _authToken = null;
              _userId = null;
              
              // 🔥 跳转到登录页面
              getx.Get.offAllNamed(AppRoutes.login);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// 设置认证 Token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// 获取当前 Token
  String? get authToken => _authToken;

  /// 清除 Token
  void clearAuthToken() {
    _authToken = null;
  }
  
  /// 设置 Token 刷新回调
  /// 当收到 401 错误时，会调用此回调尝试刷新 token
  /// 回调应返回新的 access token，如果刷新失败返回 null
  void setTokenRefreshCallback(Future<String?> Function() callback) {
    _onTokenRefreshCallback = callback;
  }

  /// 清除 Token 刷新回调
  void clearTokenRefreshCallback() {
    _onTokenRefreshCallback = null;
  }

  /// 设置用户ID
  void setUserId(String? userId) {
    _userId = userId;
  }

  /// 获取当前用户ID
  String? get userId => _userId;

  /// 清除用户ID
  void clearUserId() {
    _userId = null;
  }

  /// 更新基础 URL
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// GET 请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST 请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH 请求
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 下载文件
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 上传文件
  Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 统一错误处理
  Exception _handleError(DioException error) {
    if (error.error is HttpException) {
      return error.error as HttpException;
    }

    String errorMessage;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = '连接超时，请检查网络设置';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = '发送超时，请检查网络设置';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = '响应超时，请稍后重试';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleStatusCode(error.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        errorMessage = '请求已取消';
        break;
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          errorMessage = '网络连接失败，请检查网络设置';
        } else {
          errorMessage = '未知错误: ${error.message}';
        }
        break;
      default:
        errorMessage = '网络请求失败';
    }

    return HttpException(errorMessage, error.response?.statusCode);
  }

  /// 处理 HTTP 状态码
  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请先登录';
      case 403:
        return '无权限访问';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不允许';
      case 408:
        return '请求超时';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      case 504:
        return '网关超时';
      default:
        return '请求失败 ($statusCode)';
    }
  }
}

/// HTTP 异常类
class HttpException implements Exception {
  final String message;
  final int? statusCode;
  final List<String> errors;

  HttpException(this.message, [this.statusCode, List<String>? errors])
      : errors = errors ?? const [];

  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() {
    final buffer = StringBuffer('HttpException: $message');
    if (statusCode != null) {
      buffer.write(' (Status Code: $statusCode)');
    }
    if (errors.isNotEmpty) {
      buffer.write(' Errors: ${errors.join(', ')}');
    }
    return buffer.toString();
  }
}

class _ApiResponseEnvelope {
  _ApiResponseEnvelope(this.meta, this.data);

  final ApiResponseMeta meta;
  final dynamic data;
}

_ApiResponseEnvelope? _unwrapApiResponse(Response response) {
  final body = response.data;

  if (body is! Map<String, dynamic>) {
    return null;
  }

  final success = body['success'];
  if (success is! bool) {
    return null;
  }

  final message = body['message']?.toString() ?? '';
  final rawErrors = body['errors'];
  final errors = <String>[];

  if (rawErrors is Iterable) {
    for (final item in rawErrors) {
      if (item == null) {
        continue;
      }
      errors.add(item.toString());
    }
  } else if (rawErrors is Map) {
    rawErrors.forEach((key, value) {
      if (value != null) {
        errors.add(value.toString());
      } else if (key != null) {
        errors.add(key.toString());
      }
    });
  }

  final meta = ApiResponseMeta(
    success: success,
    message: message,
    errors: errors,
    statusCode: response.statusCode,
  );

  response.extra[HttpService.apiResponseMetaKey] = meta;
  response.extra[HttpService.apiResponseRawKey] = body;

  final data = body.containsKey('data') ? body['data'] : null;

  return _ApiResponseEnvelope(meta, data);
}
