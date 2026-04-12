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
- Visa Center 当前进入产品级收口阶段: 页面保留现有视觉方向，但需要补齐最后刷新时间、焦点档案关键信号、空值兜底、错误文案收敛、提醒动作禁用态、编辑抽屉表单校验、日期选择器、保存中保护和失败回退，避免继续停留在“可演示但不够稳”的状态。
- City Detail 决策面板已消费 City Nomad Summary 的预算信号、推荐住宿、推荐共享办公和即将举行的 meetup 预览；guide prose、tabs、hotel/coworking/meetup 独立列表和详情页仍没有整体改造。
- Community 现在补上了真实 Q&A 写模型和互动持久化；首页 intelligence feed 与 question detail 优先消费真实 `community_questions/community_answers` 数据，独立 Meetup 列表、详情页、RSVP、SignalR 主链路仍未纳入本轮。
- P1 当前状态: 未系统启动。Nomad Circles、联合办公增强、长住/Coliving、收件箱统一化深化、Nomad Profile 匹配升级仍是 backlog。
- P2 当前状态: 未系统启动。上下文 AI 助手、自动化推荐匹配、国际化/本地协助工具、商业化增强仍是 backlog。
- Post-P 当前状态: 已启动 UI 标准化准备阶段。当前先做高频反馈组件、auth 壳层、图标语义和提示文案标准化，不做一次性全量换皮。
- 工程说明: 当前策略一直是按风险受控的 backend-driven slice 逐步替换关键决策面，而不是一次性完成全量页面重写；因此“很多页面还没有完成改造”是当前真实状态，不是你看错了。

## 2A. UI Standardization Baseline

### 当前问题

- glass panel / hero / metric / action card 体系只覆盖部分一级产品面，auth、反馈类组件、弹层和辅助交互仍未收口到统一语言。
- 图标来源混用 Material、FontAwesome 和局部自定义映射，同一语义在不同页面使用不同 icon。
- 提示文字存在英文默认标题、长句提示、重复 toast 和页面内临时拼接文案并存的问题。
- 页面内部仍有较多临时色值、半径、边距和状态样式，组件可复用性不足。

### 本轮标准化原则

- 优先统一语义，而不是先统一皮肤；先把“提示是什么、图标代表什么、组件承担什么职责”收口，再扩展到更大面积视觉升级。
- 提示组件统一为 success / error / warning / info 四类，文案采用“结果 + 下一步”短句结构。
- 图标采用双轨制: 通用系统语义优先 Material Symbols；品牌/平台图标继续用 FontAwesome。公共动作通过 token 映射输出，不允许页面局部随意替换。
- 组件采用渐进替换，不做全量重写。优先覆盖登录前主链路、权限提示、底部抽屉、toast 和状态卡。

### 首批组件目标

- App feedback primitives: toast、loading dialog、inline notice、status card、empty state。
- App form primitives: field shell、section label、helper/error text、submit bar。
- App icon primitives: icon token、size token、state icon mapping。
- App surface primitives: section card、bottom drawer header、modal action row。

### 首批页面接入顺序

- Login / Register / Forgot Password
- First Launch Privacy / Permission Purpose Dialog
- Share / Report / Common Bottom Drawer

### 当前落地状态

- 已完成 Phase 1: auth 链路与反馈基础件已统一到 `AppUiTokens`、`AppIcons`、`AppInputField`、`AppPrimaryButton`、`AuthStepShell`。
- 已完成 Phase 2 的首批高频交互: Permission Purpose Dialog、Share Bottom Sheet、Report Dialog、AppBar/Sliver 的 back/share/report 动作按钮已切到统一容器和 icon 语义。
- 已启动 Phase 3: 新增 `AppSectionSurface`、`AppStateSurface` 两个页面壳层基础件，并已接入 Explore Dashboard、Land Hub、Community、Inbox、Me。
- 已开始把二级模块接到同一套标准件，Profile 的 collaboration widget 已切到共享 section surface，内部 tag 空态已使用统一 state surface。
- Profile 的 snapshot widget 已切到共享 section surface，Travel History 与 Travel Plans 的 loading/empty 卡片也已改用统一 state surface。
- 已补充并执行 [DIGITAL_NOMAD_UI_SECONDARY_MODULE_CLEANUP.md](DIGITAL_NOMAD_UI_SECONDARY_MODULE_CLEANUP.md)：Home / Community 的 subsection header、ProfileSectionHeader wrapper、Profile Header bio、Travel History / Travel Plans 的 interactive card、Badges / Social Links / Nomad Stats 卡片、Skills / Interests 空态均已切到 shared surface 语言。
- 本轮执行单覆盖范围已完成静态验证，Home / Community / Profile 范围内不再残留旧的 `CockpitPanel` / `CockpitSectionHeader` 组合；当前下一步只剩更深层的详情区块和复杂状态卡迁移。

### 风险与边界

- 本轮不改业务接口、不改 backend app/config 契约、不改导航结构。
- 若单个页面在替换统一组件后出现布局或交互回退，允许局部回滚，不阻塞其他页面继续标准化。

## 3. Current API Usage Matrix

### 已对齐并已在客户端使用的接口

- GET /api/v1/explore-dashboard/current
  - 用途: Explore Dashboard 首页聚合读取
  - 客户端: IExploreDashboardRepository
- GET /api/v1/app/config
  - 用途: Flutter 静态配置中心读取，优先承接社区准则文案和首次法律文档同意版本
  - 客户端: AppConfigService
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
- Community Guidelines + First-Launch Legal Consent Version
  - 当前方式: 社区准则页面正文已切到 app/config；首次启动法律文档同意版本已优先读取 app/config。首启隐私弹窗的标题、说明、勾选提示、按钮、底部说明、摘要兜底、未勾选提示和拒绝确认弹窗文案均已优先读取 app/config，并保留本地 fallback。
  - 本轮切片: Flutter 首启隐私弹窗优先读取 `GET /api/v1/app/config` 中 locale 对应的 `legal.first_launch.dialog.*` 静态文本；摘要卡片继续优先读取隐私政策 `summary`，隐私政策/用户协议链接标题优先读取 legal document `title`。当 backend 未发布这些键时，继续回退到客户端本地默认值，确保首启流程不阻塞。
  - 后台治理约束: admin 对 `legal.first_launch.dialog.*` 的修改与发布必须走 Gateway 的 `/api/v1/admin/*` 链路；ConfigService bootstrap 只会修正仍由 bootstrap 持有的默认值，不会覆盖管理员已发布的首启文案。

### App Config Key Contract

- StaticTexts
  - `legal.community_guidelines.sections_json`
    - 含义: 社区准则章节数组 JSON，按 locale 发布。
    - 形状:

      ```json
      [
        {
          "title": "1. 尊重与友善",
          "content": "请尊重他人观点与文化差异，避免人身攻击、歧视、骚扰或仇恨言论。"
        }
      ]
      ```

  - `legal.first_launch.dialog.title`
  - `legal.first_launch.dialog.intro`
  - `legal.first_launch.dialog.privacy_checkbox_prefix`
  - `legal.first_launch.dialog.terms_checkbox_prefix`
  - `legal.first_launch.dialog.decline_tip_prefix`
  - `legal.first_launch.dialog.sdk_link_label`
  - `legal.first_launch.dialog.agree_button`
  - `legal.first_launch.dialog.reject_button`
  - `legal.first_launch.dialog.summary_fallback_title`
  - `legal.first_launch.dialog.summary_fallback_content`
  - `legal.first_launch.dialog.unchecked_toast_title`
  - `legal.first_launch.dialog.unchecked_toast_message`
  - `legal.first_launch.dialog.decline_confirm_title`
  - `legal.first_launch.dialog.decline_confirm_message`
  - `legal.first_launch.dialog.decline_confirm_cancel`
  - `legal.first_launch.dialog.decline_confirm_exit`
  - `auth.forgot_password.step.account.title`
  - `auth.forgot_password.step.account.description`
  - `auth.forgot_password.step.account.input_label`
  - `auth.forgot_password.step.account.send_code_button`
  - `auth.forgot_password.step.verify.title`
  - `auth.forgot_password.step.verify.description_template`
  - `auth.forgot_password.step.verify.code_label`
  - `auth.forgot_password.step.verify.resend_countdown_template`
  - `auth.forgot_password.step.verify.resend_button`
  - `auth.forgot_password.step.verify.next_button`
  - `auth.forgot_password.step.reset.title`
  - `auth.forgot_password.step.reset.description`
  - `auth.forgot_password.step.reset.new_password_label`
  - `auth.forgot_password.step.reset.confirm_password_label`
  - `auth.forgot_password.step.reset.submit_button`
  - `auth.forgot_password.toast.account_required`
  - `auth.forgot_password.toast.code_sent_email`
  - `auth.forgot_password.toast.code_sent_phone`
  - `auth.forgot_password.toast.send_failed_fallback`
  - `auth.forgot_password.toast.code_required`
  - `auth.forgot_password.toast.code_incomplete`
  - `auth.forgot_password.toast.new_password_required`
  - `auth.forgot_password.toast.password_min_length`
  - `auth.forgot_password.toast.confirm_password_required`
  - `auth.forgot_password.toast.password_mismatch`
  - `auth.forgot_password.toast.reset_success`
  - `auth.forgot_password.toast.reset_failed_fallback`
  - `auth.login.terms.prefix`
  - `auth.login.terms.connector`
  - `auth.login.terms.suffix`
  - `auth.register.terms.prefix`
  - `auth.register.terms.connector`
  - `auth.register.terms.community_prefix`
  - `auth.register.terms.suffix`
  - `auth.legal_links.prefix`
  - `auth.legal_links.connector`
  - `auth.legal_links.suffix`
  - `brand.loading.title`
  - `brand.loading.tagline`
  - `brand.footer.copyright`
  - `brand.footer.icp_record`
  - `auth.login.header.title`
  - `auth.login.header.subtitle`
  - `auth.login.link.register_prefix`
  - `auth.login.community.title`
  - `auth.login.community.subtitle`
  - `auth.login.community.badge.meetups`
  - `auth.login.community.badge.messages`
  - `auth.login.community.badge.cities`
  - `auth.register.header.title`
  - `auth.register.header.subtitle`
  - `auth.register.link.login_prefix`
  - `auth.register.highlights.title`
  - `auth.register.highlights.meetups.title`
  - `auth.register.highlights.meetups.subtitle`
  - `auth.register.highlights.people.title`
  - `auth.register.highlights.people.subtitle`
  - `auth.register.highlights.destinations.title`
  - `auth.register.highlights.destinations.subtitle`
  - `auth.register.highlights.chat.title`
  - `auth.register.highlights.chat.subtitle`
  - `auth.register.highlights.travels.title`
  - `auth.register.highlights.travels.subtitle`
  - `legal.first_launch.dialog.decline_tip_link_separator`
  - `legal.first_launch.dialog.decline_tip_link_final_connector`
  - `legal.first_launch.dialog.decline_tip_suffix`
  - `auth.login.form.tab.email`
  - `auth.login.form.tab.phone`
  - `auth.login.form.email.label`
  - `auth.login.form.email.hint`
  - `auth.login.form.password.label`
  - `auth.login.form.password.hint`
  - `auth.login.form.remember_me`
  - `auth.login.form.forgot_password`
  - `auth.login.form.submit_email_button`
  - `auth.login.form.phone.label`
  - `auth.login.form.phone.hint`
  - `auth.login.form.sms_code.label`
  - `auth.login.form.sms_code.hint`
  - `auth.login.form.sms_code.send_button`
  - `auth.login.form.submit_phone_button`
  - `auth.register.form.username.label`
  - `auth.register.form.username.hint`
  - `auth.register.form.email.label`
  - `auth.register.form.email.hint`
  - `auth.register.form.verification_code.label`
  - `auth.register.form.verification_code.hint`
  - `auth.register.form.verification_code.send_button`
  - `auth.register.form.verification_code.resend_button`
  - `auth.register.form.password.label`
  - `auth.register.form.password.hint`
  - `auth.register.form.confirm_password.label`
  - `auth.register.form.confirm_password.hint`
  - `auth.register.form.submit_button`
  - `auth.register.form.toast.terms_required_title`
  - `auth.register.form.toast.terms_required_message`
  - `auth.register.form.toast.welcome_message`
  - `auth.register.form.toast.success_title`
  - `permission.location.purpose_dialog_json`
  - `permission.calendar.purpose_dialog_json`
  - `permission.notification.purpose_dialog_json`
  - `permission.location.dialog.title`
  - `permission.location.dialog.description`
  - `permission.location.dialog.cancel_button`
  - `permission.location.dialog.confirm_button`
  - `permission.location.status.loading`
  - `permission.location.status.disabled`
  - `permission.location.status.enable_action`

- SystemSettings
  - section=`legal_documents`, key=`privacy_policy_version`
  - section=`legal_documents`, key=`terms_of_service_version`

### Client Fallback Rules

- `GET /api/v1/app/config` 失败或未命中目标 key 时，Flutter 必须继续使用本地社区准则文案、首启弹窗默认文案、登录/注册表单默认文案、品牌/备案默认文案、权限用途说明默认文案、位置权限弹窗/状态卡片默认文案和既有默认版本，不能阻塞首次启动、注册或登录流程。
- 后端配置优先级高于本地默认值，但法律文档正文、摘要和文档标题仍继续以 `/api/v1/users/legal/*` 为 source of truth；`app/config` 在本轮负责补充“社区准则正文”“首启隐私弹窗外围与交互文案”“找回密码流程文案”“登录/注册法律包装文案”“登录/注册表单壳层文案”“品牌与备案壳层文案”“权限用途说明弹窗文案”和“本地 consent 版本号”。

### 当前切片: Location Permission Widget Governance

- 目标: 把位置权限请求弹窗与位置状态卡片中的标题、说明、按钮和状态提示迁到 `GET /api/v1/app/config`，让 admin 可在不发版的情况下调整位置权限前置引导文案。
- 范围: 仅迁移 `LocationPermissionDialog` 与 `LocationInfoWidget` 中的文案 ownership，不改变 `controller.getCurrentLocation()` 调用时序、按钮行为、图标、配色或卡片布局。
- 客户端原则: 位置权限弹窗与状态卡片优先读取 `permission.location.dialog.*` 和 `permission.location.status.*`；远端未命中时继续回退到当前本地默认中文，不能阻塞定位申请和位置刷新链路。
- 发布安全: 新 key 保持匿名可读，但只承载公开展示文案；如果 app/config 暂时缺失，位置权限弹窗和位置状态卡片必须继续以本地默认文案正常工作。

### 已完成切片: Pre-Auth Marketing Shell Governance

- 目标: 把登录/注册第一页可见的 header、副标题、跳转提示、登录亮点和注册亮点文案迁到 `GET /api/v1/app/config`，让 admin 可在不发版的情况下调整登录前营销与引导话术。
- 范围: 仅迁移 `LoginHeader`、`LoginCommunityHighlight`、`LoginRegisterLink`、`RegisterHeader`、`RegisterFeatureHighlights`、`RegisterLoginLink` 的文案 ownership；不改变登录模式切换、表单校验、注册提交、图标、emoji 或布局结构。
- 客户端原则: `LoginPage` 与 `RegisterPage` 页面级只读取一次 pre-auth marketing copy，再透传给子组件；远端未命中时继续回退到当前 l10n 文案，不能阻塞匿名用户进入登录/注册页。
- 发布安全: 新 key 保持匿名可读，但只承载公开 marketing / onboarding 文案；若 app/config 暂时缺失，登录/注册页必须继续使用现有本地国际化文案稳定展示。

### 已完成切片: Auth Entry Form Copy Governance

- 目标: 收口首启隐私弹窗 decline tip 中剩余的连接符硬编码，并把登录/注册表单中的 tab、字段标题、placeholder、发送验证码按钮、主 CTA 和注册成功前置 toast 文案迁到 `GET /api/v1/app/config`，让 admin 可在不发版的情况下调整匿名入口表单体验。
- 范围: 仅迁移 `FirstLaunchPrivacyDialog` 的 decline tip 连接符/结尾标点，以及 `LoginPage`、`LoginEmailForm`、`LoginPhoneForm`、`RegisterForm`、`RegisterSubmitButton` 中的展示 copy ownership；不改变登录模式切换、校验语义、验证码发送逻辑、注册提交接口或倒计时行为。
- 客户端原则: `LoginPage` 与 `RegisterPage` 页面级分别只读取一次 entry copy bundle，再透传给 tab 和表单子组件；`FirstLaunchPrivacyDialog` 继续复用现有 dialog copy 结构，只新增 decline tip 链接分隔符 key；远端未命中时继续回退到当前 l10n / 本地默认文案。
- 发布安全: 新 key 保持匿名可读，但只承载公开入口 UI copy；若 app/config 暂时缺失，首启弹窗与登录/注册页必须继续稳定展示并允许用户继续完成登录或注册流程。

### 已完成切片: Auth Entry Feedback Copy Governance

- 目标: 把登录/注册入口动作后的 toast、发送验证码反馈和登录 loading 文案迁到 `GET /api/v1/app/config`，让 admin 可在不发版的情况下调整匿名入口的反馈话术。
- 范围: 仅迁移 `LoginController` 与 `RegisterController` 中用户可见的反馈 copy ownership，包括协议未勾选提醒、短信/邮箱验证码发送反馈、登录成功/失败提示、社交登录 loading 文案和注册失败提示；不改变字段校验规则、倒计时格式、接口错误优先级、社交登录流程或注册提交逻辑。
- 客户端原则: `LoginPage` 与 `RegisterPage` 继续页面级只读取一次 entry copy bundle，但 bundle 会新增 feedback 子结构并注入各自 controller；远端未命中时继续回退到当前 l10n / 本地默认文案，不能阻塞发送验证码、登录、社交登录或注册流程。
- 发布安全: 新 key 保持匿名可读，但只承载公开反馈文案；若 app/config 暂时缺失，控制器必须继续使用现有本地文案完成 toast 与 loading 展示，不能因为 copy 缺失影响交互闭环。

### 已完成切片: Auth Social Entry Copy Governance

- 目标: 把登录页社交登录区域中的分隔线、平台按钮标签和暂未开放入口提示迁到 `GET /api/v1/app/config`，让 admin 可在不发版的情况下调整第三方登录入口的话术。
- 范围: 仅迁移 `LoginSocialButtons` 中分隔线文案、各平台按钮标签，以及 Facebook 暂不可用时的 info toast 标题/内容；不改变中国区/国际区分流、iOS 平台判断、provider 图标配色、社交登录调用顺序或真实 provider 可用性。
- 客户端原则: `LoginPage` 页面级继续只读取一次 entry copy bundle，并新增 social 子结构透传给 `LoginSocialButtons`；按钮点击时仍把当前展示标签传给 `LoginController.handleSocialLogin()`，远端未命中时继续回退现有 l10n / 品牌名。
- 发布安全: 新 key 保持匿名可读，但只承载公开入口 UI copy；若 app/config 暂时缺失，登录页社交入口必须继续稳定展示，Facebook 未开放提示也必须继续使用本地默认文案。

### 当前切片: Auth Form Validation Copy Governance

- 目标: 把登录/注册表单中的字段级校验错误提示和验证码倒计时模板迁到 `GET /api/v1/app/config`，让 admin 可在不发版的情况下调整匿名入口的微交互反馈。
- 范围: 仅迁移 `LoginEmailForm`、`LoginPhoneForm`、`RegisterForm` 中 error text 与倒计时模板的文案 ownership；不改变 controller 内部 error key、字段校验规则、验证码长度判断、倒计时秒数、按钮禁用逻辑或提交接口。
- 客户端原则: 继续复用现有 `LoginFormCopy` / `RegisterFormCopy` 承载新增 validation/countdown 字段；表单组件按 error key 映射远端文案，未命中时回退当前本地默认错误提示或字符串模板，其中倒计时模板使用 `{seconds}` 占位。
- 发布安全: 新 key 保持匿名可读，但只承载公开表单文案；若 app/config 暂时缺失，登录/注册表单必须继续正常显示字段错误与验证码倒计时，不能影响输入校验和发送按钮状态机。

### 下一切片: Forgot Password Copy Governance

- 目标: 把 forgot-password 三步流中的标题、步骤说明、按钮和关键 toast 迁到 `GET /api/v1/app/config`，让 admin 可以在不发版的情况下调整登录前找回密码体验。
- 范围: 仅迁移文案 ownership，不改变找回密码接口契约、步骤流转、验证码发送逻辑或密码重置写接口。
- 客户端原则: ForgotPasswordController 在进入页面时异步读取 `auth.forgot_password.*`，页面继续走 controller + GetX 现有结构；如果远端未命中则回退到本地默认中文，不阻塞找回密码流程。
- 占位符约束: `auth.forgot_password.step.verify.description_template` 使用 `{target}` 占位脱敏目标，`auth.forgot_password.step.verify.resend_countdown_template` 使用 `{seconds}` 占位倒计时秒数。
- 发布安全: 新 key 仍必须遵循“先发配置、后发消费”或“消费代码自带 fallback”；toast 与步骤标题必须可在空配置下稳定回退。

### 下一切片: Login/Register Legal Wrapper Governance

- 目标: 把登录页勾选框、注册页勾选框以及底部 legal links 的包装层文案迁到 `GET /api/v1/app/config`，让 admin 可调整登录前合规话术，而不改动法律正文标题和跳转逻辑。
- 范围: 仅迁移 wrapper text ownership，不改变 `termsAndConditions`、`privacyPolicy`、`communityGuidelines` 三个链接标题的来源；这些标题仍继续使用现有 l10n / 业务来源。
- 客户端原则: `LoginTermsCheckbox`、`RegisterTermsCheckbox`、`LegalLinksWidget` 直接读取 `auth.login.terms.*`、`auth.register.terms.*`、`auth.legal_links.*`；未命中时回退到当前本地文案。
- 发布安全: 新 key 必须与现有跳转一同保持可空回退，不能因为匿名 app/config 读取失败导致登录/注册页丢失法律链接。

### 下一切片: Brand/Footer Copy Governance

- 目标: 把登录前与全局 loading 壳层中的品牌标题、副标题、版权和备案号迁到 `GET /api/v1/app/config`，让 admin 可在不发版的情况下调整品牌展示与备案信息。
- 范围: 仅迁移 `CopyrightWidget` 和 `AppLoadingWidget` 中的静态壳层文案 ownership，不改变 logo、配色、loading 动效或布局结构。
- 客户端原则: `CopyrightWidget` 读取 `brand.footer.*`，`AppLoadingWidget` 读取 `brand.loading.*`；远端未命中时必须回退到现有本地默认文案，不能影响任意页面的加载态显示。
- 发布安全: 品牌类 key 保持匿名可读，但只允许公开展示文本；如部署顺序出现 app/config 暂时缺失，页面必须继续显示本地默认品牌信息。

### 下一切片: Permission Purpose Dialog Governance

- 目标: 把位置、日历、通知三种权限申请前的用途说明弹窗文案迁到 `GET /api/v1/app/config`，让 admin 可在不发版的情况下调整首次授权前的合规说明。
- 范围: 仅迁移 `PermissionPurposeDialog` 中 title、description、用途列表、note、confirmText 的文案 ownership；图标、配色、弹窗结构、`Get.back()` 关闭行为和后续系统权限申请时序保持不变。
- 客户端原则: `PermissionPurposeDialog` 优先读取 `permission.*.purpose_dialog_json`，按 JSON 解析 title、description、purposes、note、confirmText；远端未命中时继续回退到现有本地默认文案，不能阻塞任何权限申请链路。
- 发布安全: 该批 key 保持匿名可读，但仅包含公开合规说明文案；若 app/config 暂时缺失，位置/日历/通知权限弹窗必须继续使用本地 fallback 正常展示。

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
