# 📋 高德地图 Key 配置快速参考

## 🎯 为什么需要两个 Key？

```
你的应用：
├── iOS     → Bundle ID: com.example.dfAdminMobile
└── Android → Package Name: com.example.df_admin_mobile
             （注意：不同！）

高德地图验证规则：
Key 必须与平台标识符严格匹配！
```

## ✅ 当前配置状态

| 平台 | 标识符 | Key 状态 |
|------|--------|---------|
| iOS | `com.example.dfAdminMobile` | ✅ 已配置 |
| Android | `com.example.df_admin_mobile` | ⚠️ 待配置 |

## 📝 配置文件位置

```
lib/config/amap_keys.dart
```

## 🚀 快速配置 Android Key

### 1. 获取 SHA1
```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android | grep SHA1
```

### 2. 在高德控制台创建应用
- 平台：Android
- Package Name：`com.example.df_admin_mobile`
- SHA1：（从上面获取）

### 3. 更新配置文件
```dart
// lib/config/amap_keys.dart
static const String _androidKey = '你的Android Key';
```

## 📚 详细文档

- `AMAP_DUAL_PLATFORM_KEYS_GUIDE.md` - 完整配置指南
- `AMAP_KEY_GUIDE.md` - Key 获取详细步骤
- 高德控制台：https://console.amap.com/dev/key/app
