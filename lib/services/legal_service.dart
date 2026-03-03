import 'dart:developer';

import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/models/legal_document.dart';
import 'package:go_nomads_app/services/http_service.dart';

/// 法律文档服务 — 从后端获取隐私政策等法律文档，带本地缓存
class LegalService {
  static final LegalService _instance = LegalService._internal();
  factory LegalService() => _instance;
  LegalService._internal();

  final HttpService _http = HttpService();

  /// 内存缓存
  LegalDocument? _cachedPrivacyPolicy;

  /// 获取隐私政策（优先缓存）
  Future<LegalDocument?> getPrivacyPolicy({String lang = 'zh', bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPrivacyPolicy != null) {
      return _cachedPrivacyPolicy;
    }

    try {
      final response = await _http.get(
        ApiConfig.legalPrivacyPolicyEndpoint,
        queryParameters: {'lang': lang},
      );

      final data = response.data;
      if (data != null && data is Map<String, dynamic>) {
        _cachedPrivacyPolicy = LegalDocument.fromJson(data);
        log('✅ 隐私政策加载成功: v${_cachedPrivacyPolicy!.version}');
        return _cachedPrivacyPolicy;
      }
    } catch (e) {
      log('❌ 获取隐私政策失败: $e');
    }
    return null;
  }

  /// 清除缓存
  void clearCache() {
    _cachedPrivacyPolicy = null;
  }
}
