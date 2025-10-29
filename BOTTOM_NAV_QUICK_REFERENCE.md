# 底部导航布局 - 快速参考

## 📋 概览

统一的底部导航布局系统，所有主页面共享相同的底部导航栏。

---

## 🎯 核心文件

```
lib/
├── controllers/
│   └── bottom_nav_controller.dart    # 全局状态管理
└── layouts/
    └── bottom_nav_layout.dart         # 布局组件
```

---

## 🚀 快速使用

### 获取控制器

```dart
final controller = Get.find<BottomNavController>();
```

### 切换标签页

```dart
controller.changeTab(0);  // 首页
controller.changeTab(2);  // 个人中心
```

### 显示/隐藏底部导航

```dart
controller.hideBottomNav();  // 隐藏
controller.showBottomNav();  // 显示
```

### 重置到首页

```dart
controller.resetToHome();
```

---

## 📱 页面结构

| 索引 | 页面 | 图标 | 说明 |
|-----|------|------|------|
| 0 | DataServicePage | home | 首页 |
| 1 | AI Chat | smart_toy | 跳转到独立页面 |
| 2 | ProfilePage | person | 个人中心 |

---

## 🔐 AI助手逻辑

```
点击AI助手
   ↓
检查登录状态
   ├── 已登录 → 跳转到 AI聊天页面
   └── 未登录 → 跳转到 登录页
   ↓
重置导航栏到首页
```

---

## 🎨 样式配置

- **选中颜色**: `Colors.blue[700]`
- **未选中颜色**: `AppColors.textTertiary`
- **背景色**: `Colors.white`
- **字体大小**: 选中12 / 未选中12

---

## 🌍 国际化

标签会根据当前语言自动切换：

| 标签 | 中文 | 英文 |
|------|------|------|
| 首页 | 首页 | Home |
| AI助手 | AI助手 | AI Assistant |
| 个人中心 | 个人中心 | Profile |

---

## ✅ 已完成功能

- ✅ 统一的底部导航布局
- ✅ 页面状态保持（IndexedStack）
- ✅ AI助手登录检查
- ✅ 动态显示/隐藏导航栏
- ✅ 国际化支持
- ✅ 响应式UI（Obx）

---

## 📝 测试清单

- [ ] 点击首页标签，验证显示正确
- [ ] 点击个人中心标签，验证显示正确
- [ ] 未登录时点击AI助手，验证跳转到登录页
- [ ] 已登录时点击AI助手，验证跳转到AI聊天页
- [ ] 切换标签，验证页面状态保持
- [ ] 切换语言，验证标签文字更新

---

## 🔧 常见问题

**Q: 如何在子页面隐藏底部导航？**

A: 在子页面中调用 `Get.find<BottomNavController>().hideBottomNav()`

**Q: 如何添加新的标签页？**

A: 修改 `bottom_nav_layout.dart`：
1. 在 `pages` 列表中添加新页面
2. 在 `items` 列表中添加新的 `BottomNavigationBarItem`
3. 更新索引处理逻辑

**Q: 为什么AI助手不在IndexedStack中？**

A: AI助手需要单独的页面和更复杂的功能，所以设计为跳转到独立页面。

---

## 📚 相关文档

- 详细实现文档: `BOTTOM_NAV_LAYOUT_COMPLETE.md`
- 路由配置: `lib/routes/app_routes.dart`
- 全局控制器初始化: `lib/main.dart`

---

**最后更新**: 2025-01-XX  
**状态**: ✅ 已完成
