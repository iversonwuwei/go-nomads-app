import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/user/domain/repositories/i_user_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  // 业务语言（用于业务逻辑判断，默认中文）
  final locale = const Locale('zh', 'CN').obs;

  // UI 显示语言（用于界面文案切换）
  final uiLocale = const Locale('zh', 'CN').obs;

  // SharedPreferences 缓存 key
  static const _kLanguageCode = 'saved_language_code';

  // 支持的语言列表
  final supportedLocales = const [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  @override
  void onInit() {
    super.onInit();
    // 从本地存储加载语言设置
    _loadSavedLocale();
  }

  /// 从 SharedPreferences 加载已保存的语言设置，若无则使用系统语言
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_kLanguageCode);

      if (savedCode != null) {
        // 使用上次保存的界面语言（不影响业务语言）
        _applyUiLocale(savedCode);
        log('📦 从本地缓存恢复语言设置: $savedCode');
        return;
      }
    } catch (e) {
      log('⚠️ 读取本地语言缓存失败: $e');
    }

    // 无缓存，强制默认中文（无论系统语言）
    _applyUiLocale('zh');
  }

  /// 从后端偏好设置同步语言（在加载 UserPreferences 后调用）
  void syncFromPreferences(String languageCode) {
    if (languageCode.isNotEmpty && languageCode != uiLocale.value.languageCode) {
      _applyUiLocale(languageCode);
      _saveToLocal(languageCode);
      log('🔄 从后端偏好同步语言: $languageCode');
    }
  }

  // 切换语言
  void changeLocale(String languageCode) {
    _applyLocale(languageCode);

    // 保存到 SharedPreferences（立即生效）
    _saveToLocal(languageCode);

    // 持久化到后端数据库
    _saveToBackend(languageCode);
  }

  // 仅切换界面语言（不触发后端偏好联动）
  void changeLocaleUiOnly(String languageCode) {
    _applyUiLocale(languageCode);
  }

  /// 应用语言到 UI
  void _applyLocale(String languageCode) {
    if (languageCode == 'zh') {
      locale.value = const Locale('zh', 'CN');
      uiLocale.value = const Locale('zh', 'CN');
    } else if (languageCode == 'en') {
      locale.value = const Locale('en', 'US');
      uiLocale.value = const Locale('en', 'US');
    }
    Get.updateLocale(uiLocale.value);
  }

  /// 仅应用语言到 UI（不改变业务语言）
  void _applyUiLocale(String languageCode) {
    if (languageCode == 'en') {
      uiLocale.value = const Locale('en', 'US');
    } else {
      uiLocale.value = const Locale('zh', 'CN');
    }
    Get.updateLocale(uiLocale.value);
  }

  /// 保存到 SharedPreferences（本地缓存，下次启动立即恢复）
  Future<void> _saveToLocal(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLanguageCode, languageCode);
      log('💾 语言设置已保存到本地: $languageCode');
    } catch (e) {
      log('⚠️ 保存语言到本地失败: $e');
    }
  }

  /// 持久化到后端数据库
  Future<void> _saveToBackend(String languageCode) async {
    if (!Get.isRegistered<IUserPreferencesRepository>()) return;

    try {
      final repo = Get.find<IUserPreferencesRepository>();
      await repo.updatePreferences(language: languageCode);
      log('✅ 语言设置已保存到数据库: $languageCode');
    } catch (e) {
      log('⚠️ 保存语言到数据库失败: $e');
    }
  }

  // 获取当前语言名称
  String get currentLanguageName {
    return uiLocale.value.languageCode == 'zh' ? '中文' : 'English';
  }

  // 判断是否为中文
  bool get isChinese => locale.value.languageCode == 'zh';

  // 判断是否为英文
  bool get isEnglish => locale.value.languageCode == 'en';
}
