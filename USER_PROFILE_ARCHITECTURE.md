# 用户资料模块化系统架构文档

## 📋 概述

本系统将用户资料拆分为8个独立模块，每个模块都有自己的数据表和管理接口，可以独立编辑和存储到SQLite数据库。

## 🗂️ 模块列表

### 1. 基本信息模块 (UserBasicInfo)
**表名**: `user_basic_info`

**字段**:
- `id`: 主键
- `account_id`: 关联账户ID（唯一）
- `name`: 姓名 ✅ 可编辑
- `bio`: 个人简介 ✅ 可编辑
- `avatar_url`: 头像URL ✅ 可编辑
- `current_city`: 当前城市 ✅ 可编辑
- `current_country`: 当前国家 ✅ 可编辑
- `birth_date`: 生日 ✅ 可编辑
- `gender`: 性别 ✅ 可编辑
- `occupation`: 职业 ✅ 可编辑
- `company`: 公司 ✅ 可编辑
- `website`: 个人网站 ✅ 可编辑
- `created_at`: 创建时间
- `updated_at`: 更新时间

**操作**:
```dart
// 保存/更新基本信息
await userProfileDao.saveBasicInfo(UserBasicInfo(...));

// 获取基本信息
final info = await userProfileDao.getBasicInfo(accountId);
```

---

### 2. 游牧状态统计模块 (NomadStats)
**表名**: `nomad_stats`

**字段**:
- `id`: 主键
- `account_id`: 关联账户ID（唯一）
- `countries_visited`: 访问国家数 🤖 自动记录
- `cities_lived`: 居住城市数 🤖 自动记录
- `days_nomading`: 游牧天数 🤖 自动记录
- `meetups_attended`: 参加聚会数 🤖 自动记录
- `trips_completed`: 完成旅行数 🤖 自动记录
- `reviews_written`: 撰写评论数 🤖 自动记录
- `created_at`: 创建时间
- `updated_at`: 更新时间

**特点**: 
- 默认值为 0
- 通过用户操作自动增加（参加meetup、完成旅行、写评论等）
- 不可手动编辑，由系统自动维护

**操作**:
```dart
// 增加计数器（在相应操作时调用）
await userProfileDao.incrementStat(accountId, 'meetupsAttended');
await userProfileDao.incrementStat(accountId, 'countriesVisited');
await userProfileDao.incrementStat(accountId, 'reviewsWritten');

// 获取统计数据
final stats = await userProfileDao.getNomadStats(accountId);
```

---

### 3. 技能标签模块 (UserSkill)
**表名**: `user_skills`

**字段**:
- `id`: 主键
- `account_id`: 关联账户ID
- `skill_name`: 技能名称 ✅ 可编辑
- `created_at`: 创建时间

**预定义技能标签** (35个):
```dart
技术类: Web Development, Mobile Development, UI/UX Design, Data Science, 
        Machine Learning, DevOps, Cloud Computing, Cybersecurity, Blockchain, 
        Game Development

商业类: Project Management, Product Management, Business Analysis, Marketing,
        Sales, Customer Success, Finance, Accounting, HR, Consulting

创意类: Graphic Design, Video Editing, Photography, Content Writing,
        Copywriting, Social Media, Animation, Illustration, Music Production,
        3D Modeling

其他: Teaching, Translation, Virtual Assistant, Customer Support, Data Entry
```

**功能**:
- ✅ 用户可从预定义列表选择
- ✅ 用户可自定义输入新技能
- ✅ 支持多选
- ✅ 可删除已添加的技能

**操作**:
```dart
// 添加技能
await userProfileDao.addSkill(UserSkill(
  accountId: accountId,
  skillName: 'Web Development',
  createdAt: now,
));

// 删除技能
await userProfileDao.removeSkill(accountId, 'Web Development');

// 获取所有技能
final skills = await userProfileDao.getSkills(accountId);
```

---

### 4. 兴趣爱好标签模块 (UserInterest)
**表名**: `user_interests`

**字段**:
- `id`: 主键
- `account_id`: 关联账户ID
- `interest_name`: 兴趣名称 ✅ 可编辑
- `created_at`: 创建时间

**预定义兴趣标签** (50+个):
```dart
旅行相关: Travel, Adventure, Backpacking, Road Trips, City Exploring,
          Beach Life, Mountain Hiking, Cultural Tours

运动健身: Fitness, Yoga, Running, Cycling, Swimming, Surfing,
          Rock Climbing, Martial Arts

艺术文化: Photography, Art, Music, Reading, Writing, Movies, Theater, Museums

美食: Food, Cooking, Coffee, Wine Tasting, Street Food, Vegan, Vegetarian

社交: Networking, Language Exchange, Volunteering, Meetups, Parties, Nightlife

学习: Learning Languages, Online Courses, Podcasts, Meditation, 
      Personal Development

科技: Technology, Gaming, Coding, Startups, Cryptocurrency
```

**功能**:
- ✅ 用户可从预定义列表选择
- ✅ 用户可自定义输入新兴趣
- ✅ 支持多选
- ✅ 可删除已添加的兴趣

**操作**:
```dart
// 添加兴趣
await userProfileDao.addInterest(UserInterest(
  accountId: accountId,
  interestName: 'Travel',
  createdAt: now,
));

// 删除兴趣
await userProfileDao.removeInterest(accountId, 'Travel');

// 获取所有兴趣
final interests = await userProfileDao.getInterests(accountId);
```

---

### 5. 社交联系方式模块 (UserSocialLink)
**表名**: `user_social_links`

**字段**:
- `id`: 主键
- `account_id`: 关联账户ID
- `platform`: 平台名称 ✅ 可选择
- `url`: 链接地址 ✅ 可编辑
- `created_at`: 创建时间
- `updated_at`: 更新时间

**支持的社交平台** (19个):
```dart
Instagram 📷      Twitter/X 🐦✖️    LinkedIn 💼     Facebook 👤
GitHub 💻        YouTube 📹        TikTok 🎵       Pinterest 📌
Medium ✍️        Behance 🎨        Dribbble 🏀     Spotify 🎧
Twitch 🎮        Discord 💬        Telegram ✈️     WhatsApp 📱
WeChat 💚        Personal Website 🌐
```

**功能**:
- ✅ 用户可从支持的平台列表多选
- ✅ 每个平台输入对应的URL
- ✅ 可随时编辑或删除
- ✅ 每个平台只能添加一次

**操作**:
```dart
// 保存/更新社交链接
await userProfileDao.saveSocialLink(UserSocialLink(
  accountId: accountId,
  platform: 'instagram',
  url: 'https://instagram.com/username',
  createdAt: now,
  updatedAt: now,
));

// 删除社交链接
await userProfileDao.removeSocialLink(accountId, 'instagram');

// 获取所有社交链接
final links = await userProfileDao.getSocialLinks(accountId);
```

---

### 6. 旅行计划模块 (TravelPlan)
**表名**: `travel_plans`

**字段**:
- `id`: 主键
- `account_id`: 关联账户ID
- `title`: 计划标题 ✅ 可编辑
- `destination`: 目的地 ✅ 可编辑
- `start_date`: 开始日期 ✅ 可编辑
- `end_date`: 结束日期 ✅ 可编辑
- `description`: 描述 ✅ 可编辑
- `itinerary`: 详细行程（JSON格式）🤖 AI生成
- `budget`: 预算 ✅ 可编辑
- `accommodation`: 住宿信息 ✅ 可编辑
- `transportation`: 交通信息 ✅ 可编辑
- `status`: 状态（planning/confirmed/completed/cancelled）✅ 可编辑
- `created_at`: 创建时间
- `updated_at`: 更新时间

**特点**:
- 🤖 AI生成旅行计划后自动存储
- ✅ 用户可手动编辑所有字段
- ✅ 支持多个旅行计划
- ✅ 可按状态筛选

**操作**:
```dart
// 保存旅行计划（AI生成后）
await userProfileDao.saveTravelPlan(TravelPlan(
  accountId: accountId,
  title: 'Tokyo Adventure',
  destination: 'Tokyo, Japan',
  itinerary: jsonEncode(aiGeneratedItinerary),
  status: 'planning',
  createdAt: now,
  updatedAt: now,
));

// 获取所有计划
final plans = await userProfileDao.getTravelPlans(accountId);

// 按状态获取
final activePlans = await userProfileDao.getTravelPlans(accountId, status: 'confirmed');

// 删除计划
await userProfileDao.deleteTravelPlan(planId);
```

---

### 7. 徽章模块 (UserBadge)
**表名**: `user_badges`

**字段**:
- `id`: 主键
- `account_id`: 关联账户ID
- `badge_id`: 徽章唯一标识
- `badge_name`: 徽章名称
- `badge_icon`: 徽章图标（emoji）
- `description`: 徽章描述
- `earned_date`: 获得日期
- `created_at`: 创建时间

**特点**:
- 📌 暂时使用测试数据固定显示
- 🤖 未来可根据用户成就自动授予
- 🚫 用户不可手动编辑

**测试徽章数据**:
```dart
Early Adopter 🌟
Super Connector 🤝
Globe Trotter 🌍
Tech Guru 💻
Coffee Connoisseur ☕
Content Creator 📹
Local Expert 🗺️
Community Star ⭐
```

**操作**:
```dart
// 授予徽章（系统自动调用）
await userProfileDao.awardBadge(UserBadge(
  accountId: accountId,
  badgeId: 'early_adopter',
  badgeName: 'Early Adopter',
  badgeIcon: '🌟',
  description: 'Joined the platform in its early days',
  earnedDate: now,
  createdAt: now,
));

// 获取所有徽章
final badges = await userProfileDao.getBadges(accountId);
```

---

### 8. 旅行历史模块 (TravelHistory)
**表名**: `travel_history`

**字段**:
- `id`: 主键
- `account_id`: 关联账户ID
- `city`: 城市
- `country`: 国家
- `start_date`: 开始日期
- `end_date`: 结束日期
- `review`: 评论
- `rating`: 评分（1-5星）
- `photos`: 照片URLs（JSON数组）
- `created_at`: 创建时间
- `updated_at`: 更新时间

**特点**:
- 📌 暂时使用测试数据
- ✅ 未来可手动添加编辑
- 🤖 也可从完成的旅行计划自动生成

**操作**:
```dart
// 保存旅行历史
await userProfileDao.saveTravelHistory(TravelHistory(
  accountId: accountId,
  city: 'Bangkok',
  country: 'Thailand',
  startDate: '2024-01-15',
  endDate: '2024-02-20',
  review: 'Amazing city with great food!',
  rating: 4.8,
  createdAt: now,
  updatedAt: now,
));

// 获取旅行历史
final history = await userProfileDao.getTravelHistory(accountId);

// 删除历史记录
await userProfileDao.deleteTravelHistory(historyId);
```

---

## 🔧 数据库初始化

### 在注册时自动初始化
```dart
// 在 AccountDao.registerAccount() 中添加
final accountId = await db.insert('user_accounts', {...});

// 初始化用户资料模块
final userProfileDao = UserProfileDao();
await userProfileDao.initializeUserProfile(accountId, name);
```

### 创建表
```dart
// 在 DatabaseInitializer 中调用
final userProfileDao = UserProfileDao();
await userProfileDao.createUserProfileTables();
```

---

## 📱 UI编辑页面建议

### 1. 基本信息编辑页面
- 头像上传/选择
- 文本输入框：姓名、简介、职业、公司、网站
- 位置选择器：当前城市、国家
- 日期选择器：生日
- 性别选择器

### 2. 技能和兴趣编辑页面
**技能部分**:
- 芯片选择器显示预定义技能标签
- 自定义输入框
- 已选技能列表（可删除）

**兴趣部分**:
- 分类标签选择器（旅行、运动、艺术等）
- 自定义输入框
- 已选兴趣列表（可删除）

### 3. 社交链接编辑页面
- 平台列表（带图标）
- 每个平台的URL输入框
- 验证URL格式
- 已添加链接列表（可编辑/删除）

### 4. 旅行计划编辑页面
- 计划列表（按状态分组）
- 新建/编辑表单：
  - 标题、目的地、日期范围
  - 描述、预算
  - 状态选择器
- AI生成的行程显示（只读或可编辑）

### 5. 游牧状态显示页面
- 只读显示统计数据
- 可视化图表
- 成就进度条

### 6. 徽章展示页面
- 网格布局显示徽章
- 点击查看详情
- 暂时只读

### 7. 旅行历史页面
- 时间线显示
- 地图标记
- 暂时只读（使用测试数据）

---

## 🔄 数据流程

### 用户注册流程
```
1. 用户填写注册信息（email, username, password）
2. 创建 user_accounts 记录
3. 自动创建 user_basic_info 记录（基本字段）
4. 自动创建 nomad_stats 记录（全部为0）
5. 其他模块为空，等待用户添加
```

### 用户编辑资料流程
```
1. 进入对应模块编辑页面
2. 加载当前数据
3. 用户修改/添加/删除
4. 保存到对应数据表
5. 更新 updated_at 时间戳
```

### 系统自动更新流程
```
// 用户参加meetup时
await userProfileDao.incrementStat(accountId, 'meetupsAttended');

// 用户写评论时
await userProfileDao.incrementStat(accountId, 'reviewsWritten');

// 用户完成旅行时
await userProfileDao.incrementStat(accountId, 'tripsCompleted');
```

---

## 📊 数据关联

所有模块都通过 `account_id` 与用户账户关联：

```
user_accounts (主表)
  ├── user_basic_info (1:1)
  ├── nomad_stats (1:1)
  ├── user_skills (1:N)
  ├── user_interests (1:N)
  ├── user_social_links (1:N)
  ├── travel_plans (1:N)
  ├── user_badges (1:N)
  └── travel_history (1:N)
```

级联删除：删除账户时自动删除所有关联数据 (`ON DELETE CASCADE`)

---

## 🎯 下一步开发建议

1. **优先级1**: 实现基本信息编辑页面
2. **优先级2**: 实现技能和兴趣标签选择器
3. **优先级3**: 实现社交链接管理
4. **优先级4**: 集成AI旅行计划生成和存储
5. **优先级5**: 实现自动统计更新逻辑
6. **优先级6**: 徽章系统完善（成就条件）
7. **优先级7**: 旅行历史手动添加功能

---

## 📝 示例代码

### 完整的用户资料获取
```dart
class UserCompleteProfile {
  final UserBasicInfo? basicInfo;
  final NomadStats? stats;
  final List<UserSkill> skills;
  final List<UserInterest> interests;
  final List<UserSocialLink> socialLinks;
  final List<TravelPlan> travelPlans;
  final List<UserBadge> badges;
  final List<TravelHistory> travelHistory;
}

Future<UserCompleteProfile> getCompleteProfile(int accountId) async {
  final dao = UserProfileDao();
  
  return UserCompleteProfile(
    basicInfo: await dao.getBasicInfo(accountId),
    stats: await dao.getNomadStats(accountId),
    skills: await dao.getSkills(accountId),
    interests: await dao.getInterests(accountId),
    socialLinks: await dao.getSocialLinks(accountId),
    travelPlans: await dao.getTravelPlans(accountId),
    badges: await dao.getBadges(accountId),
    travelHistory: await dao.getTravelHistory(accountId),
  );
}
```

---

## ✅ 总结

- ✅ 8个独立模块，各司其职
- ✅ 每个模块都有独立的数据表
- ✅ 提供完整的CRUD操作接口
- ✅ 支持用户手动编辑（除了统计和徽章）
- ✅ 支持系统自动更新（统计数据）
- ✅ 预定义标签 + 自定义输入
- ✅ 级联删除保证数据一致性
- ✅ 时间戳记录所有变更
