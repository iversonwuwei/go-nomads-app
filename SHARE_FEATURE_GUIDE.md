# 分享功能使用指南

## 功能概述

已为应用添加完整的分享功能，支持分享到国内外主流社交平台。

## 已实现的页面

### 1. 城市详情页 (`city_detail_page.dart`)
- 点击右上角的分享按钮
- 分享城市信息，包括城市名称、描述和链接

### 2. Meetup 详情页 (`meetup_detail_page.dart`)
- 点击右上角的分享按钮
- 分享聚会活动信息，包括时间、地点、组织者和描述

## 支持的分享平台

### 国际平台
- **系统分享**: 调用系统原生分享菜单
- **复制链接**: 快速复制分享链接
- **Twitter**: 直接分享到 Twitter
- **Facebook**: 直接分享到 Facebook
- **WhatsApp**: 通过 WhatsApp 分享
- **Telegram**: 通过 Telegram 分享
- **Reddit**: 发布到 Reddit
- **LinkedIn**: 分享到 LinkedIn
- **邮件**: 通过邮件分享

### 国内平台
- **微信**: 通过系统分享菜单选择微信（需要安装微信客户端）
- **微博**: 直接分享到微博
- **QQ**: 通过系统分享菜单选择 QQ（需要安装 QQ 客户端）

## 技术实现

### 核心文件

1. **`lib/widgets/share_bottom_sheet.dart`**
   - 分享底部抽屉组件
   - 提供统一的分享 UI 和逻辑

2. **依赖包**
   - `share_plus: ^10.1.2` - 系统分享功能
   - `url_launcher` - 打开外部 URL（已有）

### 使用方法

在任何页面调用分享功能：

```dart
import 'package:df_admin_mobile/widgets/share_bottom_sheet.dart';

// 显示分享底部抽屉
ShareBottomSheet.show(
  context,
  title: '分享标题',
  description: '分享描述',
  imageUrl: '可选的图片URL',  // 可选
  shareUrl: '分享链接',
);
```

### 扩展到其他页面

要在其他页面添加分享功能：

1. 导入 `ShareBottomSheet`：
```dart
import 'package:df_admin_mobile/widgets/share_bottom_sheet.dart';
```

2. 添加分享按钮（通常在 AppBar）：
```dart
IconButton(
  icon: Icon(FontAwesomeIcons.shareNodes),
  onPressed: () {
    ShareBottomSheet.show(
      context,
      title: '您的标题',
      description: '您的描述',
      shareUrl: '您的链接',
    );
  },
)
```

## 平台特定配置

### iOS 配置

在 `ios/Runner/Info.plist` 中添加（如果尚未添加）：

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>weixin</string>
    <string>wechat</string>
    <string>sinaweibo</string>
    <string>mqq</string>
    <string>mqqapi</string>
    <string>telprompt</string>
    <string>whatsapp</string>
    <string>telegram</string>
</array>
```

### Android 配置

在 `android/app/src/main/AndroidManifest.xml` 中确保有网络权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 功能特点

### 1. 底部抽屉设计
- 美观的 Material Design 底部抽屉
- 支持拖动关闭
- 图标化的分享选项

### 2. 多平台支持
- 优雅处理不同平台的分享方式
- 对于需要 SDK 的平台（微信、QQ），优雅降级到系统分享

### 3. 错误处理
- 完善的错误提示
- 检查 URL 是否可以打开
- 用户友好的反馈信息

### 4. 灵活扩展
- 易于添加新的分享平台
- 可自定义分享内容格式
- 支持图片分享（预留接口）

## 未来优化建议

1. **集成官方 SDK**
   - 微信 SDK：实现原生微信分享
   - QQ SDK：实现原生 QQ 分享
   - 微博 SDK：增强微博分享功能

2. **分享统计**
   - 追踪分享次数
   - 分析热门分享渠道
   - 优化分享内容

3. **图片分享**
   - 生成带二维码的分享图片
   - 支持分享时附带图片
   - 优化移动端图片展示

4. **深度链接**
   - 实现 App Deep Link
   - 支持直接打开应用内页面
   - 提升用户体验

## 测试建议

1. **功能测试**
   - 测试每个社交平台的分享功能
   - 验证分享内容格式是否正确
   - 检查链接是否可以正常打开

2. **兼容性测试**
   - iOS 和 Android 平台测试
   - 不同版本系统测试
   - 有/无安装社交应用的情况

3. **用户体验测试**
   - 分享流程是否流畅
   - 错误提示是否清晰
   - UI 是否美观易用

## 常见问题

**Q: 微信/QQ 分享没有反应？**
A: 确保设备上已安装相应的应用，系统分享菜单会自动列出可用的应用。

**Q: 如何自定义分享链接？**
A: 修改调用 `ShareBottomSheet.show()` 时传入的 `shareUrl` 参数。

**Q: 可以添加更多社交平台吗？**
A: 可以，在 `share_bottom_sheet.dart` 中添加新的 `_buildShareOption` 即可。

**Q: 分享失败怎么办？**
A: 检查网络连接，确保 URL 格式正确，并查看控制台错误信息。
