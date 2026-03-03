import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 在任意页面中使用国际化的示例辅助类
class L10nHelper {
  /// 获取当前上下文的本地化对象
  ///
  /// 使用方法：
  /// ```dart
  /// final l10n = L10nHelper.of(context);
  /// Text(l10n.welcome);
  /// ```
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  /// 快速访问常用文本
  ///
  /// 使用方法：
  /// ```dart
  /// Text(L10nHelper.text(context).save);
  /// ```
  static AppLocalizations text(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
}

/// 国际化使用示例和文档
///
/// 1. 在任意 Widget 中使用国际化：
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   final l10n = AppLocalizations.of(context)!;
///
///   return Scaffold(
///     appBar: AppBar(
///       title: Text(l10n.appTitle),
///     ),
///     body: Column(
///       children: [
///         Text(l10n.welcome),
///         ElevatedButton(
///           onPressed: () {},
///           child: Text(l10n.save),
///         ),
///       ],
///     ),
///   );
/// }
/// ```
///
/// 2. 使用辅助类：
/// ```dart
/// Text(L10nHelper.of(context).cancel)
/// ```
///
/// 3. 切换语言：
/// ```dart
/// final localeController = Get.find<LocaleController>();
/// localeController.changeLocale('en'); // 切换到英文
/// localeController.changeLocale('zh'); // 切换到中文
/// ```
///
/// 4. 添加新的翻译：
/// - 在 lib/l10n/app_zh.arb 中添加中文翻译
/// - 在 lib/l10n/app_en.arb 中添加对应的英文翻译
/// - 运行 `flutter gen-l10n` 重新生成代码
///
/// 5. ARB 文件格式示例：
/// ```json
/// {
///   "@@locale": "zh",
///   "yourKey": "您的翻译文本",
///   "@yourKey": {
///     "description": "对这个键的说明"
///   }
/// }
/// ```
class L10nExampleWidget extends StatelessWidget {
  const L10nExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.globe),
            onPressed: () {
              Get.toNamed('/language-settings');
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSection(l10n.home, [
            l10n.welcome,
            l10n.search,
            l10n.filter,
          ]),
          const Divider(),
          _buildSection(l10n.settings, [
            l10n.language,
            l10n.theme,
            l10n.notifications,
          ]),
          const Divider(),
          _buildSection('${l10n.city} & ${l10n.coworking}', [
            l10n.cities,
            l10n.cityDetail,
            l10n.coworkingSpaces,
          ]),
          const Divider(),
          _buildSection(l10n.community, [
            l10n.members,
            l10n.meetup,
            l10n.chat,
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items.map((item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Text('• $item'),
            )),
      ],
    );
  }
}
