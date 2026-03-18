import 'dart:developer';

import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/widgets/report_dialog.dart';

/// 举报服务
/// 将用户举报信息提交到后端（保存数据库 + 通知管理员）
class ReportService {
  final HttpService _http = HttpService();

  /// 提交举报到后端 API（后端负责保存记录并通知管理员）
  Future<bool> submitReport({
    required ReportContentType contentType,
    required String targetId,
    required String reasonId,
    required String reasonLabel,
    String? targetName,
  }) async {
    try {
      // 调用后端举报 API — 后端会保存到数据库并通知管理员
      final url = ApiConfig.buildUrl(ApiConfig.reportsEndpoint);
      await _http.post(url, data: {
        'contentType': contentType.name,
        'targetId': targetId,
        'targetName': targetName,
        'reasonId': reasonId,
        'reasonLabel': reasonLabel,
      });

      log('✅ 举报提交成功: ${contentType.name} - $targetId');
      return true;
    } catch (e) {
      log('❌ 举报提交失败: $e');
      return false;
    }
  }
}
