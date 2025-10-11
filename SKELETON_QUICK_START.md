# 骨架屏组件快速使用指南

## ✨ 已优化的页面

### ✅ Data Service Page (城市列表页)
**骨架屏类型**: `SkeletonType.list`
**位置**: 加载城市数据时
```dart
if (controller.isLoading.value) {
  return const SkeletonLoader(type: SkeletonType.list);
}
```

### ✅ City Detail Page (城市详情页)
**骨架屏类型**: `SkeletonType.detail`
**位置**: 加载城市详细信息时
```dart
if (controller.isLoading.value) {
  return const SkeletonLoader(type: SkeletonType.detail);
}
```

### ✅ Travel Plan Page (旅行计划页)
**骨架屏类型**: 自定义详细骨架屏
**位置**: 生成AI旅行计划时
- 已有自定义骨架屏实现
- 包含header、卡片等详细元素

## 🚀 快速集成到其他页面

### 1. 导入组件
```dart
import '../widgets/skeleton_loader.dart';
```

### 2. 替换loading状态
**之前**:
```dart
if (controller.isLoading.value) {
  return const Center(
    child: CircularProgressIndicator(),
  );
}
```

**现在**:
```dart
if (controller.isLoading.value) {
  return const SkeletonLoader(type: SkeletonType.list);
}
```

### 3. 选择合适的类型

| 页面类型 | 推荐骨架屏 |
|---------|-----------|
| 列表页面 | `SkeletonType.list` |
| 网格布局 | `SkeletonType.grid` |
| 详情页面 | `SkeletonType.detail` |
| 个人资料 | `SkeletonType.profile` |
| 单个卡片 | `SkeletonType.card` |

## 📋 待优化页面清单

### Profile Page (个人资料页)
```dart
// 文件: lib/pages/profile_page.dart
// 建议类型: SkeletonType.profile

if (controller.isLoading.value) {
  return const SkeletonLoader(type: SkeletonType.profile);
}
```

### Chat Page (聊天页面)
```dart
// 文件: lib/pages/city_chat_page.dart
// 建议类型: SkeletonType.list

if (controller.isLoading.value) {
  return const SkeletonLoader(type: SkeletonType.list);
}
```

### Shopping Page (购物页面)
```dart
// 文件: lib/pages/shopping_page.dart
// 建议类型: SkeletonType.grid

if (controller.isLoading.value) {
  return const SkeletonLoader(type: SkeletonType.grid);
}
```

## 🎨 动画特性

所有骨架屏都自带:
- ✨ 1.5秒循环的闪烁动画
- 🌊 平滑的渐变光效
- 🎭 专业的灰色配色方案
- 📱 响应式布局适配

## 💡 最佳实践

1. **统一风格**: 整个应用使用相同的骨架屏组件
2. **类型匹配**: 选择与实际内容布局相似的类型
3. **自动管理**: 无需手动控制动画,组件会自动处理
4. **性能优化**: 组件已优化,不会影响性能

## 🔄 迁移步骤

1. 导入组件: `import '../widgets/skeleton_loader.dart';`
2. 找到loading状态判断
3. 替换CircularProgressIndicator为SkeletonLoader
4. 选择合适的type参数
5. 测试效果

## 📦 组件文件位置

```
lib/
├── widgets/
│   └── skeleton_loader.dart         # 骨架屏组件
└── pages/
    ├── data_service_page.dart       # ✅ 已使用
    ├── city_detail_page.dart        # ✅ 已使用
    ├── travel_plan_page.dart        # ✅ 已使用(自定义)
    ├── profile_page.dart            # 待优化
    ├── city_chat_page.dart          # 待优化
    └── shopping_page.dart           # 待优化
```

## 🎯 下一步行动

推荐按以下顺序优化其他页面:

1. **Profile Page** - 用户会经常访问
2. **Chat Page** - 提升聊天体验
3. **Shopping Page** - 改善购物体验

每个页面只需要3-5行代码即可完成集成!
