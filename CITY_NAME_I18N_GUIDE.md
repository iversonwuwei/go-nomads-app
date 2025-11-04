# 城市名称国际化使用指南

## 快速开始

### 1. 在应用启动时加载城市名称映射

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'utils/city_name_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 加载城市名称映射（默认中文）
  await CityNameHelper.loadCityNames('zh');
  
  runApp(MyApp());
}
```

### 2. 在Widget中使用本地化城市名称

#### 方式1：使用LocalizedCityName Widget（推荐）

```dart
import 'package:flutter/material.dart';
import '../widgets/localized_city_name.dart';

class CityCard extends StatelessWidget {
  final String cityName; // API返回的英文名称，如 "Beijing"

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // 自动转换为本地化名称（中文环境显示"北京"）
          LocalizedCityName(
            cityName: cityName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 方式2：使用CityNameHelper直接转换

```dart
import '../utils/city_name_helper.dart';

// 在需要的地方直接转换
String apiCityName = 'Shanghai';
String displayName = CityNameHelper.getLocalizedCityName(apiCityName);
print(displayName); // 输出: 上海
```

#### 方式3：批量转换城市列表

```dart
import '../utils/city_name_helper.dart';

// API返回的城市列表
List<Map<String, dynamic>> cities = [
  {'id': '1', 'name': 'Beijing', 'country': 'China'},
  {'id': '2', 'name': 'Shanghai', 'country': 'China'},
];

// 批量添加本地化名称
List<Map<String, dynamic>> localizedCities = 
    CityNameHelper.localizeCityList(cities);

// 结果:
// [
//   {'id': '1', 'name': 'Beijing', 'country': 'China', 'localizedName': '北京'},
//   {'id': '2', 'name': 'Shanghai', 'country': 'China', 'localizedName': '上海'},
// ]
```

### 3. 语言切换

```dart
import '../utils/city_name_helper.dart';

// 切换到英文
await CityNameHelper.loadCityNames('en');

// 切换到中文
await CityNameHelper.loadCityNames('zh');

// 或者根据系统语言自动切换
final locale = Localizations.localeOf(context).languageCode;
await CityNameHelper.loadCityNames(locale);
```

## 实际应用示例

### 城市列表页面

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/city_controller.dart';
import '../widgets/localized_city_name.dart';

class CityListPage extends StatelessWidget {
  final controller = Get.find<CityController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('城市列表')),
      body: Obx(() => ListView.builder(
        itemCount: controller.cities.length,
        itemBuilder: (context, index) {
          final city = controller.cities[index];
          return ListTile(
            title: LocalizedCityName(
              cityName: city.name, // API返回的英文名称
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(city.country),
            leading: Icon(Icons.location_city),
            onTap: () => Get.to(() => CityDetailPage(cityId: city.id)),
          );
        },
      )),
    );
  }
}
```

### 城市详情页面

```dart
import 'package:flutter/material.dart';
import '../widgets/localized_city_name.dart';

class CityDetailPage extends StatelessWidget {
  final String cityName;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LocalizedCityName(
          cityName: cityName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 城市名称展示
            LocalizedCityName(
              cityName: cityName,
              style: TextStyle(fontSize: 24),
            ),
            // 其他内容...
          ],
        ),
      ),
    );
  }
}
```

### 搜索结果页面

```dart
import 'package:flutter/material.dart';
import '../utils/city_name_helper.dart';

class CitySearchResults extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final city = searchResults[index];
        final localizedName = CityNameHelper.getLocalizedCityName(
          city['name']
        );
        
        return ListTile(
          title: Text(localizedName),
          subtitle: Text('${city['country']} · ${city['region']}'),
        );
      },
    );
  }
}
```

## 性能优化建议

### 1. 预加载城市名称映射

```dart
// 在Splash Screen或首页加载时预加载
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 加载城市名称映射
    await CityNameHelper.loadCityNames(
      Localizations.localeOf(context).languageCode
    );
    
    // 其他初始化...
    
    // 跳转到主页
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

### 2. 使用同步版本Widget（性能更好）

```dart
// 确保已经加载过映射后，使用同步版本
LocalizedCityNameSync(
  cityName: 'Beijing',
  style: TextStyle(fontSize: 18),
)
```

## 常见问题

### Q1: 某个城市显示不了中文怎么办？

A: 检查 `/lib/l10n/city_names_zh.json` 文件中是否包含该城市的映射。如果没有，手动添加：

```json
{
  "cityNames": {
    "NewCityName": "新城市名称"
  }
}
```

### Q2: 如何添加其他语言支持？

A: 创建新的语言文件，如 `city_names_ja.json`（日语），然后在 `CityNameHelper.loadCityNames()` 中添加对应的逻辑。

### Q3: 语言切换后名称没有更新？

A: 调用 `CityNameHelper.clearCache()` 清除缓存，然后重新加载：

```dart
CityNameHelper.clearCache();
await CityNameHelper.loadCityNames('en');
```

## 测试

```dart
void testCityNameLocalization() async {
  // 加载中文映射
  await CityNameHelper.loadCityNames('zh');
  
  // 测试转换
  assert(CityNameHelper.getLocalizedCityName('Beijing') == '北京');
  assert(CityNameHelper.getLocalizedCityName('Shanghai') == '上海');
  
  // 测试不存在的城市（应返回原始名称）
  assert(CityNameHelper.getLocalizedCityName('UnknownCity') == 'UnknownCity');
  
  print('✅ 所有测试通过');
}
```

## 注意事项

1. ⚠️ 确保在使用 `LocalizedCityNameSync` 前已调用过 `loadCityNames()`
2. ⚠️ JSON文件必须放在 `lib/l10n/` 目录下
3. ⚠️ 需要在 `pubspec.yaml` 中声明 JSON 文件为资源：

```yaml
flutter:
  assets:
    - lib/l10n/city_names_zh.json
    - lib/l10n/city_names_en.json
```

## 相关文件

- `/lib/utils/city_name_helper.dart` - 城市名称辅助类
- `/lib/widgets/localized_city_name.dart` - 本地化Widget
- `/lib/l10n/city_names_zh.json` - 中文映射
- `/lib/l10n/city_names_en.json` - 英文映射
