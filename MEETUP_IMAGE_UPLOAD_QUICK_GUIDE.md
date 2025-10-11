# 📸 Meetup 图片上传 - 快速使用指南

## 🚀 快速开始

### 用户操作流程

1. **打开创建 Meetup 页面**
2. **填写基本信息**（标题、类型、城市等）
3. **滚动到 "Venue Photos" 区域**
4. **添加场地图片**：
   - 点击 "Add Venue Photos" 大区域（无图片时）
   - 或点击网格中的 "Add Photo" 按钮（已有图片时）
5. **选择图片来源**：
   - 📷 **从相册选择** - 可多选（最多 10 张）
   - 📸 **使用相机拍摄** - 拍摄新照片
6. **管理图片**：
   - 点击右上角 ❌ 删除不需要的图片
   - 第一张图片会自动标记为 "Cover" 封面
7. **提交创建** Meetup

## 📋 功能亮点

| 功能 | 描述 |
|------|------|
| 📱 多图上传 | 最多 10 张图片 |
| 🎯 智能压缩 | 1920x1080, 85% 质量 |
| 🖼️ 封面标记 | 第一张自动设为封面 |
| 🗑️ 快速删除 | 点击图片右上角删除 |
| 📸 双重来源 | 相册 + 相机 |
| 💡 实时预览 | 3 列网格布局 |

## ⚙️ 技术细节

### 依赖包
```yaml
image_picker: ^1.0.7
```

### 权限配置

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以上传场地照片</string>
<key>NSCameraUsageDescription</key>
<string>需要访问相机以拍摄场地照片</string>
```

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

## 💡 最佳实践

### 用户建议
1. 📷 上传清晰的场地照片
2. 🏞️ 横向拍摄效果更佳
3. 🌟 建议至少 3-5 张图片
4. 🎯 第一张作为封面，选择最佳照片

### 开发建议
1. 图片自动压缩优化存储
2. 限制最多 10 张防止滥用
3. 使用封面标记提升用户体验
4. 底部菜单清晰展示选项

## 🔗 相关文档

- 📖 [完整功能文档](./MEETUP_IMAGE_UPLOAD_FEATURE.md)
- 🎨 [UI 设计规范](./DESIGN_SYSTEM_GUIDE.md)
- 🚀 [快速入门](./QUICK_START.md)

## 📝 更新记录

- **v1.0.0** (2025-10-10) - 初始版本发布

---

**快速问题？** 查看 [完整文档](./MEETUP_IMAGE_UPLOAD_FEATURE.md) 获取详细说明。
