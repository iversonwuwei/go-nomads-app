# 地图功能快速参考

## 🗺️ 当前地图方案

**OpenStreetMap** (通过 flutter_map)

- ✅ 完全免费
- ✅ 无需 API Key
- ✅ 跨平台支持
- ✅ 稳定可靠

---

## 🎯 使用方法

### 在代码中调用

```dart
// 从 city_detail_page.dart
final result = await Get.to(() => const AmapLocationPickerPage());

if (result != null) {
  setState(() {
    departureLocation = result['address'] as String;
    // 可选：获取经纬度
    double latitude = result['latitude'];
    double longitude = result['longitude'];
  });
}
```

### 返回的数据格式

```dart
{
  'address': '位置描述字符串',
  'latitude': 39.909187,
  'longitude': 116.397451,
  'city': '城市名称',
  'province': '省份名称',
}
```

---

## 🌏 切换地图源（可选）

### 当前：OpenStreetMap（国际，免费）

```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.example.app',
)
```

### 高德地图瓦片（中国，免费，无需 Key）

```dart
TileLayer(
  urlTemplate: 'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}',
  subdomains: const ['1', '2', '3', '4'],
  userAgentPackageName: 'com.example.app',
)
```

### 天地图（中国，需要 Key）

```dart
TileLayer(
  urlTemplate: 'http://t{s}.tianditu.gov.cn/DataServer?T=vec_w&x={x}&y={y}&l={z}&tk=YOUR_KEY',
  subdomains: const ['0', '1', '2', '3', '4', '5', '6', '7'],
  userAgentPackageName: 'com.example.app',
)
```

**修改位置**：`lib/pages/amap_location_picker_page.dart` 第 213 行左右

---

## 🔧 常见问题解决

### Q: 地图加载慢？
**A**: 切换到国内地图源（高德瓦片）

### Q: 想显示真实地址而非坐标？
**A**: 参考 `MAP_MIGRATION_OPENSTREETMAP.md` 中的逆地理编码部分

### Q: 定位不准确？
**A**: 检查设备定位权限是否开启

---

## 📦 依赖包

```yaml
flutter_map: ^8.2.2      # 地图显示
latlong2: ^0.9.1         # 经纬度
geolocator: ^13.0.2      # GPS定位
```

---

## 📄 相关文档

- **详细迁移文档**: `MAP_MIGRATION_OPENSTREETMAP.md`
- **API Key 配置**: `AMAP_API_KEY_CONFIG.md` (已过时，已移除高德地图)
- **功能文档**: `AMAP_LOCATION_PICKER_FEATURE.md`

---

## ✨ 功能特性

- ✅ 点击地图选择位置
- ✅ GPS 当前定位
- ✅ 地图缩放控制
- ✅ 位置标记显示
- ✅ 位置信息返回
- ⏳ 逆地理编码（待集成）
- ⏳ 地址搜索（待开发）

---

**最后更新**: 2025年10月11日
