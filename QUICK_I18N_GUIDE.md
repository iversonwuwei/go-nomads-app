# 🚀 国际化快速实施指南

基于 `city_list_page.dart` 的成功经验

## ⚡ 快速三步法

### 第 1 步: 添加 import (1 行)
```dart
import '../generated/app_localizations.dart';
```

### 第 2 步: 获取 l10n 实例 (1 行)
在 `build()` 方法中添加:
```dart
final l10n = AppLocalizations.of(context)!;
```

### 第 3 步: 替换文本
使用 VSCode 全局搜索替换 (Ctrl+H):

**搜索模式:**
- `Text('xxxx')` → `Text(l10n.xxxx)`
- `title: 'xxxx'` → `title: l10n.xxxx`
- `hintText: 'xxxx'` → `hintText: l10n.xxxx`

## 📋 常用翻译键速查表

### 基础操作 (已存在)
| 文本 | 键名 | 中文 |
|------|------|------|
| Save | `l10n.save` | 保存 |
| Cancel | `l10n.cancel` | 取消 |
| Confirm | `l10n.confirm` | 确认 |
| Delete | `l10n.delete` | 删除 |
| Edit | `l10n.edit` | 编辑 |
| Add | `l10n.add` | 添加 |
| Share | `l10n.share` | 分享 |
| Search | `l10n.search` | 搜索 |
| Filter | `l10n.filter` | 筛选 |

### 状态提示 (已存在)
| 文本 | 键名 | 中文 |
|------|------|------|
| Loading... | `l10n.loading` | 加载中... |
| No Data | `l10n.noData` | 暂无数据 |
| Success | `l10n.success` | 成功 |
| Error | `l10n.error` | 错误 |
| Network Error | `l10n.networkError` | 网络错误 |

### 表单字段 (已存在)
| 文本 | 键名 | 中文 |
|------|------|------|
| Title | `l10n.title` | 标题 |
| Name | `l10n.name` | 名称 |
| Description | `l10n.description` | 描述 |
| Email | `l10n.email` | 邮箱 |
| Password | `l10n.password` | 密码 |

### 社交功能 (已存在)
| 文本 | 键名 | 中文 |
|------|------|------|
| Follow | `l10n.follow` | 关注 |
| Like | `l10n.like` | 点赞 |
| Comment | `l10n.comment` | 评论 |
| Share | `l10n.share` | 分享 |

### 完整列表
查看 `lib/l10n/app_en.arb` 获取所有 415+ 个已有键

## 🔧 Builder Widget 使用 (子方法中需要 context)

**问题:** 子方法无法直接访问 context

```dart
// ❌ 错误 - 无法访问 context
Widget _buildSection() {
  final l10n = AppLocalizations.of(context)!; // 错误!
  return Text(l10n.title);
}
```

**解决方案 1: Builder Widget (推荐)**
```dart
// ✅ 正确 - 使用 Builder
Widget _buildSection() {
  return Builder(
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return Text(l10n.title);
    },
  );
}
```

**解决方案 2: 传递 BuildContext**
```dart
// ✅ 正确 - 传递 context
Widget _buildSection(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return Text(l10n.title);
}

// 调用时
_buildSection(context)
```

## 💡 实用技巧

### 技巧 1: 处理动态文本
```dart
// 简单拼接
Text('${count} items')
// 改为
Text('${count} ${l10n.items}')

// 或添加专门的键 (如果需要特殊格式)
"itemsCount": "{count} 个项目"
Text(l10n.itemsCount.replaceAll('{count}', count.toString()))
```

### 技巧 2: 条件文本
```dart
// 原代码
Text(isMobile ? 'Create' : 'Create Meetup')
// 改为
Text(isMobile ? l10n.create : l10n.createMeetup)
```

### 技巧 3: 列表和数组
```dart
// 原代码
final tabs = ['All', 'Active', 'Completed'];
// 改为
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final tabs = [l10n.all, l10n.active, l10n.completed];
  // ...
}
```

### 技巧 4: AppBar 和 Dialog
```dart
// AppBar
appBar: AppBar(
  title: Text(l10n.settings),
)

// Dialog
showDialog(
  title: Text(l10n.confirm),
  content: Text(l10n.deleteConfirm),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(l10n.cancel),
    ),
    TextButton(
      onPressed: () => _handleDelete(),
      child: Text(l10n.delete),
    ),
  ],
)

// SnackBar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(l10n.saveSuccess)),
)
```

### 技巧 5: 去除 const
```dart
// const Text 不能使用变量
// ❌ const Text(l10n.title) // 错误!
// ✅ Text(l10n.title)       // 正确
```

## 🎯 页面国际化检查清单

对于每个页面:

- [ ] 添加 import
- [ ] 在 build 中获取 l10n
- [ ] 搜索并替换 `Text('`
- [ ] 搜索并替换 `title:`
- [ ] 搜索并替换 `hintText:`
- [ ] 搜索并替换 `label:`
- [ ] 搜索并替换 `tooltip:`
- [ ] 检查 AppBar 标题
- [ ] 检查按钮文本
- [ ] 检查对话框文本
- [ ] 检查表单字段标签
- [ ] 处理子方法中的文本 (使用 Builder)
- [ ] 检查编译错误
- [ ] 测试语言切换

## 📦 需要添加新键时

### 1. 编辑 ARB 文件

**app_zh.arb:**
```json
{
  "newKey": "新文本",
  "otherExistingKeys": "..."
}
```

**app_en.arb:**
```json
{
  "newKey": "New Text",
  "otherExistingKeys": "..."
}
```

注意: JSON 最后一项后面不要有逗号!

### 2. 生成代码
```bash
flutter gen-l10n
```

### 3. 使用新键
```dart
Text(l10n.newKey)
```

## 🐛 常见错误

### 错误 1: Missing l10n import
```
Error: Undefined name 'AppLocalizations'
```
**解决:** 添加 `import '../generated/app_localizations.dart';`

### 错误 2: Context not available
```
Error: The getter 'context' isn't defined for the class
```
**解决:** 使用 Builder widget 或传递 BuildContext 参数

### 错误 3: Undefined getter
```
Error: The getter 'someKey' isn't defined for the type 'AppLocalizations'
```
**解决:** 
1. 检查 ARB 文件中是否有该键
2. 运行 `flutter gen-l10n`
3. 重启 IDE

### 错误 4: JSON format error
```
Error: FormatException: Unexpected character
```
**解决:** 检查 ARB 文件的 JSON 格式，确保逗号、引号正确

## 📊 效率提升工具

### VSCode 多光标编辑
1. Alt + Click - 添加多个光标
2. Ctrl + D - 选中下一个相同内容
3. Ctrl + Shift + L - 选中所有相同内容

### VSCode 正则搜索替换
查找: `Text\('([^']+)'\)`
替换: `Text(l10n.$1)`

### 批量操作
1. 收集页面中所有需要翻译的文本
2. 一次性添加到 ARB 文件
3. 运行 gen-l10n
4. 批量替换页面代码

## 📈 预计工作量

| 页面类型 | 预计时间 | 新增键数 |
|----------|----------|----------|
| 简单页面 (< 200行) | 10-15 分钟 | 5-10 个 |
| 中等页面 (200-500行) | 20-30 分钟 | 10-20 个 |
| 复杂页面 (500-1000行) | 40-60 分钟 | 20-40 个 |
| 超大页面 (>1000行) | 1-2 小时 | 40+ 个 |

**city_list_page** 实际用时: ~30 分钟 (包含文档)

## 🎓 学习资源

- **示例代码**: `lib/pages/city_list_page.dart`
- **翻译键**: `lib/l10n/app_zh.arb`
- **进度跟踪**: `README_i18n_progress.md`
- **批量指南**: `BATCH_I18N_GUIDE.md`
- **完成报告**: `CITY_LIST_I18N_REPORT.md`

---

**提示**: 从简单页面开始练习，熟悉流程后再处理复杂页面!
