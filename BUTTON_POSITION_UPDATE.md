# 添加按钮位置更新

## 更新内容

已将 City Detail 页面所有 tab 中的浮动添加按钮从右侧移动到左侧。

## 修改的按钮

✅ **所有 7 个浮动添加按钮位置已更新**

### 修改前
- 位置：`right: 16` （右下角）

### 修改后  
- 位置：`left: 16` （左下角）

### 受影响的 Tab

1. ✅ **Scores** - 评分分享按钮
2. ✅ **Guide** - 指南分享按钮
3. ✅ **Pros & Cons** - 优缺点分享按钮
4. ✅ **Reviews** - 评论分享按钮
5. ✅ **Cost** - 费用分享按钮
6. ✅ **Photos** - 照片上传按钮
7. ✅ **Neighborhoods** - 社区信息分享按钮

## 视觉效果

所有添加按钮现在显示在页面的**左下角**，距离底部和左侧各 16px。

## 技术细节

```dart
// 修改前
Positioned(
  bottom: 16,
  right: 16,  // ❌ 旧位置
  child: FloatingActionButton(...)
)

// 修改后
Positioned(
  bottom: 16,
  left: 16,   // ✅ 新位置
  child: FloatingActionButton(...)
)
```

## 编译状态

✅ 无编译错误  
✅ 所有功能正常  
✅ 7 个按钮位置已统一更新

## 注意事项

- 按钮的颜色、图标、功能保持不变
- 仅调整了水平位置（从右到左）
- 垂直位置保持不变（bottom: 16）
- AI Travel Plan 按钮仍保持在右下角（该按钮位于页面级别，不在 tab 内）
