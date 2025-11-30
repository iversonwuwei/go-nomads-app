import 'package:df_admin_mobile/features/moderator/domain/entities/moderator_application.dart';
import 'package:df_admin_mobile/features/moderator/domain/repositories/i_moderator_application_repository.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:get/get.dart';

/// 版主申请仓储实现
class ModeratorApplicationRepository implements IModeratorApplicationRepository {
  final HttpService _httpService = Get.find<HttpService>();

  @override
  Future<void> applyForModerator({
    required String cityId,
    required String reason,
  }) async {
    final response = await _httpService.post(
      '/cities/moderator/apply',
      data: {
        'cityId': cityId,
        'reason': reason,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['message'] ?? '申请失败');
    }
  }

  @override
  Future<List<ModeratorApplication>> getMyApplications() async {
    final response = await _httpService.get('/cities/moderator/applications/my');

    if (response.statusCode != 200) {
      throw Exception(response.data?['message'] ?? '获取申请列表失败');
    }

    // HttpService 已自动解包响应，response.data 直接就是数据
    final data = response.data as List<dynamic>?;
    if (data == null) {
      return [];
    }

    return data
        .map((json) => ModeratorApplication.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ModeratorApplication>> getPendingApplications({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _httpService.get(
      '/cities/moderator/applications/pending',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['message'] ?? '获取待处理申请失败');
    }

    // HttpService 已自动解包响应，response.data 直接就是数据
    final data = response.data as List<dynamic>?;
    if (data == null) {
      return [];
    }

    return data
        .map((json) => ModeratorApplication.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> handleApplication({
    required String applicationId,
    required String action,
    String? rejectionReason,
  }) async {
    final response = await _httpService.post(
      '/cities/moderator/handle',
      data: {
        'applicationId': applicationId,
        'action': action,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['message'] ?? '处理申请失败');
    }
  }

  @override
  Future<ModeratorApplication> getApplicationById(String id) async {
    final response = await _httpService.get('/cities/moderator/applications/$id');

    if (response.statusCode != 200) {
      throw Exception(response.data?['message'] ?? '获取申请详情失败');
    }

    // HttpService 已自动解包响应，response.data 直接就是数据对象
    final data = response.data;
    if (data == null) {
      throw Exception('申请不存在');
    }

    return ModeratorApplication.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    final response = await _httpService.get('/cities/moderator/applications/statistics');

    if (response.statusCode != 200) {
      throw Exception(response.data?['message'] ?? '获取统计数据失败');
    }

    // HttpService 已自动解包响应，response.data 直接就是数据
    final data = response.data as Map<String, dynamic>?;
    if (data == null) {
      return {};
    }

    return data.map((key, value) => MapEntry(key, value as int));
  }
}
