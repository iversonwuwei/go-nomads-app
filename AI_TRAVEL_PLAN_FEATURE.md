# AI旅行计划生成功能

## 功能概述

在城市详情页中,用户可以使用AI生成个性化的旅行计划。生成的计划包含完整的行程安排、交通住宿建议、景点餐厅推荐和预算明细,可保存到用户的Profile中随时查看。

## 功能特点

### 1. 智能计划生成
- **自定义参数**:
  - 旅行天数 (1-30天)
  - 预算等级 (Low/Medium/High)
  - 旅行风格 (Culture/Adventure/Relaxation/Nightlife)
  - 兴趣标签 (Food/Shopping/Photography/History/Nature/Art)

### 2. 完整的计划内容

#### 交通安排
- 到达方式推荐
- 预估费用
- 当地交通方案
- 每日交通成本

#### 住宿建议
- 住宿类型推荐
- 具体酒店/民宿建议
- 推荐区域
- 每晚价格
- 便利设施列表
- 预订小贴士

#### 每日行程
- 按天组织的详细行程
- 每天的主题
- 具体活动安排:
  - 时间
  - 活动名称
  - 描述
  - 地点
  - 预估费用
  - 持续时间
- 每日注意事项

#### 景点推荐
- 必游景点列表
- 景点描述
- 分类标签
- 评分
- 门票价格
- 最佳游览时间
- 配图

#### 餐厅推荐
- 特色餐厅列表
- 菜系类型
- 招牌菜
- 评分
- 价格区间
- 位置
- 配图

#### 旅行小贴士
- 天气提醒
- 货币建议
- 交通指南
- 着装建议
- SIM卡信息
- 美食推荐
- 语言提示
- 电源转换器

#### 预算明细
- 交通费用
- 住宿费用
- 餐饮费用
- 活动费用
- 杂费
- 总预算
- 货币单位

## 使用方法

### 1. 生成旅行计划

1. 进入任意城市详情页
2. 点击顶部的 **"AI Travel Plan"** 按钮
3. 在弹出的对话框中设置:
   - 拖动滑块选择旅行天数
   - 选择预算等级 (Low/Medium/High)
   - 选择旅行风格
   - (可选) 选择感兴趣的标签
4. 点击 **"Generate AI Plan"** 按钮
5. 等待3秒,AI生成个性化计划
6. 自动跳转到计划详情页

### 2. 查看计划详情

计划页面包含以下部分:
- 顶部城市banner和计划概览
- 预算明细卡片
- 交通方案
- 住宿建议
- 每日详细行程
- 必游景点
- 推荐餐厅
- 旅行小贴士

### 3. 保存和分享

在计划详情页:
- 点击右上角 **下载图标** 保存计划到Profile
- 点击 **分享图标** 分享计划给朋友

### 4. 查看已保存的计划

1. 进入 **Profile** 页面
2. 滚动到 **"My Travel Plans"** 部分
3. 查看所有已保存的旅行计划
4. 点击任意计划查看详情

## 文件结构

```
lib/
├── models/
│   └── travel_plan_model.dart          # 旅行计划数据模型
├── controllers/
│   └── city_detail_controller.dart     # 城市详情控制器 (包含生成逻辑)
├── pages/
│   ├── city_detail_page.dart           # 城市详情页 (包含生成按钮)
│   ├── travel_plan_page.dart           # 旅行计划详情页
│   └── profile_page.dart               # 个人资料页 (显示保存的计划)
```

## 数据模型

### TravelPlan (旅行计划)
- id, cityId, cityName, cityImage
- createdAt, duration, budget, travelStyle, interests
- transportation, accommodation
- dailyItineraries (每日行程)
- attractions (景点), restaurants (餐厅)
- tips (小贴士), budgetBreakdown (预算明细)

### TransportationPlan (交通计划)
- arrivalMethod, arrivalDetails, estimatedCost
- localTransport, localTransportDetails, dailyTransportCost

### AccommodationPlan (住宿计划)
- type, recommendation, area
- pricePerNight, amenities, bookingTips

### DailyItinerary (每日行程)
- day, theme
- activities (活动列表)
- notes

### Activity (活动)
- time, name, description
- location, estimatedCost, duration

### Attraction (景点)
- name, description, category
- rating, location, entryFee
- bestTime, image

### Restaurant (餐厅)
- name, cuisine, description
- rating, priceRange, location
- specialty, image

### BudgetBreakdown (预算明细)
- transportation, accommodation
- food, activities, miscellaneous
- total, currency

## 技术实现

### AI生成逻辑
当前使用模拟数据生成,包含:
- 根据预算等级调整价格 (0.7x / 1.0x / 1.5x)
- 根据旅行风格推荐住宿区域
- 根据旅行天数生成每日行程
- 智能预算计算

### 未来扩展
TODO: 集成真实的AI API (OpenAI/Claude/Gemini):
```dart
Future<TravelPlan?> generateTravelPlan(...) async {
  // 调用AI API
  final response = await openAIClient.chat.completions.create(
    model: "gpt-4",
    messages: [
      {"role": "system", "content": "You are a travel planning expert..."},
      {"role": "user", "content": "Generate a travel plan for $cityName..."}
    ],
  );
  
  // 解析响应并创建TravelPlan对象
  return TravelPlan.fromJson(jsonDecode(response.content));
}
```

## UI/UX特性

### 生成对话框
- 清晰的参数选择界面
- 滑块选择天数
- 芯片式预算选择
- 图标化旅行风格选择
- 多选兴趣标签
- 加载状态显示

### 计划详情页
- 大图banner
- 卡片式信息展示
- 颜色编码的分类图标
- 时间轴式每日行程
- 网格布局的景点餐厅
- 列表式旅行小贴士
- 下载和分享功能

### Profile集成
- 空状态引导用户生成计划
- 计划列表展示 (TODO)
- 快速访问计划详情

## 状态管理

使用GetX进行状态管理:
- `isGeneratingPlan`: 生成中状态
- `generatedPlan`: 当前生成的计划
- 自动响应式UI更新

## 示例用法

```dart
// 在城市详情页点击按钮
ElevatedButton(
  onPressed: () => _showTravelPlanDialog(controller),
  child: Text('AI Travel Plan'),
)

// 生成计划
final plan = await controller.generateTravelPlan(
  duration: 7,
  budget: 'medium',
  travelStyle: 'culture',
  interests: ['Food', 'Photography'],
);

// 显示计划
if (plan != null) {
  Get.to(() => TravelPlanPage(plan: plan));
}

// 保存到用户数据 (TODO)
userController.saveTravelPlan(plan);
```

## 待完成功能 (TODO)

1. **用户数据持久化**
   - 将生成的计划保存到用户Profile
   - 从本地存储/云端加载已保存的计划
   - 在Profile页面显示计划列表

2. **真实AI集成**
   - 集成OpenAI/Claude/Gemini API
   - 根据城市评分数据生成更精准的建议
   - 利用用户历史偏好个性化推荐

3. **增强功能**
   - 编辑和自定义生成的计划
   - 导出为PDF
   - 添加到日历
   - 计划协作分享
   - 实时同步到云端

4. **数据增强**
   - 真实的景点数据 (Google Places API)
   - 实时价格信息
   - 天气预报集成
   - 航班和酒店搜索集成

## 注意事项

- 当前为演示版本,使用模拟数据
- 实际部署需要集成AI API密钥
- 需要实现用户认证和数据存储
- 建议添加缓存机制避免重复生成相同计划

## 支持

如需帮助或有建议,请联系开发团队。
