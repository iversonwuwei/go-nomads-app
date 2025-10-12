# 🔄 切换到高德官方 Flutter 插件方案

**日期**: 2025年10月12日  
**状态**: ⚠️ 需要注意兼容性问题

---

## 📋 插件对比

### 当前使用: amap_map_fluttify
```yaml
dependencies:
  amap_map_fluttify: ^2.0.2
```

**优点**:
- ✅ 兼容 Flutter 3.x
- ✅ 已完成配置和代码实现
- ✅ 无编译错误

**缺点**:
- ⚠️ 非官方维护
- ⚠️ iOS 模拟器支持差

### 建议切换到: amap_flutter (官方)
```yaml
dependencies:
  amap_flutter_map: ^3.0.0
  amap_flutter_location: ^3.0.0
  amap_flutter_base: ^3.0.0
```

**优点**:
- ✅ 高德官方维护
- ✅ 功能更完整
- ✅ 文档更详细

**缺点**:
- ❌ **之前遇到 hashValues 兼容性问题**
- ⚠️ 可能需要修复源码
- ⚠️ API 完全不同，需要重写代码

---

## ⚠️ 已知问题

### hashValues 错误（之前遇到的）

**错误信息**:
```
Error: The getter 'hashValues' isn't defined for the class 'Object'.
```

**原因**:
- `amap_flutter_map v3.0.0` 使用了已废弃的 `hashValues`
- Flutter 3.x 移除了 `hashValues`

**可能的解决方案**:
1. 等待官方更新到兼容版本
2. Fork 仓库并修复 hashValues 问题
3. 使用 dependency_overrides 覆盖依赖

---

## 🔄 迁移步骤（如果坚持切换）

### Step 1: 移除当前插件

```bash
flutter pub remove amap_map_fluttify
```

这会自动移除：
- amap_map_fluttify
- amap_core_fluttify
- amap_location_fluttify
- amap_search_fluttify
- foundation_fluttify

### Step 2: 添加官方插件

```bash
flutter pub add amap_flutter_map amap_flutter_location amap_flutter_base
```

### Step 3: 检查是否有错误

```bash
flutter pub get
flutter analyze
```

**预期**: 可能会遇到 hashValues 错误

### Step 4: 修复 hashValues 问题（如果出现）

**方案 A: 使用 dependency_overrides**
```yaml
dependency_overrides:
  amap_flutter_base:
    git:
      url: https://github.com/你的fork/amap_flutter_base.git
      ref: fix-hashvalues
```

**方案 B: 等待官方修复**

**方案 C: 继续使用 amap_map_fluttify**（推荐）

### Step 5: 重写地图页面代码

官方插件的 API 完全不同：

**当前代码** (amap_map_fluttify):
```dart
AmapView(
  onMapCreated: (controller) async {
    _mapController = controller;
    await controller.setCenterCoordinate(latLng, animated: true);
  },
  markers: [MarkerOption(coordinate: latLng)],
)
```

**需要改为** (amap_flutter_map):
```dart
AMapWidget(
  apiKey: AMapApiKey(iosKey: 'xxx', androidKey: 'xxx'),
  onMapCreated: (controller) {
    _mapController = controller;
    controller.moveCamera(CameraUpdate.newLatLng(latLng));
  },
  markers: Set<Marker>.of([
    Marker(markerId: MarkerId('1'), position: latLng)
  ]),
)
```

### Step 6: 更新初始化代码

**当前** (main.dart):
```dart
await AmapCore.init(AmapKeys.platformKey);
```

**需要改为**:
```dart
// 官方插件在 Widget 中配置，不需要 main.dart 初始化
AMapWidget(
  apiKey: AMapApiKey(
    iosKey: AmapKeys.iosKey,
    androidKey: AmapKeys.androidKey,
  ),
  // ...
)
```

---

## 🎯 推荐方案

### 选项 A: 保持当前方案 ✅ **（强烈推荐）**

**理由**:
- ✅ 已经可以正常工作
- ✅ 无兼容性问题
- ✅ 代码已完成
- ✅ 只需配置 Android Key

**下一步**:
1. 配置 Android Key
2. 在真机上测试
3. 完成功能验证

### 选项 B: 切换到官方插件 ⚠️ **（有风险）**

**理由**:
- ✅ 官方支持
- ❌ 需要解决 hashValues 问题
- ❌ 需要重写所有代码
- ❌ 耗时 2-3 小时

**下一步**:
1. 尝试添加官方插件
2. 如果遇到错误，Fork 修复
3. 完全重写地图页面
4. 重新测试所有功能

---

## 🤔 我的建议

**在做决定之前，请回答**:

1. **当前方案有什么具体问题吗**？
   - 地图不显示？（iOS 模拟器是正常现象）
   - 功能缺失？
   - 性能问题？

2. **为什么想切换到官方插件**？
   - 特定功能需求？
   - 官方支持更好？
   - 其他原因？

3. **有时间预算吗**？
   - 切换需要 2-3 小时重写代码
   - 可能需要调试和修复

---

## ⏸️ 暂停切换，先解决 Android 构建问题

当前 Android 构建失败的原因：
```
Error resolving plugin [id: 'dev.flutter.flutter-plugin-loader', version: '1.0.0']
```

这与地图插件无关，切换插件不会解决这个问题。

**建议**:
1. 先修复 Android 构建配置
2. 然后再决定是否切换插件

需要我先帮你修复 Android 构建问题吗？
