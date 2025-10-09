# 修复 Android 模拟器 DNS 问题

## 问题描述
Android 模拟器无法解析域名（DNS），导致图片加载失败：
```
Failed host lookup: 'images.unsplash.com' (OS Error: No address associated with hostname, errno = 7)
```

## 解决方案

### 方案 1：使用 Google DNS 重启模拟器（推荐）

1. **关闭当前运行的 Android 模拟器**

2. **在命令行中使用以下命令启动模拟器**：
   ```bash
   # Windows (PowerShell)
   cd $env:LOCALAPPDATA\Android\Sdk\emulator
   .\emulator.exe -avd <你的模拟器名称> -dns-server 8.8.8.8,8.8.4.4
   
   # 或者使用国内 DNS
   .\emulator.exe -avd <你的模拟器名称> -dns-server 114.114.114.114,223.5.5.5
   ```

3. **查找你的模拟器名称**：
   ```bash
   cd $env:LOCALAPPDATA\Android\Sdk\emulator
   .\emulator.exe -list-avds
   ```

### 方案 2：通过 Android Studio AVD Manager 配置

1. 打开 **Android Studio**
2. 点击 **Tools** → **AVD Manager**
3. 点击模拟器右侧的 **编辑图标（铅笔）**
4. 点击 **Show Advanced Settings**
5. 在 **Network** 部分，设置：
   - **DNS Server 1**: `8.8.8.8` 或 `114.114.114.114`
   - **DNS Server 2**: `8.8.4.4` 或 `223.5.5.5`
6. 点击 **Finish** 保存
7. 重启模拟器

### 方案 3：通过 ADB 配置 DNS（临时）

在模拟器运行时执行：
```bash
# 设置 DNS
adb shell "settings put global private_dns_mode hostname"
adb shell "settings put global private_dns_specifier dns.google"

# 或使用国内 DNS
adb shell "settings put global private_dns_specifier dns.alidns.com"

# 重启网络
adb shell "svc wifi disable"
adb shell "svc wifi enable"
```

### 方案 4：检查主机网络设置

如果上述方法都不行，可能是主机网络问题：

1. **检查 Windows 防火墙**是否阻止了模拟器
2. **检查代理设置**：
   - 打开 Android Studio → **Settings** → **Appearance & Behavior** → **System Settings** → **HTTP Proxy**
   - 确保设置为 **No proxy** 或配置正确的代理
3. **重启 Android Emulator** 进程

### 方案 5：在代码中添加更好的错误处理

虽然不能解决 DNS 问题，但可以改善用户体验：

```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
  placeholder: (context, url) => Container(
    color: Colors.grey[200],
    child: const Center(
      child: CircularProgressIndicator(),
    ),
  ),
  errorWidget: (context, url, error) {
    print('图片加载失败: $url');
    print('错误详情: $error');
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
          SizedBox(height: 8),
          Text(
            '图片加载失败',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  },
)
```

## 推荐 DNS 服务器

### 国际 DNS
- Google DNS: `8.8.8.8`, `8.8.4.4`
- Cloudflare DNS: `1.1.1.1`, `1.0.0.1`

### 国内 DNS（更快）
- 阿里 DNS: `223.5.5.5`, `223.6.6.6`
- 114 DNS: `114.114.114.114`, `114.114.115.115`
- 腾讯 DNS: `119.29.29.29`

## 验证 DNS 是否工作

启动模拟器后，在命令行执行：
```bash
adb shell "ping -c 3 images.unsplash.com"
```

如果能看到回复，说明 DNS 已正常工作。

## 为什么 iPhone 模拟器没问题？

iOS 模拟器使用 macOS 主机的网络配置，而 Android 模拟器有独立的网络栈，需要单独配置 DNS。
