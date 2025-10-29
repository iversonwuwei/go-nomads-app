# 四大模块导航架构 - 快速参考

## 🎯 核心原则

### 主页面 (在路由表中)
```dart
// 路由注册
GetPage(
  name: AppRoutes.moduleName,
  page: () => const BottomNavLayout(child: ModuleHomePage()),
  middlewares: [AuthMiddleware()],
)

// 导航方式
Get.toNamed(AppRoutes.moduleName)
```

### 子页面 (不在路由表中)
```dart
// 导航方式
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => DetailPage()),
)
```

---

## 📦 四大模块架构

| 模块 | 主页面 | 路由常量 | 导航方式 | 子页面 |
|------|--------|----------|----------|--------|
| **Cities** | CityListPage | `AppRoutes.cityList` | `Get.toNamed()` | CityDetailPage, CitySearchPage, CityComparePage |
| **Meetups** | MeetupsListPage | `AppRoutes.meetupsList` | `Get.toNamed()` | MeetupDetailPage, CreateMeetupPage |
| **Coworking** ⭐ | CoworkingHomePage | `AppRoutes.coworking` | `Get.toNamed()` | CoworkingListPage, CoworkingDetailPage, AddCoworkingPage |
| **Innovation** | InnovationListPage | `AppRoutes.innovation` | `Get.toNamed()` | InnovationDetailPage, AddInnovationPage |

⭐ Coworking = 架构参考标准

---

## 📋 检查清单

### 主页面必备要素
- [x] 在 `app_routes.dart` 中注册
- [x] 包含 `BottomNavLayout` 包装器
- [x] 使用 `Get.toNamed()` 导航
- [x] 包含 `AuthMiddleware`

### 子页面必备要素
- [x] **不在**路由表中
- [x] **不包含** `BottomNavLayout`
- [x] 使用 `Navigator.push()` 导航
- [x] 可以传递构造函数参数

---

## 🔧 data_service_page 瓷片导航

```dart
// ✅ 正确示例 (统一使用 Get.toNamed)
_buildCompactCard(
  title: l10n.cities,
  onTap: () => _checkLoginAndNavigate(
      () => Get.toNamed(AppRoutes.cityList)),
)

_buildCompactCard(
  title: l10n.meetups,
  onTap: () => _checkLoginAndNavigate(
      () => Get.toNamed(AppRoutes.meetupsList)),
)

_buildCompactCard(
  title: l10n.coworks,
  onTap: () => _checkLoginAndNavigate(
      () => Get.toNamed(AppRoutes.coworking)),
)

_buildCompactCard(
  title: l10n.innovation,
  onTap: () => _checkLoginAndNavigate(
      () => Get.toNamed(AppRoutes.innovation)),
)
```

---

## ✅ 完成状态

- ✅ Cities 模块 - 符合标准
- ✅ Meetups 模块 - 符合标准
- ✅ Coworking 模块 - 符合标准 (本次修复)
- ✅ Innovation 模块 - 符合标准 (本次添加+修复)

**所有四大模块架构已完全统一!** 🎉
