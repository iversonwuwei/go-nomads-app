# 高德地图集成测试指南

## 🎯 测试目标

验证原生高德地图 Platform Channel 集成是否正常工作。

---

## 📱 测试环境

- **设备**: iPhone 16 Pro Simulator (或真实 iPhone)
- **Flutter**: 3.35.3 stable
- **Dart**: 3.9.2
- **iOS SDK**: AMap3DMap 10.0.1000

---

## ✅ 已修复的问题

### 问题 1: AMapSearchAPI 崩溃
- **错误**: `Fatal error at line 211: Unexpectedly found nil`
- **修复**: 将 `AMapSearchAPI!` 改为 `AMapSearchAPI?`
- **状态**: ✅ 已修复

### 问题 2: MAMapView 崩溃
- **错误**: `Fatal error at line 217: Unexpectedly found nil`
- **修复**: 将 `MAMapView!` 改为 `MAMapView?`，使用 guard 语句
- **状态**: ✅ 已修复

---

## 🧪 测试步骤

### 1. 启动应用

```bash
cd /Users/walden/Workspaces/WaldenProjects/open-platform-app
flutter run -d 781542BD-8FAE-4F3E-B528-ACDC7BD97951
```

**预期结果:**
```
Xcode build done. ~6-10s
flutter: ✅ 应用初始化
flutter: 📍 使用 Geolocator 进行定位服务
✅ 应用成功启动
```

### 2. 导航到城市详情页

**操作路径:**
1. 打开应用
2. 进入 Data Service 页面
3. 点击任意城市卡片
4. 进入城市详情页

**预期日志:**
```
[GETX] GOING TO ROUTE /data-service
[GETX] GOING TO ROUTE /CityDetailPage
[GETX] Instance "CityDetailController" has been created
```

### 3. 打开地图选择器

**操作:**
在城市详情页的 AI Travel Planner 中点击 "Departure Location"

**预期行为:**
- ✅ 弹出地图选择器对话框
- ✅ 不崩溃
- ❌ 地图可能不显示（模拟器限制）

**预期日志:**
```
[GETX] OPEN DIALOG xxxxx
[GETX] GOING TO ROUTE /AmapNativePickerPage
```

**⚠️ 注意**: 在模拟器上，地图可能显示为空白，这是正常的。需要真机测试才能看到实际地图。

### 4. 测试 Platform Channel 连接

**方法 1: 使用测试页面**

在 `lib/main.dart` 中添加测试路由（临时）:
```dart
import 'package:df_admin_mobile/pages/amap_native_test_page.dart';

// 在 routes 中添加
'/amap-test': (context) => AmapNativeTestPage(),
```

然后导航到 `/amap-test` 测试 Platform Channel。

**方法 2: 查看日志**

如果 Platform Channel 正常工作，应该看到：
```
✅ Platform Channel 连接成功
✅ AMapSearchAPI 初始化成功（或跳过初始化）
```

如果失败，可能看到：
```
⚠️ Platform Channel 测试失败: [错误信息]
⚠️ MAMapView 初始化失败
⚠️ AMapSearchAPI 初始化失败
```

---

## 🔍 调试检查清单

### iOS 配置检查

#### 1. Podfile 依赖
```bash
cd ios && cat Podfile | grep -A 5 "AMap"
```

**应该看到:**
```ruby
pod 'AMap3DMap', '~> 10.0.0'
pod 'AMapFoundation', '~> 1.8.0'
pod 'AMapLocation', '~> 2.10.0'
pod 'AMapSearch', '~> 9.7.0'
```

#### 2. Info.plist 配置
```bash
cat ios/Runner/Info.plist | grep -A 3 "AMapApiKey"
```

**应该看到:**
```xml
<key>AMapApiKey</key>
<string>6b053c71911726f46271e4b54124d35f</string>
```

#### 3. AppDelegate 注册
```bash
grep "AMapServices" ios/Runner/AppDelegate.swift
```

**应该看到:**
```swift
AMapServices.shared().apiKey = "6b053c71911726f46271e4b54124d35f"
```

### Flutter 配置检查

#### 1. Platform Channel 配置
```bash
cat lib/config/amap_native_config.dart
```

**应该看到:**
```dart
static const String channelName = 'com.example.df_admin_mobile/amap';
static const String apiKey = '6b053c71911726f46271e4b54124d35f';
```

#### 2. Service 实现
```bash
cat lib/services/amap_native_service.dart | grep "openMapPicker"
```

**应该看到方法定义。**

---

## 📊 测试矩阵

| 测试项 | 模拟器 | 真机 | 状态 |
|--------|--------|------|------|
| 应用启动 | ✅ | ✅ | 通过 |
| 编译无错误 | ✅ | ✅ | 通过 |
| Platform Channel 连接 | ✅ | ✅ | 待测试 |
| 打开地图选择器 | ✅ | ✅ | 待测试 |
| 地图显示 | ❌ | ✅ | 待测试 |
| 位置选择 | ❌ | ✅ | 待测试 |
| 逆地理编码 | ❌ | ✅ | 待测试 |
| 返回位置信息 | ✅ | ✅ | 待测试 |

**图例:**
- ✅ 支持/通过
- ❌ 不支持（模拟器限制）
- 待测试: 需要真机测试

---

## 🚨 常见问题

### Q1: 应用启动后立即崩溃
**可能原因:**
- AppDelegate.swift 中的可选类型强制解包失败

**解决方案:**
检查以下类型声明都使用了 `?` 而不是 `!`:
```swift
private var mapView: MAMapView?        // ✅
private var search: AMapSearchAPI?     // ✅
```

### Q2: 地图不显示（白屏）
**可能原因:**
1. 模拟器不支持地图渲染（正常现象）
2. API Key 配置错误
3. 高德 SDK 初始化失败

**解决方案:**
1. 在真机上测试
2. 检查 Info.plist 和 AppDelegate 中的 API Key
3. 查看 Xcode 控制台的初始化日志

### Q3: Platform Channel 调用失败
**可能原因:**
- Channel 名称不匹配
- 方法名不匹配
- 参数格式错误

**解决方案:**
检查 Flutter 和 iOS 两侧的 Channel 配置:
```dart
// Flutter 端
static const String channelName = 'com.example.df_admin_mobile/amap';
```

```swift
// iOS 端
let amapChannel = FlutterMethodChannel(name: "com.example.df_admin_mobile/amap", ...)
```

### Q4: 逆地理编码不返回结果
**可能原因:**
- 模拟器网络限制
- AMapSearchAPI 未正确初始化
- API Key 权限不足

**解决方案:**
1. 在真机上测试
2. 检查 `setupSearch()` 方法的初始化日志
3. 登录高德开放平台检查 API Key 权限

---

## 📝 测试报告模板

```markdown
### 测试日期: [YYYY-MM-DD]
### 测试设备: [iPhone 型号 / 模拟器]
### 测试人员: [姓名]

#### 测试结果
- [ ] 应用启动成功
- [ ] 无崩溃
- [ ] 地图选择器打开
- [ ] 地图正常显示
- [ ] 可以选择位置
- [ ] 逆地理编码工作
- [ ] 位置信息正确返回 Flutter

#### 发现的问题
1. [问题描述]
2. [问题描述]

#### 备注
[其他说明]
```

---

## 🎯 下一步

### 短期（本周）
- [ ] 在真实 iPhone 设备上测试
- [ ] 验证地图显示正常
- [ ] 测试位置选择功能
- [ ] 验证逆地理编码返回的地址格式

### 中期（本月）
- [ ] 优化 UI 设计（按钮样式、颜色等）
- [ ] 添加定位到当前位置功能
- [ ] 添加搜索地点功能
- [ ] 完善错误处理和用户提示

### 长期（未来）
- [ ] 实现 Android 原生地图（使用相同 Platform Channel 接口）
- [ ] 添加地图缓存优化
- [ ] 添加路径规划功能
- [ ] 添加周边搜索功能

---

**测试指南版本**: 1.0  
**创建日期**: 2025-01-12  
**最后更新**: 2025-01-12
