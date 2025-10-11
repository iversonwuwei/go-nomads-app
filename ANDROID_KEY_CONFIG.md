# 📋 Android 高德地图 Key 配置信息

**生成时间**: 2025年10月12日

---

## 🔑 配置信息总结

### Package Name（包名）
```
com.example.df_admin_mobile
```

### SHA1 签名（调试版）
```
80:14:37:54:EC:ED:51:EB:AF:41:7C:92:AF:71:A1:E8:4A:7D:80:6B
```

---

## 🚀 在高德控制台配置步骤

### Step 1: 登录高德控制台
访问：https://console.amap.com/dev/key/app

### Step 2: 创建或选择应用
- **选项 A**: 在现有应用下添加 Android Key
- **选项 B**: 创建新应用 "Nomads Platform - Android"

### Step 3: 添加 Android Key

点击 **"添加 Key"**，填写以下信息：

#### 基本信息
- **Key 名称**: `Android Development Key`
- **服务平台**: **Android 平台** ✅

#### 应用信息
- **PackageName（包名）**: 
  ```
  com.example.df_admin_mobile
  ```

#### 签名信息
- **发布版安全码 SHA1**: （如果有发布密钥库，填写这里；暂时可留空）
  ```
  （发布版 SHA1）
  ```

- **调试版安全码 SHA1**: 
  ```
  80:14:37:54:EC:ED:51:EB:AF:41:7C:92:AF:71:A1:E8:4A:7D:80:6B
  ```

### Step 4: 提交并获取 Key

1. 点击 **"提交"**
2. 复制生成的 **Android Key**（40位字符串）
3. 保存到 `lib/config/amap_keys.dart`

---

## 📝 更新配置文件

将获取的 Android Key 填入：

```dart
// lib/config/amap_keys.dart
static const String _androidKey = '你复制的Android Key粘贴到这里';
```

---

## ✅ 验证配置

### 1. 检查配置
```dart
// lib/config/amap_keys.dart
static const String _androidKey = 'a1b2c3d4...'; // 确保已填写
```

### 2. 运行测试
```bash
flutter run  # 在 Android 设备/模拟器上
```

### 3. 查看日志
应该看到：
```
✅ 高德地图初始化成功
📱 平台: Android
🔑 Key: a1b2c3d4...
```

---

## 🔍 快速参考

| 项目 | 值 |
|------|-----|
| **Package Name** | `com.example.df_admin_mobile` |
| **调试版 SHA1** | `80:14:37:54:EC:ED:51:EB:AF:41:7C:92:AF:71:A1:E8:4A:7D:80:6B` |
| **密钥库位置** | `~/.android/debug.keystore` |
| **密钥库密码** | `android` |
| **别名** | `androiddebugkey` |
| **别名密码** | `android` |

---

## 📚 后续步骤

### 发布版 SHA1（生产环境）

当你准备发布应用时，需要：

1. **创建发布密钥库**:
   ```bash
   keytool -genkey -v -keystore ~/release-keystore.jks \
     -alias release-key -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **获取发布版 SHA1**:
   ```bash
   keytool -list -v -keystore ~/release-keystore.jks \
     -alias release-key
   ```

3. **在高德控制台添加发布版 SHA1**

4. **配置 Android 签名**:
   - 编辑 `android/app/build.gradle`
   - 添加签名配置
   - 使用发布密钥库

---

**生成时间**: 2025年10月12日  
**下一步**: 在高德控制台使用上述信息创建 Android Key
