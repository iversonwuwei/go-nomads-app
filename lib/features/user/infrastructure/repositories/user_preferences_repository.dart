import 'dart:developer';

import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user_preferences.dart';
import 'package:df_admin_mobile/features/user/domain/repositories/i_user_preferences_repository.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:dio/dio.dart';

/// 用户偏好设置仓储实现
class UserPreferencesRepository implements IUserPreferencesRepository {
  final Dio _dio;
  final TokenStorageService _tokenService;

  UserPreferencesRepository({
    required Dio dio,
    required TokenStorageService tokenService,
  })  : _dio = dio,
        _tokenService = tokenService;

  @override
  Future<UserPreferences> getCurrentUserPreferences() async {
    log('📥 获取当前用户偏好设置');

    try {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}/api/v1/users/me/preferences',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final preferences = UserPreferences.fromJson(response.data['data'] as Map<String, dynamic>);
        log('✅ 成功获取用户偏好设置');
        return preferences;
      }

      throw Exception('获取用户偏好设置失败');
    } catch (e) {
      log('❌ 获取用户偏好设置失败: $e');
      rethrow;
    }
  }

  @override
  Future<UserPreferences> updatePreferences({
    bool? notificationsEnabled,
    bool? travelHistoryVisible,
    bool? profilePublic,
    String? currency,
    String? temperatureUnit,
    String? language,
  }) async {
    log('📤 更新用户偏好设置');

    try {
      final token = await _tokenService.getAccessToken();

      // 构建请求体（只包含非空字段）
      final Map<String, dynamic> requestBody = {};
      if (notificationsEnabled != null) {
        requestBody['notificationsEnabled'] = notificationsEnabled;
      }
      if (travelHistoryVisible != null) {
        requestBody['travelHistoryVisible'] = travelHistoryVisible;
      }
      if (profilePublic != null) {
        requestBody['profilePublic'] = profilePublic;
      }
      if (currency != null) {
        requestBody['currency'] = currency;
      }
      if (temperatureUnit != null) {
        requestBody['temperatureUnit'] = temperatureUnit;
      }
      if (language != null) {
        requestBody['language'] = language;
      }

      final response = await _dio.patch(
        '${ApiConfig.currentApiBaseUrl}/api/v1/users/me/preferences',
        data: requestBody,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final preferences = UserPreferences.fromJson(response.data['data'] as Map<String, dynamic>);
        log('✅ 成功更新用户偏好设置');
        return preferences;
      }

      throw Exception('更新用户偏好设置失败');
    } catch (e) {
      log('❌ 更新用户偏好设置失败: $e');
      rethrow;
    }
  }
}
