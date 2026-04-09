# Go-Nomads App Digital Nomad Implementation Sync

<!-- markdownlint-disable-file MD024 -->

## 1. Purpose

- 记录 go-nomads-app 当前已落地的数字游民产品改造，避免前端实现继续领先于文档。
- 作为 backend API 开发与 Flutter 对接的同步基线。
- 将“已完成页面重构”“当前调用契约”“下一步需要服务端承接的聚合口”放在同一份文档里维护。

## 2. Frontend State Snapshot

### 已完成的一级产品面

- Explore / Land / Community / Inbox / Me 五个一级入口已替换旧 Home / AI Planner / 分离消息通知入口的信息架构。
- Explore Dashboard 已切换为 GET /api/v1/explore-dashboard/current 单接口读取，并以任务优先级组织首页卡片。
- Land Hub 已完成无顶栏、glass 语言和落地 checklist 结构化改造，并切换为 GET /api/v1/land-hub/current 单接口读取。
- Community 主页面与详情流已完成结构重组，重点支持 meetup、问答、协作和圈层入口。
- Inbox Hub 已完成消息、通知、系统动作聚合入口。
- Profile 主页面、Travel Plans、Travel History、Travel Plan Detail 已完成现代化与产品级信息收敛。

### 已完成的产品级收敛规则

- 一级产品页已持续执行去说明化，不在主页面保留教程式说明、内部研究语境和过长 subtitle。
- Hero、Section Header、Action Card 默认优先展示标题、状态、指标和动作，不再承担说明书职能。
- 共享视觉语言已统一到 glass panel / hero / metric / action card 组件体系。

### Phase Delivery Reality

- P0 当前整体状态: 部分完成。
- 已落地的 P0 切片主要是入口和高价值决策面聚合: Explore Dashboard、Land Hub、Inbox Hub、Profile Snapshot、Community Snapshot v2、City Nomad Summary，以及一级信息架构重组。
- 这些切片大多属于 backend-driven 数据收口，不等于对应完整页面或完整 epic 已全部完成。
- Migration Workspace 已切到真实 plan-level 状态源，阶段、待办和时间轴写入 `ai_travel_plans.plan_data.migrationWorkspace`，Flutter 页面补齐了最小编辑入口。
- Budget Center 已切到真实预算基线写模型，月预算目标、模板、提醒阈值和分类预算写入 `ai_travel_plans.plan_data.budgetWorkspace`。
- Visa Center 已切到真实签证档案写模型，签证类型、停留区间、材料清单和提醒时间写入 `ai_travel_plans.plan_data.visaWorkspace`。
- City Detail 决策面板已消费 City Nomad Summary 的预算信号、推荐住宿、推荐共享办公和即将举行的 meetup 预览；guide prose、tabs、hotel/coworking/meetup 独立列表和详情页仍没有整体改造。
- Community 现在补上了真实 Q&A 写模型和互动持久化；首页 intelligence feed 与 question detail 优先消费真实 `community_questions/community_answers` 数据，独立 Meetup 列表、详情页、RSVP、SignalR 主链路仍未纳入本轮。
- P1 当前状态: 未系统启动。Nomad Circles、联合办公增强、长住/Coliving、收件箱统一化深化、Nomad Profile 匹配升级仍是 backlog。
- P2 当前状态: 未系统启动。上下文 AI 助手、自动化推荐匹配、国际化/本地协助工具、商业化增强仍是 backlog。
- Post-P 当前状态: 未启动。统一 UI/UX 驾驶舱式重设计应在 P* 功能主链路基本闭环后再进入。
- 工程说明: 当前策略一直是按风险受控的 backend-driven slice 逐步替换关键决策面，而不是一次性完成全量页面重写；因此“很多页面还没有完成改造”是当前真实状态，不是你看错了。

## 3. Current API Usage Matrix

### 已对齐并已在客户端使用的接口

- GET /api/v1/explore-dashboard/current
  - 用途: Explore Dashboard 首页聚合读取
  - 客户端: IExploreDashboardRepository
- GET /api/v1/migration-workspace
  - 用途: Migration Workspace 列表与首页摘要
  - 客户端: IMigrationWorkspaceRepository
- GET /api/v1/budgets/current
  - 用途: Budget Center 聚合首页
  - 客户端: IBudgetCenterRepository
- GET /api/v1/visa/profiles
  - 用途: Visa Center 聚合首页
  - 客户端: IVisaCenterRepository
- GET /api/v1/inbox/summary
  - 用途: Inbox Summary 与 Explore Dashboard 摘要
  - 客户端: IInboxSummaryRepository
- GET /api/v1/land-hub/current
  - 用途: Land Hub 聚合读取
  - 客户端: ILandHubRepository
- GET /api/v1/community-snapshot/current
  - 用途: Community 首屏 field notes 聚合读取
  - 客户端: ICommunityRepository.getTripReports
- GET /api/v1/ai/chat/travel-plans/{planId}/detail
  - 用途: Travel Plan 详情、Land Hub 焦点计划明细
  - 客户端: GetTravelPlanDetailUseCase

### 当前仍由客户端拼装的聚合页与候选切片

- Community Hub
  - 当前方式: field notes、questions、recommendations 与 Community 首页 meetup preview 已统一切换为 `/api/v1/community-snapshot/current`；question detail answers 由 snapshot 内嵌 payload 缓存读取，独立 Meetup 列表与详情页继续沿用原有活动模块。
  - 当前约束: Community Snapshot v1 已交付后端聚合接口，但由于 EventService 在服务内调用下 `isJoined` 语义尚不稳定，本轮不强制切换 meetups 数据源，避免回退现有参与状态体验。
- City Detail Decision Panel
  - 当前方式: `CityDecisionPanel` 仍基于 `CityDetailStateController.currentCity` 与 `AiStateController.currentGuide` 在客户端推导 budget、network、video call、visa、timezone、community、climate、safety 等信号。
  - 问题: 城市决策信号与推荐资源没有统一快照，CityDetail、guide、cost summary、meetups、coworking、hotels 的刷新时序分散，导致页面虽然有“决策面板”，但仍缺少真正的 backend-driven nomad snapshot。

## 4. Backend-Driven Slices

### Slice: Explore Dashboard Aggregate API

- 新增接口: GET /api/v1/explore-dashboard/current
- 目标: 由服务端一次返回 Explore Dashboard 所需的 Migration Workspace、Budget Center、Visa Center 与 Inbox Summary，消除首页四次并发聚合。

### Implementation Status

- 已完成: AIService `GET /api/v1/explore-dashboard/current` 聚合接口实现。
- 已完成: HomePageController 改为通过单一 ExploreDashboardRepository 加载首页数字游民摘要。
- 保持不变: 首页 UI 结构、summary cards 和 priority queue 客户端推导逻辑。
- 已验证: `flutter analyze` 覆盖首页改动文件，无静态问题。

### Product + Design Notes

- 首页 UI 结构不重写，继续保持当前 cockpit hero、summary cards 与 priority queue 的视觉语言。
- 本轮只收口数据来源，不扩大首页信息密度，不新增说明型文案，不改变当前 Explore 的导航位置。
- Explore Dashboard 失败时允许局部为空，但页面仍保持现有登录态与空态逻辑，不新增第二套降级视图。
- Priority queue 仍由客户端根据聚合结果推导，先不下沉到后端排序，避免一次切片承担过多行为变化。

### Response Draft

```json
{
  "migrationWorkspace": {
    "totalPlans": 2,
    "activePlans": 1,
    "draftPlans": 1,
    "upcomingDepartures": 1,
    "recommendedAction": "review-upcoming-departure",
    "lastUpdatedAt": "2026-04-06T10:00:00Z",
    "latestPlan": {
      "id": "plan_1",
      "cityId": "bangkok",
      "cityName": "Bangkok"
    },
    "plans": []
  },
  "budgetCenter": {
    "monthlyBudgetTargetUsd": 1800,
    "forecastMonthlyCostUsd": 1650,
    "deltaUsd": 150,
    "activePlanCount": 1,
    "trackedCityCount": 1,
    "budgetHealth": "on_track",
    "recommendedAction": "finalize-budget-baseline",
    "lastUpdatedAt": "2026-04-06T10:00:00Z",
    "focusPlan": {},
    "plans": []
  },
  "visaCenter": {
    "activeProfileCount": 1,
    "attentionRequiredCount": 0,
    "reminderReadyCount": 1,
    "recommendedAction": "review-latest-visa",
    "lastUpdatedAt": "2026-04-06T10:00:00Z",
    "focusProfile": {},
    "profiles": []
  },
  "inboxSummary": {
    "unreadNotifications": 3,
    "totalNotifications": 8,
    "actionRequiredCount": 2,
    "latestNotificationAt": "2026-04-06T09:40:00Z",
    "recentNotifications": []
  },
  "lastUpdatedAt": "2026-04-06T10:00:00Z"
}
```

### 客户端对接原则

- HomePageController 改为只依赖一个 ExploreDashboardRepository 获取聚合结果。
- Home Hero、summary cards、priority queue 与未登录 prompt 不重写，只切换数据来源。
- 若聚合接口失败，继续复用当前 dashboardErrorMessage 和首页空态逻辑。

### Slice: Land Hub Aggregate API

- 新增接口: GET /api/v1/land-hub/current
- 目标: 由服务端一次返回 Land Hub 所需的迁移、预算、签证和焦点计划明细，消除客户端多接口拼装

### Implementation Status

- 已完成: Land Hub 已切换为单次读取 GET /api/v1/land-hub/current。
- 已完成: 焦点计划明细由 backend 聚合后返回，客户端不再自行拼 Migration / Budget / Visa / Travel Plan detail。
- 保持不变: Land 页面结构、glass hero、action checklist 和现有错误态表现。

### Response Draft

```json
{
  "migrationWorkspace": {
    "totalPlans": 2,
    "activePlans": 1,
    "draftPlans": 1,
    "upcomingDepartures": 1,
    "recommendedAction": "lock-departure-window",
    "lastUpdatedAt": "2026-04-06T10:00:00Z",
    "latestPlan": {
      "id": "plan_1",
      "cityId": "bangkok",
      "cityName": "Bangkok"
    },
    "plans": []
  },
  "budgetCenter": {
    "monthlyBudgetTargetUsd": 1800,
    "forecastMonthlyCostUsd": 1650,
    "deltaUsd": 150,
    "activePlanCount": 1,
    "trackedCityCount": 1,
    "budgetHealth": "on_track",
    "recommendedAction": "finalize-budget-baseline",
    "lastUpdatedAt": "2026-04-06T10:00:00Z",
    "focusPlan": {},
    "plans": []
  },
  "visaCenter": {
    "activeProfileCount": 1,
    "attentionRequiredCount": 0,
    "reminderReadyCount": 1,
    "recommendedAction": "review-latest-visa",
    "lastUpdatedAt": "2026-04-06T10:00:00Z",
    "focusProfile": {},
    "profiles": []
  },
  "focusTravelPlan": {
    "id": "plan_1",
    "cityId": "bangkok",
    "cityName": "Bangkok",
    "transportation": {},
    "accommodation": {}
  },
  "lastUpdatedAt": "2026-04-06T10:00:00Z"
}
```

### 客户端对接原则

- Land Hub Controller 改为只依赖一个 LandHubRepository。
- UI 不重写结构，只替换数据来源。
- 若聚合接口失败，Land Hub 维持当前错误态，不新增隐式降级逻辑。

### Slice: Profile Snapshot Aggregate API

- 新增接口: GET /api/v1/profile-snapshot/current
- 目标: 由服务端一次返回 Me 页面首屏所需的用户资料、会员快照、Nomad 统计、收藏城市、最新旅行计划与下一站城市摘要，替代客户端多源拼装。

### Implementation Status

- 已完成: UserService 新增 GET /api/v1/profile-snapshot/current，由 ProfileSnapshotService 聚合 users/me、stats、favorite city ids、latest travel plan 与 next destination city。
- 已完成: Profile Snapshot 聚合在 AIService 与 CityService 下游失败时支持部分成功降级，latestTravelPlan 与 nextDestinationCity 可为空。
- 已完成: Flutter ProfileController 切换为单次读取 ProfileSnapshotRepository，并同步 MembershipCard 与 TravelPlansWidget 到快照数据源。
- 已验证: `dotnet build src/Services/UserService/UserService/UserService.csproj` 成功。
- 已验证: `dotnet test tests/UserService.Tests/UserService.Tests.csproj --filter FullyQualifiedName~ProfileSnapshotServiceTests` 成功，2 个测试通过。
- 已验证: `flutter analyze` 覆盖 Profile Snapshot 接入相关文件，无静态问题。

### Product + Design Notes

- 本切片只收口数据来源，不重写 Profile UI 结构，不调整 Hero、snapshot、membership card 和 action list 的视觉布局。
- 用户资料与会员信息继续遵循当前 Me 页面语义，优先复用现有 UserDto 与 membership 字段，不额外引入第二套会员展示模型。
- nextDestinationCity 允许为空；当用户没有旅行计划或城市详情下游失败时，Profile 仍展示基础资料与统计。
- 路由动作、按钮文案、Profile Snapshot 的展示文案与 focus route 推导逻辑暂时继续保留在客户端。

### Response Draft

```json
{
  "user": {
    "id": "user_1",
    "name": "Walden",
    "avatarUrl": "https://example.com/avatar.png",
    "bio": "Remote product builder",
    "currentCity": "Bangkok",
    "skills": [],
    "interests": [],
    "socialLinks": {},
    "membership": {
      "level": 1,
      "levelName": "basic",
      "expiryDate": "2026-12-31T00:00:00Z",
      "isActive": true,
      "aiUsageThisMonth": 4,
      "aiUsageLimit": 30,
      "remainingDays": 180,
      "canUseAI": true,
      "canApplyModerator": false
    }
  },
  "nomadStats": {
    "countriesVisited": 6,
    "citiesLived": 4,
    "daysNomading": 280,
    "tripsCompleted": 9,
    "meetupsCreated": 2,
    "meetupsJoined": 5,
    "favoriteCitiesCount": 8
  },
  "favoriteCityIds": [
    "bangkok",
    "lisbon"
  ],
  "latestTravelPlan": {
    "id": "plan_1",
    "cityId": "bangkok",
    "cityName": "Bangkok",
    "duration": 30,
    "budgetLevel": "medium",
    "travelStyle": "culture",
    "status": "planning",
    "departureDate": "2026-05-01T00:00:00Z"
  },
  "nextDestinationCity": {
    "id": "bangkok",
    "name": "Bangkok",
    "country": "Thailand",
    "timezone": "Asia/Bangkok"
  },
  "lastUpdatedAt": "2026-04-06T10:00:00Z"
}
```

### 客户端对接原则

- ProfileController 改为只依赖一个 ProfileSnapshotRepository 完成首屏加载与路由恢复刷新。
- 现有 membershipController、userController、aiController 的页面展示状态不扩大职责，优先通过聚合结果同步必要字段。
- 若 latestTravelPlan 或 nextDestinationCity 缺失，页面继续沿用当前空态与回退文案，不新增第二套降级视图。

### Slice: Community Snapshot API

- 新增接口: GET /api/v1/community-snapshot/current
- 目标: 为 Community 首屏一次返回当前焦点城市、upcoming meetups、field notes、questions 与 recommendations，把 intelligence feed 从客户端 mock 迁回后端聚合。

### Implementation Status

- 已完成: AIService `GET /api/v1/community-snapshot/current` 聚合接口实现，可返回 focus city、upcoming meetups 与 field notes。
- 已完成: `CommunityRepository.getTripReports()` 改为使用 Community Snapshot 的 `fieldNotes`，Community 页面不再依赖 mock trip reports。
- 已完成: `CommunityRepository.getQuestions()`、`getRecommendations()` 与 `getAnswers()` 改为消费 Community Snapshot 的 `questions`、`recommendations` 与内嵌 `answers`，Community intelligence feed 不再依赖 mock 数据。
- 已完成: Community 首页 meetup 卡片已改为消费 Community Snapshot 的 `upcomingMeetups`，首页不再依赖 `MeetupStateController` 的 preview 数据。
- 保持不变: 独立 Meetup 列表、详情页、SignalR 与 RSVP 主链路保持现有实现；问题点赞、答案点赞与互动动作本轮仍保留本地 optimistic state。
- 已验证: `flutter analyze lib/features/community/infrastructure/repositories/community_repository.dart lib/pages/community_page.dart` 无静态问题。

### Scope Notes

- 本切片只收口 Community 首页中的两块真实数据区域:
  - Meetups: 继续复用 EventService 现有活动能力，由聚合层裁剪为首屏所需的 upcoming meetups。
  - Field Notes: 复用 CityService 用户城市评论，映射成 Community 页面使用的 trip report 卡片数据。
- 本切片新增收口:
  - Questions: 由真实 field notes 映射成 Community intelligence threads，并在 question payload 内嵌 answers。
  - Recommendations: 由城市 pros-cons 与 field notes 映射成结构化 recommendation 列表，先服务状态收口与后续页面复用。
- 暂不纳入本切片:
  - 问题创建、回答发布、投票持久化: 当前仍无独立 Community Q&A 写模型，本轮不新增写接口。

### Next Slice Notes

- Community Snapshot v2 已完成，继续坚持“不新建独立 Community Q&A 服务”的边界。
- 当前 question detail answers 来自 snapshot 内嵌聚合结果；system-generated community signals 不开放私聊入口，避免把无真实作者的答案暴露成可聊天对象。
- Community 首页 meetup preview 切换已完成，只替换首页的 3 条 preview 数据源，没有触碰独立 Meetup 列表、详情页、SignalR 或 RSVP 主链路。
- 下一自然切片应回到 Community Q&A 写模型与互动持久化，而不是继续改首页 preview 展示层。

### Product + Design Notes

- Community 页面现有 hero、layers、meetup list、field notes 列表与 suggested circles 结构不重写，只替换数据来源。
- Suggested circles 继续由客户端基于 user、travel plan 与页面快照推导，不在本切片下沉到后端。
- questions 区块若继续使用客户端数据，不新增“已切后端”的误导性文案，也不强制并入同一个 repository。
- 当 field notes 下游为空时，Community 首屏仍保留 meetups 与 questions，继续沿用当前空态表现。

### Response Draft

```json
{
  "focusCity": "Bangkok",
  "nextCoordinationCity": "Bangkok",
  "upcomingMeetups": [
    {
      "id": "meetup_1",
      "title": "Friday Cowork Sprint",
      "cityId": "bangkok",
      "cityName": "Bangkok",
      "venue": "The Work Loft",
      "startTime": "2026-04-08T09:00:00Z",
      "participantCount": 12,
      "maxParticipants": 20,
      "isJoined": true
    }
  ],
  "fieldNotes": [
    {
      "id": "review_1",
      "userId": "user_2",
      "userName": "Nomad Ada",
      "userAvatar": "https://example.com/avatar.png",
      "city": "Bangkok",
      "country": "Thailand",
      "title": "One month in Ari",
      "content": "Quiet mornings, reliable Wi-Fi, easy BTS access.",
      "overallRating": 4.0,
      "ratings": {
        "internet": 5.0,
        "safety": 4.0,
        "cost": 4.0,
        "community": 4.0,
        "weather": 3.0
      },
      "photos": [],
      "likes": 0,
      "comments": 0,
      "createdAt": "2026-04-05T10:00:00Z"
    }
  ],
  "questions": [
    {
      "id": "question_review_1",
      "userId": "user_2",
      "userName": "Nomad Ada",
      "city": "Bangkok",
      "title": "One month in Ari",
      "content": "Quiet mornings, reliable Wi-Fi, easy BTS access.",
      "tags": ["internet", "safety", "field-note"],
      "upvotes": 0,
      "answerCount": 3,
      "hasAcceptedAnswer": true,
      "createdAt": "2026-04-05T10:00:00Z",
      "isUpvoted": false,
      "answers": [
        {
          "id": "question_review_1-rating-internet",
          "questionId": "question_review_1",
          "userId": "system-community-signal",
          "userName": "Community signal",
          "content": "This review highlights internet at 5/5 for Bangkok.",
          "upvotes": 1,
          "isAccepted": true,
          "createdAt": "2026-04-05T10:00:00Z",
          "isUpvoted": false
        }
      ]
    }
  ],
  "recommendations": [
    {
      "id": "recommendation-note-review_1",
      "city": "Bangkok",
      "name": "One month in Ari",
      "category": "Coworking",
      "description": "Quiet mornings, reliable Wi-Fi, easy BTS access.",
      "rating": 4.0,
      "reviewCount": 1,
      "priceRange": "$$",
      "address": null,
      "photos": [],
      "website": null,
      "tags": ["internet", "safety", "field-note"],
      "userId": "user_2",
      "userName": "Nomad Ada",
      "userAvatar": "https://example.com/avatar.png"
    }
  ],
  "lastUpdatedAt": "2026-04-06T10:00:00Z"
}
```

### 客户端对接原则

- Community 页面通过 `ICommunityRepository` 使用 Community Snapshot 一次性填充 meetup preview、field notes、questions、recommendations 与 question detail answers，移除首页聚合数据的 mock 和多 controller 依赖。
- 独立 Meetup 列表继续保留 `MeetupStateController`，当前不把详情页、RSVP 与 SignalR 主链路并入 Community Snapshot。
- 若聚合接口部分失败，允许 upcomingMeetups、fieldNotes、questions、recommendations 任一侧为空，Community 页面不新增第二套降级布局。

### Slice: City Nomad Summary API

- 新增接口: GET /api/v1/cities/{cityId}/nomad-summary
- 目标: 为 City Detail 决策面板提供单次聚合读取能力，把 budget range、decision signals 与 top resource previews 收口到 backend，避免页面继续从 city detail 与 AI guide 自行推导数字游民决策信号。

### Implementation Status

- 已完成: CityService 已新增 `GET /api/v1/cities/{cityId}/nomad-summary` 聚合接口，返回决策面板当前实际消费的 budget range、decision signals 与 top coworking / stay / meetup 预览数据。
- 已完成: `CityDetailStateController` 已额外加载 City Nomad Summary，`CityDecisionPanel` 优先展示真实 signal 数据；guide 的 visa 文案与现有 tabs 继续保留。
- 已验证: `dotnet build src/Services/CityService/CityService/CityService.csproj` 成功。
- 已验证: `flutter analyze lib/features/city/domain/entities/city_nomad_summary.dart lib/config/api_config.dart lib/features/city/domain/repositories/i_city_repository.dart lib/features/city/infrastructure/repositories/city_repository.dart lib/features/city/application/use_cases/city_use_cases.dart lib/core/di/dependency_injection.dart lib/features/city/presentation/controllers/city_detail_state_controller.dart lib/pages/city_detail/widgets/city_decision_panel.dart` 无静态问题。

### Scope Notes

- 本切片只收口 City Detail 决策面板所需的聚合摘要:
  - Budget range: 基于 CityService 用户费用统计输出 monthly budget range。
  - Decision signals: network、video call、visa、timezone、community、climate、safety 由后端统一计算并返回。
  - Resource previews: 返回 top coworking、top stays、upcoming meetups，先服务决策面板的数据闭环，不重写酒店/Coworking/Meetup 列表页。
- 暂不纳入本切片:
  - City Detail 现有 tabs 的整体重构。
  - AI guide overview、best areas、tips 的后端契约重塑。
  - Compare Cities 页面和其他城市卡片的数据源切换。

### Product + Design Notes

- City Detail 当前 hero、tab 结构、guide 内容块与 action buttons 不重写，只替换决策面板的数据来源。
- `CityDecisionPanel` 继续保留当前视觉结构，不新增大段说明文案，也不把推荐资源扩展成新的大型列表区块。
- 若 City Nomad Summary 下游部分失败，页面允许回退到当前 city detail / guide 的既有展示，不新增第二套布局。

### Response Draft

```json
{
  "cityId": "bangkok",
  "cityName": "Bangkok",
  "country": "Thailand",
  "timezone": "Asia/Bangkok",
  "monthlyBudgetRange": {
    "currency": "USD",
    "min": 900,
    "max": 1800
  },
  "decisionSignals": {
    "networkQualityScore": 88,
    "videoCallFriendlinessScore": 84,
    "visaFriendlinessScore": 78,
    "timezoneOverlapScore": 72,
    "communityActivityScore": 81,
    "climateStabilityScore": 66,
    "safetyScore": 74
  },
  "recommendedCoworkings": [
    {
      "id": "cwk_1",
      "name": "The Work Loft",
      "rating": 4.7,
      "dayPassPrice": 12,
      "currency": "USD"
    }
  ],
  "recommendedStays": [
    {
      "id": "stay_1",
      "name": "Nomad Base Bangkok",
      "rating": 4.5,
      "pricePerNight": 68,
      "currency": "USD"
    }
  ],
  "upcomingMeetups": [
    {
      "id": "meet_1",
      "title": "Friday Nomad Mixer",
      "startTime": "2026-04-06T11:00:00Z"
    }
  ],
  "lastUpdatedAt": "2026-04-06T10:00:00Z"
}
```

### 客户端对接原则

- `CityDetailStateController` 继续负责城市详情首屏状态，但额外维护 City Nomad Summary 的加载与错误状态，不再让 `CityDecisionPanel` 直接从 `City` 和 `DigitalNomadGuide` 推导 signal 数值。
- `CityDecisionPanel` 优先消费 City Nomad Summary；当 summary 缺失或部分字段为空时，允许回退到当前客户端推导逻辑，确保城市详情页不出现空白决策卡。
- hotels、coworking、meetups 的独立页面和现有 tabs 继续维持原数据源，不在本切片强制并表。

## 5. Delivery + Validation

### 文档优先顺序

1. 更新本同步文档
2. 更新 backend 契约文档
3. 实现 backend 聚合接口
4. 切换 Flutter 对接

### 验证要求

- backend: 至少完成目标服务编译或静态错误检查
- app: 至少完成修改文件的 flutter analyze
- 契约: 路径、字段名、可空策略与客户端解析保持一致
