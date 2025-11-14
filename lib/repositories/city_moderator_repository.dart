import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/city_moderator.dart';
import '../services/token_storage_service.dart';

/// 城市版主 Repository
class CityModeratorRepository {
  final _tokenStorage = TokenStorageService();

  /// 获取城市的版主列表
  Future<List<CityModerator>> getModerators(String cityId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.currentApiBaseUrl}/api/v1/cities/$cityId/moderators'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => CityModerator.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('❌ 获取版主列表失败: $e');
      rethrow;
    }
  }

  /// 添加版主（仅管理员）
  Future<bool> addModerator({
    required String cityId,
    required String userId,
    bool canEditCity = true,
    bool canManageCoworks = true,
    bool canManageCosts = true,
    bool canManageVisas = true,
    bool canModerateChats = true,
    String? notes,
  }) async {
    try {
      final adminUserId = await _tokenStorage.getUserId();
      if (adminUserId == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.currentApiBaseUrl}/api/v1/cities/$cityId/moderators'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Id': adminUserId,
          'X-User-Role': 'admin',
        },
        body: json.encode({
          'cityId': cityId,
          'userId': userId,
          'canEditCity': canEditCity,
          'canManageCoworks': canManageCoworks,
          'canManageCosts': canManageCosts,
          'canManageVisas': canManageVisas,
          'canModerateChats': canModerateChats,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('❌ 添加版主失败: $e');
      return false;
    }
  }

  /// 删除版主（仅管理员）
  Future<bool> removeModerator(String cityId, String userId) async {
    try {
      final adminUserId = await _tokenStorage.getUserId();
      if (adminUserId == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.currentApiBaseUrl}/api/v1/cities/$cityId/moderators/$userId'),
        headers: {
          'X-User-Id': adminUserId,
          'X-User-Role': 'admin',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('❌ 删除版主失败: $e');
      return false;
    }
  }

  /// 更新版主权限（仅管理员）
  Future<bool> updateModeratorPermissions({
    required String cityId,
    required String moderatorId,
    bool? canEditCity,
    bool? canManageCoworks,
    bool? canManageCosts,
    bool? canManageVisas,
    bool? canModerateChats,
    bool? isActive,
    String? notes,
  }) async {
    try {
      final adminUserId = await _tokenStorage.getUserId();
      if (adminUserId == null) return false;

      final body = <String, dynamic>{};
      if (canEditCity != null) body['canEditCity'] = canEditCity;
      if (canManageCoworks != null) body['canManageCoworks'] = canManageCoworks;
      if (canManageCosts != null) body['canManageCosts'] = canManageCosts;
      if (canManageVisas != null) body['canManageVisas'] = canManageVisas;
      if (canModerateChats != null) body['canModerateChats'] = canModerateChats;
      if (isActive != null) body['isActive'] = isActive;
      if (notes != null) body['notes'] = notes;

      final response = await http.patch(
        Uri.parse('${ApiConfig.currentApiBaseUrl}/api/v1/cities/$cityId/moderators/$moderatorId'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Id': adminUserId,
          'X-User-Role': 'admin',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('❌ 更新版主权限失败: $e');
      return false;
    }
  }

  /// 搜索用户（用于选择版主）
  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    String? role,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final userId = await _tokenStorage.getUserId();
      if (userId == null) return [];

      final uri = Uri.parse('${ApiConfig.currentApiBaseUrl}/api/v1/users/search')
          .replace(queryParameters: {
        'q': query,
        if (role != null) 'role': role,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          'X-User-Id': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']['items'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('❌ 搜索用户失败: $e');
      return [];
    }
  }
}
