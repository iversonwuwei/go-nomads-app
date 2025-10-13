# 高德地图显示问题 - 最终解决方案

## 问题现状

**截图显示:** 地图页面显示灰色网格占位符,而非真实高德地图

**错误日志:**
```
E/EGL_emulation: tid 18469: eglSurfaceAttrib(1493): error 0x3009 (EGL_BAD_MATCH)
W/OpenGLRenderer: Failed to set EGL_SWAP_BEHAVIOR on surface 0x76386e029000, error=EGL_BAD_MATCH
W/System.err: org.json.JSONException: End of input at character 0 of
```

**关键发现:**
- ✅ AmapCityView 创建成功
- ✅ 地图配置完成 ("Map configured successfully")
- ✅ 标记添加成功 ("Marker added for Bangkok")
- ❌ 隐私合规错误持续出现 (JSONException)
- ❌ EGL渲染错误 (EGL_BAD_MATCH)

## 根本原因分析

### 原因1: 隐私合规未提前设置
高德地图 SDK 要求在 **MapView 初始化之前** 设置隐私合规,否则会报 JSONException 错误,导致地图瓦片无法加载。

### 原因2: 时机问题
虽然我们创建了 MyApplication 类,但其 onCreate 可能执行时机不对,或者没有被正确调用。

## 解决方案进化

### 方案1: MyApplication 类 (未生效)
```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        MapsInitializer.updatePrivacyShow(this, true, true)
        MapsInitializer.updatePrivacyAgree(this, true)
    }
}
```
**问题:** 日志中看不到 MyApplication 的输出,说明可能未被加载

### 方案2: MainActivity onCreate (尝试中)
```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    MapsInitializer.updatePrivacyShow(applicationContext, true, true)
    MapsInitializer.updatePrivacyAgree(applicationContext, true)
}
```
**问题:** 日志中也看不到 MainActivity 的 onCreate 输出

### 方案3: AmapCityViewFactory 静态初始化 (当前方案)
```kotlin
companion object {
    private var privacyInitialized = false
    
    @Synchronized
    fun ensurePrivacyCompliance(context: Context) {
        if (!privacyInitialized) {
            MapsInitializer.updatePrivacyShow(context, true, true)
            MapsInitializer.updatePrivacyAgree(context, true)
            privacyInitialized = true
        }
    }
}

override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    ensurePrivacyCompliance(context) // 在创建视图前调用
    return AmapCityView(context, viewId, params)
}
```

**优点:**
- 保证在 MapView 创建前执行
- 使用 @Synchronized 确保线程安全
- 使用 flag 避免重复初始化
- 有详细日志输出

## 测试步骤

1. 打开应用
2. 点击 Bangkok 城市
3. 进入城市详情页
4. 向左滑动到地图页面
5. 查看日志输出

## 预期日志

应该看到:
```
D/AmapCityViewFactory: 🔧 Initializing Amap privacy compliance...
D/AmapCityViewFactory: ✅ Amap privacy compliance configured
D/AmapCityView: Creating view with params: {cityName=Bangkok}
D/AmapCityView: Initializing map view #0
D/AmapCityView: AMap instance: true
D/AmapCityView: Configuring map...
D/AmapCityView: Map configured successfully
```

**不应该再看到:**
```
W/System.err: org.json.JSONException: End of input
```

## 如果仍然显示占位符

### 备选方案 A: 使用 Hybrid Composition
修改 Flutter 端的 AndroidView:
```dart
AndroidView(
  viewType: 'amap_city_view',
  creationParams: {'cityName': widget.cityName},
  creationParamsCodec: const StandardMessageCodec(),
  // 强制使用 Hybrid Composition
  hybrid Composition: true, 
)
```

### 备选方案 B: 给 MapView 设置 LayoutParams
在 AmapCityView init 中添加:
```kotlin
import android.widget.FrameLayout

mapView.layoutParams = FrameLayout.LayoutParams(
    FrameLayout.LayoutParams.MATCH_PARENT,
    FrameLayout.LayoutParams.MATCH_PARENT
)
```

### 备选方案 C: 检查 API Key
确认 AndroidManifest.xml 中的高德地图 Key 是否正确:
```xml
<meta-data
    android:name="com.amap.api.v2.apikey"
    android:value="YOUR_AMAP_KEY_HERE" />
```

## EGL_BAD_MATCH 错误

这个警告通常不是致命错误,是模拟器的渲染问题。如果在真机上测试应该会消失。

## 当前状态

- ✅ AmapCityViewFactory 隐私合规设置已添加
- ✅ 详细日志已添加
- 🔄 等待用户测试并查看日志
- 📱 需要用户导航到地图页面触发视图创建

## 下一步

1. 用户滑动到地图页面
2. 查看终端日志输出
3. 确认是否出现 "✅ Amap privacy compliance configured"
4. 检查是否还有 JSONException 错误
5. 观察地图是否正确显示

**更新时间:** 2025-10-13
**状态:** 等待测试
