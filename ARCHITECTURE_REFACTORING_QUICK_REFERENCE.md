# 架构重构快速参考

## 核心原则

### ✅ Coworking 架构模式(标准参考)

```
主页面 → 路由表 + BottomNavLayout
详情页 → Navigator.push (NOT in routes)
表单页 → Navigator.push (NOT in routes)
```

## 导航模式对比

### 🟢 主页面导航 (Get.toNamed)

```dart
// 在路由表中定义
GetPage(
  name: cityList,
  page: () => const BottomNavLayout(child: CityListPage()),
  middlewares: [AuthMiddleware()],
)

// 使用时
Get.toNamed(AppRoutes.cityList);
```

### 🟡 详情页导航 (Navigator.push)

```dart
// ❌ 不在路由表中

// 使用时
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CityDetailPage(
      cityId: cityId,
      cityName: cityName,
      cityImage: cityImage,
      overallScore: score,
      reviewCount: count,
    ),
  ),
);
```

### 🟡 表单页导航 (Navigator.push)

```dart
// ❌ 不在路由表中

// 使用时
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CreateMeetupPage(),
  ),
);

// 处理返回值
if (result == true) {
  _loadData();
}
```

## 本次重构变更

### 移除的路由

- ❌ `cityDetail` - 详情页
- ❌ `citySearch` - 工具页
- ❌ `cityCompare` - 工具页
- ❌ `createMeetup` - 表单页

### 保留的路由

- ✅ `cityList` - 主页面
- ✅ `meetupsList` - 主页面
- ✅ `coworking` - 主页面
- ✅ `cityChat` - 主页面

## 修改的文件

1. `lib/routes/app_routes.dart` - 移除4个路由
2. `lib/pages/meetups_list_page.dart` - 1处 CreateMeetup
3. `lib/pages/data_service_page.dart` - 2处 CreateMeetup + 2处 CityDetail
4. `lib/pages/invite_to_meetup_page.dart` - 1处 CreateMeetup
5. `lib/pages/favorites_page.dart` - 2处 CityDetail
6. `lib/pages/city_compare_page.dart` - 1处 CityDetail

## 判断标准

### 应该在路由表的页面

- ✅ 有底部导航的主入口页面
- ✅ 可以从多个地方直接访问
- ✅ 是应用的核心功能页

### 应该用 Navigator.push 的页面

- ✅ 详情页(显示单个对象的信息)
- ✅ 表单页(创建/编辑数据)
- ✅ 工具页(搜索、对比等)
- ✅ 只从一个父页面打开的页面

## 优势对比

| 方面 | Get.toNamed | Navigator.push |
|------|-------------|----------------|
| 参数传递 | Get.arguments (动态) | 构造函数(类型安全) |
| 路由表 | 需要配置 | 不需要 |
| 底部导航 | 支持 | 不支持 |
| 页面栈 | 独立栈 | 正常栈 |
| 适用场景 | 主页面 | 详情/表单页 |

## 验证清单

- [ ] 所有 Dart 文件编译通过
- [ ] 导入正确(有 import 页面类)
- [ ] 参数正确传递(构造函数参数)
- [ ] 返回值处理正确
- [ ] 路由表简洁(只有主页面)

## 相关文档

- `ARCHITECTURE_REFACTORING_COMPLETE.md` - 详细重构文档
- `COWORKING_ARCHITECTURE_ROLLBACK.md` - Coworking 架构恢复
- `ROUTE_REFACTORING_COMPLETE.md` - 路由重构文档
