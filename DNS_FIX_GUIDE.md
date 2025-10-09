# 快速修复 Android 模拟器 DNS 问题

## 你的模拟器名称
`Pixel_9_Pro_API_31`

## 🚀 最简单的解决方法（推荐）

### 步骤 1：打开 Android Studio
1. 启动 Android Studio
2. 点击顶部菜单 **Tools** → **AVD Manager**（或点击工具栏的设备图标）

### 步骤 2：编辑模拟器配置
1. 找到 `Pixel 9 Pro API 31` 模拟器
2. 点击右侧的 **铅笔图标**（Edit）
3. 点击底部的 **Show Advanced Settings**
4. 滚动到 **Network** 部分

### 步骤 3：配置 DNS
在 Network 部分设置：
- **DNS Server 1**: `223.5.5.5` （阿里 DNS - 国内速度快）
- **DNS Server 2**: `8.8.8.8` （Google DNS - 备用）

或使用：
- **DNS Server 1**: `114.114.114.114` （114 DNS）
- **DNS Server 2**: `223.6.6.6` （阿里 DNS 备用）

### 步骤 4：保存并重启
1. 点击 **Finish** 保存配置
2. 关闭当前运行的模拟器（如果有）
3. 从 AVD Manager 重新启动模拟器
4. 运行 Flutter 应用：`flutter run`

---

## 🔧 或者：命令行启动（带 DNS 参数）

如果不想修改配置，可以用以下命令临时启动：

```powershell
# 切换到模拟器目录
cd $env:LOCALAPPDATA\Android\Sdk\emulator

# 使用国内 DNS 启动（推荐）
.\emulator.exe -avd Pixel_9_Pro_API_31 -dns-server 223.5.5.5,114.114.114.114

# 或使用 Google DNS
.\emulator.exe -avd Pixel_9_Pro_API_31 -dns-server 8.8.8.8,8.8.4.4
```

启动后，在新的 PowerShell 窗口运行：
```powershell
cd E:\Workspaces\WaldenProjects\df_admin_mobile
flutter run
```

---

## 📱 验证 DNS 是否工作

模拟器启动后，在新终端执行：
```powershell
cd $env:LOCALAPPDATA\Android\Sdk\platform-tools
.\adb.exe shell "ping -c 3 images.unsplash.com"
```

如果看到类似这样的输出，说明 DNS 正常：
```
PING images.unsplash.com (151.101.128.133): 56 data bytes
64 bytes from 151.101.128.133: icmp_seq=0 ttl=58 time=25.123 ms
```

---

## 🌐 为什么会出现这个问题？

1. **Windows 网络环境**：某些 Windows 网络配置可能导致模拟器 DNS 解析失败
2. **防火墙/代理**：可能阻止了模拟器的 DNS 请求
3. **Android 模拟器默认配置**：有时使用的 DNS 服务器不可达

## ✅ iPhone 模拟器为什么正常？

- **iOS 模拟器**（在 macOS 上）直接使用主机的网络配置
- **Android 模拟器**有独立的网络栈，需要单独配置

---

## 🎯 下一步

1. 按照上述方法配置 DNS
2. 重启模拟器
3. 运行 `flutter run`
4. 图片应该可以正常加载了！

如果还有问题，可能需要检查：
- Windows 防火墙设置
- 网络代理配置
- VPN 是否影响模拟器网络
