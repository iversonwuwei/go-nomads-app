# Go-Nomads App UI Secondary Module Cleanup

## Goal

- 一次性清理一级产品页之下残留的二级内容模块壳层差异，不再按小批次反复推进。
- 将二级标题、二级交互卡片、二级 empty/loading state 收口到统一 shared surface 语言。

## Scope

- Home
  - Explore Dashboard 的 priority queue 子区块标题。
- Community
  - intelligence 内 questions / field notes 的子区块标题。
- Profile
  - ProfileSectionHeader 的统一封装。
  - Snapshot 外层 section。
  - Profile Header bio 卡片。
  - Travel History / Travel Plans 的 loading、empty、interactive card surface。
  - Collaboration 的 tag empty state。
  - Skills / Interests 的 empty state。
  - Badges / Social Links / Nomad Stats 的 section header 与卡片 surface。

## Shared Primitives

- `AppSubsectionHeader`
  - 统一二级模块标题、可选 subtitle、icon、trailing、clickable header。
- `AppCardSurface`
  - 统一可点击或静态卡片的圆角、边框、背景、点击反馈和 padding。
- `AppStateSurface`
  - 继续承担 loading / message / empty 容器；本轮作为二级内容模块的默认状态容器。

## Execution

- [completed] 新增 `AppSubsectionHeader`。
- [completed] 新增 `AppCardSurface`。
- [completed] Home / Community 内部子区块标题切到统一二级标题组件。
- [completed] ProfileSectionHeader 改为包装统一二级标题组件。
- [completed] Snapshot 外层切到 `AppSectionSurface`。
- [completed] Travel History / Travel Plans 的 loading / empty / latest card 切到统一 surface。
- [completed] Skills / Interests / Collaboration 的空态切到统一 state surface。
- [completed] Badges / Social Links / Nomad Stats / Profile Header bio 切到统一 card surface，并移除 Profile 页面残余旧 wrapper。

## Acceptance

- 活跃主链路中不再残留“手写二级标题样式 + 局部空态容器 + CockpitPanel 交互卡片”混搭模式。
- `flutter analyze` 对本轮变更文件通过。
- Home / Community / Profile 本轮覆盖范围内不再残留 `CockpitPanel` / `CockpitSectionHeader` 旧壳层。
- 文档与实现状态保持同步。

## Rollback

- 所有改动均基于新增 shared primitive 或对旧 wrapper 的兼容替换。
- 若单个二级模块视觉回退，可按模块回滚，不影响其他页面继续使用 shared surface。
