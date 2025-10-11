# 🔑 高德地图 API Key 配置完整指南

**更新日期**: 2025年10月11日  
**适用于**: Flutter + amap_map_fluttify

---

## 📋 Key 类型说明

### 1️⃣ iOS 平台 Key
- **用途**: iOS 原生地图 SDK
- **在哪里使用**: `AmapCore.init()` (iOS)
- **必需**: ✅ 是（如果要在 iOS 上运行）

### 2️⃣ Android 平台 Key  
- **用途**: Android 原生地图 SDK
- **在哪里使用**: `AmapCore.init()` (Android)
- **必需**: ✅ 是（如果要在 Android 上运行）

### 3️⃣ Web 服务 Key
- **用途**: 逆地理编码、POI 搜索、路径规划等 Web API
- **在哪里使用**: `AmapSearch` 等服务调用
- **必需**: ⚠️ 可选（但推荐，用于高级功能）

---

## 🚀 获取 Key 的详细步骤

### Step 1: 注册高德开放平台账号

1. 访问：https://lbs.amap.com/
2. 点击右上角 "注册"
3. 填写个人/企业信息
4. 完成实名认证（推荐）

### Step 2: 创建应用

1. 登录控制台：https://console.amap.com/dev/key/app
2. 点击 **"创建新应用"**
3. 填写信息：
   - **应用名称**: Nomads Open Platform（或你的应用名）
   - **应用类型**: 移动应用
4. 提交

### Step 3: 添加 iOS Key

#### 3.1 获取 iOS Bundle ID

```bash
# 查看你的 Bundle ID
cat ios/Runner.xcodeproj/project.pbxproj | grep PRODUCT_BUNDLE_IDENTIFIER
```

**你的 Bundle ID**: `com.example.openPlatformApp`

#### 3.2 创建 iOS Key

1. 在应用详情页，点击 **"添加 Key"**
2. 选择配置：
   - **服务平台**: `iOS 平台` ✅
   - **Bundle ID**: `com.example.openPlatformApp`
3. 点击 **"提交"**
4. 复制生成的 **iOS Key**（40 位字符串）

#### 3.3 配置到代码

```dart
// main.dart
if (Platform.isIOS) {
  await AmapCore.init('你复制的iOS Key');
}
```

### Step 4: 添加 Android Key

#### 4.1 获取 Android 包名

```bash
# 查看你的包名
cat android/app/build.gradle | grep applicationId
```

**你的包名**: `com.example.open_platform_app`

#### 4.2 获取 SHA1 签名

**开发版签名**（用于测试）:
```bash
cd android
./gradlew signingReport
# 查找 SHA1 fingerprint
```

或使用 keytool:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**发布版签名**（用于生产）:
```bash
keytool -list -v -keystore /path/to/your/release.keystore
```

#### 4.3 创建 Android Key

1. 点击 **"添加 Key"**
2. 选择配置：
   - **服务平台**: `Android 平台` ✅
   - **发布版安全码 SHA1**: `你的发布版SHA1`
   - **调试版安全码 SHA1**: `你的调试版SHA1`
   - **PackageName**: `com.example.open_platform_app`
3. 点击 **"提交"**
4. 复制生成的 **Android Key**

#### 4.4 配置到代码

```dart
// main.dart
if (Platform.isAndroid) {
  await AmapCore.init('你复制的Android Key');
}
```

### Step 5: 添加 Web 服务 Key（可选但推荐）

1. 点击 **"添加 Key"**
2. 选择配置：
   - **服务平台**: `Web 服务` ✅
3. 点击 **"提交"**
4. 复制生成的 **Web Service Key**

**用途示例**:
```dart
// 如果使用 Web API 进行逆地理编码等
final response = await http.get(
  Uri.parse('https://restapi.amap.com/v3/geocode/regeo?key=你的WebServiceKey&location=$lon,$lat'),
);
```

---

## ✅ 当前配置检查

### 你现在使用的 Key

```dart
await AmapCore.init('a867f44038c8acc41324858ea172364a');
```

**Key 值**: `a867f44038c8acc41324858ea172364a`

### ⚠️ 需要确认的问题

1. **这个 Key 对应的平台是什么？**
   - [ ] iOS 平台
   - [ ] Android 平台
   - [ ] Web 服务

2. **Bundle ID / 包名是否匹配？**
   - iOS Bundle ID: `com.example.openPlatformApp`
   - Android 包名: `com.example.open_platform_app`

3. **SHA1 签名是否配置？**（仅 Android）
   - [ ] 调试版 SHA1
   - [ ] 发布版 SHA1

### 🔍 验证方法

访问控制台查看：
```
https://console.amap.com/dev/key/app
```

在应用列表中找到你的 Key，确认：
- ✅ 平台类型（iOS/Android/Web）
- ✅ Bundle ID / 包名
- ✅ 启用状态（已启用）
- ✅ 配额使用情况

---

## 🎯 推荐的完整配置

### main.dart（最佳实践）

```dart
import 'dart:io';
import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';

// 配置常量（建议放在单独的 config 文件中）
class AmapConfig {
  // iOS 平台 Key
  static const String iosKey = 'a867f44038c8acc41324858ea172364a';
  
  // Android 平台 Key（需要在高德控制台创建）
  static const String androidKey = '你的Android Key';
  
  // Web 服务 Key（用于高级功能）
  static const String webServiceKey = '你的Web Service Key';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 根据平台初始化
  if (Platform.isIOS) {
    await AmapCore.init(AmapConfig.iosKey);
    print('✅ 高德地图 iOS SDK 初始化成功');
  } else if (Platform.isAndroid) {
    await AmapCore.init(AmapConfig.androidKey);
    print('✅ 高德地图 Android SDK 初始化成功');
  }
  
  runApp(const MyApp());
}
```

### 创建独立配置文件（更安全）

**lib/config/amap_config.dart**:
```dart
import 'dart:io';

class AmapConfig {
  // 私有构造函数，防止实例化
  AmapConfig._();
  
  // iOS Key
  static const String _iosKey = 'a867f44038c8acc41324858ea172364a';
  
  // Android Key
  static const String _androidKey = '你的Android Key';
  
  // Web Service Key
  static const String _webServiceKey = '你的Web Service Key';
  
  // 根据平台返回正确的 Key
  static String get platformKey {
    if (Platform.isIOS) {
      return _iosKey;
    } else if (Platform.isAndroid) {
      return _androidKey;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
  
  static String get webServiceKey => _webServiceKey;
}
```

**使用方式**:
```dart
// main.dart
import 'config/amap_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AmapCore.init(AmapConfig.platformKey);
  runApp(const MyApp());
}
```

---

## 🔒 安全最佳实践

### 1. 不要将 Key 硬编码在代码中（生产环境）

**使用环境变量**:
```dart
// 从环境变量读取
const amapKey = String.fromEnvironment('AMAP_KEY', defaultValue: '');
```

**编译时传入**:
```bash
flutter build apk --dart-define=AMAP_KEY=你的Key
```

### 2. 使用 .gitignore 排除配置文件

```gitignore
# .gitignore
lib/config/amap_config.dart
```

### 3. 创建示例配置文件

**lib/config/amap_config.example.dart**:
```dart
class AmapConfig {
  static const String iosKey = '请在高德控制台获取';
  static const String androidKey = '请在高德控制台获取';
  static const String webServiceKey = '请在高德控制台获取';
}
```

团队成员复制此文件并重命名为 `amap_config.dart`，填入自己的 Key。

---

## 🚨 常见错误排查

### 错误 1: "INVALID_USER_KEY"

**原因**:
- Key 不正确或已过期
- 平台类型不匹配（用了 Android Key 在 iOS 上）

**解决**:
```dart
// 确保平台判断正确
if (Platform.isIOS) {
  await AmapCore.init('iOS Key'); // ✅
} else if (Platform.isAndroid) {
  await AmapCore.init('Android Key'); // ✅
}
```

### 错误 2: "INVALID_USER_SIGNATURE"（Android）

**原因**:
- SHA1 签名不匹配
- 包名不正确

**解决**:
1. 重新获取 SHA1 签名
2. 在控制台更新配置
3. 确认包名一致

### 错误 3: "USERKEY_PLAT_NOMATCH"

**原因**:
- 在 iOS 上使用了 Android Key
- 在 Android 上使用了 iOS Key

**解决**:
```dart
// 使用平台判断
if (Platform.isIOS) {
  await AmapCore.init('iOS专用Key');
} else {
  await AmapCore.init('Android专用Key');
}
```

### 错误 4: 地图显示空白

**原因**:
- Bundle ID 或包名配置错误
- Key 未启用
- 网络权限未配置

**解决**:
1. 检查控制台中的 Bundle ID
2. 确认 Key 状态为 "已启用"
3. 检查网络权限配置

---

## 📊 配额管理

### 免费版配额

每个 Key 每天的免费调用次数：

| 服务类型 | 配额 |
|---------|------|
| 地图显示 | 无限制 |
| 定位 | 30万次/天 |
| 逆地理编码 | 30万次/天 |
| POI 搜索 | 10万次/天 |
| 路径规划 | 10万次/天 |

### 查看配额使用情况

访问：https://console.amap.com/dev/flow/manage

---

## 📝 配置检查清单

完成以下检查，确保配置正确：

### iOS 配置
- [ ] 在高德控制台创建了 iOS 应用
- [ ] 获取了 iOS Key
- [ ] Bundle ID 与 Xcode 中一致
- [ ] main.dart 中 iOS 平台使用了正确的 Key
- [ ] Info.plist 配置了网络权限
- [ ] 测试地图能正常显示

### Android 配置
- [ ] 在高德控制台创建了 Android 应用
- [ ] 获取了 Android Key
- [ ] 配置了调试版 SHA1
- [ ] 配置了发布版 SHA1（如需发布）
- [ ] 包名与 build.gradle 中一致
- [ ] main.dart 中 Android 平台使用了正确的 Key
- [ ] AndroidManifest.xml 配置了网络权限
- [ ] 测试地图能正常显示

### Web 服务配置（可选）
- [ ] 创建了 Web 服务 Key
- [ ] 在需要的地方使用 Web Service Key

---

## 🎓 总结

### 你需要的 Key

对于 `amap_map_fluttify` Flutter 包：

1. **iOS Key** - 用于 iOS 设备
   - 在高德控制台创建 **iOS 平台** 应用
   - 配置 Bundle ID: `com.example.openPlatformApp`

2. **Android Key** - 用于 Android 设备
   - 在高德控制台创建 **Android 平台** 应用
   - 配置包名: `com.example.open_platform_app`
   - 配置 SHA1 签名

3. **Web Service Key**（可选）- 用于高级 API
   - 在高德控制台创建 **Web 服务** 应用

### 正确使用方式

```dart
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isIOS) {
    await AmapCore.init('你的iOS Key');
  } else if (Platform.isAndroid) {
    await AmapCore.init('你的Android Key');
  }
  
  runApp(const MyApp());
}
```

### ⚠️ 重要提醒

- **不是 Web 服务 Key！** `AmapCore.init()` 需要的是平台 Key（iOS/Android）
- 每个平台需要单独的 Key
- Bundle ID 和包名必须严格匹配
- Android 必须配置 SHA1 签名

---

**完成配置后，你的高德地图就能正常工作了！** 🎉

如有问题，访问：https://lbs.amap.com/api/android-sdk/guide/create-project/get-key
