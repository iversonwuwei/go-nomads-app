# 多语言国际化 (i18n) 使用指南

本项目已集成 Flutter 官方的国际化解决方案，支持**中文（简体）**和**英文**两种语言。

## 📁 项目结构

```
lib/
├── l10n/                       # 国际化资源文件
│   ├── app_zh.arb             # 中文翻译
│   └── app_en.arb             # 英文翻译
├── generated/                  # 自动生成的文件
│   ├── app_localizations.dart # 主文件
│   ├── app_localizations_zh.dart
│   └── app_localizations_en.dart
├── controllers/
│   └── locale_controller.dart # 语言切换控制器
├── pages/
│   └── language_settings_page.dart # 语言设置页面
└── utils/
    └── l10n_helper.dart       # 国际化辅助类和示例

l10n.yaml                      # 国际化配置文件
```

## 🚀 快速开始

### 1. 在页面中使用国际化文本

```dart
import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),  // 自动显示 "行途" 或 "Xingtu"
      ),
      body: Column(
        children: [
          Text(l10n.welcome),
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
```

### 2. 切换语言

```dart
import 'package:get/get.dart';
import '../controllers/locale_controller.dart';

// 获取语言控制器
final localeController = Get.find<LocaleController>();

// 切换到英文
localeController.changeLocale('en');

// 切换到中文
localeController.changeLocale('zh');

// 获取当前语言
String currentLang = localeController.currentLanguageName; // "中文" 或 "English"

// 判断当前语言
bool isChinese = localeController.isChinese;
bool isEnglish = localeController.isEnglish;
```

### 3. 使用语言设置页面

已经创建好了语言设置页面，可以直接跳转：

```dart
import 'package:get/get.dart';
import '../routes/app_routes.dart';

// 跳转到语言设置页面
Get.toNamed(AppRoutes.languageSettings);

// 或者
Navigator.pushNamed(context, AppRoutes.languageSettings);
```

## ✏️ 添加新的翻译

### 步骤 1: 在 ARB 文件中添加翻译

**lib/l10n/app_zh.arb** (中文):
```json
{
  "@@locale": "zh",
  "myNewKey": "我的新文本",
  "@myNewKey": {
    "description": "对这个键的说明"
  }
}
```

**lib/l10n/app_en.arb** (英文):
```json
{
  "@@locale": "en",
  "myNewKey": "My New Text",
  "@myNewKey": {
    "description": "Description for this key"
  }
}
```

### 步骤 2: 重新生成代码

```bash
flutter gen-l10n
```

或者运行任何 Flutter 命令都会自动触发生成：
```bash
flutter pub get
flutter run
flutter build
```

### 步骤 3: 使用新的翻译

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.myNewKey);  // 自动显示 "我的新文本" 或 "My New Text"
```

## 📝 已有的翻译键

当前已经预定义了 100+ 个常用翻译键，包括：

### 通用
- `appTitle`, `home`, `profile`, `settings`
- `login`, `logout`, `register`
- `save`, `cancel`, `confirm`, `delete`, `edit`, `add`
- `loading`, `noData`, `retry`, `success`, `error`

### 城市相关
- `city`, `cities`, `cityDetail`, `cityCompare`
- `weather`, `temperature`, `location`

### 社区功能
- `member`, `members`, `meetup`, `createMeetup`
- `invite`, `inviteToMeetup`, `participants`
- `coworking`, `coworkingSpaces`, `venue`

### 其他功能
- `cost`, `addCost`, `category`, `amount`, `currency`
- `food`, `transport`, `accommodation`, `shopping`, `entertainment`
- `analytics`, `statistics`, `chart`
- `aiChat`, `askAI`, `sendMessage`
- `travelPlan`, `createPlan`, `viewPlan`

完整列表请查看 `lib/l10n/app_zh.arb` 和 `lib/l10n/app_en.arb` 文件。

## 🎨 最佳实践

### 1. 始终使用国际化文本

❌ **不推荐**：
```dart
Text('保存')
Text('Save')
```

✅ **推荐**：
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.save)  // 自动根据语言显示
```

### 2. 在顶层获取 l10n 对象

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Column(
    children: [
      Text(l10n.title),
      Text(l10n.description),
      Text(l10n.more),
    ],
  );
}
```

### 3. 使用描述性的键名

❌ **不推荐**：
```json
{
  "text1": "保存",
  "btn2": "取消"
}
```

✅ **推荐**：
```json
{
  "save": "保存",
  "cancel": "取消",
  "confirmDelete": "确认删除",
  "deleteSuccess": "删除成功"
}
```

### 4. 为复杂文本添加占位符

```json
{
  "welcomeUser": "欢迎, {userName}!",
  "@welcomeUser": {
    "description": "欢迎用户的消息",
    "placeholders": {
      "userName": {
        "type": "String",
        "example": "张三"
      }
    }
  }
}
```

使用：
```dart
Text(l10n.welcomeUser('张三'))
```

## 🔧 配置说明

### l10n.yaml
```yaml
arb-dir: lib/l10n                    # ARB 文件目录
template-arb-file: app_zh.arb        # 模板文件（中文）
output-localization-file: app_localizations.dart
output-dir: lib/generated             # 生成文件的输出目录
```

### pubspec.yaml
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true  # 启用代码生成
```

## 🌍 添加新语言

如果需要添加更多语言（例如日语、韩语）：

### 1. 创建新的 ARB 文件
```bash
lib/l10n/app_ja.arb  # 日语
lib/l10n/app_ko.arb  # 韩语
```

### 2. 在 LocaleController 中添加支持
```dart
final supportedLocales = const [
  Locale('zh', 'CN'),
  Locale('en', 'US'),
  Locale('ja', 'JP'),  // 添加日语
  Locale('ko', 'KR'),  // 添加韩语
];
```

### 3. 更新 changeLocale 方法
```dart
void changeLocale(String languageCode) {
  switch (languageCode) {
    case 'zh':
      locale.value = const Locale('zh', 'CN');
      break;
    case 'en':
      locale.value = const Locale('en', 'US');
      break;
    case 'ja':
      locale.value = const Locale('ja', 'JP');
      break;
    case 'ko':
      locale.value = const Locale('ko', 'KR');
      break;
  }
  Get.updateLocale(locale.value);
}
```

## 📱 示例页面

项目中包含以下示例：

1. **语言设置页面** (`lib/pages/language_settings_page.dart`)
   - 显示所有支持的语言
   - 当前语言高亮显示
   - 点击切换语言

2. **国际化辅助类** (`lib/utils/l10n_helper.dart`)
   - 快速访问国际化文本
   - 包含详细的使用示例和文档

## 🐛 常见问题

### Q: 生成的文件在哪里？
A: 在 `lib/generated/` 目录下，包括：
- `app_localizations.dart` - 主文件
- `app_localizations_zh.dart` - 中文实现
- `app_localizations_en.dart` - 英文实现

### Q: 修改 ARB 文件后没有生效？
A: 运行 `flutter gen-l10n` 或 `flutter pub get` 重新生成代码。

### Q: 如何设置默认语言？
A: 在 `LocaleController` 的 `_loadSavedLocale()` 方法中修改。

### Q: 如何保存用户选择的语言？
A: 在 `LocaleController.changeLocale()` 中添加 SharedPreferences 或其他持久化存储。

## 📚 更多资源

- [Flutter 国际化官方文档](https://docs.flutter.dev/ui/accessibility-and-localization/internationalization)
- [ARB 文件格式说明](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [GetX 国际化](https://github.com/jonataslaw/getx#internationalization)

---

## ✨ 功能特性

- ✅ 支持中文和英文
- ✅ 自动跟随系统语言
- ✅ 应用内动态切换语言
- ✅ 类型安全的 API
- ✅ 代码自动生成
- ✅ 易于扩展新语言
- ✅ GetX 集成
- ✅ 预定义 100+ 常用翻译

Happy Coding! 🎉
