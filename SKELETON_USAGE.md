# 骨架屏使用快速指南

## 🎯 一分钟快速上手

### 基本使用

在任何需要加载状态的页面，只需三步：

**步骤1**: 导入组件
```dart
import '../widgets/skeleton_loader.dart';
```

**步骤2**: 替换加载指示器
```dart
// ❌ 旧的方式
if (controller.isLoading.value) {
  return const Center(child: CircularProgressIndicator());
}

// ✅ 新的方式
if (controller.isLoading.value) {
  return const SkeletonLoader(type: SkeletonType.list);
}
```

**步骤3**: 选择合适的骨架屏类型（见下方类型对照表）

## 📋 骨架屏类型快速选择

| 如果你的页面是... | 使用类型 | 示例页面 |
|-----------------|---------|---------|
| 首页（轮播图+网格卡片） | `SkeletonType.home` | home_page |
| 城市/商品详情页 | `SkeletonType.detail` | city_detail_page |
| 普通列表页 | `SkeletonType.list` | data_service_page |
| 聊天室列表 | `SkeletonType.chat` | city_chat_page(列表) |
| 聊天消息列表 | `SkeletonType.messages` | city_chat_page(消息) |
| 个人资料页 | `SkeletonType.profile` | profile_page |
| 社区内容流 | `SkeletonType.community` | community_page |
| 网格布局 | `SkeletonType.grid` | - |
| 单张卡片 | `SkeletonType.card` | - |

## 💡 常见场景

### 场景1: 列表页面加载
```dart
// pages/my_list_page.dart
import '../widgets/skeleton_loader.dart';

body: Obx(() {
  if (controller.isLoading.value) {
    return const SkeletonLoader(type: SkeletonType.list);
  }
  return ListView.builder(...);
})
```

### 场景2: 详情页加载
```dart
// pages/product_detail_page.dart
import '../widgets/skeleton_loader.dart';

body: Obx(() {
  if (controller.isLoading.value) {
    return const SkeletonLoader(type: SkeletonType.detail);
  }
  return DetailContent(...);
})
```

### 场景3: 首页加载
```dart
// pages/home_page.dart
import '../widgets/skeleton_loader.dart';

body: Obx(() {
  if (controller.isLoading.value) {
    return const SkeletonLoader(type: SkeletonType.home);
  }
  return HomeContent(...);
})
```

### 场景4: 聊天消息加载
```dart
// pages/chat_page.dart
import '../widgets/skeleton_loader.dart';

Expanded(
  child: Obx(() {
    if (controller.isLoading.value) {
      return const SkeletonLoader(type: SkeletonType.messages);
    }
    return MessagesList(...);
  }),
)
```

## 🎨 视觉效果

所有骨架屏自动包含：
- ✨ **Shimmer闪烁动画** (1500ms循环)
- 🎯 **统一的圆角和间距**
- 📱 **响应式布局**
- 🌈 **与实际内容结构匹配的形状**

## ⚙️ 高级用法

### 自定义骨架屏
如果预设类型都不满足需求，可以传入自定义骨架：

```dart
SkeletonLoader(
  customSkeleton: MyCustomSkeletonWidget(),
)
```

### 在现有组件中使用骨架元素

```dart
// 使用骨架卡片
SkeletonCard(
  shimmerController: _shimmerController,
  height: 200,
  child: YourContent(),
)

// 使用骨架盒子
SkeletonBox(
  shimmerController: _shimmerController,
  width: 100,
  height: 20,
  borderRadius: 8,
)
```

## ✅ 已优化页面清单

- [x] home_page.dart (首页)
- [x] city_detail_page.dart (城市详情)
- [x] data_service_page.dart (数据服务)
- [x] city_chat_page.dart (聊天室列表 + 消息列表)
- [x] profile_page.dart (个人资料)
- [x] community_page.dart (社区)
- [x] travel_plan_page.dart (旅行计划，自定义骨架)

## 🚀 快速迁移指南

将现有页面迁移到骨架屏只需3分钟：

1. 添加import: `import '../widgets/skeleton_loader.dart';`
2. 找到 `CircularProgressIndicator` 所在的加载判断
3. 替换为 `SkeletonLoader(type: SkeletonType.xxx)`
4. 根据页面内容选择合适的类型
5. 保存并测试

## 📞 需要帮助？

查看完整文档：
- `SKELETON_LOADER_GUIDE.md` - 完整使用指南
- `SKELETON_COMPLETE.md` - 优化完成报告
- `lib/widgets/skeleton_loader.dart` - 源代码和注释
