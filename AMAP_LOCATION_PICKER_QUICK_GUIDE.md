# 🗺️ 高德地图位置选择器 - 快速使用指南

## 🚀 快速开始

### 用户操作流程

1. **打开 City Detail 页面**
2. **点击右下角 "AI Travel Plan" 浮动按钮**
3. **在对话框中找到 "Departure Location"**
4. **点击地图图标按钮** 🗺️
5. **在地图上选择位置**：
   - 🎯 自动定位到当前位置
   - 👆 点击地图选择其他地点
   - 🔍 使用缩放按钮查看详情
6. **点击 "Confirm" 确认**
7. **位置自动填充到输入框**
8. **继续填写其他信息生成旅行计划**

## 📋 核心功能

| 功能 | 说明 | 图标 |
|------|------|------|
| 📍 **地图选择** | 点击地图任意位置选择 | 红色标记 |
| 🎯 **当前定位** | 自动获取GPS位置 | 📍 按钮 |
| 🔍 **缩放地图** | 放大缩小查看细节 | ➕ ➖ |
| 📊 **位置信息** | 显示地址和坐标 | 卡片展示 |
| ✅ **确认选择** | 携带数据返回 | Confirm 按钮 |

## 🎨 界面说明

### 顶部
- **返回按钮**: 取消选择，返回上一页
- **标题**: "Select Location"
- **确认按钮**: 确认选中的位置

### 中间
- **位置信息卡片**: 显示选中地址和坐标
- **地图主体**: 高德地图展示
- **红色标记**: 指示选中位置

### 底部
- **提示文字**: "Tap on the map to select a location"
- **定位按钮**: 获取当前GPS位置
- **缩放按钮**: 放大/缩小地图

## ⚙️ 快速配置

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 配置高德地图 API Key

#### Android
在 `android/app/src/main/AndroidManifest.xml` 添加：
```xml
<meta-data
    android:name="com.amap.api.v2.apikey"
    android:value="你的Android Key"/>
```

#### iOS
在 `ios/Runner/AppDelegate.swift` 添加：
```swift
AMapServices.shared().apiKey = "你的iOS Key"
```

### 3. 配置权限

#### Android
`android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### iOS
`ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要获取您的位置以显示地图</string>
```

## 💡 使用技巧

### 快速选择
1. **当前位置**: 打开页面会自动定位
2. **点击选择**: 轻触地图任意位置
3. **精准定位**: 放大地图选择准确位置

### 地图操作
- **单击**: 选择位置
- **双击**: 放大地图
- **双指缩放**: 精确调整视野
- **拖动**: 移动地图

### 位置确认
1. 查看顶部位置信息卡片
2. 确认地址和坐标正确
3. 点击 "Confirm" 按钮

## 🔧 故障排除

### 地图不显示
- 检查 API Key 是否配置
- 确认网络连接正常
- 查看控制台错误信息

### 无法定位
- 检查位置权限是否授予
- 确认 GPS 已开启
- 尝试手动点击定位按钮

### 标记不显示
- 确认已点击地图
- 检查选中位置是否有效
- 尝试重新选择位置

## 📱 返回数据

选择位置后返回的数据结构：

```dart
{
  'address': '北京市朝阳区...',  // 地址描述
  'latitude': 39.909187,         // 纬度
  'longitude': 116.397451,       // 经度
  'city': '北京市',               // 城市
  'province': '北京市',           // 省份
}
```

## 🎯 后续增强

即将推出的功能：
- 🔍 地点搜索
- ⭐ 收藏常用位置
- 📝 历史记录
- 🎨 地图样式切换
- 🚗 路线预览

## 🔗 相关文档

- 📖 [完整功能文档](./AMAP_LOCATION_PICKER_FEATURE.md)
- 🎨 [设计规范](./DESIGN_SYSTEM_GUIDE.md)
- 🚀 [快速入门](./QUICK_START.md)

## 📞 获取帮助

遇到问题？查看：
1. [常见问题解决](./AMAP_LOCATION_PICKER_FEATURE.md#🐛-常见问题解决)
2. [高德地图文档](https://lbs.amap.com/api/flutter/summary)
3. 项目 Issue 列表

---

**版本**: 1.0.0  
**更新**: 2025-10-11  
**快速使用，精准定位！** 🗺️✨
