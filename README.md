# 数金数据 - Flutter Getx 购物应用

这是一个使用 Flutter 和 GetX 状态管理的现代化购物应用。

## 项目结构

```
lib/
├── main.dart                         # 应用入口，仅包含应用配置
├── controllers/                      # 控制器目录
│   ├── counter_controller.dart       # 计数器控制器（示例）
│   └── shopping_controller.dart      # 购物应用主控制器
├── models/                          # 数据模型目录
│   └── product_model.dart           # 商品和轮播图数据模型
├── pages/                           # 页面目录
│   ├── main_page.dart              # 主页面容器（包含底部导航）
│   ├── home_page.dart              # 购物首页
│   ├── profile_page.dart           # 个人中心页面
│   └── second_page.dart            # 第二页（示例）
└── routes/                          # 路由配置目录
    └── app_routes.dart             # 应用路由配置
```

## 应用特性

### 🏠 购物首页
- ✅ **轮播图Banner**: 自动播放，带指示器
- ✅ **快捷功能区**: 分类、优惠券、秒杀、礼品等快捷入口
- ✅ **热门精选**: 热门商品网格展示，带"HOT"标签
- ✅ **精选推荐**: 推荐商品网格展示
- ✅ **商品卡片**: 包含图片、名称、价格、原价（划线）
- ✅ **网络图片缓存**: 使用cached_network_image优化加载

### 👤 个人中心
- ✅ **用户信息**: 头像、用户名、邮箱展示
- ✅ **功能菜单**: 我的订单、收藏、购物车、地址、支付方式
- ✅ **设置选项**: 设置、帮助反馈、关于我们
- ✅ **退出登录**: 带确认对话框

### 🧭 底部导航
- ✅ **双Tab设计**: 首页 + 我的
- ✅ **状态保持**: 使用GetX状态管理切换
- ✅ **图标设计**: Material Design图标

### 🎨 UI/UX设计
- ✅ **现代化设计**: 卡片式布局，圆角阴影
- ✅ **响应式布局**: 适配不同屏幕尺寸
- ✅ **加载状态**: 图片加载占位符和错误处理
- ✅ **交互反馈**: 点击效果和消息提示

## 技术栈

### 核心框架
- **Flutter**: 跨平台UI框架
- **GetX**: 状态管理、路由管理、依赖注入

### 第三方插件
- **carousel_slider**: 轮播图实现
- **dots_indicator**: 轮播图指示器
- **cached_network_image**: 网络图片缓存
- **cupertino_icons**: iOS风格图标

## 运行项目

```bash
# 安装依赖
flutter pub get

# 运行项目（默认设备）
flutter run

# Windows端运行
flutter run -d windows

# Android端运行
flutter run -d android

# iOS端运行  
flutter run -d ios
```

## 开发指南

### 添加新页面
1. 在 `lib/pages/` 目录下创建新的页面文件
2. 在 `lib/routes/app_routes.dart` 中添加路由配置
3. 在对应的控制器中添加页面逻辑

### 添加新功能
1. 在 `lib/controllers/` 目录下创建或修改控制器
2. 在 `lib/models/` 目录下定义数据模型
3. 在页面中使用 `Get.find()` 获取控制器实例

### 数据管理
- 使用 `RxList` 和 `Rx` 变量实现响应式数据
- 使用 `Obx()` 包装需要响应更新的Widget
- 控制器继承 `GetxController` 并重写 `onInit()` 方法

## 项目截图

> 注：实际运行效果包含轮播图、商品网格、底部导航等完整购物应用界面

## 后续开发计划

- [ ] 商品详情页面
- [ ] 购物车功能
- [ ] 用户登录注册
- [ ] 订单管理
- [ ] 支付集成
- [ ] 搜索功能
- [ ] 分类页面
- [ ] 个人信息编辑

这种模块化的代码结构使项目更容易维护和扩展，符合Flutter开发最佳实践。
