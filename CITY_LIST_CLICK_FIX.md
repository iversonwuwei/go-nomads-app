# City List 页面点击错误修复

## 🐛 问题描述

### 错误信息
```
type 'Null' is not a subtype of type 'num' in type cast
```

### 错误原因
在城市列表页面点击卡片跳转到城市详情页时，由于某些城市数据字段为 `null`，在进行类型转换时导致运行时错误。

## ✅ 修复内容

### 1. 修复跳转参数的类型转换

**位置**: `city_list_page.dart` 第 410 行

**修改前：**
```dart
overallScore: (city['score'] as num).toDouble(),
```

**修改后：**
```dart
overallScore: (city['score'] as num?)?.toDouble() ?? 0.0,
```

**说明：**
- 使用 `as num?` 允许 null 值
- 使用 `?.toDouble()` 安全调用
- 使用 `?? 0.0` 提供默认值

### 2. 修复评分显示

**位置**: `city_list_page.dart` 第 497 行

**修改前：**
```dart
Text(
  city['score'].toString(),
  // ...
)
```

**修改后：**
```dart
Text(
  (city['score'] ?? 0.0).toString(),
  // ...
)
```

### 3. 修复关键指标显示

**位置**: `city_list_page.dart` 第 515-527 行

**修改前：**
```dart
'${city['temperature']}°'
'${city['internet']} Mbps'
'\$${city['cost']}'
```

**修改后：**
```dart
'${city['temperature'] ?? 0}°'
'${city['internet'] ?? 0} Mbps'
'\$${city['cost'] ?? 0}'
```

## 🎯 测试验证

✅ 代码编译无错误
✅ 点击城市卡片跳转正常
✅ 城市详情页正常显示
✅ 无运行时异常

## 🎉 修复完成

所有 null 值问题已修复，城市列表页面点击跳转功能正常工作！
