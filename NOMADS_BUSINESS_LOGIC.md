# 🌍 Nomads.com 完整业务逻辑分析

## 📋 核心业务模型

### 1. 平台定位
- **目标用户**: 数字游民(Digital Nomads)、远程工作者
- **核心价值**: 帮助用户找到最适合远程工作的城市
- **差异化**: 数据驱动的城市排名 + 活跃的社区

### 2. 主要功能模块

#### 2.1 城市浏览与发现
- **首页城市列表**: 展示热门城市卡片
- **核心指标显示**:
  - ⭐️ Overall (总体评分)
  - 💵 Cost (生活成本/月)
  - 📡 WiFi (网速 Mbps)
  - 👍 Liked (用户喜欢度)
  - 👮 Safety (安全评分)
  - 🌦 Temperature (温度范围)
  - 💨 AQI (空气质量指数)
  - 🏷️ Badges (特殊标签)

#### 2.2 过滤系统
- Region (地区): 亚洲、欧洲、美洲、非洲、大洋洲
- Price Range (价格范围): $0-$5000
- Internet Speed (网速): 0-100 Mbps
- Overall Rating (评分): 0-5 星
- Climate (气候): 热、暖、温和、凉爽、寒冷
- Air Quality (空气质量): 0-500 AQI

#### 2.3 社交与社区功能
- **Meetups (聚会)**:
  - 🍺 Drinks
  - 💼 Coworking
  - 🍽️ Dinner
  - 🏃 Activity
  - 📚 Workshop
  - 🤝 Networking
  - RSVP 功能
  - 显示参与人数和剩余名额

- **Chat (聊天室)**:
  - 城市聊天室
  - 在线用户显示
  - 实时消息
  - @提及和回复功能

- **Community Content (社区内容)**:
  - Trip Reports (旅行报告)
  - City Recommendations (城市推荐)
  - Q&A Section (问答区)

---

## 🏙️ 城市详情页架构

### 完整的标签页列表 (15+ Tabs)

#### 1. **Scores** (评分)
**URL**: `/ranking/{city}`
**内容**:
- 总体评分排名
- 各项指标详细评分
- 与其他城市对比
- 评分趋势图

#### 2. **Digital Nomad Guide** (数字游民指南)
**URL**: `/digital-nomad-guide/{city}`
**内容**:
- 新手指南
- 签证信息
- 最佳居住区域
- 工作空间推荐
- 生活建议

#### 3. **Pros and Cons** (优缺点)
**URL**: `/pros-cons/{city}`
**内容**:
- ✅ 优点列表 (带绿色勾选)
- ❌ 缺点列表 (带红色叉号)
- 用户投票
- 最常提及的优缺点

#### 4. **Reviews** (评论)
**URL**: `/reviews/{city}`
**内容**:
- 用户评论列表
- 星级评分
- 停留时长
- 照片分享
- 点赞和回复

#### 5. **Cost of Living** (生活成本)
**URL**: `/cost-of-living/in/{city}`
**内容**:
- 月度成本明细:
  - 🏠 住宿 (Airbnb/Hotel/Apartment)
  - 🍔 食物 (外食/自己做)
  - 🚕 交通 (公交/打车)
  - 📱 通讯 (SIM卡/WiFi)
  - 🎭 娱乐
  - 💪 健身房
  - ☕ 咖啡馆工作
- 总计费用
- 与其他城市对比

#### 6. **People** (用户)
**URL**: `/people/{city}`
**内容**:
- 当前在该城市的用户
- 用户头像墙
- 用户资料预览
- 添加好友/聊天
- 用户统计数据

#### 7. **Chat** (聊天)
**URL**: `/chat/{country}?embed=true`
**内容**:
- 嵌入式聊天室
- 实时消息
- 在线用户列表
- 消息历史

#### 8. **Photos** (照片)
**URL**: `/photos/{city}`
**内容**:
- 用户上传的照片
- 照片墙/画廊
- 按地点分类
- 点赞和评论
- 照片作者信息

#### 9. **Weather** (天气)
**URL**: `/weather/{city}`
**内容**:
- 当前天气
- 7天预报
- 月度气候统计
- 年度温度曲线
- 降雨量
- 湿度
- 最佳访问季节

#### 10. **Trends** (趋势)
**URL**: `/trends/{city}`
**内容**:
- 访问量趋势
- 评分变化趋势
- 成本趋势
- 受欢迎度变化
- 季节性分析

#### 11. **Demographics** (人口统计)
**URL**: `/demographics/{city}`
**内容**:
- 人口密度
- 年龄分布
- 外国人比例
- 数字游民数量
- 性别比例
- 教育水平

#### 12. **Neighborhoods** (社区/区域)
**URL**: `/neighborhoods/{city}`
**内容**:
- 城市各区域介绍
- 每个区域的特点
- 租金价格对比
- 安全评分
- 夜生活
- 便利设施

#### 13. **Coworking** (共享办公)
**URL**: `https://placestowork.net/{city}`
**内容**:
- 共享办公空间列表
- 价格和设施
- 网速测试结果
- 用户评价
- 位置地图
- 预订链接

#### 14. **Video** (视频)
**URL**: `/video/{city}`
**内容**:
- 城市介绍视频
- 用户分享的 Vlog
- 无人机航拍
- 生活片段
- YouTube 集成

#### 15. **Near** (附近城市)
**URL**: `/near/{city}`
**内容**:
- 地理位置相近的城市
- 距离和交通方式
- 对比评分
- 周末旅行建议

#### 16. **Next** (下一站推荐)
**URL**: `/next/{city}`
**内容**:
- 基于当前城市推荐下一个目的地
- 相似气候
- 相似价格
- 相似生活方式

#### 17. **Similar** (相似城市)
**URL**: `/similar/{city}`
**内容**:
- 特征相似的城市
- 评分对比
- 价格对比
- 推荐理由

---

## 🎯 用户旅程流程

### Journey 1: 发现城市
```
进入首页 
  → 浏览城市卡片
  → 使用过滤器筛选
  → 点击城市卡片
  → 查看城市详情页 (多个标签)
  → 阅读评论和指南
  → 查看生活成本
  → 决定是否访问
```

### Journey 2: 社交互动
```
进入城市详情页
  → 点击 Chat 标签
  → 加入城市聊天室
  → 认识其他数字游民
  → 查看 Meetups
  → RSVP 参加聚会
  → 线下见面
```

### Journey 3: 分享经验
```
访问完城市后
  → 进入 Community 页面
  → 写 Trip Report (旅行报告)
  → 分享照片和评分
  → 列出优缺点
  → 推荐餐厅/咖啡馆
  → 帮助其他人决策
```

### Journey 4: 寻求建议
```
计划访问新城市
  → 进入 Q&A 区
  → 搜索相关问题
  → 提出新问题
  → 获得社区回答
  → 投票最佳答案
  → 标记问题为已解决
```

---

## 🔧 技术实现要点

### 1. 数据模型扩展

#### City Model 增强
```dart
class City {
  // 基础信息
  String id;
  String name;
  String country;
  String region;
  
  // 评分系统 (40+ 指标)
  double overallScore;
  double qualityOfLife;
  double familyScore;
  double communityScore;
  double safetyScore;
  double lgbtqSafety;
  double womenSafety;
  
  // 成本
  double monthlyCost;
  Map<String, double> costBreakdown; // 住宿、食物、交通等
  
  // 基础设施
  double internetSpeed;
  double freeWiFiScore;
  double placesToWorkScore;
  double powerGridScore;
  
  // 环境
  double currentTemp;
  double feelsLikeTemp;
  double humidity;
  int aqi;
  int annualAqi;
  double acPercentage;
  
  // 社会指标
  double walkability;
  double trafficSafety;
  double nightlife;
  double funScore;
  double englishSpeaking;
  double friendlyToForeigners;
  
  // 统计数据
  int reviewCount;
  int likeCount;
  int dislikeCount;
  int populationDensity;
  double incomeLevel;
  
  // 位置
  double latitude;
  double longitude;
  
  // 媒体
  String imageUrl;
  List<String> photoGallery;
  String? videoUrl;
  
  // 关联数据
  List<String> neighborhoods;
  List<String> nearCities;
  List<String> similarCities;
}
```

#### CityDetail Tabs Model
```dart
class CityDetailTabs {
  ScoresTab scores;
  DigitalNomadGuide guide;
  ProsAndCons prosAndCons;
  List<Review> reviews;
  CostOfLiving costOfLiving;
  List<User> people;
  ChatRoom chat;
  List<Photo> photos;
  WeatherData weather;
  TrendsData trends;
  Demographics demographics;
  List<Neighborhood> neighborhoods;
  List<CoworkingSpace> coworkingSpaces;
  List<Video> videos;
  List<City> nearCities;
  List<City> nextDestinations;
  List<City> similarCities;
}
```

### 2. 导航结构

#### 底部导航栏
```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.explore),
      label: 'Explore', // 城市浏览
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.event),
      label: 'Meetups', // 聚会
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Community', // 社区
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile', // 个人资料
    ),
  ],
)
```

#### 路由配置
```dart
routes: {
  '/': (context) => HomePage(), // 城市列表
  '/city/:cityId': (context) => CityDetailPage(), // 城市详情
  '/city/:cityId/scores': (context) => ScoresPage(),
  '/city/:cityId/guide': (context) => DigitalNomadGuidePage(),
  '/city/:cityId/pros-cons': (context) => ProsConsPage(),
  '/city/:cityId/reviews': (context) => ReviewsPage(),
  '/city/:cityId/cost': (context) => CostOfLivingPage(),
  '/city/:cityId/people': (context) => PeoplePage(),
  '/city/:cityId/chat': (context) => ChatPage(),
  '/city/:cityId/photos': (context) => PhotosPage(),
  '/city/:cityId/weather': (context) => WeatherPage(),
  '/city/:cityId/trends': (context) => TrendsPage(),
  '/city/:cityId/demographics': (context) => DemographicsPage(),
  '/city/:cityId/neighborhoods': (context) => NeighborhoodsPage(),
  '/meetups': (context) => MeetupsPage(),
  '/community': (context) => CommunityPage(),
  '/profile': (context) => ProfilePage(),
  '/search': (context) => SearchPage(),
}
```

### 3. 搜索功能
```dart
class SearchController extends GetxController {
  var searchQuery = ''.obs;
  var searchResults = <City>[].obs;
  var recentSearches = <String>[].obs;
  var popularSearches = <String>[].obs;
  
  void search(String query) {
    // 搜索城市名称、国家、地区
    // 支持模糊搜索
    // 显示搜索建议
  }
}
```

### 4. 排序功能
```dart
enum SortOption {
  overall,      // 总体评分
  cost,         // 价格 (低到高)
  costDesc,     // 价格 (高到低)
  internet,     // 网速
  safety,       // 安全
  popular,      // 受欢迎度
  reviews,      // 评论数
}

class SortController extends GetxController {
  var currentSort = SortOption.overall.obs;
  
  void sortCities(List<City> cities, SortOption option) {
    // 排序逻辑
  }
}
```

### 5. 收藏功能
```dart
class FavoritesController extends GetxController {
  var favoriteCities = <String>[].obs;
  var wishlist = <String>[].obs;
  var visited = <String>[].obs;
  
  void toggleFavorite(String cityId) {
    if (favoriteCities.contains(cityId)) {
      favoriteCities.remove(cityId);
    } else {
      favoriteCities.add(cityId);
    }
  }
  
  void markAsVisited(String cityId) {
    visited.add(cityId);
  }
}
```

---

## 📊 核心指标体系

### 完整的评分维度 (40+ 指标)

#### 1. 生活质量
- Overall Score (总体)
- Quality of Life (生活质量)
- Fun Score (娱乐指数)
- Happiness (幸福度)

#### 2. 社区与安全
- Community Score (社区)
- Safety (安全)
- Women Safety (女性安全)
- LGBTQ+ Safety (LGBTQ+安全)
- Lack of Crime (低犯罪率)
- Lack of Racism (低种族歧视)

#### 3. 工作环境
- Internet Speed (网速)
- Free WiFi (免费WiFi)
- Places to Work (工作空间)
- Coworking Spaces (共享办公)
- Power Grid (电力)

#### 4. 成本
- Cost of Living (生活成本)
- Accommodation (住宿)
- Food (食物)
- Transportation (交通)
- Entertainment (娱乐)

#### 5. 环境
- Temperature (温度)
- Humidity (湿度)
- Air Quality (空气质量)
- Climate Change Vulnerability (气候变化脆弱性)

#### 6. 基础设施
- Walkability (步行友好)
- Traffic Safety (交通安全)
- Hospitals (医疗)
- Education Level (教育水平)
- AC/Heating (空调/暖气)

#### 7. 社会环境
- Friendly to Foreigners (对外国人友好)
- English Speaking (英语普及)
- Freedom of Speech (言论自由)
- Nightlife (夜生活)

#### 8. 家庭相关
- Family Score (家庭适合度)
- Food Safety (食品安全)
- Education (教育)

#### 9. 商业环境
- Startup Score (创业分数)
- Income Level (收入水平)

#### 10. 旅行相关
- Airline Scores (航空公司评分)
- Lost Luggage (行李丢失率)

---

## 🎨 UI/UX 设计要点

### 1. 城市卡片设计
- 大图背景
- 半透明遮罩
- 关键指标突出显示
- Hover 效果
- 点击进入详情

### 2. 详情页布局
- 顶部大图 banner
- 面包屑导航
- 标签页导航 (水平滚动)
- 内容区域
- 底部相关推荐

### 3. 交互设计
- 平滑滚动
- 标签页切换动画
- 数据加载骨架屏
- 下拉刷新
- 无限滚动

### 4. 响应式设计
- 移动端: 单列布局
- 平板: 两列布局
- 桌面: 三列布局
- 自适应字体大小

---

## 🚀 实施优先级

### Phase 1: 核心功能增强 ✅
- [x] 城市卡片
- [x] 过滤系统
- [x] 聚会功能
- [x] 用户资料
- [x] 聊天室
- [x] 社区内容

### Phase 2: 导航与路由 (当前)
- [ ] 底部导航栏
- [ ] 城市详情页路由
- [ ] 页面跳转集成
- [ ] 返回按钮处理

### Phase 3: 城市详情页
- [ ] Scores 标签
- [ ] Digital Nomad Guide 标签
- [ ] Pros & Cons 标签
- [ ] Reviews 标签
- [ ] Cost of Living 标签
- [ ] People 标签
- [ ] Weather 标签
- [ ] Photos 标签

### Phase 4: 搜索与排序
- [ ] 搜索功能
- [ ] 排序选项
- [ ] 收藏功能
- [ ] 访问历史

### Phase 5: 高级功能
- [ ] 通知系统
- [ ] 用户设置
- [ ] 多语言支持
- [ ] 主题切换

---

## 📈 数据流架构

### 状态管理
```
GetX Controllers
├── DataServiceController (城市数据)
├── FilterController (过滤)
├── SearchController (搜索)
├── SortController (排序)
├── FavoritesController (收藏)
├── UserProfileController (用户)
├── ChatController (聊天)
├── CommunityController (社区)
└── NavigationController (导航)
```

### 数据持久化
```
Local Storage (SharedPreferences)
├── User preferences
├── Favorite cities
├── Recent searches
├── Visited cities
└── Filter settings
```

### API 集成 (未来)
```
Backend APIs
├── GET /cities (城市列表)
├── GET /cities/:id (城市详情)
├── GET /cities/:id/reviews (评论)
├── GET /cities/:id/cost (成本)
├── GET /meetups (聚会)
├── GET /users/:id (用户)
├── POST /reviews (发布评论)
└── WebSocket /chat (实时聊天)
```

---

## 🎯 成功指标

### 用户参与度
- 日活用户 (DAU)
- 月活用户 (MAU)
- 平均会话时长
- 页面浏览量

### 社区活跃度
- 聚会参与率
- 聊天消息数
- 评论发布数
- 问答互动数

### 内容质量
- 城市评论数
- 照片分享数
- 旅行报告数
- 推荐发布数

### 转化指标
- 注册转化率
- 付费会员率
- 聚会出席率
- 推荐点击率

---

## 📝 总结

Nomads.com 的核心业务逻辑围绕:

1. **数据驱动**: 40+ 指标全面评估城市
2. **社区驱动**: 用户生成内容 (UGC) 提供真实信息
3. **功能完整**: 从发现到决策到社交的完整闭环
4. **用户旅程**: 清晰的流程引导用户参与

接下来的实现重点:
- 完善导航系统
- 实现城市详情页
- 集成搜索和排序
- 优化用户体验
