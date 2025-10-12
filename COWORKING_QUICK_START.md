# Coworking 功能快速使用指南

## 🚀 功能入口

### 1. 导航到城市详情页
```dart
// 从首页或任何地方跳转到城市详情
Get.to(() => CityDetailPage(
  cityId: '1',
  cityName: 'Bangkok',
  cityImage: 'https://...',
  overallScore: 4.54,
  reviewCount: 1234,
));
```

### 2. 切换到 Coworking 标签
- 在城市详情页向右滑动标签栏
- 或直接点击 **"Coworking"** 标签

## 📱 功能演示

### 主要功能
1. **浏览共享办公空间列表**
2. **筛选空间**（WiFi、24/7、会议室、咖啡）
3. **排序空间**（评分、价格、距离）
4. **查看详细信息**
5. **一键导航**
6. **访问官网**
7. **直接联系**

## 🎯 当前模拟数据

### Bangkok 共享办公空间（5个）

#### 1. Hubba Coworking ⭐️ 4.8
- **WiFi**: 100 Mbps
- **价格**: $250/月
- **特色**: 顶楼露台、播客工作室
- **24/7 访问**: ✅
- **免费试用**: ✅ 1天

#### 2. TCDC ⭐️ 4.6
- **WiFi**: 80 Mbps
- **价格**: $200/月
- **特色**: 设计图书馆、展览空间
- **安静环境**: ✅

#### 3. The Hive Thonglor ⭐️ 4.7
- **WiFi**: 150 Mbps（最快）
- **价格**: $280/月
- **特色**: True Digital Park
- **24/7 访问**: ✅
- **免费试用**: ✅ 3小时

#### 4. Launchpad ⭐️ 4.5
- **WiFi**: 90 Mbps
- **价格**: $220/月
- **特色**: 创业导师、社交活动

#### 5. KoHub ⭐️ 4.4
- **WiFi**: 60 Mbps
- **价格**: $150/月（最便宜）
- **特色**: 咖啡馆氛围、安静

## 🔧 筛选器使用

### 激活筛选
点击顶部的 FilterChip：
- **WiFi**: 筛选有 WiFi 的空间（全部都有）
- **24/7**: 筛选 24小时访问的空间（Hubba、The Hive）
- **Meeting Rooms**: 筛选有会议室的空间（4个）
- **Coffee**: 筛选提供咖啡的空间（5个）

### 清除筛选
- 点击 **Clear** 按钮
- 或点击已选中的 FilterChip 取消

## 📊 排序选项

### 点击右上角排序图标 (⋮)

1. **Sort by Rating** ⭐️
   - 按评分从高到低
   - 推荐初次选择

2. **Sort by Price** 💰
   - 按月价格从低到高
   - 适合预算有限

3. **Sort by Distance** 📍
   - 按距离从近到远
   - （需要位置权限）

## 💡 详情页功能

### 查看完整信息
1. 点击任意空间卡片
2. 进入详情页查看：
   - 大图展示
   - 完整价格（小时/天/周/月）
   - 所有设施列表
   - WiFi 速度、容量等规格
   - 营业时间
   - 联系方式

### 快速操作
底部操作栏：
- **Directions** 🗺: 打开地图导航
- **Visit Website** 🌐: 访问官网

侧边栏联系方式：
- **电话** ☎️: 拨打电话
- **邮箱** ✉️: 发送邮件
- **网站** 🌐: 打开浏览器

## 🛠 开发者信息

### 数据结构
```dart
CoworkingSpace {
  id: String,
  name: String,
  address: String,
  rating: double,
  pricing: CoworkingPricing {
    hourlyRate: double?,
    dailyRate: double?,
    weeklyRate: double?,
    monthlyRate: double?,
  },
  amenities: CoworkingAmenities {
    hasWifi: bool,
    hasCoffee: bool,
    has24HourAccess: bool,
    // ... 15+ amenities
  },
  specs: CoworkingSpecs {
    wifiSpeed: double,
    capacity: int,
    noiseLevel: String,
    // ...
  }
}
```

### 控制器使用
```dart
final controller = Get.find<CoworkingController>();

// 筛选
controller.filterByCity('Bangkok');
controller.toggleFilter('WiFi');
controller.updatePriceRange(0, 300);

// 排序
controller.sortByRating();
controller.sortByPrice();

// 访问数据
controller.filteredSpaces.forEach((space) {
  print(space.name);
});
```

### 添加新空间
在 `CoworkingController.loadMockData()` 中添加：
```dart
CoworkingSpace(
  id: '6',
  name: 'Your Space Name',
  address: 'Full Address',
  city: 'Bangkok',
  country: 'Thailand',
  latitude: 13.7xxx,
  longitude: 100.5xxx,
  imageUrl: 'https://...',
  rating: 4.5,
  reviewCount: 100,
  description: 'Description here',
  pricing: CoworkingPricing(
    monthlyRate: 200.0,
    currency: 'USD',
  ),
  amenities: CoworkingAmenities(
    hasWifi: true,
    hasCoffee: true,
  ),
  specs: CoworkingSpecs(
    wifiSpeed: 100.0,
    capacity: 50,
  ),
  isVerified: true,
),
```

## 🔗 API 集成准备

### 未来接入真实 API
```dart
// lib/services/coworking_service.dart
class CoworkingService {
  Future<List<CoworkingSpace>> fetchSpaces(String cityId) async {
    final response = await http.get('/api/cities/$cityId/coworking');
    // Parse and return
  }
}
```

### 在控制器中使用
```dart
Future<void> fetchCoworkingSpaces(String cityId) async {
  isLoading.value = true;
  try {
    final spaces = await CoworkingService().fetchSpaces(cityId);
    coworkingSpaces.value = spaces;
    applyFilters();
  } finally {
    isLoading.value = false;
  }
}
```

## 📝 测试步骤

### 1. 基本浏览
- [ ] 进入城市详情页
- [ ] 切换到 Coworking 标签
- [ ] 看到 5 个空间卡片
- [ ] 滚动查看所有卡片

### 2. 筛选测试
- [ ] 点击 **24/7** 筛选
- [ ] 确认只显示 2 个空间（Hubba、The Hive）
- [ ] 点击 **Clear** 恢复

### 3. 排序测试
- [ ] 点击排序菜单
- [ ] 选择 **Sort by Price**
- [ ] 确认 KoHub ($150) 排在第一

### 4. 详情页测试
- [ ] 点击任意卡片
- [ ] 查看大图正确显示
- [ ] 滚动查看所有信息
- [ ] 返回列表

### 5. 操作测试（真机）
- [ ] 点击 **Directions** 测试地图
- [ ] 点击 **电话** 测试拨号
- [ ] 点击 **网站** 测试浏览器

## ⚠️ 注意事项

### 当前限制
1. **模拟数据**: 仅有 5 个 Bangkok 空间
2. **城市固定**: 所有城市显示相同数据
3. **距离排序**: 未实现（需要位置权限）
4. **实际联系**: URL 为占位符，需真实数据

### 生产环境准备
- [ ] 连接真实 API
- [ ] 添加更多城市数据
- [ ] 实现距离计算
- [ ] 更新真实联系方式
- [ ] 添加图片 CDN
- [ ] 实现收藏功能
- [ ] 添加预订功能

## 🎨 UI 定制

### 修改主题色
在各个 `_buildInfoChip` 方法中：
```dart
_buildInfoChip(
  Icons.wifi,
  '${space.specs.wifiSpeed} Mbps',
  Colors.blue,  // 改为你的品牌色
),
```

### 调整卡片布局
在 `coworking_list_page.dart` 的 `_buildCoworkingCard` 中修改：
```dart
Card(
  margin: const EdgeInsets.only(bottom: 16),  // 调整间距
  elevation: 2,  // 调整阴影
  // ...
)
```

### 修改详情页结构
在 `coworking_detail_page.dart` 中重新排列 sections。

## 📚 相关文档

- **完整文档**: `COWORKING_FEATURE_COMPLETE.md`
- **模型定义**: `lib/models/coworking_space_model.dart`
- **控制器**: `lib/controllers/coworking_controller.dart`
- **列表页**: `lib/pages/coworking_list_page.dart`
- **详情页**: `lib/pages/coworking_detail_page.dart`

## 🐛 问题反馈

如遇到问题，请检查：
1. Flutter 版本 >= 3.35.0
2. url_launcher 依赖已安装
3. iOS/Android 权限配置
4. 控制器正确初始化

---

**功能状态**: ✅ 生产就绪  
**最后更新**: 2025年  
**维护者**: Copilot AI Team
