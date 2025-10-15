# 骨架屏组件快速参考

## 快速开始

### 1. 导入
```dart
import '../widgets/skeletons/skeletons.dart';
```

### 2. 使用
```dart
// 在加载状态时显示对应的骨架屏
if (isLoading) {
  return const HomeSkeleton();  // 或其他页面的骨架屏
}
```

## 可用的骨架屏组件

| 组件名称 | 适用页面 | 说明 |
|---------|---------|------|
| `HomeSkeleton` | 首页 | 轮播图、快捷功能、API网格 |
| `CityListSkeleton` | 城市列表 | 城市卡片列表 |
| `CityDetailSkeleton` | 城市详情 | 大图、标题、详情卡片 |
| `ProfileSkeleton` | 个人资料 | 头像、统计卡片、列表 |
| `ChatListSkeleton` | 聊天室列表 | 聊天室卡片 |
| `MessagesSkeleton` | 聊天消息 | 消息气泡（左右对齐） |
| `CommunitySkeleton` | 社区 | 用户发帖卡片 |
| `DataServiceListSkeleton` | 数据服务 | 服务卡片列表 |
| `GridSkeleton` | 通用网格 | 可配置的网格布局 |

## 基础组件

### SkeletonBox - 矩形占位符
```dart
SkeletonBox(
  shimmerController: shimmerController,
  width: 100,
  height: 20,
  borderRadius: 4,
)
```

### SkeletonCircle - 圆形占位符（头像）
```dart
SkeletonCircle(
  shimmerController: shimmerController,
  size: 48,
)
```

### SkeletonCard - 卡片容器
```dart
SkeletonCard(
  shimmerController: shimmerController,
  height: 100,
  child: YourContent(),
)
```

## 创建新骨架屏

```dart
class MyPageSkeleton extends BaseSkeleton {
  const MyPageSkeleton({super.key});

  @override
  State<MyPageSkeleton> createState() => _MyPageSkeletonState();
}

class _MyPageSkeletonState extends BaseSkeletonState<MyPageSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    return Column(
      children: [
        SkeletonBox(
          shimmerController: shimmerController,
          width: 200,
          height: 20,
        ),
      ],
    );
  }
}
```

## 常用模式

### 列表布局
```dart
ListView.builder(
  itemCount: 5,
  itemBuilder: (context, index) {
    return SkeletonCard(
      shimmerController: shimmerController,
      height: 100,
    );
  },
)
```

### 网格布局
```dart
GridView.count(
  crossAxisCount: 2,
  children: List.generate(4, (index) {
    return SkeletonCard(
      shimmerController: shimmerController,
    );
  }),
)
```

### 头像+文本组合
```dart
Row(
  children: [
    SkeletonCircle(
      shimmerController: shimmerController,
      size: 48,
    ),
    const SizedBox(width: 12),
    Expanded(
      child: SkeletonBox(
        shimmerController: shimmerController,
        height: 16,
      ),
    ),
  ],
)
```

## 注意事项

1. ✅ 所有骨架屏组件都是 `const` 构造，性能优化
2. ✅ `shimmerController` 自动管理，无需手动释放
3. ✅ 完全匹配实际页面布局，提供最佳用户体验
4. ✅ 独立组件，互不影响，易于维护

## 更多信息

详细文档请参阅：
- `SKELETON_COMPONENTS_GUIDE.md` - 完整使用指南
- `SKELETON_REFACTOR_SUMMARY.md` - 重构说明
