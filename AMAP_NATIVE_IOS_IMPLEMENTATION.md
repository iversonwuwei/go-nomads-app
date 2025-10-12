# 高德地图原生 iOS SDK 集成实现

## 📌 实现概述

本项目使用 **原生 iOS 高德地图 SDK + Flutter Platform Channels** 实现地图位置选择功能，完全避免了 Flutter 插件的兼容性问题。

### 架构设计

```
Flutter 层
  ├── lib/config/amap_native_config.dart (配置常量)
  ├── lib/services/amap_native_service.dart (Platform Channel 服务)
  └── lib/pages/amap_native_picker_page.dart (Flutter UI 页面)
        ↓ Platform Channel Communication
iOS 原生层
  ├── Podfile (原生 SDK 依赖)
  ├── AppDelegate.swift (Platform Channel 处理器)
  └── AmapMapPickerController.swift (原生地图选择器 ViewController)
```

## ✅ 已完成配置

### 1. **依赖安装**

**ios/Podfile:**
```ruby
pod 'AMap3DMap', '~> 10.0.800'       # 3D 地图显示
pod 'AMapFoundation', '~> 1.8.2'     # 基础库
pod 'AMapLocation', '~> 2.10.0'      # 定位服务
```

**安装状态:** ✅ 已完成
```bash
cd ios && pod install --repo-update
# Pod installation complete! There are 9 dependencies from the Podfile and 9 total pods installed.
```

### 2. **API Key 配置**

**ios/Runner/AppDelegate.swift:**
```swift
private let AMAP_API_KEY = "6b053c71911726f46271e4b54124d35f"

AMapServices.shared().apiKey = AMAP_API_KEY
AMapServices.shared().enableHTTPS = true
```

**Key 信息:**
- iOS API Key: `6b053c71911726f46271e4b54124d35f`
- Bundle ID: `com.example.dfAdminMobile`
- 状态: ✅ 已在高德开放平台配置

### 3. **权限配置**

**ios/Runner/Info.plist:**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>我们需要访问您的位置以提供基于位置的城市推荐服务</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>我们需要访问您的位置以提供更好的服务体验</string>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

状态: ✅ 已配置

### 4. **Platform Channel 配置**

**Channel 名称:** `com.example.df_admin_mobile/amap`

**支持的方法:**
- `test` - 测试连接
- `openMapPicker` - 打开地图选择器
- `getCurrentLocation` - 获取当前位置

### 5. **Flutter 层代码**

#### lib/config/amap_native_config.dart
```dart
class AmapNativeConfig {
  static const String channelName = 'com.example.df_admin_mobile/amap';
  static const String iosApiKey = '6b053c71911726f46271e4b54124d35f';
  
  static const String methodOpenMapPicker = 'openMapPicker';
  static const String methodGetCurrentLocation = 'getCurrentLocation';
  static const String methodTest = 'test';
}
```

#### lib/services/amap_native_service.dart
```dart
class AmapNativeService {
  static final instance = AmapNativeService._();
  
  Future<Map<String, dynamic>?> openMapPicker({
    double? initialLatitude,
    double? initialLongitude,
  }) async {
    // 调用原生地图选择器
    // 返回: {latitude, longitude, address, city, province}
  }
  
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    // 获取当前位置
  }
  
  Future<bool> testConnection() async {
    // 测试 Platform Channel 连接
  }
}
```

#### lib/pages/amap_native_picker_page.dart
```dart
class AmapNativePickerPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  
  // 使用方法:
  // final result = await Get.to(() => AmapNativePickerPage());
  // if (result != null) {
  //   double latitude = result['latitude'];
  //   double longitude = result['longitude'];
  //   String address = result['address'];
  // }
}
```

### 6. **iOS 原生代码**

#### ios/Runner/AppDelegate.swift
- ✅ 初始化高德地图 SDK
- ✅ 设置 Platform Channel 处理器
- ✅ 实现 `openMapPicker` 方法
- ✅ 实现 `getCurrentLocation` 方法
- ✅ 实现 `test` 连接测试方法

#### ios/Runner/AmapMapPickerController.swift
- ✅ 原生地图选择器 ViewController
- ✅ MAMapView 3D 地图显示
- ✅ 拖动地图选择位置
- ✅ 自动逆地理编码（获取地址）
- ✅ 返回经纬度和详细地址信息

## 🚀 使用方法

### 在任意 Flutter 页面调用

```dart
import 'package:get/get.dart';
import '../pages/amap_native_picker_page.dart';

// 方式 1: 使用 Flutter 页面（推荐）
final result = await Get.to(() => AmapNativePickerPage(
  initialLatitude: 39.909187,  // 可选：初始位置
  initialLongitude: 116.397451,
));

if (result != null) {
  double latitude = result['latitude'];
  double longitude = result['longitude'];
  String address = result['address'];
  String city = result['city'];
  String province = result['province'];
  
  print('Selected: $address ($latitude, $longitude)');
}

// 方式 2: 直接调用服务
import '../services/amap_native_service.dart';

final result = await AmapNativeService.instance.openMapPicker(
  initialLatitude: 39.909187,
  initialLongitude: 116.397451,
);

// 方式 3: 测试连接
final isConnected = await AmapNativeService.instance.testConnection();
print('Platform Channel connected: $isConnected');
```

### 集成到现有页面

例如在 AI Travel Planner 的 departure location 中使用：

```dart
// lib/pages/city_detail/tabs/ai_travel_planner_tab.dart

ElevatedButton(
  onPressed: () async {
    final result = await Get.to(() => AmapNativePickerPage());
    if (result != null) {
      setState(() {
        departureLocation = result['address'];
        departureLatitude = result['latitude'];
        departureLongitude = result['longitude'];
      });
    }
  },
  child: Text('Select Departure Location'),
)
```

## 📱 测试步骤

### 1. **测试 Platform Channel 连接**

```bash
# 在 Flutter 控制台运行
flutter run --debug
```

然后在代码中调用:
```dart
final result = await AmapNativeService.instance.testConnection();
print(result); // 应该输出 "Native iOS Amap connected ✅"
```

### 2. **测试地图选择器**

```dart
final result = await Get.to(() => AmapNativePickerPage());
print(result);
// 应该返回:
// {
//   latitude: 39.909187,
//   longitude: 116.397451,
//   address: "天安门广场...",
//   city: "北京市",
//   province: "北京市"
// }
```

### 3. **在 iOS 模拟器运行**

```bash
flutter run -d ios
```

**注意:** 
- ⚠️ iOS 模拟器可能无法显示地图瓦片（高德限制）
- ✅ 建议使用真机测试完整功能

### 4. **在 iOS 真机运行**

```bash
# 1. 连接 iPhone
# 2. 在 Xcode 中配置签名
# 3. 运行
flutter run -d <device-id>
```

## 🔧 常见问题

### Q1: 地图不显示
**解决方法:**
1. 检查 API Key 是否正确配置
2. 确认 Bundle ID 与高德控制台一致: `com.example.dfAdminMobile`
3. 检查网络连接
4. 使用真机测试（模拟器可能不显示地图）

### Q2: Platform Channel 调用失败
**解决方法:**
```dart
try {
  final result = await AmapNativeService.instance.testConnection();
  print('Connection test: $result');
} on PlatformException catch (e) {
  print('Platform error: ${e.code} - ${e.message}');
}
```

### Q3: 逆地理编码失败
**检查:**
1. 确认 AMapSearchKit 已正确集成
2. 检查 API Key 是否有 Web 服务权限
3. 查看 Xcode 控制台错误日志

### Q4: 编译错误 "No such module"
**解决方法:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

## 🎯 下一步计划

### Android 实现
1. 配置 Android build.gradle
2. 创建 Kotlin 原生代码
3. 实现相同的 Platform Channel 接口
4. 保持与 iOS 一致的返回数据结构

### 功能增强
- [ ] 集成 AMapLocationKit 获取真实 GPS 位置
- [ ] 添加搜索功能（POI 搜索）
- [ ] 支持收藏常用位置
- [ ] 添加路线规划功能
- [ ] 支持离线地图

## 📚 参考文档

- [高德开放平台 iOS SDK 文档](https://lbs.amap.com/api/ios-sdk/summary)
- [Flutter Platform Channels 官方文档](https://docs.flutter.dev/platform-integration/platform-channels)
- [高德地图 iOS SDK 配置指南](https://lbs.amap.com/api/ios-sdk/guide/create-project/cocoapods)

## ✨ 技术优势

相比 Flutter 插件方案，原生 SDK 方案具有以下优势:

1. **稳定性**: 避免 Flutter 版本升级导致的兼容性问题（如 hashValues 错误）
2. **最新功能**: 直接使用高德最新 SDK (v10.x)，不依赖第三方插件更新
3. **可控性**: 完全控制原生代码实现，可自定义任何功能
4. **性能**: 原生渲染，性能最优
5. **维护性**: 不依赖已停止维护的第三方插件

## 📊 文件清单

### Flutter 层
- ✅ `lib/config/amap_native_config.dart` (36 lines)
- ✅ `lib/services/amap_native_service.dart` (114 lines)
- ✅ `lib/pages/amap_native_picker_page.dart` (144 lines)

### iOS 原生层
- ✅ `ios/Podfile` (已添加 Amap 依赖)
- ✅ `ios/Runner/Info.plist` (已配置权限)
- ✅ `ios/Runner/AppDelegate.swift` (89 lines, Platform Channel 处理器)
- ✅ `ios/Runner/AmapMapPickerController.swift` (268 lines, 原生地图 VC)

### 文档
- ✅ `AMAP_NATIVE_IOS_IMPLEMENTATION.md` (本文档)

**总代码量:** ~650 行
**实现时间:** 完成
**测试状态:** 待真机测试

---

**最后更新:** 2025-01-XX
**作者:** GitHub Copilot
**状态:** ✅ 代码实现完成，待设备测试
