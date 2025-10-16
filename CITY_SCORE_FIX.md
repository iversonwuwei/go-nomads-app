# 城市综合得分显示修复

## 修复时间
2025年10月16日

## 问题描述
城市列表页面和详情页面中的综合得分没有被正确显示：
1. **城市列表页面**：卡片上的得分显示为 0.0
2. **城市详情页面**：跳转后显示的综合得分也是 0.0

## 问题根源
数据源字段名不一致：
- **数据源**（`DataServiceController`）使用的键名：`'overall'`
- **界面代码**尝试访问的键名：`'score'`

## 修复文件

### 1. lib/pages/data_service_page.dart
修复了两处：

**① 城市卡片显示得分**（第 1313 行附近）
```dart
// 修复前
Text((widget.data['score'] as num?)?.toStringAsFixed(1) ?? '0.0')

// 修复后
Text((widget.data['overall'] as num?)?.toStringAsFixed(1) ?? '0.0')
```

**② 跳转到详情页参数**（第 1111 行附近）
```dart
// 修复前
overallScore: (widget.data['score'] as num?)?.toDouble() ?? 0.0

// 修复后
overallScore: (widget.data['overall'] as num?)?.toDouble() ?? 0.0
```

### 2. lib/pages/city_list_page.dart
修复了两处：

**① 城市卡片显示得分**（第 582 行附近）
```dart
// 修复前
Text((city['score'] ?? 0.0).toString())

// 修复后
Text((city['overall'] as num?)?.toStringAsFixed(1) ?? '0.0')
```

**② 跳转到详情页参数**（第 495 行附近）
```dart
// 修复前
overallScore: (city['score'] as num?)?.toDouble() ?? 0.0

// 修复后
overallScore: (city['overall'] as num?)?.toDouble() ?? 0.0
```

### 3. lib/pages/city_detail_page.dart
✅ **无需修改**
- 该页面通过构造函数参数 `overallScore` 接收数据
- 显示逻辑正确（第 192 行）：`widget.overallScore.toStringAsFixed(1)`

## 数据源说明

### DataServiceController 数据映射
`lib/controllers/data_service_controller.dart` 第 126 行：
```dart
'overall': (city['overall_score'] as num?)?.toDouble() ?? 4.0,
```

**数据流程：**
```
数据库 overall_score 字段
    ↓
DataServiceController 映射为 'overall' 键
    ↓
界面代码读取 data['overall']
    ↓
显示：⭐ 4.8 综合得分
```

## 修复效果

### Data Service 页面（首页城市卡片）
- ✅ 城市卡片显示：⭐ 4.8 综合得分（金色星星）
- ✅ 点击跳转时传递正确的得分值

### City List 页面（完整城市列表）
- ✅ 城市卡片显示：⭐ 4.8（红色星星）
- ✅ 点击跳转时传递正确的得分值

### City Detail 页面（城市详情）
- ✅ 顶部评分卡片显示：⭐ 4.8（白色星星）
- ✅ 正确接收并显示传递的得分值

## 验证结果

### 代码分析
```bash
flutter analyze lib/pages/data_service_page.dart
✅ No issues found!

flutter analyze lib/pages/city_list_page.dart
✅ No issues found! (仅有 5 个 avoid_print 的 lint 提示)
```

### 预期行为
1. **首页城市卡片**：显示真实得分（如 4.8、4.6 等）
2. **城市列表卡片**：显示真实得分
3. **城市详情页面**：显示真实得分
4. **得分格式**：保留一位小数（如 4.8）

## 注意事项

### 统一字段名规范
今后访问城市综合得分时，请使用：
- ✅ **正确**：`city['overall']` 或 `data['overall']`
- ❌ **错误**：`city['score']` 或 `data['score']`

### 数据类型处理
```dart
// 推荐的安全读取方式
(city['overall'] as num?)?.toDouble() ?? 0.0
(city['overall'] as num?)?.toStringAsFixed(1) ?? '0.0'
```

## 相关文件
- `lib/controllers/data_service_controller.dart` - 数据源定义
- `lib/pages/data_service_page.dart` - 首页数据服务
- `lib/pages/city_list_page.dart` - 城市列表页面
- `lib/pages/city_detail_page.dart` - 城市详情页面

## 总结
通过将所有引用 `'score'` 字段的地方统一改为 `'overall'`，确保了数据源和界面代码的一致性，使得城市综合得分能够在所有页面正确显示。
