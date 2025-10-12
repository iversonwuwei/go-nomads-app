# 🚀 高德地图官方插件快速参考

## ✅ 迁移状态

### 已完成
- [x] pubspec.yaml 更新到官方插件 v3.0.0
- [x] flutter pub get 成功 (无 hashValues 错误!)
- [x] lib/config/amap_keys.dart 重写
- [x] lib/main.dart 初始化更新
- [x] lib/pages/amap_location_picker_page.dart 完全重写 (343 行)
- [x] 编译通过 (仅警告/提示，无错误)

### 待处理
- [ ] 修复 Android Gradle 构建 (与插件无关)
- [ ] 添加 amap_flutter_search (逆地理编码)
- [ ] iOS 真机测试
- [ ] Android 真机测试

---

## 📦 依赖版本

```yaml
amap_flutter_map: ^3.0.0
amap_flutter_location: ^3.0.0
amap_flutter_base: ^3.0.0
geolocator: ^13.0.2
```

---

## 🔑 API Keys

| 平台 | Key | Package ID |
|------|-----|-----------|
| iOS | `6b053c71911726f46271e4b54124d35f` | `com.example.dfAdminMobile` |
| Android | `1b1caa568d9884680086a15613448b40` | `com.example.df_admin_mobile` |

Android SHA1: `80:14:37:54:EC:ED:51:EB:AF:41:7C:92:AF:71:A1:E8:4A:7D:80:6B`

---

## 🔧 核心代码

### 初始化 (main.dart)
```dart
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'config/amap_keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 高德地图初始化
  AMapFlutterLocation.setApiKey(
    AmapKeys.iosKey,
    AmapKeys.androidKey,
  );
  AMapFlutterLocation.updatePrivacyShow(true, true);
  AMapFlutterLocation.updatePrivacyAgree(true);
  
  runApp(const MyApp());
}
```

### 配置 (amap_keys.dart)
```dart
import 'package:amap_flutter_base/amap_flutter_base.dart';

class AmapKeys {
  static const String iosKey = '6b053c71911726f46271e4b54124d35f';
  static const String androidKey = '1b1caa568d9884680086a15613448b40';
  
  static AMapApiKey get apiKey => AMapApiKey(
    iosKey: iosKey,
    androidKey: androidKey,
  );
  
  static AMapPrivacyStatement get privacyStatement => AMapPrivacyStatement(
    hasContains: true,
    hasShow: true,
    hasAgree: true,
  );
}
```

### 地图组件
```dart
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

AMapWidget(
  apiKey: AmapKeys.apiKey,
  privacyStatement: AmapKeys.privacyStatement,
  initialCameraPosition: CameraPosition(
    target: LatLng(39.909187, 116.397451),
    zoom: 15,
  ),
  onMapCreated: (controller) {
    _mapController = controller;
  },
  onTap: (latLng) {
    // 处理地图点击
  },
  markers: _markers, // Set<Marker>
)
```

### 标记管理
```dart
final Set<Marker> _markers = {};

void addMarker(LatLng position) {
  final marker = Marker(
    position: position,
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueRed,
    ),
  );
  
  setState(() {
    _markers.add(marker);
  });
}
```

### 地图控制
```dart
// 移动到位置
_mapController?.moveCamera(
  CameraUpdate.newLatLng(LatLng(lat, lng)),
  animated: true,
);

// 缩放
_mapController?.moveCamera(CameraUpdate.zoomIn(), animated: true);
_mapController?.moveCamera(CameraUpdate.zoomOut(), animated: true);
```

---

## 🆚 API 对比

| 功能 | 旧 (fluttify) | 新 (官方) |
|------|--------------|----------|
| **初始化** | `AmapCore.init(key)` | `AMapFlutterLocation.setApiKey()` + 隐私声明 |
| **组件** | `AmapView` | `AMapWidget` |
| **控制器** | `AmapController` | `AMapController` |
| **地图点击** | `setMapClickedListener` | `onTap` 回调 |
| **标记** | `MarkerOption` | `Marker` |
| **移动** | `setCenterCoordinate` | `moveCamera(CameraUpdate.newLatLng())` |
| **缩放** | `setZoomLevel(zoom)` | `moveCamera(zoomIn/Out())` |

---

## ⚠️ 已知问题

### 1. Android 构建失败
**错误**: `flutter-plugin-loader` 解析失败  
**状态**: 与高德插件无关，Flutter Gradle 配置问题  
**临时方案**: 使用 iOS 进行测试

### 2. iOS 模拟器不显示地图
**原因**: 高德官方限制  
**解决**: 使用真机测试

---

## 🎯 下一步

1. **Android 构建**: 排查 Gradle 配置
2. **逆地理编码**: 集成 `amap_flutter_search`
3. **真机测试**: iOS/Android 实机验证
4. **代码优化**: 移除 unused imports, 替换 deprecated APIs

---

## 📝 备份

旧实现已备份至:
```
lib/pages/amap_location_picker_page.dart.backup (413 行)
```

---

**更新**: 2025-01-XX  
**状态**: ✅ 编译成功，功能可用  
**测试**: ⏳ 等待真机测试
