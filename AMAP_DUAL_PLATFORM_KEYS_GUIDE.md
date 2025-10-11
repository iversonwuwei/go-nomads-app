# 🔑 高德地图双平台 API Key 配置指南

**更新日期**: 2025年10月12日  
**重要**: iOS 和 Android 需要**分别配置不同的 Key**

---

## 📋 你的应用信息

### iOS 应用
- **Bundle ID**: `com.example.dfAdminMobile`
- **平台**: iOS 平台
- **需要配置**: Bundle Identifier

### Android 应用
- **Package Name**: `com.example.df_admin_mobile`
- **平台**: Android 平台
- **需要配置**: Package Name + SHA1 签名

⚠️ **注意**: 两个平台的标识符不同，所以必须创建两个独立的高德应用！

---

## 🚀 完整配置步骤

### Step 1: 登录高德开放平台

1. 访问：https://console.amap.com/dev/key/app
2. 使用账号登录（如无账号先注册）

### Step 2: 创建 iOS 平台应用

#### 2.1 创建应用
1. 点击 **"创建新应用"**
2. 填写：
   - **应用名称**: `Nomads Platform - iOS`
   - **应用类型**: 移动应用
3. 点击 **"提交"**

#### 2.2 添加 iOS Key
1. 在应用详情页，点击 **"添加 Key"**
2. 配置：
   - **Key 名称**: `iOS Development Key` 或 `iOS Production Key`
   - **服务平台**: **iOS 平台** ✅
   - **Bundle Identifier**: `com.example.dfAdminMobile`
3. 点击 **"提交"**
4. **复制生成的 Key**（40位字符串）

#### 2.3 保存到配置文件
```dart
// lib/config/amap_keys.dart
static const String _iosKey = '复制的iOS Key粘贴到这里';
```

### Step 3: 创建 Android 平台应用

#### 3.1 创建应用（或在同一应用下添加）
可以选择：
- **选项 A**: 在现有应用下添加 Android Key
- **选项 B**: 创建新应用 `Nomads Platform - Android`

推荐使用 **选项 A**（同一应用下管理多个平台）

#### 3.2 获取 Android SHA1 签名

**调试版 SHA1**（用于开发）:
```bash
cd /Users/walden/Workspaces/WaldenProjects/open-platform-app

# 方法 1: 使用 keytool
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android | grep SHA1

# 方法 2: 使用 Gradle（如果上面不行）
cd android
./gradlew signingReport | grep SHA1
```

**发布版 SHA1**（用于生产）:
```bash
# 使用你的发布密钥库
keytool -list -v -keystore /path/to/your/release.keystore \
  -alias your_alias_name | grep SHA1
```

#### 3.3 添加 Android Key
1. 点击 **"添加 Key"**
2. 配置：
   - **Key 名称**: `Android Development Key`
   - **服务平台**: **Android 平台** ✅
   - **PackageName**: `com.example.df_admin_mobile`
   - **发布版安全码 SHA1**: （从上面获取）
   - **调试版安全码 SHA1**: （从上面获取）
3. 点击 **"提交"**
4. **复制生成的 Key**

#### 3.4 保存到配置文件
```dart
// lib/config/amap_keys.dart
static const String _androidKey = '复制的Android Key粘贴到这里';
```

### Step 4: 验证配置

#### 4.1 检查配置文件
```dart
// lib/config/amap_keys.dart
class AmapKeys {
  static const String _iosKey = 'a1b2c3d4...'; // iOS Key
  static const String _androidKey = 'e5f6g7h8...'; // Android Key
}
```

确保：
- ✅ 两个 Key 都已填写
- ✅ 没有包含 "你的" 这样的占位符
- ✅ Key 长度为 32-40 个字符

#### 4.2 运行测试
```bash
# iOS 测试
flutter run -d "iPhone 16 Pro"

# Android 测试（连接真机或模拟器）
flutter run -d <Android设备ID>
```

查看日志：
```
✅ 高德地图初始化成功
📱 平台: iOS
🔑 Key: 6b053c71...
```

---

## 🔍 快速参考

### 当前配置状态

| 平台 | 标识符 | Key 状态 | 配置位置 |
|------|--------|---------|---------|
| **iOS** | `com.example.dfAdminMobile` | ✅ 已配置 | `_iosKey` |
| **Android** | `com.example.df_admin_mobile` | ❌ 待配置 | `_androidKey` |

### 文件位置

```
lib/config/amap_keys.dart     ← API Key 配置文件
lib/main.dart                 ← 初始化代码
```

### 控制台地址

- **高德开放平台**: https://console.amap.com/dev/key/app
- **应用管理**: https://console.amap.com/dev/key/app
- **API 文档**: https://lbs.amap.com/api/ios-sdk/summary/

---

## 🐛 常见问题

### Q1: 为什么要用两个不同的 Key？

**A**: 因为 iOS 和 Android 的应用标识符不同：
- iOS: `com.example.dfAdminMobile` (驼峰命名)
- Android: `com.example.df_admin_mobile` (下划线)

高德地图会验证 Key 与标识符的匹配关系，所以必须分别配置。

### Q2: 可以用同一个 Key 吗？

**A**: 不行。每个 Key 都绑定了特定的平台和标识符：
- iOS Key → 绑定 Bundle ID
- Android Key → 绑定 Package Name + SHA1

### Q3: 如何知道当前使用的是哪个 Key？

**A**: 查看应用启动日志：
```
✅ 高德地图初始化成功
📱 平台: iOS          ← 当前平台
🔑 Key: 6b053c71...   ← Key 前 8 位
```

### Q4: Android SHA1 获取失败怎么办？

**A**: 尝试以下方法：

**方法 1**: 手动生成调试密钥库
```bash
keytool -genkey -v -keystore ~/.android/debug.keystore \
  -storepass android -alias androiddebugkey \
  -keypass android -keyalg RSA -keysize 2048 -validity 10000
```

**方法 2**: 运行 Android 应用后再获取
```bash
flutter build apk --debug
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

**方法 3**: 从 Gradle 报告获取
```bash
cd android
./gradlew signingReport
```

### Q5: Key 配置错误会怎样？

**可能现象**:
- ❌ 地图显示空白
- ❌ 控制台报错：`INVALID_USER_KEY`
- ❌ 控制台报错：`USERKEY_PLAT_NOMATCH`

**解决方法**:
1. 检查 Key 是否正确复制
2. 检查平台选择是否正确
3. 检查 Bundle ID / Package Name 是否匹配

---

## ✅ 配置检查清单

完成以下步骤后打勾：

### iOS 平台配置
- [ ] 在高德控制台创建了 iOS 应用
- [ ] Bundle ID 填写为: `com.example.dfAdminMobile`
- [ ] 获取了 iOS Key（40位字符串）
- [ ] 将 Key 填入 `lib/config/amap_keys.dart` 的 `_iosKey`
- [ ] 在 iOS 模拟器或真机上测试（真机推荐）
- [ ] 看到日志：`✅ 高德地图初始化成功`

### Android 平台配置
- [ ] 在高德控制台创建了 Android 应用
- [ ] Package Name 填写为: `com.example.df_admin_mobile`
- [ ] 获取了调试版 SHA1 签名
- [ ] 获取了发布版 SHA1 签名（如需发布）
- [ ] 将两个 SHA1 都配置到控制台
- [ ] 获取了 Android Key
- [ ] 将 Key 填入 `lib/config/amap_keys.dart` 的 `_androidKey`
- [ ] 在 Android 真机或模拟器上测试
- [ ] 看到日志：`✅ 高德地图初始化成功`

---

## 📝 配置示例

### 正确的配置
```dart
// lib/config/amap_keys.dart
class AmapKeys {
  // iOS Key (真实 Key)
  static const String _iosKey = '6b053c71911726f46271e4b54124d35f';
  
  // Android Key (真实 Key)
  static const String _androidKey = 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6';
}
```

### 错误的配置
```dart
// ❌ 两个平台用同一个 Key
static const String _iosKey = '6b053c71911726f46271e4b54124d35f';
static const String _androidKey = '6b053c71911726f46271e4b54124d35f'; // 错误！

// ❌ 包含占位符
static const String _androidKey = '你的Android平台Key'; // 错误！

// ❌ Key 为空
static const String _androidKey = ''; // 错误！
```

---

## 🎯 总结

### 为什么需要两个 Key？
- iOS 和 Android 的应用标识符不同
- 高德地图严格验证 Key 与标识符的绑定关系
- 确保安全性和准确性

### 配置流程
1. ✅ iOS: 创建应用 → 配置 Bundle ID → 获取 Key
2. ✅ Android: 创建应用 → 配置 Package Name + SHA1 → 获取 Key
3. ✅ 填入配置文件
4. ✅ 测试验证

### 当前状态
- ✅ iOS Key: 已配置 `6b053c71911726f46271e4b54124d35f`
- ⚠️ Android Key: 待配置（请按上述步骤获取）

---

**下一步**: 
1. 获取 Android SHA1 签名
2. 在高德控制台创建 Android 应用
3. 将 Android Key 填入配置文件
4. 在 Android 设备上测试

**需要帮助?** 参考官方文档：https://lbs.amap.com/api/android-sdk/guide/create-project/get-key
