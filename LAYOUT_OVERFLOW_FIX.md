# 地图瓦片源选择器布局溢出修复

## ❌ 问题

运行应用后,点击地图页面左下角的瓦片源选择器时,出现布局溢出错误:

```
Exception caught by rendering library
A RenderFlex overflowed by 51 pixels on the bottom.
```

## ✅ 修复方案

将固定高度的 `Column` 改为可滚动的 `DraggableScrollableSheet` + `ListView`

### 修改前
```dart
Column(
  mainAxisSize: MainAxisSize.min,  // ❌ 内容多时溢出
  children: [
    Container(...),  // 标题
    ..._tileSources.entries.map(...),  // 6个ListTile
  ],
)
```

### 修改后
```dart
DraggableScrollableSheet(
  initialChildSize: 0.6,  // 初始高度 60%
  minChildSize: 0.4,      // 最小 40%
  maxChildSize: 0.8,      // 最大 80%
  builder: (context, scrollController) {
    return Column(
      children: [
        Container(...),  // 标题
        Expanded(
          child: ListView(  // ✅ 可滚动
            controller: scrollController,
            children: _tileSources.entries.map(...).toList(),
          ),
        ),
      ],
    );
  },
)
```

## 🎯 改进效果

- ✅ 所有 6 个瓦片源都能正常显示
- ✅ 可以滚动查看全部选项
- ✅ 可以拖动调整菜单高度
- ✅ 无布局溢出错误
- ✅ 适配不同屏幕尺寸

## 📝 修改文件

**lib/pages/global_map_page.dart:** Lines 132-238

热重载后生效! 🚀
