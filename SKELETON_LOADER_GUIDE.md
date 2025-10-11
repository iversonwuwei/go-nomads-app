# 通用骨架屏加载组件使用指南

## 📦 组件介绍

`SkeletonLoader` 是一个通用的骨架屏加载组件,提供了多种预设样式和闪烁动画效果,可以在整个应用中复用。

## 🎨 预设骨架屏类型

### 1. List - 列表骨架屏
适用于: 城市列表、评论列表、消息列表等

```dart
SkeletonLoader(type: SkeletonType.list)
```

### 2. Grid - 网格骨架屏
适用于: 图片网格、卡片网格、商品列表等

```dart
SkeletonLoader(type: SkeletonType.grid)
```

### 3. Detail - 详情页骨架屏
适用于: 城市详情、用户详情、文章详情等

```dart
SkeletonLoader(type: SkeletonType.detail)
```

### 4. Profile - 个人资料骨架屏
适用于: 用户资料页、个人中心等

```dart
SkeletonLoader(type: SkeletonType.profile)
```

### 5. Card - 卡片骨架屏
适用于: 单个卡片、信息面板等

```dart
SkeletonLoader(type: SkeletonType.card)
```

## 🚀 使用方法

### 基础使用

```dart
Obx(() {
  if (controller.isLoading.value) {
    return const SkeletonLoader(type: SkeletonType.list);
  }
  return YourActualContent();
})
```

### 在 StatefulWidget 中使用

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyController>();
    
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SkeletonLoader(type: SkeletonType.detail);
        }
        
        return CustomScrollView(
          // 实际内容
        );
      }),
    );
  }
}
```

### 自定义骨架屏

```dart
class MyCustomSkeleton extends StatefulWidget {
  @override
  State<MyCustomSkeleton> createState() => _MyCustomSkeletonState();
}

class _MyCustomSkeletonState extends State<MyCustomSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SkeletonBox(
            shimmerController: _shimmerController,
            width: 200,
            height: 20,
            borderRadius: 8,
          ),
          const SizedBox(height: 16),
          SkeletonCard(
            shimmerController: _shimmerController,
            height: 300,
            child: Column(
              children: [
                // 自定义骨架内容
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🎯 实际应用示例

### 示例 1: 城市列表页面

```dart
class CityListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataServiceController>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Cities')),
      body: Obx(() {
        if (controller.isLoading.value) {
          // 显示列表骨架屏
          return const SkeletonLoader(type: SkeletonType.list);
        }
        
        return ListView.builder(
          itemCount: controller.cities.length,
          itemBuilder: (context, index) {
            return CityCard(city: controller.cities[index]);
          },
        );
      }),
    );
  }
}
```

### 示例 2: 城市详情页面

```dart
class CityDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityDetailController>();
    
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          // 显示详情骨架屏
          return const SkeletonLoader(type: SkeletonType.detail);
        }
        
        return CustomScrollView(
          slivers: [
            SliverAppBar(/* ... */),
            SliverToBoxAdapter(/* 实际内容 */),
          ],
        );
      }),
    );
  }
}
```

### 示例 3: 个人资料页面

```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserProfileController>();
    
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          // 显示个人资料骨架屏
          return const SkeletonLoader(type: SkeletonType.profile);
        }
        
        return SingleChildScrollView(
          child: ProfileContent(user: controller.user.value),
        );
      }),
    );
  }
}
```

## 🎨 动画效果

所有骨架屏都包含以下动画效果:

- ✨ **闪烁动画**: 1.5秒循环的渐变光效
- 🌊 **流畅过渡**: 使用 LinearGradient 创建平滑的光泽扫过效果
- 🎭 **三色渐变**: 深灰 → 浅灰 → 深灰的自然过渡

## 📐 组件结构

```
SkeletonLoader (主组件)
├── SkeletonCard (卡片容器)
│   └── 带阴影和圆角的白色容器
└── SkeletonBox (基础方块)
    └── 带闪烁动画的灰色矩形
```

## ⚙️ 自定义参数

### SkeletonLoader

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| type | SkeletonType | list | 骨架屏类型 |
| customSkeleton | Widget? | null | 自定义骨架屏组件 |

### SkeletonBox

| 参数 | 类型 | 必需 | 说明 |
|------|------|------|------|
| shimmerController | AnimationController | ✅ | 动画控制器 |
| width | double | ✅ | 宽度 |
| height | double | ✅ | 高度 |
| borderRadius | double | 4 | 圆角半径 |

### SkeletonCard

| 参数 | 类型 | 必需 | 说明 |
|------|------|------|------|
| shimmerController | AnimationController | ✅ | 动画控制器 |
| height | double? | ❌ | 高度 |
| child | Widget? | ❌ | 子组件 |

## 🎯 最佳实践

1. **统一使用**: 在整个应用中使用相同的骨架屏风格
2. **类型匹配**: 选择与实际内容布局相似的骨架屏类型
3. **性能优化**: 骨架屏会自动优化,无需手动处理
4. **过渡平滑**: 配合 Obx 或 StreamBuilder 实现平滑过渡

## 🔧 技术细节

- **动画控制器**: 使用 SingleTickerProviderStateMixin
- **动画时长**: 1500ms (1.5秒)
- **动画曲线**: Linear (均匀运动)
- **渐变停止点**: [0.0, 0.5, 1.0]
- **颜色**: grey[300] / grey[100] / grey[300]

## 📝 注意事项

1. 确保在使用前导入组件:
   ```dart
   import 'package:your_app/widgets/skeleton_loader.dart';
   ```

2. 骨架屏会自动处理动画,无需手动启动或停止

3. 在页面销毁时,动画控制器会自动释放

4. 建议在数据加载超过 300ms 时才显示骨架屏,避免闪烁
