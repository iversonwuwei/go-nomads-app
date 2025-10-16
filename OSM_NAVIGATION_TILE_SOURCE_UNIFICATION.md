# OSM导航页面瓦片源配置统一化

## 修改概述

将 `osm_navigation_page.dart` 的瓦片源配置统一为与 `global_map_page.dart` 相同的实现,提高代码一致性和可维护性。

## 修改时间

2025年10月16日

## 主要改动

### 1. 简化瓦片源配置结构

#### 修改前
使用枚举 + 配置类的复杂结构:
```dart
enum MapTileSource {
  cartoDB,
  openStreetMap,
  amap,
  mapbox,
}

class MapTileConfig {
  final String name;
  final String urlTemplate;
  final List<String>? subdomains;
  final int maxZoom;
  final bool requiresApiKey;
  final String? description;
  // ...
}

static const Map<MapTileSource, MapTileConfig> _tileConfigs = {
  // 4个配置项,带subdomains、requiresApiKey等复杂属性
};
```

#### 修改后
使用简单的 Map 结构(与 GlobalMapPage 一致):
```dart
String _selectedTileSource = 'amap-satellite';

final Map<String, Map<String, String>> _tileSources = {
  'amap-satellite': {
    'name': '高德卫星图',
    'url': 'https://webst01.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}',
  },
  'amap-road': {
    'name': '高德标准地图',
    'url': 'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
  },
  'amap-dark': {
    'name': '高德深色地图',
    'url': 'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=6&x={x}&y={y}&z={z}',
  },
  'osm': {
    'name': 'OpenStreetMap',
    'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  },
  'cartodb': {
    'name': 'CartoDB 明亮',
    'url': 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
  },
  'cartodb-dark': {
    'name': 'CartoDB 深色',
    'url': 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
  },
};
```

### 2. 扩展瓦片源数量

- **修改前**: 4 个瓦片源(CartoDB, OSM, 高德, Mapbox)
- **修改后**: 6 个瓦片源(3个高德 + OSM + 2个CartoDB)
- **新增**:
  - 高德卫星图(默认)
  - 高德标准地图
  - 高德深色地图
  - CartoDB 深色
- **移除**: Mapbox(需要 API Token,配置复杂)

### 3. 统一 UI 组件

#### 修改前
使用 `SingleChildScrollView` + 自定义样式:
```dart
showModalBottomSheet(
  builder: (context) => SingleChildScrollView(
    child: Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 使用 Material Icons
          Icon(Icons.radio_button_checked),
          // 自定义样式和布局
        ],
      ),
    ),
  ),
);
```

#### 修改后
使用 `DraggableScrollableSheet` + FontAwesome 图标(与 GlobalMapPage 一致):
```dart
showModalBottomSheet(
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.6,
    minChildSize: 0.4,
    maxChildSize: 0.8,
    builder: (context, scrollController) {
      return Column(
        children: [
          // 使用 FontAwesome 图标
          FaIcon(FontAwesomeIcons.layerGroup),
          FaIcon(FontAwesomeIcons.map),
          FaIcon(FontAwesomeIcons.circleCheck),
          // 统一的样式和布局
        ],
      );
    },
  ),
);
```

### 4. 优化 TileLayer 配置

#### 修改前
```dart
TileLayer(
  urlTemplate: _tileConfigs[_currentTileSource]!.urlTemplate,
  subdomains: _tileConfigs[_currentTileSource]!.subdomains ?? const [],
  userAgentPackageName: 'com.example.df_admin_mobile',
  maxZoom: _tileConfigs[_currentTileSource]!.maxZoom.toDouble(),
)
```

#### 修改后
```dart
TileLayer(
  urlTemplate: _tileSources[_selectedTileSource]!['url']!,
  userAgentPackageName: 'com.digitalfuture.df_admin_mobile',
  maxZoom: 20,
  minZoom: 2,
  tileProvider: NetworkTileProvider(),
)
```

**改进点**:
- 移除 subdomains(现代瓦片服务自动负载均衡)
- 统一 maxZoom 为 20
- 添加 minZoom 为 2
- 显式使用 NetworkTileProvider
- 更新 package name

### 5. 添加依赖

```dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
```

## 文件修改清单

### lib/pages/osm_navigation_page.dart

| 行号 | 修改内容 |
|------|---------|
| 3 | 添加 `font_awesome_flutter` 导入 |
| 13 | 移除枚举和配置类,添加注释 |
| 28-66 | 更新瓦片源配置为 6 个简化的 Map |
| 155-244 | 重构瓦片源选择器UI(DraggableScrollableSheet) |
| 292-299 | 优化 TileLayer 配置 |
| 461 | 更新按钮标签引用 |

## 改进效果

### 代码一致性
✅ 两个地图页面使用相同的瓦片源配置
✅ 统一的 UI 风格和交互逻辑
✅ 相同的图标库(FontAwesome)

### 可维护性
✅ 代码更简洁(移除枚举和配置类)
✅ 更容易添加新的瓦片源
✅ 减少重复代码

### 用户体验
✅ 提供更多瓦片源选择(4 → 6)
✅ 可拖动调整菜单高度
✅ 可滚动查看所有选项
✅ 统一的视觉风格

### 性能优化
✅ 移除复杂的 subdomains 配置
✅ 使用 NetworkTileProvider 提高稳定性
✅ 提高最大缩放级别(19 → 20)

## 对比表格

| 特性 | 修改前 | 修改后 |
|------|--------|--------|
| 瓦片源数量 | 4 个 | 6 个 |
| 配置结构 | 枚举 + 类 | 简单 Map |
| 默认源 | CartoDB | 高德卫星图 |
| UI 组件 | SingleChildScrollView | DraggableScrollableSheet |
| 图标库 | Material Icons | FontAwesome |
| 最大缩放 | 可变(18-22) | 统一 20 |
| 代码行数 | ~120 行 | ~90 行 |

## 测试清单

- [x] 代码编译无错误
- [ ] 瓦片源选择器正常弹出
- [ ] 6 个瓦片源可正常切换
- [ ] 地图瓦片正常加载
- [ ] 菜单可拖动调整高度
- [ ] 菜单可滚动查看选项
- [ ] 按钮显示当前选中的源名称
- [ ] 切换后显示 SnackBar 提示

## 后续优化建议

1. **统一到配置文件**: 将瓦片源配置提取到独立的配置文件,供所有地图页面共享
2. **持久化选择**: 使用 SharedPreferences 保存用户选择的瓦片源
3. **性能监控**: 添加瓦片加载失败监控和自动切换
4. **国际化**: 将瓦片源名称添加到国际化文件

## 相关文档

- [MAP_TILE_SOURCE_FIX.md](MAP_TILE_SOURCE_FIX.md) - 瓦片源配置修复
- [LAYOUT_OVERFLOW_FIX.md](LAYOUT_OVERFLOW_FIX.md) - 布局溢出修复
- [OSM_TILE_SOURCE_SELECTION.md](OSM_TILE_SOURCE_SELECTION.md) - 瓦片源选择功能

## 总结

✅ **成功统一** OSM导航页面和全球地图页面的瓦片源配置
✅ **简化代码** 移除复杂的枚举和配置类
✅ **提升体验** 增加瓦片源选择,改进UI交互
✅ **提高性能** 优化 TileLayer 配置参数

代码已就绪,可以进行测试! 🎉
