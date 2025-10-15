import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleController extends GetxController {
  // 当前语言
  final locale = const Locale('zh', 'CN').obs;

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

  void _loadSavedLocale() {
    // TODO: 从 SharedPreferences 或其他存储加载保存的语言设置
    // 目前使用系统语言或默认中文
    final systemLocale = Get.deviceLocale;
    if (systemLocale != null && systemLocale.languageCode == 'en') {
      locale.value = const Locale('en', 'US');
    } else {
      locale.value = const Locale('zh', 'CN');
    }
  }

  // 切换语言
  void changeLocale(String languageCode) {
    if (languageCode == 'zh') {
      locale.value = const Locale('zh', 'CN');
    } else if (languageCode == 'en') {
      locale.value = const Locale('en', 'US');
    }
    Get.updateLocale(locale.value);
    // TODO: 保存语言设置到本地存储
  }

  // 获取当前语言名称
  String get currentLanguageName {
    return locale.value.languageCode == 'zh' ? '中文' : 'English';
  }

  // 判断是否为中文
  bool get isChinese => locale.value.languageCode == 'zh';

  // 判断是否为英文
  bool get isEnglish => locale.value.languageCode == 'en';
}
