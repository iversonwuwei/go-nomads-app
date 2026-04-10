# Go-Nomads App Digital Nomad P0 Execution Plan

## 1. Requirement Frame

### 目标

- 将 P0 从产品 backlog 转成可实施的客户端与服务协同执行稿。
- 优先完成一级导航重组、数字游民首页、迁移工作台、预算中心、签证中心、城市决策页。
- 保证现有路由兼容、登录态恢复稳定、AI 能力平滑收敛，不触发不可控大改。

### 当前代码现实

- 当前底部导航仍为 Home / 消息 / AI / AI Planner / 通知 / 我的。
- Travel Plan 现有实体偏旅行内容生成，聚合了交通、住宿、行程、餐厅、景点与预算，并不适合作为迁移工作台直接复用。
- Cost 相关能力仍以城市内容录入为主，缺少用户级预算中心。
- Visa 相关功能在 Flutter 客户端中尚未形成独立 feature。
- User Profile 具备基础游民统计，但缺少“下一站、预算档位、工作时区、长住偏好”等数字游民匹配信息。

### 约束

- 继续遵循 GetX feature 化结构，不回退成 pages 目录堆叠。
- 尽量复用现有 city、travel_plan、user_profile、chat、meetup、hotel、coworking 能力。
- 新增入口需要支持灰度或保留旧入口回退。
- P0 阶段不引入复杂推荐系统，不先做 P2 级智能化。
- 当前 P0 至 P2 阶段优先交付功能闭环，不在中途做大面积 UI 换皮。
- 全部 P* 功能完成后再启动统一 UI/UX 重设计，设计方向参考新能源车 App 的驾驶舱式信息组织与高焦点交互。
- 2026-04 新决策: 进入 Post-P UI 标准化阶段，优先做高频交互与基础组件统一，不一次性重写全部页面。
- 本轮先收口提示文字、图标语义、反馈组件、表单壳层、弹层/底部抽屉和状态卡，再逐步扩展到一级产品页。
- 本轮 UI 优化不得改变既有业务契约、导航语义、登录态恢复和关键写操作链路。

## 2A. Post-P UI Standardization Wave

### 目标

- 将 go-nomads-app 从“局部有驾驶舱风格”收口为“整端有统一产品语言”的 Flutter 应用。
- 统一提示文字语气、图标来源、组件语义、状态反馈和表单容器，减少页面之间的视觉与交互漂移。
- 优先提升登录前链路、系统反馈组件、权限提示和基础操作组件的专业度与可复用性。

### 首批范围

- Auth 流程: login、register、forgot password。
- 反馈组件: toast、loading dialog、bottom drawer、inline notice、empty/error/loading state。
- 图标标准: 通用功能图标、状态图标、品牌图标的来源和尺寸规则。
- 通用容器: hero header、section card、form field shell、action row。

### 统一标准

- 提示文字分为四类: success、error、warning、info；标题和正文语气保持简短、明确、可执行，不使用教程式长句。
- 图标分为三类: navigation/system 使用 Material Symbols 语义图标；brand/platform 使用 FontAwesome 品牌图标；高频产品动作使用统一 token 映射，禁止页面内临时挑选相近 icon。
- 组件统一遵循 token 化约束: 颜色、圆角、间距、描边、阴影、状态色由公共配置导出，页面不再散写魔法数和临时色值。
- 表单与反馈组件必须同时覆盖 loading、error、empty、disabled、success 五类状态，避免只做 happy path 视觉。

### 分阶段实施

- Phase 1: 建立通用 token 与组件封装，落地 auth + feedback 场景。
- Phase 2: 将权限弹窗、分享面板、举报、列表空态和状态卡切到统一语义。
- Phase 3: 将 Explore / Land / Community / Inbox / Me 的局部页面壳层统一到同一套组件语言。

### 当前执行状态

- 已完成 Phase 1: auth、toast、loading dialog、bottom drawer 的基础组件标准化。
- 已完成 Phase 2 的高频交互子集: 权限用途说明、分享面板、举报面板、顶部动作按钮已统一到同一套 token 与 icon 规则。
- 已启动 Phase 3: 新增 `AppSectionSurface` 与 `AppStateSurface`，并已接入 Explore Dashboard、Land Hub、Community、Inbox、Me 的 section shell 与 loading/empty/error 面板。
- 已开始推进二级模块: Profile 的协作资料模块已切到共享 section surface，tag 空态也接入了统一 state surface。
- Profile 的 Snapshot、Travel History、Travel Plans 也已开始接入统一二级内容语言，其中 section 外壳与 loading/empty 卡片优先切到共享 surface。
- 已形成并执行 [DIGITAL_NOMAD_UI_SECONDARY_MODULE_CLEANUP.md](DIGITAL_NOMAD_UI_SECONDARY_MODULE_CLEANUP.md)，本轮范围内的 Home / Community / Profile 二级标题、二级交互卡片、二级 empty/loading state 以及 Profile 深层资料卡片已按执行单完成统一，并通过定向 `flutter analyze`。
- Phase 3 下一步只保留更深层的详情区块和复杂状态卡，不再继续回头修本轮执行单已覆盖的模块。

### 验收标准

- 同类提示在不同页面的标题结构、颜色语义、图标语义保持一致。
- 登录前主链路不再出现多套 loading/dialog/toast 样式并存。
- 新增 UI 组件至少在两个真实页面复用，而不是只为单页包装。
- `flutter analyze` 通过；高频路径至少完成登录、找回密码、权限提示三类场景静态验证。

### 回滚边界

- 所有 UI 标准化优先采用“新增公共组件 + 页面渐进替换”的方式，不直接删除旧组件实现。
- 若某个页面替换后出现体验回退，可单页回退到原组件，不影响其他页面。

## 2. Target Information Architecture

### 新一级导航

- 探索 Explore
- 落地 Land
- 社区 Community
- 收件箱 Inbox
- 我的 Me

### 导航迁移映射

- Home -> Explore Dashboard
- AI Assistant Tab -> 取消一级入口，改为全局助手入口
- AI Planner Tab -> 并入 Land / Migration Workspace
- Conversations + Notifications -> 聚合到 Inbox
- Profile -> 保留为 Me

### 首页重构原则

- 不再只展示城市和 Meetup。
- 首屏必须表达“我下一步该做什么”。
- 首页卡片按任务优先级排序，而不是按内容类型排序。
- 当前 Explore Dashboard 先保证任务流与模块聚合正确，视觉语言后续统一进入 Post-P 设计阶段重构。

### Explore Dashboard 首屏卡片建议

- 推荐城市卡片
- 当前目标城市卡片
- 预算差值卡片
- 签证倒计时卡片
- 本周 Meetup 卡片
- 迁移计划进度卡片
- 全局 AI 助手快捷入口

## 3. P0 Workstreams

### Workstream A 导航与首页重构

#### 客户端任务

- 重构 bottom_nav 的 item 和路由索引。
- 新增 Explore、Land、Community、Inbox、Me 五个主入口容器。
- 首页改造成 Explore Dashboard。
- 消息和通知入口从分离状态收敛为 Inbox 总入口。
- 增加全局 AI 助手入口，优先使用浮动入口或顶部 action。

#### 影响文件范围

- lib/layouts/bottom_nav/
- lib/routes/app_routes.dart
- lib/pages/home/
- lib/pages/conversations/
- lib/pages/notifications_page.dart

#### 兼容策略

- 旧路由 home、conversations、notifications、aiAssistantTab、aiPlannerTab 继续保留。
- 旧入口点击后跳转到新容器中的对应页面，而不是直接删除。

### Workstream B 城市详情升级为决策页

#### 客户端任务

- 在城市详情页增加数字游民决策指标区域。
- 增加城市对比 CTA。
- 增加推荐住宿、推荐办公、推荐 Meetup、加入迁移工作台 CTA。
- 成本、天气、地图、评分卡片重新组合为决策面板。

#### 最小字段集

- estimatedMonthlyBudget
- networkQualityScore
- videoCallFriendlinessScore
- visaFriendlinessScore
- timezoneOverlapScore
- communityActivityScore
- climateStabilityScore
- safetyScore

#### 影响文件范围

- lib/pages/city_detail/
- lib/features/city/
- lib/features/weather/

### Workstream C Migration Workspace

#### 客户端任务

- 将现有 Travel Plan 升级为 Migration Workspace UI。
- 保留 AI 生成行程内容，但在迁移工作台中降级为辅助区块，不再作为主体。
- 新增迁移阶段状态、任务清单、签证卡、预算卡、住宿卡、办公卡。

#### 设计原则

- 一个迁移计划就是一个项目。
- 页面首屏优先展示阶段、风险、待办，而不是景点/餐厅。
- 旅行内容卡片后置到“探索建议”区域。

#### 影响文件范围

- lib/pages/travel_plan/
- lib/pages/create_travel_plan/
- lib/features/travel_plan/

### Workstream D Budget Center

#### 客户端任务

- 新增预算中心入口和预算概览页。
- 把城市成本录入与个人预算视图分离。
- 增加月预算、阶段预算、城市预算预测、超支提醒。

#### 复用逻辑

- 复用 add_cost 和 manage_cost 的录入与类别结构。
- 新增个人预算聚合模型，不直接污染城市内容模型。

#### 影响文件范围

- lib/pages/add_cost/
- lib/pages/manage_cost_page.dart
- lib/controllers/add_cost_page_controller.dart
- lib/controllers/manage_cost_page_controller.dart
- 新增 lib/features/budget/

### Workstream E Visa Center

#### 客户端任务

- 新增签证列表页、签证详情页、创建/编辑页。
- 在目标城市与迁移计划中显示签证摘要卡。
- 增加停留天数倒计时、材料清单、续签提醒。

#### 新增模块建议

- lib/features/visa/
  - domain/
  - application/
  - infrastructure/
  - presentation/

### Workstream F Nomad Profile 最小升级

#### 客户端任务

- 在现有 UserProfile 上扩展数字游民字段。
- 增加下一站、工作时区、预算档位、工作方式、语言能力、长住偏好。
- 在个人页展示“当前迁移状态”和“偏好标签”。

#### 影响文件范围

- lib/features/user_profile/
- lib/pages/profile/
- lib/pages/profile_edit_page.dart

## 4. Route And Module Mapping

### 建议新增主路由

- /explore
- /land
- /community-hub
- /inbox
- /me
- /budget-center
- /visa-center
- /migration-workspace

### 旧路由兼容映射

- /home -> /explore
- /ai-assistant-tab -> 当前页面保留，但入口迁移到全局助手
- /ai-planner-tab -> /migration-workspace
- /conversations -> /inbox?tab=messages
- /notifications -> /inbox?tab=notifications
- /travel-plan -> /migration-workspace

### 模块落位建议

- explore feature
  - 首页仪表盘、城市对比、推荐城市
- land feature
  - 落地中心、预算、签证、住宿、办公、迁移清单
- inbox feature
  - 消息、通知、系统提醒聚合
- migration feature
  - 迁移计划、阶段、任务、风险、时间线

## 5. Data Model Delta

### TravelPlan -> MigrationWorkspace 迁移建议

#### 保留字段

- destination
- budget
- accommodation
- departureLocation
- departureDate

#### 降级为辅助字段

- dailyItineraries
- attractions
- restaurants
- tips

#### 新增字段

- stage
- targetMoveDate
- checklists
- visaSummary
- workspacePreferences
- stayPreferences
- budgetSnapshot
- riskFlags
- linkedMeetups
- linkedCoworkingSpaces
- linkedStays

### Budget Center 最小模型

- MonthlyBudget
- BudgetCategorySummary
- BudgetForecast
- BudgetAlert
- BudgetEntry

### Visa Center 最小模型

- VisaProfile
- VisaRuleSummary
- StayRecord
- VisaChecklistItem
- VisaReminder

### UserProfile 扩展字段建议

- nextDestinationCityId
- nextDestinationCityName
- preferredBudgetLevel
- workTimezone
- workMode
- languages
- stayPreference
- coworkingPreference
- relocationStatus

## 6. Minimal API Contract Draft

### City Intelligence API

#### GET /api/v1/cities/{cityId}/nomad-summary

返回：

- cityId
- monthlyBudgetRange
- networkQualityScore
- videoCallFriendlinessScore
- visaFriendlinessScore
- timezoneOverlapScore
- communityActivityScore
- climateStabilityScore
- safetyScore
- recommendedCoworkings[]
- recommendedStays[]
- upcomingMeetups[]

### Migration Workspace API

#### GET /api/v1/migrations

返回用户迁移计划列表。

#### POST /api/v1/migrations

创建迁移计划。

#### GET /api/v1/migrations/{migrationId}

返回完整迁移工作台数据。

#### PATCH /api/v1/migrations/{migrationId}

更新阶段、日期、偏好、任务状态。

### Budget API

#### GET /api/v1/budgets/current

返回当前预算快照。

#### POST /api/v1/budgets/monthly

创建月预算。

#### GET /api/v1/budgets/forecast

按城市与阶段返回预算预测。

### Visa API

#### GET /api/v1/visa/profiles

返回用户签证档案列表。

#### POST /api/v1/visa/profiles

创建签证档案。

#### GET /api/v1/visa/rules/{countryCode}

返回国家签证摘要与停留规则。

### Inbox API

#### GET /api/v1/inbox/summary

聚合返回：

- unreadMessages
- unreadNotifications
- budgetAlerts
- visaAlerts
- pendingTasks

## 7. Delivery Slices

### Slice 1 导航重构与 Explore Dashboard

- 重构底部导航。
- 新建 Explore 容器。
- Inbox 总入口就位。
- 保留旧路由兼容。

### Slice 2 Migration Workspace 替换 Travel Plan 主入口

- Travel Plan 首屏改为迁移工作台。
- AI 行程内容下沉到辅助区。
- 城市详情增加“加入迁移工作台”。

### Slice 3 Budget Center

- 新建预算中心。
- 打通预算摘要卡与城市成本录入。
- 首页展示预算差值摘要。

### Slice 4 Visa Center

- 新建签证中心。
- 首页与迁移工作台展示签证卡。
- 先支持手动录入和本地提醒。

### Slice 5 City Decision Upgrade

- 城市详情新增决策指标和推荐资源。
- 加入城市对比与迁移 CTA。

## 8. Validation Plan

### 客户端验证

- Flutter analyze
- 新旧路由兼容测试
- 登录态恢复后导航状态检查
- BottomNav 索引与深链跳转检查
- Migration Workspace 创建、编辑、返回列表流程验证
- Budget Center 创建预算与展示摘要验证
- Visa Center 创建记录、倒计时、提醒验证

### 场景验证

- 未登录进入新入口时的拦截与回退
- 从城市详情进入迁移工作台
- 从收件箱进入具体待办
- 预算与签证摘要在首页可见

### 未验证风险

- 若后端 API 未同步交付，客户端需先用本地 mock 或兼容 DTO。
- 若 AI Planner 与 Migration Workspace 一起改动过大，需分批发布。

## 9. Rollback Strategy

### 可快速回退项

- 新一级导航入口可回退到旧索引映射。
- Explore Dashboard 可暂时退回旧 HomePage。
- Inbox 可退回原 Conversations/Notifications 分入口。

### 需谨慎发布项

- TravelPlan -> MigrationWorkspace 数据模型升级。
- Profile 扩展字段的 DTO 兼容。
- 预算中心与城市成本模型分离。

### 回退要求

- 路由名不直接删除。
- 新增字段默认 optional。
- DTO 映射必须允许服务端未返回新增字段时安全降级。

## 10. Recommended Next Dev Tasks

### 客户端优先顺序

1. 重构 bottom_nav 与新主入口容器。
2. 产出 Migration Workspace 页面框架。
3. 新建 features/budget。
4. 新建 features/visa。
5. 升级 city_detail 为决策页。

### 服务端优先顺序

1. 输出 Migration Workspace DTO。
2. 输出 Budget API 最小契约。
3. 输出 Visa API 最小契约。
4. 输出 City Nomad Summary 聚合接口。

### 协作建议

- 设计侧先跟进导航、Explore Dashboard、Migration Workspace 三个关键页面。
- 后端与客户端先围绕 DTO 草案对齐，不先做全部业务细节。
- 埋点同步进入 P0，不要等 UI 完成后再补。
