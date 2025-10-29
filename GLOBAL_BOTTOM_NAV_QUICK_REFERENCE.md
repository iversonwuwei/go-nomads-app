# 全局底部导航 - 快速参考

## 📋 核心概念

**包装器模式**: 每个页面都可以包装在 `BottomNavLayout` 中，自动获得底部导航栏。

---

## 🚀 为页面添加底部导航

### 有底部导航的页面

```dart
GetPage(
  name: yourRoute,
  page: () => const BottomNavLayout(child: YourPage()),
),
```

### 无底部导航的页面

```dart
GetPage(
  name: yourRoute,
  page: () => const YourPage(),  // 不包装
),
```

### 可选显示底部导航

```dart
GetPage(
  name: yourRoute,
  page: () => const BottomNavLayout(
    child: YourPage(),
    showBottomNav: false,  // 隐藏导航
  ),
),
```

---

## 📱 底部导航标签

| 索引 | 图标 | 标签 | 路由 | 说明 |
|------|------|------|------|------|
| 0 | 🏠 | 首页 | `/` | 清除导航栈 |
| 1 | 🤖 | AI助手 | `/ai-chat` | 检查登录 |
| 2 | 👤 | 个人中心 | `/profile` | 普通跳转 |

---

## 🎯 路由跳转行为

```
点击首页 → Get.offAllNamed('/') → 清除所有导航栈
点击AI助手 → 检查登录 → 跳转 /ai-chat 或 /login
点击个人中心 → Get.toNamed('/profile')
```

---

## 🔧 控制器方法

```dart
final controller = Get.find<BottomNavController>();

// 切换标签
controller.changeTab(0);

// 隐藏/显示导航
controller.hideBottomNav();
controller.showBottomNav();

// 重置到首页
controller.resetToHome();

// 同步路由状态
controller.updateIndexByRoute();
```

---

## ✅ 已包含底部导航的页面

- ✅ 首页 (`/`)
- ✅ 个人中心 (`/profile`)
- ✅ 所有数据服务页面
- ✅ 城市详情、聊天等功能页面
- ✅ Coworking、Meetup等页面

## ❌ 不包含底部导航的页面

- ❌ 登录页 (`/login`)
- ❌ 注册页 (`/register`)
- ❌ AI聊天页 (`/ai-chat`)

---

## 🎨 自动同步选中状态

```dart
// BottomNavLayout 会在构建时自动调用
controller.updateIndexByRoute();

// 根据当前路由更新选中索引
'/' → 索引 0
'/profile' → 索引 2
其他路由 → 保持当前索引
```

---

## 📝 常用场景

### 添加新的主页面

1. 在 `app_routes.dart` 中添加路由
2. 包装在 `BottomNavLayout` 中
3. 完成！

```dart
GetPage(
  name: '/new-feature',
  page: () => const BottomNavLayout(child: NewFeaturePage()),
),
```

### 添加新的底部标签

1. 在 `bottom_nav_layout.dart` 的 `items` 中添加
2. 在 `onTap` 中添加跳转逻辑
3. 在 `updateIndexByRoute()` 中添加路由映射

---

## 🐛 故障排查

**问题**: 底部导航不显示
- 检查页面是否包装在 `BottomNavLayout` 中
- 检查 `showBottomNav` 是否为 `true`

**问题**: 选中状态不正确
- 检查 `updateIndexByRoute()` 中的路由映射
- 确保路由常量正确

**问题**: 点击无反应
- 检查 `onTap` 中的路由逻辑
- 查看控制台是否有错误

---

## 📚 相关文档

- 详细实现: `GLOBAL_BOTTOM_NAV_COMPLETE.md`
- 路由配置: `lib/routes/app_routes.dart`
- 布局组件: `lib/layouts/bottom_nav_layout.dart`
- 控制器: `lib/controllers/bottom_nav_controller.dart`

---

**最后更新**: 2025-10-29  
**状态**: ✅ 可用
