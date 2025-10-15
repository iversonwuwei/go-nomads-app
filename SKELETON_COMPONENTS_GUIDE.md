# 骨架屏组件使用指南

## 概述

本项目已重构骨架屏（Skeleton）组件系统，从通用的 `SkeletonLoader` 改为每个页面独立的专属骨架屏组件。新的设计模式提供了更好的可维护性和灵活性。

## 新架构说明

### 基础组件

所有骨架屏组件都位于 `lib/widgets/skeletons/` 目录下：

- **`base_skeleton.dart`** - 基础抽象类，所有骨架屏都继承自它
  - `BaseSkeleton` - 骨架屏抽象组件
  - `BaseSkeletonState` - 骨架屏抽象状态类
  - `SkeletonCard` - 卡片容器组件
  - `SkeletonBox` - 基础盒子组件
  - `SkeletonCircle` - 圆形组件（用于头像等）
  - `SkeletonDivider` - 分隔线组件

### 页面专属骨架屏组件

每个主要页面都有自己的骨架屏组件：

1. **`home_skeleton.dart`** - `HomeSkeleton`
   - 首页骨架屏
   - 包含轮播图、快捷功能网格、API接口网格

2. **`city_list_skeleton.dart`** - `CityListSkeleton`
   - 城市列表页骨架屏
   - 显示城市卡片列表布局

3. **`city_detail_skeleton.dart`** - `CityDetailSkeleton`
   - 城市详情页骨架屏
   - 包含顶部大图、标题、详情卡片

4. **`profile_skeleton.dart`** - `ProfileSkeleton`
   - 个人资料页骨架屏
   - 包含头像、用户信息、统计卡片、列表项

5. **`chat_list_skeleton.dart`** - `ChatListSkeleton`
   - 聊天室列表骨架屏
   - 显示聊天室卡片列表

6. **`messages_skeleton.dart`** - `MessagesSkeleton`
   - 聊天消息骨架屏
   - 交替显示左右对齐的消息气泡

7. **`community_skeleton.dart`** - `CommunitySkeleton`
   - 社区内容骨架屏
   - 显示用户发帖卡片布局

8. **`data_service_list_skeleton.dart`** - `DataServiceListSkeleton`
   - 数据服务列表骨架屏
   - 显示服务卡片列表

9. **`grid_skeleton.dart`** - `GridSkeleton`
   - 通用网格骨架屏
   - 可配置列数和宽高比

## 使用方法

### 1. 导入骨架屏组件

```dart
import '../widgets/skeletons/skeletons.dart';
```

### 2. 在页面中使用

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Obx(() {
      if (controller.isLoading.value) {
        // 使用对应页面的专属骨架屏
        return const HomeSkeleton();
      }
      
      // 返回实际内容
      return _buildActualContent();
    }),
  );
}
```

## 创建新的骨架屏组件

如果需要为新页面创建骨架屏组件，请遵循以下步骤：

### 1. 创建新的骨架屏文件

在 `lib/widgets/skeletons/` 目录下创建新文件，例如 `my_page_skeleton.dart`：

```dart
import 'package:flutter/material.dart';
import 'base_skeleton.dart';

/// 我的页面骨架屏组件
class MyPageSkeleton extends BaseSkeleton {
  const MyPageSkeleton({super.key});

  @override
  State<MyPageSkeleton> createState() => _MyPageSkeletonState();
}

class _MyPageSkeletonState extends BaseSkeletonState<MyPageSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 使用基础组件构建你的骨架屏布局
          SkeletonBox(
            shimmerController: shimmerController,
            width: double.infinity,
            height: 200,
            borderRadius: 16,
          ),
          const SizedBox(height: 16),
          SkeletonCard(
            shimmerController: shimmerController,
            height: 100,
            child: Row(
              children: [
                SkeletonCircle(
                  shimmerController: shimmerController,
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      SkeletonBox(
                        shimmerController: shimmerController,
                        width: double.infinity,
                        height: 16,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. 在 skeletons.dart 中导出

编辑 `lib/widgets/skeletons/skeletons.dart`，添加导出：

```dart
export 'my_page_skeleton.dart';
```

### 3. 在页面中使用

```dart
import '../widgets/skeletons/skeletons.dart';

// 在页面中使用
return const MyPageSkeleton();
```

## 可用的基础组件

### SkeletonBox

最基础的盒子组件，用于显示矩形占位符：

```dart
SkeletonBox(
  shimmerController: shimmerController,
  width: 100,        // 可选，默认为 null（自适应）
  height: 20,        // 可选，默认为 null（自适应）
  borderRadius: 4,   // 可选，默认为 4
  margin: EdgeInsets.all(8), // 可选
)
```

### SkeletonCircle

圆形组件，通常用于头像占位：

```dart
SkeletonCircle(
  shimmerController: shimmerController,
  size: 48,          // 必需
  margin: EdgeInsets.all(8), // 可选
)
```

### SkeletonCard

卡片容器，带阴影和圆角：

```dart
SkeletonCard(
  shimmerController: shimmerController,
  height: 100,       // 可选
  width: 200,        // 可选
  padding: EdgeInsets.all(16),  // 可选，默认 16
  margin: EdgeInsets.all(8),    // 可选
  child: YourContent(),  // 可选，如果提供则显示子组件
)
```

### SkeletonDivider

分隔线组件：

```dart
SkeletonDivider(
  shimmerController: shimmerController,
  width: double.infinity,  // 可选，默认全宽
  height: 1,               // 可选，默认 1
  margin: EdgeInsets.symmetric(vertical: 8), // 可选
)
```

## 优势

相比旧的通用 `SkeletonLoader` 系统，新架构有以下优势：

1. **更精确的匹配** - 每个页面的骨架屏完全匹配实际内容布局
2. **更好的可维护性** - 每个骨架屏独立，修改不会影响其他页面
3. **更灵活** - 可以为每个页面定制特殊的骨架效果
4. **类型安全** - 使用继承而不是枚举，更符合 OOP 原则
5. **易于扩展** - 添加新的骨架屏只需创建新类，无需修改通用组件
6. **复用性强** - 基础组件可以在任何骨架屏中复用

## 迁移记录

以下页面已完成迁移：

- ✅ 首页 (`home_page.dart`) - 使用 `HomeSkeleton`
- ✅ 城市列表 (`city_list_page.dart`) - 使用 `CityListSkeleton`
- ✅ 城市详情 (`city_detail_page.dart`) - 使用 `CityDetailSkeleton`
- ✅ 个人资料 (`profile_page.dart`) - 使用 `ProfileSkeleton`
- ✅ 聊天室列表 (`city_chat_page.dart`) - 使用 `ChatListSkeleton`
- ✅ 聊天消息 (`city_chat_page.dart`, `direct_chat_page.dart`) - 使用 `MessagesSkeleton`
- ✅ 社区 (`community_page.dart`) - 使用 `CommunitySkeleton`
- ✅ 数据服务 (`data_service_page.dart`) - 使用 `DataServiceListSkeleton`

旧的 `skeleton_loader.dart` 文件已被新架构完全替代，可以保留作为参考或删除。

## 常见问题

### Q: 如何调整闪光动画速度？

A: 在 `base_skeleton.dart` 的 `initState` 方法中修改 `duration`：

```dart
shimmerController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 1500), // 修改这里
)..repeat();
```

### Q: 如何改变骨架屏的颜色？

A: 在 `SkeletonBox` 或 `SkeletonCard` 的 `AnimatedBuilder` 中修改 `colors`：

```dart
gradient: LinearGradient(
  colors: [
    Colors.grey[300]!,  // 修改这些颜色
    Colors.grey[100]!,
    Colors.grey[300]!,
  ],
  ...
)
```

### Q: 为什么需要 shimmerController？

A: `shimmerController` 是动画控制器，它驱动骨架屏的闪光效果。所有继承 `BaseSkeletonState` 的类都会自动获得这个控制器，并在组件销毁时自动清理。
