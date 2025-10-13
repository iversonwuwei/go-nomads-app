# 📱 Android 高德地图原生组件配置指南

**创建时间**: 2025年1月

---

## 📋 配置信息总结

| 项目 | 值 |
|------|-----|
| **Package Name** | `com.example.df_admin_mobile` |
| **调试版 SHA1** | `80:14:37:54:EC:ED:51:EB:AF:41:7C:92:AF:71:A1:E8:4A:7D:80:6B` |
| **高德控制台** | https://console.amap.com/dev/key/app |

---

## 🚀 步骤 1: 在高德控制台创建 Android Key

### 1.1 登录高德开放平台
访问: https://console.amap.com/dev/key/app

### 1.2 创建应用（如果还没有）
- 应用名称: `Nomads Platform`
- 应用类型: 移动应用

### 1.3 添加 Android Platform Key
点击 **"添加 Key"** 按钮，填写信息:

**Key 名称**: `Android Development Key`

**服务平台**: 选择 **Android 平台** ✅

**PackageName (包名)**:
```
com.example.df_admin_mobile
```

**调试版安全码 SHA1**:
```
80:14:37:54:EC:ED:51:EB:AF:41:7C:92:AF:71:A1:E8:4A:7D:80:6B
```

**发布版安全码 SHA1**: (可选，发布时需要)
```
(如有发布密钥库，填写这里)
```

### 1.4 提交并获取 Key
1. 点击 **"提交"**
2. 复制生成的 **Android Key** (40位字符串)
   - 格式类似: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0`

---

## 🔧 步骤 2: 配置项目文件

### 2.1 更新 AndroidManifest.xml
打开文件: `android/app/src/main/AndroidManifest.xml`

找到这行:
```xml
<meta-data
    android:name="com.amap.api.v2.apikey"
    android:value="YOUR_ANDROID_KEY_HERE" />
```

替换 `YOUR_ANDROID_KEY_HERE` 为你复制的 Android Key:
```xml
<meta-data
    android:name="com.amap.api.v2.apikey"
    android:value="你复制的40位Key粘贴到这里" />
```

### 2.2 更新配置文件
打开文件: `lib/config/amap_native_config.dart`

找到这行:
```dart
static const String androidApiKey = 'YOUR_ANDROID_KEY_HERE';
```

替换为你的 Android Key:
```dart
static const String androidApiKey = '你复制的40位Key粘贴到这里';
```

---

## ✅ 步骤 3: 验证配置

### 3.1 检查文件修改
确保以下两个位置都已更新:
- ✅ `android/app/src/main/AndroidManifest.xml` - meta-data value
- ✅ `lib/config/amap_native_config.dart` - androidApiKey

### 3.2 清理并重新构建
```bash
flutter clean
flutter pub get
flutter run
```

### 3.3 测试地图功能
1. 运行应用到 Android 设备或模拟器
2. 进入 Travel Plan 页面
3. 点击 "Async with Map" 图标按钮
4. 应该能看到高德地图选择器界面

---

## 📁 已创建的文件列表

### Android 原生文件
- ✅ `android/app/src/main/kotlin/.../AmapMapPickerActivity.kt` (320行)
  - 地图选择器 Activity
  - 实现拖拽选点、逆地理编码
  
- ✅ `android/app/src/main/kotlin/.../MainActivity.kt` (已修改)
  - 添加 Platform Channel 处理
  - openMapPicker 和 getCurrentLocation 方法

### 配置文件
- ✅ `android/app/src/main/AndroidManifest.xml` (已修改)
  - 注册 AmapMapPickerActivity
  - 添加 API Key meta-data
  
- ✅ `android/app/build.gradle` (已修改)
  - 添加高德地图 SDK 依赖
  - Amap 3D Map SDK: 10.0.700
  - Amap Search SDK: 9.7.2

### Flutter 文件
- ✅ `lib/config/amap_native_config.dart` (已修改)
  - 添加 androidApiKey 配置
  
- ✅ `lib/services/amap_native_service.dart` (已存在)
  - Platform Channel 服务

---

## 🎯 功能特性

### Android 地图选择器功能
- ✅ 3D 地图展示
- ✅ 拖拽选择位置 (中心点指示器)
- ✅ 逆地理编码 (自动获取地址)
- ✅ 地址信息面板
- ✅ 确认/取消按钮
- ✅ 返回经纬度和地址到 Flutter

### 已实现的 Platform Channel 方法
1. **openMapPicker**
   - 打开地图选择器
   - 支持初始坐标参数
   - 返回: `{latitude, longitude, address}`

2. **getCurrentLocation**
   - 获取当前位置
   - 返回: `{latitude, longitude}`

---

## 🐛 故障排查

### 问题 1: 地图无法显示
**原因**: API Key 未配置或不正确
**解决**: 
1. 检查 AndroidManifest.xml 中的 Key
2. 确认 Package Name 和 SHA1 匹配
3. 检查控制台是否生成了正确的 Key

### 问题 2: 地址无法显示
**原因**: 网络问题或搜索 SDK 未正确初始化
**解决**:
1. 检查网络权限
2. 确认 Amap Search SDK 依赖已添加
3. 查看 Logcat 日志

### 问题 3: 编译失败
**原因**: 依赖版本冲突或配置错误
**解决**:
1. 运行 `flutter clean`
2. 检查 build.gradle 中的依赖版本
3. 确保 Kotlin 版本兼容

---

## 📚 相关文档

- [高德地图 Android SDK 文档](https://lbs.amap.com/api/android-sdk/summary)
- [高德地图控制台](https://console.amap.com/dev/key/app)
- [SHA1 获取方法](https://lbs.amap.com/api/android-sdk/guide/create-project/get-key)

---

## 🔑 快速参考

### API Key 位置
```dart
// Flutter 配置
lib/config/amap_native_config.dart
└── static const String androidApiKey = '...';

// Android 配置  
android/app/src/main/AndroidManifest.xml
└── <meta-data android:name="com.amap.api.v2.apikey" android:value="..." />
```

### Platform Channel
```dart
// 调用示例
final result = await AmapNativeService.openMapPicker(
  latitude: 39.9,
  longitude: 116.4,
);

print('选择的位置: ${result['address']}');
print('经纬度: ${result['latitude']}, ${result['longitude']}');
```

---

**✅ 配置完成后，Android 版本的高德地图功能将与 iOS 版本保持一致！**
