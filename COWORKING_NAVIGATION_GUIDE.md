# Coworking 导航功能 - 地图选择器

## 功能概述

在 Coworking 详情页面点击"开始导航"按钮后,会弹出一个地图选择器,让用户选择使用哪个地图应用进行导航。

## 支持的地图应用

### 1. 谷歌地图 (Google Maps)
- **图标**: 蓝色地图图标
- **App URL Scheme**: `comgooglemaps://`
- **Web 备选**: `https://www.google.com/maps/`
- **功能**: 驾车导航到目的地

### 2. 高德地图 (Amap)
- **图标**: 绿色定位图标
- **App URL Scheme**: 
  - iOS: `iosamap://`
  - Android: `androidamap://`
- **Web 备选**: `https://uri.amap.com/`
- **功能**: 驾车导航到目的地

### 3. 百度地图 (Baidu Maps)
- **图标**: 橙色导航图标
- **App URL Scheme**: `baidumap://`
- **Web 备选**: `https://api.map.baidu.com/`
- **功能**: 驾车导航到目的地

### 4. 取消按钮
- 关闭选择器,不进行导航

## 用户交互流程

```
Coworking 详情页
    ↓
点击"开始导航"按钮
    ↓
弹出地图选择 Bottom Sheet
    ↓
    ├─ 选择谷歌地图 → 打开谷歌地图 App/网页
    ├─ 选择高德地图 → 打开高德地图 App/网页
    ├─ 选择百度地图 → 打开百度地图 App/网页
    └─ 点击取消 → 关闭选择器
```

## 技术实现

### 1. Bottom Sheet 设计

```dart
showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (context) => Container(...)
)
```

**特点**:
- 圆角顶部 (20px)
- 列表式选项
- 每个选项带图标、主标题、副标题
- 底部取消按钮

### 2. URL Scheme 处理

#### 谷歌地图
```dart
// App URL
comgooglemaps://?daddr=latitude,longitude&directionsmode=driving

// Web URL (备选)
https://www.google.com/maps/dir/?api=1&destination=lat,lng
```

#### 高德地图
```dart
// iOS App URL
iosamap://navi?poiname=name&lat=lat&lon=lng&dev=0&style=2

// Android App URL
androidamap://navi?poiname=name&lat=lat&lon=lng&dev=0&style=2

// Web URL (备选)
https://uri.amap.com/navigation?to=lng,lat,name&mode=car
```

#### 百度地图
```dart
// App URL
baidumap://map/direction?destination=name:name|latlng:lat,lng&mode=driving

// Web URL (备选)
https://api.map.baidu.com/direction?destination=name:name|latlng:lat,lng
```

### 3. 打开逻辑

```dart
try {
  if (await canLaunchUrl(appUrl)) {
    // 尝试打开 App
    await launchUrl(appUrl);
  } else if (await canLaunchUrl(webUrl)) {
    // App 未安装,使用浏览器
    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  }
} catch (e) {
  debugPrint('打开地图失败: $e');
}
```

## UI 设计

### Bottom Sheet 布局

```
┌─────────────────────────────────┐
│ 📍 选择导航应用                    │
├─────────────────────────────────┤
│                                 │
│ 🗺️  谷歌地图                 →  │
│     Google Maps                 │
│                                 │
│ 📍  高德地图                 →  │
│     Amap                        │
│                                 │
│ 🧭  百度地图                 →  │
│     Baidu Maps                  │
│                                 │
│ ┌─────────────────────────────┐ │
│ │         取消                 │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### 视觉特点

**图标容器**:
- 圆角 8px
- 半透明彩色背景
- 对应品牌色

**列表项**:
- 主标题: 中文地图名称
- 副标题: 英文名称
- 右侧箭头图标

**取消按钮**:
- 边框按钮样式
- 圆角 12px
- 全宽布局

## 代码结构

### 新增方法

1. **`_showMapSelectionSheet(BuildContext context)`**
   - 显示地图选择 Bottom Sheet
   - 提供四个选项

2. **`_openGoogleMaps()`**
   - 打开谷歌地图
   - App → Web 降级策略

3. **`_openAmap()`**
   - 打开高德地图
   - iOS → Android → Web 降级策略

4. **`_openBaiduMaps()`**
   - 打开百度地图
   - App → Web 降级策略

### 修改内容

**导航按钮点击事件**:
```dart
// 修改前
onPressed: () {
  Get.to(() => OSMNavigationPage(coworkingSpace: space));
}

// 修改后
onPressed: () {
  _showMapSelectionSheet(context);
}
```

## 兼容性

### 平台支持
- ✅ iOS
- ✅ Android
- ✅ Web (使用浏览器打开)
- ⚠️ macOS (使用浏览器打开)
- ⚠️ Windows (使用浏览器打开)

### App 检测逻辑

1. 首先尝试打开原生 App
2. 如果 App 未安装,降级到 Web 版本
3. Web 版本使用外部浏览器打开

## 用户体验

### 优点
- ✅ 尊重用户选择
- ✅ 支持多种导航应用
- ✅ 自动降级策略
- ✅ 界面清晰直观

### 降级策略
1. **App 已安装**: 直接打开对应 App
2. **App 未安装**: 在浏览器中打开 Web 版本
3. **网络问题**: 显示调试日志

## 测试建议

### 功能测试
1. ✅ 点击"开始导航"按钮是否弹出选择器
2. ✅ 选择谷歌地图是否正确打开
3. ✅ 选择高德地图是否正确打开
4. ✅ 选择百度地图是否正确打开
5. ✅ 点击取消是否关闭选择器
6. ✅ 传递的位置信息是否正确

### 边界测试
1. ✅ App 未安装时的降级处理
2. ✅ 无网络情况下的表现
3. ✅ 特殊字符地名的处理
4. ✅ 经纬度边界值测试

### 平台测试
1. ✅ iOS 设备测试
2. ✅ Android 设备测试
3. ✅ 模拟器测试
4. ✅ 不同屏幕尺寸测试

## 已知限制

### 1. URL Scheme 限制
- 某些设备可能限制 URL Scheme 调用
- 需要在应用商店安装对应地图 App

### 2. 坐标系统
- 谷歌地图: WGS84
- 高德地图: GCJ-02 (火星坐标)
- 百度地图: BD-09 (百度坐标)

⚠️ **注意**: 当前实现未进行坐标系转换,可能导致位置偏差。

### 3. Web 版本限制
- 浏览器版本可能功能受限
- 某些功能需要登录

## 未来优化

### 1. 坐标系转换
- 实现 WGS84 → GCJ-02 转换
- 实现 WGS84 → BD-09 转换

### 2. 更多地图支持
- 添加苹果地图 (Apple Maps)
- 添加腾讯地图
- 添加搜狗地图

### 3. 智能推荐
- 根据用户历史选择记录偏好
- 自动选择已安装的地图

### 4. 错误提示
- 显示友好的错误消息
- 提供下载链接

### 5. 路线选择
- 支持驾车/步行/骑行/公交选择
- 记住用户偏好

## 文件清单

**修改文件**:
- `lib/pages/coworking_detail_page.dart`
  - 修改导航按钮点击事件
  - 添加 `_showMapSelectionSheet()` 方法
  - 添加 `_openGoogleMaps()` 方法
  - 添加 `_openAmap()` 方法
  - 添加 `_openBaiduMaps()` 方法

**依赖**:
- `url_launcher: ^6.2.5` (已存在)

## 代码质量

### 检查结果
```bash
flutter analyze lib/pages/coworking_detail_page.dart
```
✅ No issues found!

### 最佳实践
- ✅ 使用 try-catch 错误处理
- ✅ 使用 debugPrint 记录日志
- ✅ 提供降级策略
- ✅ URI 编码处理特殊字符

## 更新日志

### 2025-10-16
- ✅ 实现地图选择 Bottom Sheet
- ✅ 支持谷歌地图、高德地图、百度地图
- ✅ 实现 App/Web 降级策略
- ✅ 代码检查通过

## 相关文档

- [URL Launcher 文档](https://pub.dev/packages/url_launcher)
- [谷歌地图 URL Scheme](https://developers.google.com/maps/documentation/urls/ios-urlscheme)
- [高德地图 URI API](https://lbs.amap.com/api/amap-mobile/guide/ios/route)
- [百度地图 URI API](https://lbsyun.baidu.com/index.php?title=uri/api/ios)
