# TOOLS.md - Local Notes

## 开发环境

- Flutter SDK: 3.x, Dart SDK `>=3.4.0 <4.0.0`
- 状态管理: GetX
- 包管理: `flutter pub get`
- 构建: `flutter build apk` / `flutter build ios`

## 常用命令

```bash
# 开发运行
flutter run

# 生成国际化文件
flutter gen-l10n

# 清理缓存
flutter clean && flutter pub get

# 分析
flutter analyze
```

## API 环境切换

- 编辑 `lib/config/api_config.dart`
- `kIsProduction = true/false`
- `deploymentEnvironment` = docker / k8s / direct
- 真机调试: `usePhysicalDevice = true`, IP `192.168.110.67`

## 社交登录配置

- 微信: fluwx（需配置 AppID）
- QQ: tencent_kit
- Google: google_sign_in
- Apple: sign_in_with_apple

## OpenClaw Local Commands

### POI Search

- AMap Web key is already configured locally for OpenClaw POI lookups.
- Use the bundled local CLI first, not external web search.

```bash
python3 ~/.openclaw/skills/poi-discovery-guide/amap_poi.py geo "上海静安寺"
python3 ~/.openclaw/skills/poi-discovery-guide/amap_poi.py around --location 121.4454,31.2297 --keywords 咖啡 --radius 1000 --limit 5 --output markdown
python3 ~/.openclaw/skills/poi-discovery-guide/amap_poi.py text "联合办公" --city 上海 --limit 5 --output markdown
```

### Flight Search

- Use the local `flight-search` tool before any web-search fallback.

```bash
uvx flight-search SHA TYO --date 2026-03-09 --limit 3 --output json
```
