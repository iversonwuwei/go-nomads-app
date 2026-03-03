import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';

/// 腾讯云IM后端API服务
/// 用于调用后端的用户导入等接口
class TencentIMApiService {
  static TencentIMApiService? _instance;
  late final Dio _dio;
  final TokenStorageService _tokenService = TokenStorageService();

  TencentIMApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.messageServiceBaseUrl,
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 30000),
      sendTimeout: const Duration(milliseconds: 10000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加认证拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenService.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    // 添加日志拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => log('🔵 [TencentIM API] $obj'),
    ));
  }

  factory TencentIMApiService() {
    _instance ??= TencentIMApiService._internal();
    return _instance!;
  }

  /// 确保用户存在于腾讯云IM（如果不存在则导入）
  /// 后端会从 JWT Token 中的 UserContext 获取用户ID
  /// nickname 和 avatarUrl 是可选的，如果不传，后端会从 UserService 获取
  Future<Map<String, dynamic>?> ensureUserExists({
    String? nickname,
    String? avatarUrl,
  }) async {
    try {
      log('🔄 调用后端API确保当前用户存在于腾讯云IM');

      // 构建请求体，只传有值的字段
      final Map<String, dynamic> data = {};
      if (nickname != null && nickname.isNotEmpty) {
        data['nickname'] = nickname;
      }
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        data['avatarUrl'] = avatarUrl;
      }

      final response = await _dio.post(
        '/api/v1/im/accounts/ensure',
        data: data.isEmpty ? null : data,
      );

      if (response.statusCode == 200) {
        final result = response.data as Map<String, dynamic>;
        final userId = result['userId'] as String?;
        final imported = result['imported'] as bool? ?? false;
        if (imported) {
          log('✅ 用户 $userId 已导入到腾讯云IM');
        } else {
          log('✅ 用户 $userId 已存在于腾讯云IM');
        }
        return result;
      }

      log('❌ 确保用户存在失败: ${response.statusCode}');
      return null;
    } catch (e) {
      log('❌ 调用后端API失败: $e');
      return null;
    }
  }

  /// 导入指定用户到腾讯云IM
  /// 用于导入接收方用户（不是当前登录用户）
  Future<bool> importUser({
    required String userId,
    String? nickname,
    String? avatarUrl,
  }) async {
    try {
      log('🔄 导入用户到腾讯云IM: $userId');

      final response = await _dio.post(
        '/api/v1/im/accounts/import',
        data: {
          'userId': userId,
          'nickname': nickname,
          'avatarUrl': avatarUrl,
        },
      );

      if (response.statusCode == 200) {
        log('✅ 用户 $userId 导入成功');
        return true;
      }

      log('❌ 导入用户失败: ${response.statusCode}');
      return false;
    } catch (e) {
      log('❌ 导入用户失败: $e');
      return false;
    }
  }

  /// 批量导入用户
  Future<Map<String, dynamic>?> batchImportUsers(List<Map<String, dynamic>> users) async {
    try {
      log('🔄 批量导入 ${users.length} 个用户');

      final response = await _dio.post(
        '/api/v1/im/accounts/batch-import',
        data: {'users': users},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      log('❌ 批量导入用户失败: $e');
      return null;
    }
  }

  /// 从后端获取UserSig
  Future<String?> getUserSig(String userId) async {
    try {
      final response = await _dio.get(
        '/api/v1/im/usersig/$userId',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['userSig'] as String?;
      }

      return null;
    } catch (e) {
      log('❌ 获取UserSig失败: $e');
      return null;
    }
  }

  /// 检查用户是否存在
  Future<bool> checkUserExists(String userId) async {
    try {
      final response = await _dio.get(
        '/api/v1/im/accounts/$userId/exists',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['exists'] as bool? ?? false;
      }

      return false;
    } catch (e) {
      log('❌ 检查用户存在性失败: $e');
      return false;
    }
  }
}
