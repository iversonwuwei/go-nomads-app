# 🎨 Card 背景色统一更新

## 📋 更新内容

### 1. 统一卡片背景色

所有 API 卡片和数据分类图标已统一为 **浅蓝灰色** `#B0BEC5`

#### 更新前 ❌
- API 卡片: 6 种不同颜色 (蓝灰、棕灰、绿灰、紫灰、橙灰、天蓝灰)
- 数据分类: 9 种不同颜色 (深浅不一的灰色渐变)

#### 更新后 ✅
- API 卡片: 统一浅蓝灰色 `#B0BEC5`
- 数据分类图标: 统一浅蓝灰色 `#B0BEC5`

---

## 🎨 新增配色

### 卡片专用背景色

```dart
AppColors.cardBackground  // #B0BEC5 - 统一卡片背景色
```

**用途**: 所有卡片的默认背景色

---

## 📝 修改的配置

### `lib/config/app_colors.dart`

#### 1. 新增卡片背景色
```dart
/// 统一卡片背景色 - 浅蓝灰
static const Color cardBackground = Color(0xFFB0BEC5);
```

#### 2. API 卡片颜色数组
```dart
// 之前: 6 种不同颜色
static const List<Color> apiCardColors = [
  Color(0xFFB0BEC5), // 蓝灰
  Color(0xFFBCAAA4), // 棕灰
  Color(0xFFA5D6A7), // 绿灰
  Color(0xFFCE93D8), // 紫灰
  Color(0xFFFFCC80), // 橙灰
  Color(0xFF90CAF9), // 天蓝灰
];

// 现在: 统一浅蓝灰
static const List<Color> apiCardColors = [
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
];
```

#### 3. 数据分类图标颜色数组
```dart
// 之前: 9 种不同颜色
static const List<Color> dataCategoryColors = [
  Color(0xFF78909C), // 深蓝灰
  Color(0xFF90A4AE), // 中蓝灰
  Color(0xFFA1887F), // 棕灰
  Color(0xFF81C784), // 绿灰
  Color(0xFFB0BEC5), // 浅蓝灰
  Color(0xFF9E9E9E), // 中灰
  Color(0xFFAED581), // 浅绿灰
  Color(0xFFBCAAA4), // 浅棕灰
  Color(0xFFBDBDBD), // 极浅灰
];

// 现在: 统一浅蓝灰
static const List<Color> dataCategoryColors = [
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
  Color(0xFFB0BEC5), // 统一浅蓝灰
];
```

---

## 🎯 影响范围

### 自动生效的页面

由于使用了统一的 `AppColors` 配色系统,以下页面会自动应用新配色:

#### ✅ HomePage (首页)
- **数据分类图标**: 全部统一为浅蓝灰色
- **推荐API卡片**: 全部统一为浅蓝灰色

#### ✅ API Marketplace (API市场)
- **API接口卡片**: 全部统一为浅蓝灰色

---

## 🎨 视觉效果

### 统一后的优势

1. **视觉统一**: 所有卡片和图标颜色一致,更加和谐
2. **简洁明了**: 避免多色干扰,突出内容本身
3. **符合设计**: 与性冷淡风格完美契合
4. **易于识别**: 统一配色让用户更容易识别卡片类型

### 浅蓝灰色特点

- **色值**: `#B0BEC5`
- **RGB**: (176, 190, 197)
- **描述**: 柔和的浅蓝灰色,视觉舒适
- **风格**: 性冷淡、极简、现代

---

## 📖 使用方式

### 直接使用卡片背景色
```dart
Container(
  color: AppColors.cardBackground,
  // ...
)
```

### 使用数组方式(自动统一)
```dart
// API卡片
Container(
  color: AppColors.getApiCardColor(index),
  // 所有索引都返回 #B0BEC5
)

// 数据分类图标
Icon(
  Icons.category,
  color: AppColors.getDataCategoryColor(index),
  // 所有索引都返回 #B0BEC5
)
```

---

## ✅ 完成状态

- ✅ 配色文件已更新
- ✅ API卡片颜色统一
- ✅ 数据分类图标颜色统一
- ✅ 所有页面自动生效
- ✅ 无编译错误
- ✅ 符合设计规范

---

## 🔄 回滚方式

如需恢复多彩配色,只需修改 `lib/config/app_colors.dart` 中的数组:

```dart
// 恢复多色API卡片
static const List<Color> apiCardColors = [
  Color(0xFFB0BEC5),
  Color(0xFFBCAAA4),
  Color(0xFFA5D6A7),
  Color(0xFFCE93D8),
  Color(0xFFFFCC80),
  Color(0xFF90CAF9),
];

// 恢复多色数据分类
static const List<Color> dataCategoryColors = [
  Color(0xFF78909C),
  Color(0xFF90A4AE),
  Color(0xFFA1887F),
  // ...
];
```

---

**更新日期**: 2025年10月3日  
**状态**: ✅ 已完成并投入使用  
**影响**: 全局卡片和图标配色
