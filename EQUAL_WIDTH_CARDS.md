# 卡片等宽布局说明 📐

## 📋 设计调整

将两个 CTA 卡片设置为**完全相同的宽度**，不使用动画效果。

## 🎯 实现方式

### 使用 `Expanded` Widget

```dart
Row(
  children: [
    Expanded(child: _buildActionCard(...)), // 左侧卡片
    SizedBox(width: 16),                     // 固定间距
    Expanded(child: _buildActionCard(...)), // 右侧卡片
  ],
)
```

### 工作原理

- **`Expanded`**: 让子 widget 占据 Row 中的可用空间
- **默认 flex = 1**: 两个 Expanded 都是 flex: 1，所以占据相同宽度
- **`SizedBox`**: 提供固定的 12px（移动端）或 16px（桌面端）间距

## ✅ 效果

```
┌──────────────────┐  ┌──────────────────┐
│                  │  │                  │
│   Cities Card    │  │  Coworking Card  │
│                  │  │                  │
│   (50% - 8px)    │  │   (50% - 8px)    │
│                  │  │                  │
└──────────────────┘  └──────────────────┘
     相等宽度              相等宽度
```

## 📱 响应式

- **移动端**: 两个卡片各占约 50% 宽度，间距 12px
- **桌面端**: 容器宽度 600px，两个卡片各占约 292px，间距 16px

## 🔧 代码位置

**文件**: `lib/pages/data_service_page.dart`  
**方法**: `_buildTrapezoidButtons()` (Line ~260)

---

**更新日期**: 2025-10-13  
**状态**: ✅ 已完成
