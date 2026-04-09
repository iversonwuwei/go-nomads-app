import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/navigation_hub/domain/entities/inbox_summary.dart';
import 'package:go_nomads_app/features/navigation_hub/domain/repositories/i_inbox_summary_repository.dart';
import 'package:go_nomads_app/services/http_service.dart';

class InboxSummaryRepository implements IInboxSummaryRepository {
  final HttpService _httpService;

  InboxSummaryRepository(this._httpService);

  @override
  Future<Result<InboxSummary>> getInboxSummary({int recentLimit = 5}) async {
    try {
      final response = await _httpService.get(
        '/inbox/summary',
        queryParameters: {'recentLimit': recentLimit},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return Result.success(InboxSummary.fromJson(response.data as Map<String, dynamic>));
      }

      return Result.failure(const ServerException('获取收件箱摘要失败'));
    } on DioException catch (error) {
      log('❌ Inbox summary request failed: ${error.message}');
      if (error.response?.statusCode == 401) {
        return Result.failure(const UnauthorizedException('请先登录'));
      }
      return Result.failure(NetworkException('网络连接失败: ${error.message}'));
    } catch (error) {
      log('❌ Inbox summary parse failed: $error');
      return Result.failure(UnknownException('获取收件箱摘要失败: $error'));
    }
  }
}