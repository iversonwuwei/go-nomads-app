# 应用图标说明

## 📱 需要准备的图标文件

### 1. 主图标：`app_icon.png`
- **尺寸**：1024x1024 像素（推荐）
- **格式**：PNG（带透明背景）
- **用途**：iOS、Android、Web、Windows、macOS 主图标
- **要求**：
  - 高分辨率，清晰锐利
  - 四角可以是圆角或直角（系统会自动裁剪）
  - 建议使用正方形设计
  - 避免文字过小

### 2. 自适应图标前景（可选）：`app_icon_foreground.png`
- **尺寸**：1024x1024 像素
- **格式**：PNG（带透明背景）
- **用途**：Android 自适应图标的前景层
- **要求**：
  - 只包含图标主体部分
  - 透明背景
  - 主要内容在中心 66% 区域内
  - 避免边缘被裁剪

### 3. 背景色
- **当前配置**：`#FF4458`（应用主题红色）
- **用途**：Android 自适应图标背景、Web 主题色
- **可自定义**：在 `pubspec.yaml` 中修改

## 🎨 设计建议

### 图标风格
- ✅ 简洁明了
- ✅ 易于识别
- ✅ 与品牌一致
- ✅ 适合小尺寸显示
- ❌ 避免过于复杂的细节
- ❌ 避免纯文字图标

### 颜色搭配
- **主色**：#FF4458（应用主题红色）
- **辅助色**：白色、深灰色
- **建议**：使用品牌色，保持视觉一致性

### 参考示例
```
简单示例：
┌─────────────┐
│             │
│   [LOGO]    │  ← 中心区域放置主要图形
│   行途      │  ← 可选：简短文字
│             │
└─────────────┘
```

## 🚀 生成图标步骤

### 方法 1：使用命令行（推荐）

1. **准备图标文件**
   - 将 `app_icon.png` 放入 `assets/icon/` 目录
   - （可选）将 `app_icon_foreground.png` 放入同一目录

2. **安装依赖**
   ```bash
   cd /Users/walden/Workspaces/WaldenProjects/open-platform-app
   flutter pub get
   ```

3. **生成图标**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **清理并重新构建**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### 方法 2：使用 Dart 命令

```bash
dart run flutter_launcher_icons
```

## 📂 生成的图标位置

### Android
```
android/app/src/main/res/
├── mipmap-hdpi/ic_launcher.png
├── mipmap-mdpi/ic_launcher.png
├── mipmap-xhdpi/ic_launcher.png
├── mipmap-xxhdpi/ic_launcher.png
├── mipmap-xxxhdpi/ic_launcher.png
└── mipmap-anydpi-v26/
    ├── ic_launcher.xml
    └── ic_launcher_round.xml
```

### iOS
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Icon-App-*.png (多个尺寸)
└── Contents.json
```

### Web
```
web/
├── favicon.png
└── icons/
    ├── Icon-192.png
    ├── Icon-512.png
    └── Icon-maskable-*.png
```

## ⚙️ 当前配置说明

```yaml
flutter_launcher_icons:
  android: true              # 生成 Android 图标
  ios: true                  # 生成 iOS 图标
  image_path: "assets/icon/app_icon.png"  # 主图标路径
  
  # Android 自适应图标
  adaptive_icon_background: "#FF4458"     # 背景色
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"  # 前景图
  
  # iOS 配置
  remove_alpha_ios: true     # 移除 iOS 图标的透明通道
  
  # Web 图标
  web:
    generate: true
    image_path: "assets/icon/app_icon.png"
    background_color: "#FF4458"
    theme_color: "#FF4458"
  
  # Windows 图标
  windows:
    generate: true
    image_path: "assets/icon/app_icon.png"
    icon_size: 48
  
  # macOS 图标
  macos:
    generate: true
    image_path: "assets/icon/app_icon.png"
```

## 🛠️ 自定义配置

### 只为特定平台生成图标
```yaml
flutter_launcher_icons:
  android: true   # 只生成 Android
  ios: false      # 不生成 iOS
```

### 使用不同的图标
```yaml
flutter_launcher_icons:
  android: "assets/icon/android_icon.png"
  ios: "assets/icon/ios_icon.png"
```

### Android 自适应图标（推荐）
```yaml
adaptive_icon_background: "#FF4458"  # 纯色背景
# 或者
adaptive_icon_background: "assets/icon/background.png"  # 图片背景
adaptive_icon_foreground: "assets/icon/foreground.png"  # 前景层
```

## 🎯 快速开始

### 临时测试图标
如果你暂时没有设计好的图标，可以：

1. **创建临时图标**：使用在线工具快速生成
   - [App Icon Generator](https://www.appicon.co/)
   - [Icon Kitchen](https://icon.kitchen/)
   - [Figma](https://www.figma.com/) 设计

2. **使用文字图标**：
   ```
   简单设计：
   - 背景：#FF4458（红色）
   - 文字：白色 "行途" 或 "X"
   - 字体：粗体、居中
   ```

3. **从现有资源提取**：
   - 使用应用截图
   - 简化现有 Logo
   - 使用品牌色块 + 简单图形

## 📝 检查清单

生成图标后，请检查：

- [ ] Android 应用图标显示正常
- [ ] iOS 应用图标显示正常
- [ ] 图标在不同尺寸下清晰可见
- [ ] 图标与应用主题一致
- [ ] 自适应图标（Android）正常显示
- [ ] Web 图标（favicon）正常显示
- [ ] 启动画面与图标协调

## 🔧 常见问题

### Q: 图标模糊？
A: 使用更高分辨率的源图标（推荐 1024x1024）

### Q: Android 图标被裁剪？
A: 使用自适应图标，主要内容放在中心 66% 区域

### Q: iOS 图标有白边？
A: 设置 `remove_alpha_ios: true`

### Q: 更新后图标未变化？
A: 运行 `flutter clean` 然后重新构建

---

**应用名称**: 行途 - 数字游民城市探索应用  
**主题色**: #FF4458  
**更新时间**: 2025-10-26
