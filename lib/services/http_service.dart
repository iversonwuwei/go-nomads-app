import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/core/auth/token_manager.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;

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

  // 用于防止重复跳转登录页
  bool _isRedirectingToLogin = false;

  static const String apiResponseMetaKey = '__apiResponseMeta';
  static const String apiResponseRawKey = '__apiResponseRaw';
  static const String disableApiResponseUnwrapKey = '__disableApiResponseUnwrap';

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

  /// 处理 401 未授权错误 - 清除认证并跳转登录页
  Future<void> _handleUnauthorized({String? reason}) async {
    // 防止重复跳转
    if (_isRedirectingToLogin) {
      if (kDebugMode) {
        log('⏭️ 已在跳转登录页，跳过重复操作');
      }
      return;
    }

    _isRedirectingToLogin = true;

    if (kDebugMode) {
      log('🔥 处理 401 错误: ${reason ?? "Token 无效或已过期"}');
    }

    // 使用 TokenManager 统一清除所有认证信息
    final tokenManager = TokenManager();
    await tokenManager.clearToken();

    // 更新 AuthStateController 状态
    try {
      final authController = getx.Get.find<AuthStateController>();
      authController.isAuthenticated.value = false;
      authController.currentUser.value = null;
      authController.currentToken.value = null;
    } catch (e) {
      if (kDebugMode) {
        log('⚠️ 无法更新 AuthStateController: $e');
      }
    }

    // 延迟显示提示并跳转（确保在正确的上下文中）
    Future.delayed(Duration.zero, () {
      try {
        // 显示提示
        AppToast.error(reason ?? 'Your session has expired. Please login again.');

        // 跳转到登录页
        getx.Get.offAllNamed(AppRoutes.login);

        // 重置标志
        Future.delayed(const Duration(seconds: 1), () {
          _isRedirectingToLogin = false;
        });
      } catch (e) {
        if (kDebugMode) {
          log('❌ 跳转登录页失败: $e');
        }
        _isRedirectingToLogin = false;
      }
    });
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

          // HTTP 方法重写：将 PUT/DELETE/PATCH 转换为 POST + X-HTTP-Method-Override 头
          // 用于解决某些网络环境（如部分 ISP、IDC 防火墙）不支持这些方法的问题
          if (ApiConfig.useHttpMethodOverride) {
            final method = options.method.toUpperCase();
            if (method == 'PUT' || method == 'DELETE' || method == 'PATCH') {
              if (kDebugMode) {
                log('🔄 HTTP Method Override: $method -> POST (X-HTTP-Method-Override: $method)');
              }
              options.headers['X-HTTP-Method-Override'] = method;
              options.method = 'POST';
            }
          }

          // 打印请求日志 (仅开发环境)
          if (kDebugMode) {
            log('🚀 REQUEST[${options.method}] => ${options.uri}');
            log('Headers: ${options.headers}');
            if (options.data != null) {
              log('Data: ${options.data}');
            }
            if (options.queryParameters.isNotEmpty) {
              log('Query: ${options.queryParameters}');
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 打印响应日志 (仅开发环境)
          if (kDebugMode) {
            log('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
            log('Data: ${response.data}');
          }

          final disableUnwrap = response.requestOptions.extra[disableApiResponseUnwrapKey] == true;
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
                      envelope.meta.message.isNotEmpty ? envelope.meta.message : _handleStatusCode(response.statusCode),
                      response.statusCode,
                      envelope.meta.errors.isEmpty ? null : envelope.meta.errors,
                    ),
                  ),
                );
              }
            }
          }

          return handler.next(response);
        },
        onError: (error, handler) async {
          // 打印错误日志（排除 DELETE 请求的 404，这是正常的幂等删除场景）
          final isDelete404 = error.requestOptions.method == 'DELETE' && error.response?.statusCode == 404;
          if (kDebugMode && !isDelete404) {
            log('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
            log('Message: ${error.message}');
            if (error.response?.data != null) {
              // 完整打印响应数据，包括错误详情
              final responseData = error.response!.data;
              log('完整响应数据:');
              log(jsonEncode(responseData));
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
                    envelope.meta.message.isNotEmpty ? envelope.meta.message : _handleStatusCode(response.statusCode),
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
              log('⚠️ 401 Unauthorized - 认证失败');
              log('完整响应数据: ${error.response?.data}');
            }

            // 检查是否有 refresh token
            final tokenService = TokenStorageService();
            final refreshToken = await tokenService.getRefreshToken();

            // 如果没有 refresh token，说明用户未登录，直接跳转登录页
            if (refreshToken == null || refreshToken.isEmpty) {
              if (kDebugMode) {
                log('❌ 无 refresh token，跳转登录页面');
              }
              await _handleUnauthorized(reason: 'Please login to continue');
              return handler.next(error);
            }

            // 有 refresh token 且有刷新回调，尝试自动刷新
            if (_onTokenRefreshCallback != null && !_isRefreshing) {
              try {
                _isRefreshing = true;
                if (kDebugMode) {
                  log('🔄 检测到 refresh token，尝试自动刷新...');
                }

                final newToken = await _onTokenRefreshCallback!();

                if (newToken != null && newToken.isNotEmpty) {
                  if (kDebugMode) {
                    log('✅ Token 刷新成功，重试请求');
                  }

                  // 更新请求头
                  error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
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
                    log('❌ Token 刷新失败，清除认证信息并跳转登录页');
                  }
                  _isRefreshing = false;
                  await _handleUnauthorized(reason: 'Session expired. Please login again.');
                  return handler.next(error);
                }
              } catch (refreshError) {
                if (kDebugMode) {
                  log('❌ Token 刷新异常: $refreshError');
                }
                _isRefreshing = false;
                await _handleUnauthorized(reason: 'Authentication failed. Please login again.');
                return handler.next(error);
              }
            } else if (_onTokenRefreshCallback == null) {
              // 没有刷新回调，直接跳转登录
              if (kDebugMode) {
                log('❌ 无 Token 刷新回调，跳转登录页面');
              }
              await _handleUnauthorized(reason: 'Please login to continue');
              return handler.next(error);
            } else if (_isRefreshing) {
              // 正在刷新中，等待刷新完成
              if (kDebugMode) {
                log('⏳ Token 正在刷新中，等待完成...');
              }
              return handler.next(error);
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

  /// SSE (Server-Sent Events) 流式请求
  /// 用于接收服务器推送的实时数据流
  Stream<String> getServerSentEvents(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  }) async* {
    try {
      final tokenService = TokenStorageService();
      final token = await tokenService.getAccessToken();

      final uri = Uri.parse('${_dio.options.baseUrl}$path');
      final fullUri = uri.replace(queryParameters: queryParameters);

      if (kDebugMode) {
        log('🔄 SSE REQUEST => $fullUri');
      }

      final client = HttpClient();
      final request = await client.postUrl(fullUri);

      // 设置请求头
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'text/event-stream');
      request.headers.set('Cache-Control', 'no-cache');
      if (token != null && token.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $token');
      }
      if (_userId != null && _userId!.isNotEmpty) {
        request.headers.set('X-User-Id', _userId!);
      }

      // 发送请求体（使用 UTF-8 编码）
      if (data != null) {
        final jsonData = utf8.encode(jsonEncode(data));
        request.add(jsonData);
      }

      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException(
          'SSE request failed',
          response.statusCode,
        );
      }

      // 处理 SSE 流
      await for (final chunk in response.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data.isNotEmpty && data != '[DONE]') {
              yield data;
            }
          }
        }
      }

      client.close();
    } catch (e) {
      if (kDebugMode) {
        log('❌ SSE ERROR: $e');
      }
      rethrow;
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
    List<String> errors = [];

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
        // 尝试解析后端返回的详细错误信息
        if (error.response?.data != null) {
          final responseData = error.response!.data;

          // 检查是否有 errors 字段（后端验证错误格式）
          if (responseData is Map<String, dynamic> && responseData['errors'] != null) {
            final errorsData = responseData['errors'];
            if (errorsData is Map<String, dynamic>) {
              // 提取所有验证错误
              errorsData.forEach((field, messages) {
                if (messages is List) {
                  errors.addAll(messages.map((e) => '$field: $e'));
                } else if (messages is String) {
                  errors.add('$field: $messages');
                }
              });
              errorMessage = errors.isNotEmpty ? errors.join('\n') : '请求参数错误';
            } else {
              errorMessage = _handleStatusCode(error.response?.statusCode);
            }
          } else {
            errorMessage = _handleStatusCode(error.response?.statusCode);
          }
        } else {
          errorMessage = _handleStatusCode(error.response?.statusCode);
        }
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

    return HttpException(errorMessage, error.response?.statusCode, errors);
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

  HttpException(this.message, [this.statusCode, List<String>? errors]) : errors = errors ?? const [];

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
