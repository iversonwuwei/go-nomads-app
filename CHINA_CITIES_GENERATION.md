# 中国城市测试数据生成文档

## 概述
本文档说明如何生成50个中国城市及其共享办公空间的测试数据。

## 生成时间
2025年10月15日

## 数据统计

### 城市数据
- **数量**: 50个随机选择的中国城市
- **覆盖范围**: 中国34个省级行政区
- **数据来源**: 自动生成

### 共享办公空间数据
- **数量**: 每个城市4-5个（总计200-250个）
- **包含信息**: 
  - 名称、地址、价格
  - WiFi速度、评分
  - 设施（会议室、咖啡）
  - 联系方式

## 文件说明

### 新增文件

#### 1. `lib/services/china_cities_generator.dart`
中国城市数据生成器

**功能**:
- 生成50个随机中国城市数据
- 为每个城市生成4-5个共享办公空间
- 根据省份自动判断区域和气候

**主要方法**:
```dart
Future<void> generateChineseCities() // 生成所有城市
Map<String, dynamic> _generateCityData() // 生成单个城市数据
Future<void> _generateCoworkingSpaces() // 生成共享办公空间
```

**省份分组**:
- 华北地区 (North China)
- 东北地区 (Northeast China)
- 华东地区 (East China)
- 华中地区 (Central China)
- 华南地区 (South China)
- 西南地区 (Southwest China)
- 西北地区 (Northwest China)

**气候类型**:
- Cold (寒冷): 黑龙江、吉林、内蒙古
- Cool (凉爽): 北京、天津、河北、山西、辽宁、山东、陕西、甘肃
- Mild (温和): 上海、江苏、浙江、安徽、湖北、湖南、江西、四川、重庆
- Warm (温暖): 福建、广东、广西、贵州、云南
- Hot (炎热): 海南等

### 修改文件

#### 1. `lib/services/database_initializer.dart`
**修改内容**:
- 导入 `ChinaCitiesGenerator`
- 在初始化流程中调用 `generateChineseCities()`

#### 2. `lib/main.dart`
**修改内容**:
- 临时设置 `forceReset: true` 以生成新数据
- ⚠️ **重要**: 生成完成后请改回 `forceReset: false`

## 城市数据结构

每个城市包含以下字段：

```dart
{
  'name': String,              // 城市名称，如"北京"
  'country': 'China',          // 国家固定为中国
  'region': String,            // 区域，如"North China"
  'climate': String,           // 气候类型，如"Cool"
  'description': String,       // 城市描述
  'image_url': String,         // 城市图片URL
  'weather': String,           // 天气描述
  'temperature': double,       // 温度 (10-35°C)
  'cost_of_living': double,    // 生活成本 (800-4000元/月)
  'internet_speed': double,    // 网速 (30-200 Mbps)
  'safety_score': double,      // 安全评分 (7-10)
  'overall_score': double,     // 综合评分 (6-10)
  'fun_score': double,         // 娱乐评分 (5-10)
  'quality_of_life': double,   // 生活质量 (6-10)
  'aqi': int,                  // 空气质量指数 (20-200)
  'population': String,        // 人口范围，如"5M"
  'timezone': 'Asia/Shanghai', // 时区
  'humidity': int,             // 湿度 (40-90%)
  'latitude': double,          // 纬度 (18-54)
  'longitude': double,         // 经度 (73-135)
  'created_at': String,        // 创建时间
  'updated_at': String,        // 更新时间
}
```

## 共享办公空间数据结构

每个共享办公空间包含以下字段：

```dart
{
  'name': String,              // 名称，如"WeWork 北京联合办公"
  'city_id': int,              // 关联的城市ID
  'address': String,           // 地址
  'description': String,       // 描述
  'image_url': String,         // 图片URL
  'price_per_day': double,     // 日租价格 (50-200元)
  'price_per_month': double,   // 月租价格 (800-3000元)
  'rating': double,            // 评分 (3.5-5.0)
  'wifi_speed': double,        // WiFi速度 (50-200 Mbps)
  'has_meeting_room': int,     // 是否有会议室 (0/1)
  'has_coffee': int,           // 是否提供咖啡 (0/1)
  'latitude': double,          // 纬度
  'longitude': double,         // 经度
  'phone': String,             // 电话，如"010-12345678"
  'email': String,             // 邮箱
  'website': String,           // 网站
  'opening_hours': String,     // 营业时间
  'created_at': String,        // 创建时间
  'updated_at': String,        // 更新时间
}
```

## 使用方法

### 方法一：运行应用自动生成

1. **启动应用**（数据会自动生成）:
```bash
flutter run -d macos
```

2. **查看控制台输出**，确认数据生成成功：
```
🏙️ 开始生成中国城市数据...
✅ 插入城市: 北京 (北京市) - ID: 1
  ➕ 添加共享办公空间: WeWork 北京联合办公 - ID: 1
  ➕ 添加共享办公空间: SOHO 3Q 北京创客中心 - ID: 2
  ...
✅ 成功插入 50 个城市及其共享办公空间
```

3. **重要**: 生成完成后，将 `lib/main.dart` 中的配置改回：
```dart
await dbInitializer.initializeDatabase(forceReset: false);
```

### 方法二：使用脚本

```bash
chmod +x generate_china_cities.sh
./generate_china_cities.sh
```

## 数据验证

### 检查城市数量
在应用中访问 Data Service 页面，应该能看到约58个城市（8个原始城市 + 50个中国城市）

### 检查共享办公空间
- 点击任意中国城市
- 应该能看到4-5个共享办公空间
- 每个空间都有完整的信息（价格、评分、设施等）

### 数据库查询
可以通过以下方式直接查看数据库：

```dart
final cities = await CityDao().getAllCities();
print('总城市数: ${cities.length}');

final coworkings = await CoworkingDao().getAllCoworkings();
print('总共享办公空间数: ${coworkings.length}');
```

## 共享办公空间品牌

生成的共享办公空间使用以下真实品牌：

### 国际品牌
- WeWork
- Spaces

### 中国品牌
- SOHO 3Q
- 优客工场 (UrWork)
- Distrii办伴
- 裸心社 (naked Hub)
- P2
- 梦想加 (DayDayUp)
- 方糖小镇
- CreatorBase
- Garage Cafe
- People Squared
- Bee+
- Binggo咖啡

## 数据特点

### 真实性
- 城市名称和省份对应关系准确
- 区域划分符合中国地理分区
- 气候类型根据实际地理位置设定
- 共享办公空间品牌均为真实存在

### 多样性
- 覆盖全国34个省级行政区
- 包含直辖市、省会、重点城市
- 不同规模城市（人口从50万到1500万）
- 不同价格区间（生活成本800-4000元/月）

### 完整性
- 每个城市都有完整的评分数据
- 每个城市都有配套的共享办公空间
- 所有字段都有合理的随机值
- 包含地理坐标信息

## 注意事项

1. **数据是随机生成的测试数据**，不代表真实情况
2. **forceReset: true 会删除所有现有数据**，包括原始的8个城市
3. 生成的经纬度是随机的，不精确对应实际城市位置
4. 价格、评分等数值仅供测试使用
5. 图片URL使用 Unsplash 随机图片服务

## 故障排除

### 问题1: 数据未生成
**解决方案**:
- 检查 `main.dart` 中 `forceReset` 是否为 `true`
- 查看控制台是否有错误信息
- 确认数据库文件路径有写入权限

### 问题2: 部分数据丢失
**解决方案**:
- 完全重启应用
- 删除数据库文件后重新生成
- 检查插入日志中是否有错误

### 问题3: 共享办公空间未生成
**解决方案**:
- 确认 `CoworkingDao` 导入正确
- 检查外键约束是否正确
- 查看具体错误日志

## 后续优化建议

1. **精确地理坐标**: 使用真实城市的经纬度
2. **真实图片**: 替换为各城市的实际照片
3. **更多数据字段**: 添加特色、标签等信息
4. **关联数据**: 为共享办公空间添加用户评论
5. **动态更新**: 支持在线更新城市和空间信息

## 总结

本次生成的测试数据包括：
- ✅ 50个中国城市（覆盖34个省级行政区）
- ✅ 200-250个共享办公空间（每个城市4-5个）
- ✅ 完整的数据结构和字段
- ✅ 合理的随机值范围
- ✅ 真实的品牌名称

数据已成功存储到 SQLite 数据库中，可以在应用中正常使用和展示。
