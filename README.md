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

## 开发环境要求

### 必需软件

- **Flutter SDK**: >= 3.4.0
- **Dart**: >= 3.4.0
- **Java**: 21 LTS ⚠️ **重要**
- **Android SDK**: API 34+
- **iOS**: Xcode 15+ (仅 macOS)

### JDK 21 配置

本项目使用 Java 21 LTS，**必须**正确配置 `JAVA_HOME` 环境变量。

#### 快速设置 (macOS/Linux)

```bash
# 在项目根目录运行
source ./set_jdk21.sh
```

#### 手动设置

**macOS**:

```bash
# 临时设置
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
export PATH=$JAVA_HOME/bin:$PATH

# 永久设置（添加到 ~/.zshrc）
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 21)' >> ~/.zshrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```

**Windows**:

```cmd
# 设置环境变量（需要管理员权限）
setx JAVA_HOME "C:\Program Files\Java\jdk-21"
setx PATH "%JAVA_HOME%\bin;%PATH%"
```

**Linux**:

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=$JAVA_HOME/bin:$PATH
```

#### 验证配置

```bash
# 检查 JAVA_HOME
echo $JAVA_HOME  # macOS/Linux
echo %JAVA_HOME% # Windows

# 检查 Java 版本（应显示 21.x.x）
java -version
```

#### 详细说明

查看完整的 JDK 环境配置指南: [JDK_ENVIRONMENT_SETUP.md](./JDK_ENVIRONMENT_SETUP.md)

### Android 本地配置

首次运行需要创建 `android/local.properties` 文件：

```bash
cd android
cp local.properties.template local.properties
# 编辑 local.properties，填入你的本地路径
```

示例内容：

```properties
sdk.dir=/Users/your-username/Library/Android/sdk
flutter.sdk=/Users/your-username/flutter
```

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
