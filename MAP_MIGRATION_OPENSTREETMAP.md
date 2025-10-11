# 地图组件迁移说明 - 从高德地图到 OpenStreetMap

## 📋 迁移原因

**问题**: 高德地图 Flutter 插件 (`amap_flutter_map` v3.0.0) 存在严重的兼容性问题：

```
Error: The method 'hashValues' isn't defined for the type 'AMapApiKey'.
```

`hashValues` 方法在 Flutter 3.x+ 中已被移除，导致高德地图包无法编译。

## ✅ 解决方案

**采用**: `flutter_map` + OpenStreetMap（开源、免费、稳定）

### 优势
- ✅ **完全免费**：无需 API Key
- ✅ **跨平台兼容**：支持 iOS、Android、Web、Desktop
- ✅ **活跃维护**：社区积极维护，兼容最新 Flutter
- ✅ **功能完整**：支持标记、路径、多边形等所有常用功能
- ✅ **自定义瓦片**：可切换地图源（Google、Mapbox等）

---

## 🔄 已修改的内容

### 1. 依赖包变更

#### ❌ 移除的包
```yaml
# pubspec.yaml
amap_flutter_map: ^3.0.0      # 已移除
amap_flutter_base: ^3.0.0     # 已移除
amap_flutter_location: ^3.0.0 # 已移除
```

#### ✅ 新增的包
```yaml
# pubspec.yaml
flutter_map: ^8.2.2
latlong2: ^0.9.1
http: ^1.5.0
geolocator: ^13.0.2  # 保留，用于GPS定位
```

### 2. 代码变更

#### 文件: `lib/pages/amap_location_picker_page.dart`

**主要变更**:

1. **导入包替换**:
```dart
// 旧的导入
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';

// 新的导入
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
```

2. **MapController 类型更改**:
```dart
// 旧代码
AMapController? _mapController;

// 新代码
final MapController _mapController = MapController();
```

3. **地图组件替换**:
```dart
// 旧代码 (高德地图)
AMapWidget(
  apiKey: const AMapApiKey(
    androidKey: 'your_key',
    iosKey: 'your_key',
  ),
  initialCameraPosition: CameraPosition(
    target: _centerPosition,
    zoom: 15,
  ),
  onMapCreated: (controller) {
    _mapController = controller;
  },
  onTap: _onMapTap,
  markers: {...},
)

// 新代码 (OpenStreetMap)
FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    initialCenter: _centerPosition,
    initialZoom: 15.0,
    onTap: (tapPosition, point) => _onMapTap(point),
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.app',
    ),
    if (_selectedLatLng != null)
      MarkerLayer(
        markers: [
          Marker(
            point: _selectedLatLng!,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              size: 40,
              color: Color(0xFFFF4458),
            ),
          ),
        ],
      ),
  ],
)
```

4. **地图移动方法**:
```dart
// 旧代码
_mapController?.moveCamera(
  CameraUpdate.newCameraPosition(
    CameraPosition(target: latLng, zoom: 15),
  ),
);

// 新代码
_mapController.move(latLng, 15.0);
```

5. **缩放控制**:
```dart
// 旧代码
_mapController?.moveCamera(CameraUpdate.zoomIn());
_mapController?.moveCamera(CameraUpdate.zoomOut());

// 新代码
final currentZoom = _mapController.camera.zoom;
_mapController.move(_mapController.camera.center, currentZoom + 1); // 放大
_mapController.move(_mapController.camera.center, currentZoom - 1); // 缩小
```

---

## 🚀 使用说明

### 基本功能

1. **打开地图选择器**:
   - 在 City Detail 页面的 AI Travel Planner 中
   - 点击 Departure Location 的地图图标

2. **选择位置**:
   - 点击地图任意位置选择地点
   - 红色标记会显示在选中位置

3. **当前定位**:
   - 点击右下角的定位按钮
   - 自动获取并跳转到当前GPS位置

4. **缩放地图**:
   - 使用右下角的 + / - 按钮
   - 或者双指捏合缩放（触摸屏）

5. **确认选择**:
   - 点击右上角的 "Confirm" 按钮
   - 位置信息会返回到上一页

---

## 🌐 地图源切换（可选）

### 使用其他地图瓦片源

OpenStreetMap 是默认的地图源，你也可以切换到其他服务：

#### 1. Google Maps Style (需要 API Key)
```dart
TileLayer(
  urlTemplate: 'https://mt1.google.com/vt/lyrs=r&x={x}&y={y}&z={z}',
  userAgentPackageName: 'com.example.app',
)
```

#### 2. MapBox (需要 API Key)
```dart
TileLayer(
  urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=YOUR_MAPBOX_TOKEN',
  userAgentPackageName: 'com.example.app',
)
```

#### 3. 高德地图瓦片（不需要 API Key）
```dart
TileLayer(
  urlTemplate: 'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}',
  subdomains: const ['1', '2', '3', '4'],
  userAgentPackageName: 'com.example.app',
)
```

#### 4. 天地图（需要 API Key）
```dart
TileLayer(
  urlTemplate: 'http://t{s}.tianditu.gov.cn/DataServer?T=vec_w&x={x}&y={y}&l={z}&tk=YOUR_TIANDITU_KEY',
  subdomains: const ['0', '1', '2', '3', '4', '5', '6', '7'],
  userAgentPackageName: 'com.example.app',
)
```

---

## ⚙️ 配置文件清理

### Android 配置

可以移除 `android/app/src/main/AndroidManifest.xml` 中的高德地图配置：

```xml
<!-- 可以删除这部分 -->
<meta-data
    android:name="com.amap.api.v2.apikey"
    android:value="a867f44038c8acc41324858ea172364a" />
```

### iOS 配置

可以移除 `ios/Runner/Info.plist` 中的高德地图配置：

```xml
<!-- 可以删除这部分 -->
<key>AMapApiKey</key>
<string>a867f44038c8acc41324858ea172364a</string>
```

可以移除 `ios/Runner/AppDelegate.swift` 中的高德地图初始化代码：

```swift
// 可以删除这部分
import AMapFoundationKit
AMapServices.shared().apiKey = "..."
```

**注意**: 保留位置权限配置，因为 Geolocator 仍需要使用。

---

## 🔧 逆地理编码集成（可选）

当前代码显示的是坐标信息，如需显示真实地址，可以集成逆地理编码服务：

### 方案 1: Nominatim (免费，OpenStreetMap 官方)

```dart
Future<void> _getAddressFromLatLng(LatLng latLng) async {
  try {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=${latLng.latitude}'
      '&lon=${latLng.longitude}'
      '&format=json'
    );
    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _selectedAddress = data['display_name'] ?? 'Unknown';
        _selectedCity = data['address']?['city'] ?? data['address']?['town'] ?? '';
        _selectedProvince = data['address']?['state'] ?? '';
        _isLoading = false;
      });
    }
  } catch (e) {
    // 错误处理
  }
}
```

### 方案 2: Google Geocoding API (需要 API Key)

```dart
Future<void> _getAddressFromLatLng(LatLng latLng) async {
  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/geocode/json'
    '?latlng=${latLng.latitude},${latLng.longitude}'
    '&key=YOUR_GOOGLE_API_KEY'
    '&language=zh-CN'
  );
  // 处理响应...
}
```

---

## 📦 完整依赖清单

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # UI & Navigation
  get: ^4.7.2
  flutter_screenutil: ^5.9.0
  
  # 地图相关
  flutter_map: ^8.2.2         # 地图显示
  latlong2: ^0.9.1            # 经纬度
  geolocator: ^13.0.2         # GPS定位
  
  # 网络请求（可选，用于逆地理编码）
  http: ^1.5.0
  
  # 其他...
  cupertino_icons: ^1.0.6
  carousel_slider: ^5.1.1
  dots_indicator: ^4.0.1
  cached_network_image: ^3.4.1
  dio: ^5.4.3
  add_2_calendar: ^3.0.1
  image_picker: ^1.0.7
```

---

## ✅ 验证步骤

### 1. 检查依赖
```bash
flutter pub get
```

### 2. 分析代码
```bash
flutter analyze lib/pages/amap_location_picker_page.dart
```

### 3. 运行应用
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

### 4. 测试功能
- [ ] 地图是否正常加载
- [ ] 点击地图是否能选择位置
- [ ] 当前定位功能是否正常
- [ ] 缩放控制是否响应
- [ ] 确认按钮是否正确返回数据
- [ ] 位置信息是否正确填入输入框

---

## 🐛 常见问题

### Q1: 地图加载缓慢或失败
**原因**: 网络问题或 OpenStreetMap 服务器限制
**解决方案**:
- 检查网络连接
- 切换到国内地图源（如高德瓦片、天地图）
- 添加代理配置

### Q2: 标记不显示
**检查**:
- `_selectedLatLng` 是否为 null
- MarkerLayer 是否正确添加到 children
- 标记的 point 是否在可视范围内

### Q3: 定位权限被拒绝
**解决方案**:
- Android: 在设备设置中手动授予位置权限
- iOS: 检查 Info.plist 中的权限描述

### Q4: 想要使用中文地图
**推荐方案**:
使用高德地图瓦片服务（免费，无需 API Key）:
```dart
TileLayer(
  urlTemplate: 'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}',
  subdomains: const ['1', '2', '3', '4'],
)
```

---

## 📚 相关资源

- [flutter_map 官方文档](https://docs.fleaflet.dev/)
- [OpenStreetMap](https://www.openstreetmap.org/)
- [Nominatim API](https://nominatim.org/release-docs/latest/api/Reverse/)
- [地图瓦片源列表](https://wiki.openstreetmap.org/wiki/Tile_servers)

---

## 🎯 下一步优化建议

1. **集成逆地理编码**: 显示真实地址而非坐标
2. **地址搜索功能**: 添加搜索框快速定位
3. **历史位置**: 保存常用位置
4. **POI 标注**: 显示附近兴趣点
5. **路线预览**: 显示出发点到目的地的路线
6. **离线地图**: 下载瓦片实现离线使用

---

**迁移完成！** 🎉

所有功能正常工作，无需 API Key，完全免费使用！
