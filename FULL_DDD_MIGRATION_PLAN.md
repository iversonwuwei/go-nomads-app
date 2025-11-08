# 完整 DDD 迁移计划

## 📋 迁移策略

**原则**: 先完成所有域的 DDD 实现,确保功能完整迁移后,最后统一删除旧 controller 文件。

---

## ✅ 已完成的域 (DDD State Controllers)

### 1. City Domain ✅
- **State Controller**: `CityStateController` (城市列表)
- **State Controller**: `CityDetailStateController` (城市详情)
- **State Controller**: `ProsConsStateController` (优缺点)
- **功能**: 城市搜索、列表、详情、收藏、优缺点

### 2. Weather Domain ✅
- **State Controller**: `WeatherStateController`
- **功能**: 天气数据获取和展示

### 3. Coworking Domain ✅
- **State Controller**: `CoworkingStateController`
- **功能**: 共享办公空间搜索、列表、详情

### 4. User City Content Domain ✅
- **State Controller**: `UserCityContentStateController`
- **功能**: 用户评论、照片、花费、Cost Summary

### 5. AI Domain ✅
- **State Controller**: `AiStateController`
- **功能**: AI 旅游指南、旅行计划生成

### 6. Auth Domain ✅
- **State Controller**: `AuthStateController`
- **功能**: 用户认证、登录、注册

### 7. User Domain ✅
- **State Controller**: `UserStateController`
- **功能**: 用户信息管理、收藏城市

---

## 🔄 需要迁移的域

**Phase 1 分析完成**: 9/9 controllers (100%) ✅

### 迁移分类统计

| 类别 | 数量 | Controllers |
|------|------|-------------|
| 🔴 **必须迁移到DDD** | 3 | user_profile, community, data_service |
| 🟡 **可选优化** | 1 | location |
| 🟢 **保持现状** | 2 | locale, bottom_nav |
| 🗑️ **建议删除**(示例功能) | 3 | ai_chat, analytics, shopping |
| ❌ **已损坏** | 2 | add_coworking, chat |
| ✅ **已迁移** | 2 | coworking, pros_and_cons_add |

---

### 🔴 高优先级迁移 (3个)

### 8. User Profile → 合并到 User Domain 🔴
**旧 Controller**: `lib/controllers/user_profile_controller.dart` (231行)

**分析结果** ✅:
- 使用 `GetCurrentUserUseCase` (已经是DDD)
- 监听 `UserStateController.loginStateChanged`
- 功能与 `UserStateController` 重叠

**迁移决策**: **合并到现有 UserStateController**

**实施步骤**:
```dart
// 需要添加到 lib/features/user/presentation/controllers/user_state_controller.dart
- loadUserProfile() 方法
- editMode 状态管理 (Rx<bool>)
- 登录状态监听逻辑
```

**影响范围**: 搜索所有使用 `UserProfileController` 的页面并替换

---

### 9. Community Domain → 新建 DDD 架构 🔴
**旧 Controller**: `lib/controllers/community_controller.dart` (366行)

**分析结果** ✅:
- **功能**: Trip Reports(游记) / City Recommendations(推荐) / Q&A(问答)
- **特征**: 完整业务逻辑,包含点赞/评论/筛选
- **数据**: 当前使用Mock数据

**迁移决策**: **创建新的 Community Domain**

**DDD架构**:
```
lib/features/community/
├── domain/
│   ├── entities/
│   │   ├── trip_report.dart
│   │   ├── city_recommendation.dart
│   │   └── question.dart
│   └── repositories/
│       └── i_community_repository.dart
├── application/
│   └── state_controllers/
│       └── community_state_controller.dart
└── infrastructure/
    └── repositories/
        └── community_repository.dart
```

**实施步骤**:
1. 创建 Entity: `TripReport`, `CityRecommendation`, `Question`
2. 定义 Repository 接口 (CRUD + 点赞 + 评论)
3. 实现 `CommunityStateController` (迁移所有逻辑)
4. 如果有后端API,实现 Repository
5. 注册到 DI
6. 更新社区页面

---

### 10. Data Service → 拆分到 City & Event Domain 🔴
**旧 Controller**: `lib/controllers/data_service_controller.dart` (1205行)

**分析结果** ✅:
- **功能A**: 城市筛选(地区/价格/网速/评分/气候)
- **功能B**: Meetup活动(列表/RSVP/类型筛选)
- **API依赖**: `LocationApiService`, `EventsApiService`, `CityApiService`

**迁移决策**: **拆分为两部分**

**Part 1: 城市筛选 → City Domain**
```dart
// 扩展 lib/features/city/application/state_controllers/city_state_controller.dart
// 或创建 city_filter_state_controller.dart

新增状态:
- selectedRegions (List<String>)
- selectedCountries (List<String>)
- minPrice / maxPrice (double)
- minInternet / minRating (double)
- maxAqi (int)
- selectedClimates (List<String>)

新增方法:
- applyFilters()
- clearFilters()
- getFilteredCities()
```

**Part 2: Meetup → 新建 Event Domain**
```
lib/features/event/
├── domain/
│   ├── entities/
│   │   ├── meetup.dart
│   │   └── meetup_rsvp.dart
│   └── repositories/
│       └── i_event_repository.dart
├── application/
│   └── state_controllers/
│       └── event_state_controller.dart
└── infrastructure/
    └── repositories/
        └── event_repository.dart (使用 EventsApiService)
```

**实施步骤**:
1. 将城市筛选逻辑迁移到 `CityStateController`
2. 创建 Event Domain 完整架构
3. 实现 RSVP 功能
4. 保留使用现有API服务
5. 更新相关UI页面

---

### 🟡 中优先级优化 (1个)

### 11. Location Controller → 可选删除 🟡
**旧 Controller**: `lib/controllers/location_controller.dart` (156行)

**分析结果** ✅:
- **功能**: 包装 `LocationService`
- **问题**: 仅是薄包装层,没有增加太多业务逻辑

**选项**:
- **选项A**: 删除,直接在页面中使用 `LocationService`
- **选项B**: 保留,如果需要跨页面共享定位状态

**建议**: 先搜索使用情况,再决定

---

### 🟢 保持现状 (2个)

### 12. Locale Controller → 保持 🟢
**旧 Controller**: `lib/controllers/locale_controller.dart` (80行)

**分析结果** ✅:
- **功能**: 管理应用语言(中文/英文)
- **特征**: 全局UI设置,简单响应式状态

**决策**: **保持现状** - 不需要DDD架构

这是全局设置功能,可能不需要 DDD 架构,但需要验证:
- 是否已有其他实现?
- 是否需要保留在 controllers 中?

**行动**:
1. 读取 `locale_controller.dart` 分析功能
2. 检查是否有 DDD 实现
3. 决定保留或迁移

---

### 10. Location Domain ⏳
**旧 Controller**: `lib/controllers/location_controller.dart`

位置服务功能:
- 可能是全局服务
- 需要确认是否与城市域相关

**行动**:
1. 读取 `location_controller.dart` 分析功能
2. 确认职责范围
3. 决定迁移策略

---

### 11. Analytics Domain ⏳
**旧 Controller**: `lib/controllers/analytics_controller.dart`

分析/统计功能:
- 可能是横切关注点
- 需要确认是否需要 DDD

**行动**:
1. 读取 `analytics_controller.dart` 分析功能
2. 评估是否需要 DDD 架构
3. 决定处理方式

---

### 12. Bottom Navigation Domain ⏳
**旧 Controller**: `lib/controllers/bottom_nav_controller.dart`

UI 导航控制:
- 纯 UI 层逻辑
- 可能不需要 DDD

### 13. Bottom Nav Controller → 保持 �
**旧 Controller**: `lib/controllers/bottom_nav_controller.dart` (~100行)

**分析结果** ✅:
- **功能**: 管理底部导航栏索引和显隐
- **特征**: 纯UI逻辑,无业务规则

**决策**: **保持现状** - 纯UI逻辑

---

### 🗑️ 建议删除 (3个示例功能)

### 14. AI Chat Controller → 删除 🗑️
**旧 Controller**: `lib/controllers/ai_chat_controller.dart` (134行)

**分析结果** ✅:
- **功能**: AI聊天界面,15秒无操作跳转贪吃蛇游戏
- **特征**: 示例/彩蛋功能,Mock消息

**决策**: **建议删除** (非核心功能)

---

### 15. Analytics Controller → 删除 �️
**旧 Controller**: `lib/controllers/analytics_controller.dart` (270行)

**分析结果** ✅:
- **功能**: K线图数据,商品价格分析
- **特征**: Mock数据,数据可视化示例

**决策**: **建议删除** (非核心功能)

---

### 16. Shopping Controller → 删除 �️
**旧 Controller**: `lib/controllers/shopping_controller.dart` (284行)

**分析结果** ✅:
- **功能**: API接口商城,轮播图,商品列表
- **特征**: Mock数据,示例电商页面

**决策**: **建议删除** (非核心功能)

---
- **依赖**: `LocationApiService`, `EventsApiService`, `CityApiService`
- **优先级**: 🔴 高 - 核心业务逻辑

**迁移决策**: **需要拆分到两个域**

**拆分方案**:

**1. 城市筛选 → City Domain**
```
扩展 lib/features/city/application/state_controllers/city_state_controller.dart
或创建 city_filter_state_controller.dart

新增功能:
- 按地区/国家/城市筛选
- 价格范围筛选
- 网速/评分筛选
- 气候筛选
```

**2. Meetup → 新建 Event Domain**
```
lib/features/event/
├── domain/
│   ├── entities/
│   │   ├── meetup.dart
│   │   └── meetup_rsvp.dart
│   └── repositories/
│       └── i_event_repository.dart
├── application/
│   └── state_controllers/
│       └── event_state_controller.dart
└── infrastructure/
    └── repositories/
        └── event_repository.dart (使用 EventsApiService)
```

**实现步骤**:
1. **城市筛选部分**:
   - 将筛选逻辑迁移到 `CityStateController`
   - 保持使用 `CityApiService`
2. **Meetup部分**:
   - 创建完整 Event Domain
   - Entity: `Meetup`, `MeetupRsvp`
   - Repository: 实现 RSVP, 城市筛选等逻辑
   - 使用 `EventsApiService`

---

### 16. User Profile Controller 🔴
**旧 Controller**: `lib/controllers/user_profile_controller.dart` (231行)

**分析结果** ✅:
- **功能**:
  - 加载用户资料 (使用 `GetCurrentUserUseCase`)
  - 监听 `UserStateController.loginStateChanged`
  - 未登录时重定向
  - 管理编辑模式
- **问题**: 与 `UserStateController` 功能重叠
- **优先级**: 🔴 高 - 核心用户功能

**迁移决策**: **合并到现有 UserStateController**

**行动**:
1. 分析 `user_profile_controller.dart` 的所有功能
2. 将以下功能合并到 `lib/features/user/presentation/controllers/user_state_controller.dart`:
   - `loadUserProfile()` 方法
   - `editMode` 状态管理
   - 登录状态监听逻辑
3. 搜索所有使用 `UserProfileController` 的页面
4. 替换为 `UserStateController`
5. 删除 `user_profile_controller.dart`

---

### 17. Locale Controller 🟢
**旧 Controller**: `lib/controllers/locale_controller.dart` (80行)

**分析结果** ✅:
- **功能**: 管理应用语言(中文/英文)
- **特征**: 全局UI设置,简单响应式状态
- **优先级**: 🟢 低 - 功能正常

**迁移决策**: **保持现状** (全局服务,不需要DDD)

**行动**: 无需迁移,保持使用

---

### 18. Location Controller 🟡
**旧 Controller**: `lib/controllers/location_controller.dart` (156行)

**分析结果** ✅:
- **功能**: 
  - 包装 `LocationService`
  - GPS定位
  - 反向地理编码
  - 自动更新定时器
- **问题**: 仅是薄包装层,价值有限
- **优先级**: 🟡 中 - 功能性但可优化

**迁移决策**: **可选删除**

**选项**:
- **选项A**: 删除,直接在页面中使用 `LocationService`
- **选项B**: 保留,如果需要跨页面共享定位状态

**建议**: 检查使用情况后决定

---

### 19. Bottom Nav Controller 🟢
**旧 Controller**: `lib/controllers/bottom_nav_controller.dart` (~100行)

**分析结果** ✅:
- **功能**: 管理底部导航栏索引和显隐
- **特征**: 纯UI逻辑,无业务规则
- **优先级**: 🟢 低 - 功能正常

**迁移决策**: **保持现状** (纯UI逻辑)

**行动**: 无需迁移,保持使用

---

### 20. AI Chat Controller 🟢
**旧 Controller**: `lib/controllers/ai_chat_controller.dart` (134行)

**分析结果** ✅:
- **功能**: AI聊天界面,15秒无操作跳转贪吃蛇游戏
- **特征**: 示例/彩蛋功能,Mock消息
- **优先级**: 🟢 低 - 非核心功能

**迁移决策**: **建议删除** (示例功能)

**行动**:
- 确认是否为核心功能
- 如果不是,删除相关页面和路由

---

### 21. Analytics Controller 🟢
**旧 Controller**: `lib/controllers/analytics_controller.dart` (270行)

**分析结果** ✅:
- **功能**: K线图数据,商品价格分析
- **特征**: Mock数据,数据可视化示例
- **优先级**: 🟢 低 - 非核心功能

**迁移决策**: **建议删除** (示例页面)

**行动**:
- 确认是否为核心功能
- 如果不是,删除相关页面和路由

---

### 22. User State Controller (Old) 🟡
**旧 Controller**: `lib/controllers/user_state_controller.dart`

**分析结果**:
- **问题**: 与 DDD 版本的 `UserStateController` 重名
- **位置冲突**:
  - 旧版: `lib/controllers/user_state_controller.dart`
  - DDD版: `lib/features/user/presentation/controllers/user_state_controller.dart`

**迁移决策**: **需要检查并删除旧版本**

**行动**:
1. 搜索所有导入旧版本的文件
2. 替换为 DDD 版本
3. 删除旧文件
1. 读取 `data_service_controller.dart` 分析功能
2. 确认是否与 Repository 重复
3. 决定处理方式

---

### 16. AI Chat Domain ⏳
**旧 Controller**: `lib/controllers/ai_chat_controller.dart`

AI 聊天功能:
- 可能与 `AiStateController` 重复?
- 需要确认范围

**行动**:
1. 读取 `ai_chat_controller.dart` 分析功能
2. 与 `AiStateController` 对比
3. 决定合并或分离

---

## ❌ 问题 Controllers (引用不存在的文件)

### 17. Add Coworking Controller
**文件**: `lib/controllers/add_coworking_controller.dart`
**问题**: 引用 `city_option.dart`, `country_option.dart` (不存在)
**决定**: 删除或修复

### 18. Chat Controller
**文件**: `lib/controllers/chat_controller.dart`
**问题**: 引用 `chat_model.dart` (不存在)
**决定**: 删除或修复

---

## 🗑️ 示例代码 (可直接删除)

### 19. Counter Controller
**文件**: `lib/controllers/counter_controller.dart`
**类型**: 示例代码
**决定**: 直接删除

### 20. Snake Game Controller
**文件**: `lib/controllers/snake_game_controller.dart`
**类型**: 示例代码
**决定**: 直接删除

---

## 📦 已迁移 (可安全删除)

### 21. Coworking Controller ✅
**文件**: `lib/controllers/coworking_controller.dart`
**替代**: `CoworkingStateController`
**决定**: 可安全删除

### 22. Pros and Cons Add Controller ✅
**文件**: `lib/controllers/pros_and_cons_add_controller.dart`
**替代**: `ProsConsStateController`
**决定**: 可安全删除

---

## 🎯 执行计划

### Phase 1: 分析评估 (当前阶段)
```
1. 逐个读取需要迁移的 controller
2. 分析功能和职责
3. 确定迁移策略
4. 创建详细的迁移计划
```

### Phase 2: 功能域迁移
```
1. 对于核心业务域,创建完整 DDD 架构:
   - Domain Layer (Entity + Repository Interface)
   - Application Layer (Use Cases + State Controller)
   - Infrastructure Layer (Repository Implementation)
   - Presentation Layer (UI 集成)

2. 对于 UI/全局服务,决定:
   - 保留在 controllers 中
   - 或迁移到 services
   - 或重构为更合适的架构
```

### Phase 3: UI 层重构
```
1. 重构所有使用旧 controller 的页面
2. 替换为新的 State Controllers
3. 验证功能正常
```

### Phase 4: 验证测试
```
1. 运行 flutter analyze
2. 测试所有关键功能
3. 确保没有遗漏
```

### Phase 5: 清理删除
```
1. 删除已迁移的旧 controllers
2. 删除示例代码
3. 删除问题文件
4. 清理未使用的 imports
```

---

## 📊 当前进度

| Controller | 状态 | 迁移策略 | 优先级 |
|-----------|------|---------|--------|
| city_state_controller | ✅ 完成 | DDD | - |
| city_detail_state_controller | ✅ 完成 | DDD | - |
| pros_cons_state_controller | ✅ 完成 | DDD | - |
| weather_state_controller | ✅ 完成 | DDD | - |
| coworking_state_controller | ✅ 完成 | DDD | - |
| user_city_content_state_controller | ✅ 完成 | DDD | - |
| ai_state_controller | ✅ 完成 | DDD | - |
| auth_state_controller | ✅ 完成 | DDD | - |
| user_state_controller | ✅ 完成 | DDD | - |
| user_profile_controller | ⏳ 待分析 | ? | 高 |
| locale_controller | ⏳ 待分析 | ? | 中 |
| location_controller | ⏳ 待分析 | ? | 中 |
| analytics_controller | ⏳ 待分析 | ? | 低 |
| bottom_nav_controller | ⏳ 待分析 | ? | 中 |
| community_controller | ⏳ 待分析 | ? | 中 |
| shopping_controller | ⏳ 待分析 | ? | 低 |
| data_service_controller | ⏳ 待分析 | ? | 中 |
| ai_chat_controller | ⏳ 待分析 | ? | 中 |
| add_coworking_controller | ❌ 问题 | 删除 | - |
| chat_controller | ❌ 问题 | 删除 | - |
| counter_controller | 🗑️ 示例 | 删除 | - |
| snake_game_controller | 🗑️ 示例 | 删除 | - |
| coworking_controller (旧) | ✅ 已迁移 | 删除 | - |
| pros_and_cons_add_controller (旧) | ✅ 已迁移 | 删除 | - |

---

## 🚀 下一步行动

1. **开始 Phase 1**: 逐个分析待迁移的 controller
2. **确定优先级**: 根据功能重要性排序
3. **逐个迁移**: 按优先级完成迁移
4. **持续验证**: 每完成一个域就测试验证
5. **最终清理**: 所有迁移完成后统一删除旧文件

---

*计划创建时间: 2025-01-XX*
*更新时间: 持续更新*
