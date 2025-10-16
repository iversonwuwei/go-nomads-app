# OSM 多地图源切换功能指南

## 概述

OSM 导航页面现已支持多个地图瓦片源，用户可以根据不同场景选择最适合的地图源。

## 支持的地图源

### 1. CartoDB Voyager (默认)
- **URL**: `https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png`
- **子域名**: a, b, c, d (负载均衡)
- **最大缩放级别**: 20
- **特点**:
  - 🌍 国际化友好，全球可用
  - ⚡ 服务器稳定，加载速度快
  - 🎨 设计清晰美观，适合路线导航
  - ✅ 无需 API Token
  - 📍 推荐作为默认选项

### 2. OpenStreetMap 官方
- **URL**: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- **子域名**: 无
- **最大缩放级别**: 19
- **特点**:
  - 🌐 OSM 官方瓦片服务器
  - 📖 开源社区维护
  - ⚠️ 可能有速率限制
  - ✅ 无需 API Token
  - 📍 适合作为备用选项

### 3. 高德地图 (Amap)
- **URL**: `https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}`
- **子域名**: 1, 2, 3, 4 (负载均衡)
- **最大缩放级别**: 18
- **特点**:
  - 🇨🇳 中国地区优化
  - 🚀 国内访问速度快
  - 🏙️ 中文标注详细准确
  - ✅ 无需 API Token (使用 Web 服务)
  - 📍 **强烈推荐中国用户使用**
  - ⚠️ 在中国大陆以外地区可能较慢

### 4. Mapbox Streets
- **URL**: `https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=...`
- **子域名**: 无
- **最大缩放级别**: 22
- **特点**:
  - 🎨 高质量矢量地图
  - 📐 最高缩放级别 (22)
  - 🔑 需要 API Token
  - ⚠️ 当前使用演示 Token (有使用限制)
  - 📍 适合需要高精度详细地图的场景
  - 💡 **建议**: 申请个人 Mapbox Token 以获得更好体验

## 使用方法

### 1. 切换地图源

在 OSM 导航页面中:

1. 点击右侧的 **地图源按钮** (图层图标 + 当前地图源名称)
2. 在弹出的底部菜单中选择想要的地图源
3. 地图会自动刷新并加载新的瓦片

### 2. 查看当前地图源

- 右侧按钮会显示当前使用的地图源名称
- 例如: "CartoDB"、"高德地图"、"Mapbox" 等

### 3. 地图源推荐

根据不同场景选择合适的地图源:

#### 🇨🇳 中国大陆用户
**推荐**: 高德地图
- 理由: 国内服务器，加载速度快，中文标注准确

#### 🌏 国际用户
**推荐**: CartoDB Voyager
- 理由: 全球服务稳定，设计清晰，适合导航

#### 📐 需要高精度地图
**推荐**: Mapbox Streets
- 理由: 最高缩放级别 (22)，矢量地图质量高
- 注意: 建议使用个人 API Token

#### 🔄 备用选项
**推荐**: OpenStreetMap 官方
- 理由: 开源可靠，无需 Token
- 注意: 可能有速率限制

## 技术实现

### 地图源配置结构

```dart
class MapTileConfig {
  final String name;              // 地图源名称
  final String urlTemplate;       // 瓦片 URL 模板
  final List<String>? subdomains; // 子域名 (负载均衡)
  final int maxZoom;              // 最大缩放级别
  final bool requiresApiKey;      // 是否需要 API Key
  final String? description;      // 描述信息
}
```

### 地图源枚举

```dart
enum MapTileSource {
  cartoDB,        // CartoDB Voyager
  openStreetMap,  // OSM 官方
  amap,           // 高德地图
  mapbox,         // Mapbox Streets
}
```

### 动态切换实现

地图使用当前选中的配置:

```dart
TileLayer(
  urlTemplate: _tileConfigs[_currentTileSource]!.urlTemplate,
  subdomains: _tileConfigs[_currentTileSource]!.subdomains ?? const [],
  maxZoom: _tileConfigs[_currentTileSource]!.maxZoom.toDouble(),
  userAgentPackageName: 'com.example.df_admin_mobile',
)
```

## Mapbox Token 配置

### 获取 Mapbox Token

1. 访问 [Mapbox 官网](https://www.mapbox.com/)
2. 注册账号 (免费)
3. 在 Dashboard 中创建 Access Token
4. 复制 Token

### 配置 Token

编辑 `lib/pages/osm_navigation_page.dart`:

```dart
static const Map<MapTileSource, MapTileConfig> _tileConfigs = {
  MapTileSource.mapbox: MapTileConfig(
    name: 'Mapbox',
    urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=YOUR_TOKEN_HERE',
    maxZoom: 22,
    requiresApiKey: true,
    description: '高质量矢量地图，最高缩放级别',
  ),
};
```

将 `YOUR_TOKEN_HERE` 替换为您的 Token。

### Mapbox 免费额度

- 每月 50,000 次地图加载
- 对于个人项目通常足够使用

## 性能优化

### 子域名负载均衡

CartoDB 和高德地图使用多个子域名:

```dart
subdomains: const ['a', 'b', 'c', 'd'],  // CartoDB
subdomains: const ['1', '2', '3', '4'],  // 高德
```

这样可以并行加载多个瓦片，提高加载速度。

### 缓存机制

`flutter_map` 会自动缓存已加载的瓦片，切换回之前使用过的地图源时会更快。

## 常见问题

### Q1: 切换地图源后地图变空白?

**原因**: 新地图源的瓦片正在加载

**解决**: 等待几秒，如果一直空白:
1. 检查网络连接
2. 尝试切换其他地图源
3. 对于 Mapbox，检查 Token 是否有效

### Q2: 高德地图在国外加载很慢?

**原因**: 高德服务器主要在中国大陆

**解决**: 
- 国际用户切换到 CartoDB 或 Mapbox
- 中国用户使用高德可获得最佳体验

### Q3: Mapbox 提示 Token 限制?

**原因**: 使用的是演示 Token，有使用限制

**解决**: 
1. 注册 Mapbox 账号获取个人 Token
2. 在代码中配置您的 Token
3. 或切换到其他无需 Token 的地图源

### Q4: 如何添加新的地图源?

1. 在 `MapTileSource` 枚举中添加新选项
2. 在 `_tileConfigs` 中添加对应配置
3. 配置 URL 模板、子域名等参数

示例 - 添加 Google Maps:

```dart
enum MapTileSource {
  // ... 现有选项
  googleMaps,  // 新增
}

static const Map<MapTileSource, MapTileConfig> _tileConfigs = {
  // ... 现有配置
  MapTileSource.googleMaps: MapTileConfig(
    name: 'Google Maps',
    urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
    subdomains: const ['0', '1', '2', '3'],
    maxZoom: 20,
    requiresApiKey: false,
    description: 'Google 地图瓦片',
  ),
};
```

## 未来改进

### 计划功能

- [ ] 记住用户选择的地图源 (使用 SharedPreferences)
- [ ] 根据地理位置自动选择最优地图源
- [ ] 添加更多地图样式 (卫星图、地形图等)
- [ ] 支持自定义地图源配置
- [ ] 地图源切换动画效果
- [ ] 显示地图源加载状态

### 可添加的地图源

- **卫星图**: Mapbox Satellite, Google Satellite
- **地形图**: OpenTopoMap, Thunderforest Outdoors
- **夜间模式**: CartoDB Dark Matter, Mapbox Dark
- **其他中国地图**: 腾讯地图、百度地图 (需要 API Key)

## 总结

多地图源功能让用户可以根据实际情况选择最合适的地图:
- 🇨🇳 **中国用户** → 高德地图 (速度快、中文准确)
- 🌏 **国际用户** → CartoDB (全球稳定)
- 📐 **高精度需求** → Mapbox (最高缩放)
- 🆓 **开源优先** → OpenStreetMap (官方开源)

简单易用的切换界面让用户可以轻松尝试不同地图源，找到最适合自己的选项!
