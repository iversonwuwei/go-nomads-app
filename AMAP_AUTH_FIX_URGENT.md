# 🚨 高德地图鉴权错误修复指南

## ⚠️ 当前问题

**错误代码**: `INVALID_USER_SCODE` (用户MD5安全码未通过)

**错误信息**:
```
infocode: 10008
status: 0
info: INVALID_USER_SCODE
```

## 📊 实际运行信息

从应用运行日志中提取的实际配置:

| 配置项 | 值 |
|--------|-----|
| **Package Name** | `com.example.df_admin_mobile` |
| **实际 SHA1** | `5C:A4:02:33:DA:BF:48:6F:68:6C:3F:C8:A2:B0:CB:DD:C1:C1:C9:02` |
| **API Key** | `1b1caa568d9884680086a15613448b40` |

## 🔧 解决方案

### 步骤 1: 登录高德开放平台

访问: https://console.amap.com/dev/key/app

### 步骤 2: 找到您的应用

在应用列表中找到 Key 为 `1b1caa568d9884680086a15613448b40` 的应用

### 步骤 3: 配置 Android 平台信息

点击 "编辑" 或 "配置",在 **Android平台** 部分添加或更新:

#### 方式A: 添加新的 SHA1 配置(推荐)
```
PackageName: com.example.df_admin_mobile
SHA1: 5C:A4:02:33:DA:BF:48:6F:68:6C:3F:C8:A2:B0:CB:DD:C1:C1:C9:02
```

#### 方式B: 如果已有配置,检查是否匹配
确保控制台中配置的 SHA1 与实际 SHA1 完全一致(包括大小写和冒号)。

### 步骤 4: 保存并等待生效

- 点击 "提交" 保存配置
- 配置通常立即生效,但建议等待 1-2 分钟
- 重新运行应用: `flutter run`

## 🔍 验证配置

运行应用后,查看日志中的鉴权信息:

### ✅ 配置正确的日志
```
I/authErrLog: 鉴权成功
```

### ❌ 配置错误的日志
```
I/authErrLog: INVALID_USER_SCODE
I/authErrLog: 用户MD5安全码未通过
```

## 📝 常见问题

### Q1: 为什么 SHA1 与之前不同?

**A**: 可能的原因:
1. 使用了不同的签名密钥库(debug.keystore)
2. 重新安装了 Android Studio 或 SDK
3. 在不同的开发机器上运行

### Q2: 我需要同时配置多个 SHA1 吗?

**A**: 是的,如果您:
- 在多台电脑上开发(每台电脑的 debug.keystore 可能不同)
- 需要同时支持调试版和发布版
- 在团队中协作开发

可以在高德控制台添加多个 SHA1,每个 SHA1 对应一个配置。

### Q3: 如何获取发布版的 SHA1?

**A**: 使用您的发布密钥库:
```bash
keytool -list -v -keystore your-release-key.jks -alias your-alias
```

### Q4: 配置后仍然报错怎么办?

**A**: 检查清单:
- [ ] PackageName 与 AndroidManifest.xml 中的包名完全一致
- [ ] SHA1 格式正确(大写,用冒号分隔)
- [ ] API Key 正确填写在 AndroidManifest.xml 和 amap_native_config.dart
- [ ] 已等待配置生效(1-2分钟)
- [ ] 已卸载旧版本 APK 重新安装

## 🎯 快速参考

**高德控制台**: https://console.amap.com/dev/key/app

**当前配置**:
```
PackageName: com.example.df_admin_mobile
SHA1 (调试版): 5C:A4:02:33:DA:BF:48:6F:68:6C:3F:C8:A2:B0:CB:DD:C1:C1:C9:02
API Key: 1b1caa568d9884680086a15613448b40
```

**配置文件位置**:
- Android Manifest: `android/app/src/main/AndroidManifest.xml`
- Dart 配置: `lib/config/amap_native_config.dart`

## 📞 需要帮助?

参考高德官方文档: https://lbs.amap.com/api/android-sdk/guide/create-project/get-key

搜索错误代码: "INVALID_USER_SCODE"
