# UI Standardization Phase 3 Completion Plan

## 1. Goal

- 一次性收掉当前 Post-P UI 标准化 Phase 3 中剩余的二级内容壳层与局部旧组件写法。
- 以共享 surface 为核心，把一级产品页之下的二级内容模块统一到同一套 section / state / card / nested-header 语言。
- 不改业务契约、不改路由、不改交互语义，只做可验证、可回退的 UI 结构收口。

## 2. Scope

### 已确认需本轮清理的残留点

- Home Dashboard
  - 优先队列区块仍使用局部 `CockpitSectionHeader`。
- Profile Secondary Modules
  - `TravelHistoryWidget` 的最新旅行卡片仍使用 `CockpitPanel`。
  - `TravelPlansWidget` 的最新计划卡片仍使用 `CockpitPanel`。
  - `TravelHistoryWidget` / `TravelPlansWidget` 的 loading / empty 已切到统一 `AppStateSurface`，本轮继续补齐交互卡片容器语言。
- Shared Primitives
  - 增加二级内容统一所需的共享件，避免继续在页面内散写“标题 + 间距 + 透明卡片边框 + 背景色”模式。

### 非目标

- 不重写具体业务卡片内容布局。
- 不触碰后端接口、状态管理和导航结构。
- 不做视觉大改，只做结构性统一。

## 3. Target Components

- `AppSubsectionHeader`
  - 统一 section 内部二级标题与可选 subtitle。
  - 用于 Home Dashboard priority queue 等“卡内再分组”场景。
- `AppCardSurface`
  - 统一二级内容卡片的圆角、边框、背景和内边距。
  - 支持普通内容卡和可点击卡片两类场景。

## 4. File Targets

- `lib/widgets/surfaces/app_subsection_header.dart`
- `lib/widgets/surfaces/app_card_surface.dart`
- `lib/pages/home/widgets/home_nomad_dashboard.dart`
- `lib/pages/profile/widgets/travel_history_widget.dart`
- `lib/pages/profile/widgets/travel_plans_widget.dart`

## 5. Acceptance

- 上述目标文件不再依赖局部 `CockpitSectionHeader` / `CockpitPanel` 完成本轮目标内的二级内容壳层。
- 新增共享件至少在两个真实页面或模块中复用。
- `flutter analyze` 对受影响文件通过。
- 可通过 grep 验证目标文件中的旧壳层引用已被替换。

## 6. Rollback

- 若单个模块接入共享件后体验异常，可单文件回退，不影响其他模块。
- 新增共享件保持小而薄，不承载业务状态。
