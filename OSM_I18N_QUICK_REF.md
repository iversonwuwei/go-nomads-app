# OSM 国际化快速参考

## 新添加的翻译键列表

### 地图源相关
```dart
l10n.selectMapSource              // "选择地图源" / "Select Map Source"
l10n.switchedToMapSource(name)    // "已切换到 {name}" / "Switched to {name}"
l10n.mapboxTokenWarning           // Mapbox Token 警告
```

### POI 对话框
```dart
l10n.distanceFrom(placeName)      // "距离 {placeName}" / "Distance from {placeName}"
l10n.longitude                    // "经度" / "Longitude"
l10n.latitude                     // "纬度" / "Latitude"
l10n.close                        // "关闭" / "Close"
l10n.viewOnMap                    // "在地图上查看" / "View on Map"
l10n.tapMarkersTip               // 点击标记提示
```

### 距离单位
```dart
l10n.meters(count)                // "{count}米" / "{count}m"
l10n.kilometers(count)            // "{count}公里" / "{count}km"
```

### 已有键（复用）
```dart
l10n.transit                      // "交通" / "Transit"
l10n.accommodation               // "住宿" / "Accommodation"
l10n.restaurant                  // "餐饮" / "Restaurant"
l10n.recenter                    // "回到中心" / "Recenter"
l10n.startNavigation             // "开始导航" / "Start Navigation"
l10n.noMapAppAvailable           // "未找到可用的地图应用"
```

## 使用示例

### 获取 l10n 实例
```dart
final l10n = AppLocalizations.of(context)!;
```

### 简单翻译
```dart
Text(l10n.longitude)          // 显示 "经度" 或 "Longitude"
```

### 参数化翻译
```dart
Text(l10n.distanceFrom(spaceName))     // "距离 WeWork" 或 "Distance from WeWork"
AppToast.success(l10n.switchedToMapSource(name))  // 成功提示
```

### 距离显示
```dart
if (meters < 1000) {
  return l10n.meters(meters.toStringAsFixed(0));
} else {
  return l10n.kilometers((meters / 1000).toStringAsFixed(1));
}
```

## 文件位置

- 中文翻译: `lib/l10n/app_zh.arb`
- 英文翻译: `lib/l10n/app_en.arb`
- 生成代码: `lib/generated/l10n/`

## 添加新语言

1. 创建新 ARB 文件 (如 `app_ja.arb`)
2. 复制所有键并翻译
3. 运行 `flutter gen-l10n`
4. 完成！
