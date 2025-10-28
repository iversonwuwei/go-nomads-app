import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'token_storage_service.dart';

/// 用户 API 服务
class UserApiService {
  final TokenStorageService _tokenService = TokenStorageService();

  /// 批量获取用户信息
  ///
  /// 参数:
  /// - userIds: 用户ID列表
  ///
  /// 返回: 用户信息列表 (包含 id, name, email, phone, avatar 等)
  Future<List<Map<String, dynamic>>> batchGetUsers(List<String> userIds) async {
    if (userIds.isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.userBatchEndpoint}',
      );

      // 获取认证 token
      final token = await _tokenService.getAccessToken();
      print('🔑 批量获取用户 - Token: ${token != null ? "已获取" : "未获取"}');

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('🌐 批量获取用户 API: $url');
      print('📦 请求用户数量: ${userIds.length}');

      final response = await http
          .post(
            url,
            headers: headers,
            body: json.encode({
              'userIds': userIds,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('📡 批量获取用户响应状态: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // 处理后端的 ApiResponse 结构
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> usersData = jsonResponse['data'];
          print('✅ 成功获取 ${usersData.length} 个用户信息');
          return usersData.map((user) => user as Map<String, dynamic>).toList();
        }
      } else {
        print('❌ 批量获取用户失败: ${response.statusCode}');
        print('响应内容: ${response.body}');
      }

      // 请求失败，返回空列表
      return [];
    } catch (e) {
      print('❌ 批量获取用户信息异常: $e');
      return [];
    }
  }

  /// 获取单个用户信息
  ///
  /// 参数:
  /// - userId: 用户ID
  ///
  /// 返回: 用户信息 Map 或 null
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final endpoint = ApiConfig.userDetailEndpoint.replaceAll('{id}', userId);
      final url = Uri.parse('${ApiConfig.currentApiBaseUrl}$endpoint');

      // 获取认证 token
      final token = await _tokenService.getAccessToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return jsonResponse['data'] as Map<String, dynamic>;
        }
      }

      return null;
    } catch (e) {
      print('❌ 获取用户信息失败: $e');
      return null;
    }
  }
}
