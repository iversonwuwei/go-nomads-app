# 高德地图显示问题调试

## 问题描述
在 City Detail 页面的走马灯中,第二页应该显示高德地图,但目前只显示白色或浅蓝色背景。

## 当前状态

### ✅ 已完成
1. **AmapCityViewFactory.kt** 创建完成
   - PlatformViewFactory 实现
   - MapView 初始化with `onCreate(null)` 和 `onResume()`
   - 18 个城市坐标配置
   - UI 控件禁用(放大/缩小按钮等)
   - 日志输出 (AmapCityView TAG)

2. **MainActivity.kt** 注册完成
   - 视图工厂已注册: `flutterEngine.platformViewsController.registry.registerViewFactory("amap_city_view", AmapCityViewFactory())`
   - 隐私合规设置: `MapsInitializer.updatePrivacyShow()` 和 `updatePrivacyAgree()`

3. **city_detail_page.dart** AndroidView 集成
   - `import 'package:flutter/services.dart'` 已添加
   - AndroidView with viewType 'amap_city_view'
   - creationParams 传递 cityName
   - StandardMessageCodec 使用正确
   - Container 背景色添加用于调试 (lightBlue[50])

### 📊 日志分析
从之前的运行日志可以看到:
```
I/PlatformViewsController(18058): Hosting view in a virtual display for platform view: 0
I/PlatformViewsController(18058): PlatformView is using SurfaceTexture backend
I/flutter (18058): 🗺️ Amap city view created with id: 0 for Bangkok
```

**重要发现:**
- ✅ PlatformView 成功创建 (id: 0, 1, 2)
- ✅ 使用 SurfaceTexture 后端渲染
- ✅ Flutter 层成功回调
- ⚠️ 高德SDK隐私合规警告: `org.json.JSONException: End of input`

## 可能的问题

### 1. 高德地图隐私合规问题 ⚠️
**症状:** JSON解析错误
```
W/System.err(18058): org.json.JSONException: End of input at character 0 of
W/System.err(18058): at com.amap.api.col.3l.fr.b(Privacy.java:1647)
```

**原因:** 高德SDK需要在 Application 类中初始化隐私合规

**解决方案:**
创建 Application 类并在其中初始化隐私合规设置

### 2. MapView 生命周期不完整
**当前状态:**
- ✅ onCreate(null) 已调用
- ✅ onResume() 已添加
- ✅ onPause() 在 dispose 中调用
- ✅ onDestroy() 在 dispose 中调用

### 3. 地图 API Key 配置
需要确认 AndroidManifest.xml 中的 Key 是否正确

### 4. MapView 尺寸问题
MapView 可能需要明确的 LayoutParams

## 下一步调试步骤

### Step 1: 创建 Application 类
```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // 高德地图隐私合规必须在初始化之前设置
        MapsInitializer.updatePrivacyShow(this, true, true)
        MapsInitializer.updatePrivacyAgree(this, true)
    }
}
```

### Step 2: 在 AndroidManifest.xml 中注册
```xml
<application
    android:name=".MyApplication"
    ...>
```

### Step 3: 添加详细日志
在 AmapCityView 中添加:
- ✅ 地图初始化状态
- ✅ 坐标设置情况
- ✅ 标记添加结果
- MapView 尺寸信息

### Step 4: 检查地图渲染
- 验证 MapView.map 是否为 null
- 检查地图类型设置
- 确认相机移动是否成功

## 技术细节

### AndroidView 集成方式
```dart
AndroidView(
  viewType: 'amap_city_view',
  creationParams: {'cityName': widget.cityName},
  creationParamsCodec: const StandardMessageCodec(),
  onPlatformViewCreated: (int id) {
    print('🗺️ Map created: $id');
  },
)
```

### PlatformView 生命周期
```kotlin
init {
  mapView.onCreate(null)
  mapView.onResume()
  aMap = mapView.map
  // 配置地图...
}

override fun dispose() {
  mapView.onPause()
  mapView.onDestroy()
}
```

### 城市坐标配置
- Bangkok: 13.7563, 100.5018
- Tokyo: 35.6762, 139.6503
- Seoul: 37.5665, 126.9780
- 等 18 个城市

## 预期结果
1. 打开城市详情页
2. 左滑走马灯到第二页
3. 看到高德地图显示城市位置
4. 地图上有标记显示城市名称
5. 缩放级别为 12

## 实际结果
- 显示白色/浅蓝色背景
- 没有看到地图瓦片
- 没有看到城市标记

## 最新更新
**时间:** 2025-10-13

**改进:**
1. ✅ 添加 Log.d() 详细日志
2. ✅ 添加 mapView.onResume() 调用
3. ✅ 使用 animateCamera 替代 moveCamera
4. ✅ 添加 Container 背景色用于调试
5. ✅ 默认城市设置为曼谷 (非零坐标)

**待测试:**
- 创建 Application 类解决隐私合规问题
- 查看新的日志输出
- 验证地图是否正确渲染
