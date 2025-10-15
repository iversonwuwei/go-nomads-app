# 国际化集成示例

## 如何在现有页面中添加国际化支持

以下是将现有硬编码文本替换为国际化文本的示例：

### 示例 1: 简单文本替换

**修改前：**

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: Column(
        children: [
          Text('欢迎'),
          ElevatedButton(
            onPressed: () {},
            child: Text('保存'),
          ),
        ],
      ),
    );
  }
}
```

**修改后：**

```dart
import '../generated/app_localizations.dart';  // 添加导入

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;  // 获取国际化对象
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),  // '设置' -> l10n.settings
      ),
      body: Column(
        children: [
          Text(l10n.welcome),  // '欢迎' -> l10n.welcome
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.save),  // '保存' -> l10n.save
          ),
        ],
      ),
    );
  }
}
```

### 示例 2: 在 GetX Controller 中使用

**方法 1: 在 UI 层使用（推荐）**

```dart
class MyController extends GetxController {
  // Controller 中只存储数据，不存储文本
  final itemCount = 0.obs;
  final isLoading = false.obs;
}

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<MyController>();
    
    return Obx(() => Text(
      controller.isLoading.value 
        ? l10n.loading  // 在 UI 层使用国际化
        : l10n.success
    ));
  }
}
```

**方法 2: 传递 Context 到 Controller**

```dart
class MyController extends GetxController {
  void showMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Get.snackbar(l10n.success, l10n.saveSuccess);
  }
}
```

### 示例 3: 在 Dialog 中使用

**修改前：**

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('确认删除'),
    content: Text('确定要删除这个项目吗？'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('取消'),
      ),
      TextButton(
        onPressed: () {
          // 删除逻辑
          Navigator.pop(context);
        },
        child: Text('确认'),
      ),
    ],
  ),
);
```

**修改后：**

```dart
final l10n = AppLocalizations.of(context)!;

showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(l10n.confirmDelete),
    content: Text('确定要删除这个项目吗？'),  // 如果 ARB 中没有对应的键，先添加
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(l10n.cancel),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(l10n.confirm),
      ),
    ],
  ),
);
```

### 示例 4: 添加语言切换按钮

在您的设置页面或个人资料页面添加语言切换入口：

```dart
import 'package:get/get.dart';
import '../controllers/locale_controller.dart';
import '../routes/app_routes.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeController = Get.find<LocaleController>();
    
    return ListView(
      children: [
        // 其他设置项...
        
        // 语言设置
        ListTile(
          leading: Icon(Icons.language),
          title: Text(l10n.language),
          subtitle: Obx(() => Text(localeController.currentLanguageName)),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            Get.toNamed(AppRoutes.languageSettings);
          },
        ),
      ],
    );
  }
}
```

### 示例 5: 在 Stateful Widget 中使用

```dart
class MyStatefulPage extends StatefulWidget {
  @override
  State<MyStatefulPage> createState() => _MyStatefulPageState();
}

class _MyStatefulPageState extends State<MyStatefulPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
      ),
      body: Center(
        child: Text(l10n.welcome),
      ),
    );
  }
}
```

## 常用替换对照表

| 中文硬编码 | 英文硬编码 | 国际化键 |
|---------|---------|---------|
| '首页' | 'Home' | `l10n.home` |
| '我的' / '个人中心' | 'Profile' | `l10n.profile` |
| '设置' | 'Settings' | `l10n.settings` |
| '登录' | 'Login' | `l10n.login` |
| '注册' | 'Register' | `l10n.register` |
| '保存' | 'Save' | `l10n.save` |
| '取消' | 'Cancel' | `l10n.cancel` |
| '确认' | 'Confirm' | `l10n.confirm` |
| '删除' | 'Delete' | `l10n.delete` |
| '编辑' | 'Edit' | `l10n.edit` |
| '搜索' | 'Search' | `l10n.search` |
| '筛选' | 'Filter' | `l10n.filter` |
| '加载中...' | 'Loading...' | `l10n.loading` |
| '暂无数据' | 'No Data' | `l10n.noData` |
| '成功' | 'Success' | `l10n.success` |
| '错误' | 'Error' | `l10n.error` |
| '城市' | 'City' | `l10n.city` |
| '成员' | 'Member' | `l10n.member` |
| '聚会' | 'Meetup' | `l10n.meetup` |
| '邀请' | 'Invite' | `l10n.invite` |
| '位置' | 'Location' | `l10n.location` |
| '日期' | 'Date' | `l10n.date` |
| '时间' | 'Time' | `l10n.time` |

## 快速替换步骤

### 步骤 1: 找到需要替换的文本

在 VS Code 中使用全局搜索（Ctrl+Shift+F）查找硬编码的中文文本。

### 步骤 2: 检查是否已有对应的键

查看 `lib/l10n/app_zh.arb` 文件，看是否已经有对应的翻译键。

### 步骤 3: 如果没有，添加新的键

在 `app_zh.arb` 和 `app_en.arb` 中添加新的翻译：

```json
// app_zh.arb
{
  "myNewText": "我的新文本"
}

// app_en.arb
{
  "myNewText": "My New Text"
}
```

### 步骤 4: 重新生成代码

```bash
flutter gen-l10n
```

### 步骤 5: 在代码中使用

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.myNewText)
```

## 测试国际化

### 1. 在应用内切换语言

- 运行应用
- 导航到语言设置页面（如果已添加）
- 选择不同的语言
- 观察文本是否正确切换

### 2. 测试不同语言的 UI 布局

某些语言的文本长度可能差异很大，需要确保 UI 能够适应：

```dart
// 使用 Flexible 或 Expanded 来避免溢出
Row(
  children: [
    Icon(Icons.home),
    SizedBox(width: 8),
    Flexible(
      child: Text(
        l10n.veryLongTextKey,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)
```

## 注意事项

1. **始终在 build 方法中获取 l10n 对象**，因为语言切换时需要重新构建
2. **不要在 Controller 的构造函数或 onInit 中使用国际化**，因为可能没有可用的 context
3. **给复杂的文本使用占位符**，而不是字符串拼接
4. **保持键名的一致性**，使用清晰的命名规则

## 完整示例项目

参考 `lib/pages/language_settings_page.dart` 查看完整的语言设置页面实现。

参考 `lib/utils/l10n_helper.dart` 查看更多使用示例和最佳实践。
