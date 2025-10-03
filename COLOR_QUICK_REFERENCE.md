# 配色快速参考卡

## 🎨 常用颜色

```dart
import '../config/app_colors.dart';
```

### 背景
```dart
AppColors.background     // #FAFAFA 页面背景
AppColors.white          // #FFFFFF 白色
```

### 文本
```dart
AppColors.textPrimary    // #616161 主要文本
AppColors.textSecondary  // #757575 强调文本
AppColors.textTertiary   // #9E9E9E 次要文本
```

### 边框
```dart
AppColors.border         // #E0E0E0 主边框
AppColors.borderLight    // #EEEEEE 浅边框
```

### 容器
```dart
AppColors.containerBlueGrey  // #90A4AE 卡片容器
AppColors.containerDark      // #757575 深色容器
```

### 图标
```dart
AppColors.icon           // #757575 主图标
AppColors.iconLight      // #BDBDBD 浅图标
```

### 强调
```dart
AppColors.accent         // #1976D2 蓝色强调
AppColors.accentGrey     // #757575 灰色强调
```

### 数组颜色
```dart
// API卡片 (6色)
AppColors.getApiCardColor(index)

// 数据分类 (9色)
AppColors.getDataCategoryColor(index)
```

## 📋 常见用法

### Scaffold
```dart
Scaffold(
  backgroundColor: AppColors.background,
)
```

### Text
```dart
Text(
  'Title',
  style: TextStyle(color: AppColors.textPrimary),
)
```

### Container
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.white,
    border: Border.all(color: AppColors.border),
  ),
)
```

### Icon
```dart
Icon(Icons.home, color: AppColors.icon)
```

### Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.accentGrey,
  ),
)
```

## ⚠️ 禁止

❌ `Color(0xFF616161)`  
❌ `Colors.grey[600]`  
❌ `const Color(0xFFE0E0E0)`

✅ 使用 `AppColors.*`

---
**完整文档**: `COLOR_SYSTEM_GUIDE.md`
