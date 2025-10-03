# 统一配色系统使用指南

## 📋 概述

为了避免配色错误和保持整个应用的一致性,所有颜色定义已统一到 `lib/config/app_colors.dart` 文件中。

## 🎨 配色类别

### 1. 背景色

```dart
AppColors.background     // #FAFAFA - 页面背景色
AppColors.white          // #FFFFFF - 白色背景
```

**使用场景:**
- Scaffold 背景色
- 卡片背景色
- 对话框背景色

**示例:**
```dart
Scaffold(
  backgroundColor: AppColors.background,
  // ...
)
```

---

### 2. 文本颜色

```dart
AppColors.textPrimary    // #616161 - 主要文本
AppColors.textSecondary  // #757575 - 强调文本
AppColors.textTertiary   // #9E9E9E - 次要文本
AppColors.textWhite      // #FFFFFF - 白色文本
AppColors.textWhite70    // #B3FFFFFF - 白色文本 70% 透明度
AppColors.textWhite60    // #99FFFFFF - 白色文本 60% 透明度
```

**使用场景:**
- 标题、正文、说明文字
- 按钮文字
- 输入框文字

**示例:**
```dart
Text(
  'Hello World',
  style: TextStyle(color: AppColors.textPrimary),
)
```

---

### 3. 边框颜色

```dart
AppColors.border         // #E0E0E0 - 主边框
AppColors.borderLight    // #EEEEEE - 浅边框
AppColors.borderWhite30  // #4DFFFFFF - 白色边框 30% 透明度
```

**使用场景:**
- 容器边框
- 输入框边框
- 分隔线

**示例:**
```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(color: AppColors.border),
  ),
)
```

---

### 4. 容器背景色

```dart
AppColors.containerDark      // #757575 - 深灰容器
AppColors.containerMedium    // #9E9E9E - 中灰容器
AppColors.containerBlueGrey  // #90A4AE - 浅蓝灰容器
AppColors.containerLight     // #FAFAFA - 极浅灰容器
AppColors.containerWhite15   // #26FFFFFF - 白色 15% 透明度
```

**使用场景:**
- 卡片容器
- 按钮背景
- 分组背景

**示例:**
```dart
Container(
  color: AppColors.containerBlueGrey,
  // ...
)
```

---

### 5. 分割线颜色

```dart
AppColors.divider        // #EEEEEE - 主分割线
AppColors.dividerLight   // #BDBDBD - 浅分割线
```

**使用场景:**
- Divider 组件
- 列表分隔
- 区域分隔

**示例:**
```dart
Divider(color: AppColors.divider)
```

---

### 6. 强调色

```dart
AppColors.accent         // #1976D2 - 蓝色强调
AppColors.accentGrey     // #757575 - 灰色强调
```

**使用场景:**
- 选中状态
- 激活按钮
- 关键操作提示

**示例:**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.accentGrey,
  ),
  // ...
)
```

---

### 7. 图标颜色

```dart
AppColors.icon           // #757575 - 主图标
AppColors.iconSecondary  // #9E9E9E - 次要图标
AppColors.iconLight      // #BDBDBD - 浅图标
```

**使用场景:**
- Icon 组件
- IconButton
- 装饰性图标

**示例:**
```dart
Icon(
  Icons.home,
  color: AppColors.icon,
)
```

---

### 8. API 卡片颜色（数组）

```dart
AppColors.apiCardColors  // 6 种浅灰色数组
```

**包含颜色:**
- #B0BEC5 - 蓝灰
- #BCAAA4 - 棕灰
- #A5D6A7 - 绿灰
- #CE93D8 - 紫灰
- #FFCC80 - 橙灰
- #90CAF9 - 天蓝灰

**使用方法:**
```dart
// 直接访问
final color = AppColors.apiCardColors[0];

// 使用辅助方法（自动循环）
final color = AppColors.getApiCardColor(index);
```

**使用场景:**
- API 接口卡片
- 产品卡片
- 循环列表项

---

### 9. 数据分类颜色（数组）

```dart
AppColors.dataCategoryColors  // 9 种灰色渐变数组
```

**包含颜色:**
- #78909C - 深蓝灰
- #90A4AE - 中蓝灰
- #A1887F - 棕灰
- #81C784 - 绿灰
- #B0BEC5 - 浅蓝灰
- #9E9E9E - 中灰
- #AED581 - 浅绿灰
- #BCAAA4 - 浅棕灰
- #BDBDBD - 极浅灰

**使用方法:**
```dart
// 直接访问
final color = AppColors.dataCategoryColors[0];

// 使用辅助方法（自动循环）
final color = AppColors.getDataCategoryColor(index);
```

**使用场景:**
- 数据分类图标
- 统计卡片
- 分组标签

---

## 🔧 辅助方法

### getApiCardColor(int index)

根据索引获取 API 卡片颜色,自动循环。

```dart
final color = AppColors.getApiCardColor(5); // 返回 apiCardColors[5]
final color = AppColors.getApiCardColor(7); // 返回 apiCardColors[1] (循环)
```

### getDataCategoryColor(int index)

根据索引获取数据分类颜色,自动循环。

```dart
final color = AppColors.getDataCategoryColor(3); // 返回 dataCategoryColors[3]
final color = AppColors.getDataCategoryColor(10); // 返回 dataCategoryColors[1] (循环)
```

---

## 📝 使用示例

### 示例 1: 页面背景

```dart
import '../config/app_colors.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ...
    );
  }
}
```

### 示例 2: 文本样式

```dart
Text(
  '主标题',
  style: TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w400,
  ),
)

Text(
  '副标题',
  style: TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  ),
)
```

### 示例 3: 容器边框

```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.white,
    border: Border.all(
      color: AppColors.border,
      width: 1,
    ),
  ),
  // ...
)
```

### 示例 4: API 卡片

```dart
// 使用哈希值分配颜色
final colorIndex = api.name.hashCode.abs() % AppColors.apiCardColors.length;
final cardColor = AppColors.apiCardColors[colorIndex];

Container(
  color: cardColor,
  // ...
)

// 或使用辅助方法
Container(
  color: AppColors.getApiCardColor(index),
  // ...
)
```

### 示例 5: 数据分类图标

```dart
Icon(
  category['icon'],
  size: 32,
  color: AppColors.getDataCategoryColor(index),
)
```

---

## ⚠️ 注意事项

### ❌ 错误用法

```dart
// 不要直接使用硬编码颜色
Container(
  color: const Color(0xFF616161), // ❌ 错误
)

// 不要使用 Colors.grey
Text(
  'Hello',
  style: TextStyle(color: Colors.grey[600]), // ❌ 错误
)
```

### ✅ 正确用法

```dart
// 使用统一配色
Container(
  color: AppColors.textPrimary, // ✅ 正确
)

// 使用统一配色
Text(
  'Hello',
  style: TextStyle(color: AppColors.textSecondary), // ✅ 正确
)
```

---

## 🎯 设计原则

1. **一致性**: 所有页面使用相同的配色方案
2. **可维护性**: 修改配色只需在一个文件中操作
3. **可读性**: 语义化的颜色命名,易于理解
4. **性冷淡风格**: 使用浅灰色系,避免纯黑色
5. **极简主义**: 颜色种类有限,保持视觉统一

---

## 📦 已应用页面

✅ `login_page_optimized.dart` - 登录页面  
✅ `profile_page.dart` - 个人资料页面  
✅ `home_page.dart` - 首页  
✅ `api_marketplace_page.dart` - API 市场页面

---

## 🔄 如何添加新颜色

如果需要添加新颜色,请遵循以下步骤:

1. 在 `app_colors.dart` 中添加颜色定义
2. 添加注释说明用途
3. 在本文档中更新说明
4. 在所有需要的地方使用新颜色

**示例:**

```dart
// 在 app_colors.dart 中添加
class AppColors {
  // ...
  
  /// 新功能强调色
  static const Color featureHighlight = Color(0xFF00BCD4);
}
```

---

## 🎨 配色参考表

| 颜色名称 | 色值 | 用途 |
|---------|------|------|
| background | #FAFAFA | 页面背景 |
| textPrimary | #616161 | 主要文本 |
| textSecondary | #757575 | 强调文本 |
| textTertiary | #9E9E9E | 次要文本 |
| border | #E0E0E0 | 主边框 |
| borderLight | #EEEEEE | 浅边框 |
| containerBlueGrey | #90A4AE | 卡片容器 |
| accent | #1976D2 | 强调色 |
| icon | #757575 | 图标 |

---

**最后更新**: 2025年10月3日  
**维护者**: 开发团队
