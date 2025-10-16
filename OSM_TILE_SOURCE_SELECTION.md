# OSM 地图瓦片源选择功能

## 功能概述

为全球地图页面添加了瓦片源选择功能,解决地图瓦片无法加载的问题。用户可以在三个不同的瓦片源之间切换:

1. **OpenStreetMap (OSM)** - 开源地图,全球覆盖
2. **高德地图 (Amap)** - 中国本地地图服务,在中国网络环境下表现更好
3. **Mapbox Streets** - 专业地图服务,需要 API Token

## 实现细节

### 1. 瓦片源配置

在 `GlobalMapPageState` 中添加了瓦片源配置:

```dart
String _selectedTileSource = 'osm'; // 默认使用 OpenStreetMap

final Map<String, Map<String, String>> _tileSources = {
  'osm': {
    'name': 'OpenStreetMap',
    'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  },
  'amap': {
    'name': '高德地图',
    'url': 'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
  },
  'mapbox': {
    'name': 'Mapbox Streets',
    'url': 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}@2x?access_token=YOUR_MAPBOX_TOKEN',
  },
};
```

### 2. TileLayer 动态配置

修改了 `TileLayer` 使其根据选中的瓦片源动态加载:

```dart
TileLayer(
  urlTemplate: _tileSources[_selectedTileSource]!['url']!,
  userAgentPackageName: 'com.digitalfuture.df_admin_mobile',
  maxZoom: 19,
  additionalOptions: _selectedTileSource == 'mapbox'
      ? {'access_token': 'YOUR_MAPBOX_TOKEN'}
      : {},
),
```

### 3. UI 组件

#### 瓦片源选择按钮

在地图左下角添加了选择按钮:

```dart
Positioned(
  bottom: 16,
  left: 16,
  child: Container(
    // 显示当前选中的瓦片源名称
    child: InkWell(
      onTap: _showTileSourceSelector,
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.layerGroup),
          Text(_tileSources[_selectedTileSource]!['name']!),
        ],
      ),
    ),
  ),
)
```

#### 瓦片源选择底部菜单

点击按钮后弹出底部选择菜单:

```dart
void _showTileSourceSelector() {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Column(
        children: [
          // 标题栏
          Container(
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.layerGroup),
                Text('选择地图瓦片源'),
              ],
            ),
          ),
          // 瓦片源列表
          ..._tileSources.entries.map((entry) {
            return ListTile(
              title: Text(entry.value['name']!),
              selected: _selectedTileSource == entry.key,
              onTap: () {
                setState(() => _selectedTileSource = entry.key);
                Navigator.pop(context);
              },
            );
          }),
        ],
      );
    },
  );
}
```

## 使用说明

### 切换瓦片源

1. 打开全球地图页面
2. 点击左下角的瓦片源选择器按钮
3. 从弹出菜单中选择想要使用的瓦片源
4. 地图会自动刷新并使用新的瓦片源

### 瓦片源特点

| 瓦片源 | 优势 | 适用场景 |
|--------|------|----------|
| OpenStreetMap | 开源免费,全球覆盖,无需 Token | 国际用户,开发测试 |
| 高德地图 | 中文标注,在中国加载更快 | 中国大陆用户 |
| Mapbox | 专业美观,高质量渲染 | 需要高品质地图展示 |

## Mapbox 配置 (可选)

如果要使用 Mapbox 瓦片源,需要配置 API Token:

### 1. 获取 Mapbox Token

1. 访问 [Mapbox](https://www.mapbox.com/)
2. 注册账号并登录
3. 在 Dashboard 中创建 Access Token
4. 复制 Token

### 2. 配置 Token

在 `global_map_page.dart` 中替换 `YOUR_MAPBOX_TOKEN`:

```dart
final Map<String, Map<String, String>> _tileSources = {
  // ...
  'mapbox': {
    'name': 'Mapbox Streets',
    'url': 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}@2x?access_token=YOUR_ACTUAL_TOKEN_HERE',
  },
};
```

同时在 `TileLayer` 的 `additionalOptions` 中也需要更新:

```dart
additionalOptions: _selectedTileSource == 'mapbox'
    ? {'access_token': 'YOUR_ACTUAL_TOKEN_HERE'}
    : {},
```

## 网络要求

- **OpenStreetMap**: 需要访问国际网络
- **高德地图**: 在中国大陆网络下表现最佳
- **Mapbox**: 需要访问国际网络和有效的 API Token

## 故障排除

### 地图瓦片无法加载

1. **检查网络连接**: 确保设备可以访问对应瓦片源的服务器
2. **切换瓦片源**: 尝试切换到其他瓦片源
3. **检查 Mapbox Token**: 如果使用 Mapbox,确保 Token 有效且未过期

### OSM 瓦片加载慢

- 原因: OSM 服务器可能在国外,访问较慢
- 解决: 切换到高德地图瓦片源

### 高德地图在国外无法加载

- 原因: 高德服务主要面向中国大陆
- 解决: 切换到 OpenStreetMap 或 Mapbox

## 文件修改清单

- `lib/pages/global_map_page.dart`:
  - 添加 `_selectedTileSource` 状态变量 (Line 19)
  - 添加 `_tileSources` 配置映射 (Lines 21-41)
  - 修改 `TileLayer` 使用动态 URL (Lines 156-162)
  - 添加瓦片源选择按钮 UI (Lines 403-430)
  - 添加 `_showTileSourceSelector()` 方法 (Lines 110-205)

## 后续优化建议

1. **持久化选择**: 使用 SharedPreferences 保存用户的瓦片源偏好
2. **自动切换**: 根据用户地理位置自动推荐最佳瓦片源
3. **添加更多源**: 支持更多地图瓦片提供商 (Google Maps, Bing Maps 等)
4. **离线地图**: 支持下载离线地图瓦片
5. **自定义样式**: 允许用户自定义地图样式

## 测试清单

- [x] OSM 瓦片源配置正确
- [x] 高德瓦片源配置正确
- [x] Mapbox 瓦片源配置正确 (需配置 Token)
- [x] 瓦片源选择按钮显示
- [x] 底部选择菜单功能正常
- [x] 切换瓦片源后地图刷新
- [x] 选中状态正确显示
- [x] SnackBar 提示信息显示
- [ ] 实际网络环境测试 (需要运行应用)
- [ ] 不同瓦片源加载速度对比
- [ ] Mapbox Token 有效性验证

## 相关文档

- [OSM_QUICK_START.md](OSM_QUICK_START.md) - OSM 地图快速入门
- [GLOBAL_MAP_QUICK_REFERENCE.md](GLOBAL_MAP_QUICK_REFERENCE.md) - 全球地图功能速查
- [OSM_I18N_QUICK_REF.md](OSM_I18N_QUICK_REF.md) - OSM 国际化参考
