# 模块化用户资料系统 - 快速使用指南

## 📋 概览

本文档说明如何使用新创建的模块化用户资料系统，该系统包含以下页面：

1. **ModularUserProfilePage** - 主资料页面（整合所有模块）
2. **EditBasicInfoPage** - 基本信息编辑
3. **EditSkillsPage** - 技能标签编辑
4. **EditInterestsPage** - 兴趣爱好编辑
5. **EditSocialLinksPage** - 社交链接管理

## 🚀 使用方法

### 1. 从任何页面导航到用户资料

```dart
import 'package:get/get.dart';
import '../pages/modular_user_profile_page.dart';

// 假设你有当前登录用户的账户ID
final int currentAccountId = 123; // 从登录状态或AuthController获取

// 导航到用户资料页面
Get.to(() => ModularUserProfilePage(
  accountId: currentAccountId,
  username: '用户名', // 可选
));
```

### 2. 在 Drawer 或菜单中添加入口

```dart
ListTile(
  leading: const Icon(Icons.person),
  title: const Text('我的资料'),
  onTap: () {
    final accountId = Get.find<AuthController>().currentAccountId;
    Get.to(() => ModularUserProfilePage(accountId: accountId));
  },
),
```

### 3. 在注册成功后导航

```dart
// 在 register_page.dart 的注册成功逻辑中
final accountId = await _accountDao.registerAccount(
  email,
  username,
  password,
  name,
);

if (accountId != null) {
  AppToast.success('注册成功！');
  
  // 可选：直接导航到资料页面完善信息
  Get.off(() => ModularUserProfilePage(
    accountId: accountId,
    username: username,
  ));
}
```

## 📦 各页面功能说明

### ModularUserProfilePage（主页面）

**功能：**
- 显示用户头像、姓名、职业、位置
- 显示 Nomad 统计数据（6项统计）
- 显示所有8个模块的概览
- 点击任意模块卡片进入对应编辑页面

**使用示例：**
```dart
ModularUserProfilePage(
  accountId: 123,
  username: 'john_doe',
)
```

### EditBasicInfoPage（基本信息）

**功能：**
- 编辑姓名、个人简介、性别
- 编辑当前城市、国家
- 编辑职业、公司、个人网站
- 头像上传（开发中）

**字段：**
- 姓名 * (必填)
- 个人简介
- 性别（男/女/其他/不愿透露）
- 当前城市
- 当前国家
- 职业
- 公司
- 个人网站

### EditSkillsPage（技能标签）

**功能：**
- 从预定义技能中选择（按类别分组）
- 添加自定义技能
- 查看已选技能
- 删除技能

**技能类别：**
- 技术：Web开发、移动开发、UI/UX、数据科学、机器学习等
- 商业：市场营销、产品管理、项目管理等
- 创意：平面设计、内容创作、摄影等
- 其他：教学、翻译、客户服务等

**操作：**
1. 选择类别筛选技能
2. 点击技能标签切换选中状态
3. 在输入框输入自定义技能并点击"添加"

### EditInterestsPage（兴趣爱好）

**功能：**
- 从预定义兴趣中选择（按类别分组）
- 添加自定义兴趣
- 查看已选兴趣
- 删除兴趣

**兴趣类别：**
- 旅行：旅行、冒险、背包旅行、徒步等
- 运动：健身、瑜伽、跑步、游泳等
- 艺术：摄影、绘画、音乐、舞蹈等
- 美食：美食、烹饪、咖啡、美酒等
- 社交：交友、聚会、夜生活等
- 学习：阅读、写作、语言学习等
- 科技：科技、创业、远程工作等
- 生活：冥想、正念、可持续生活等

### EditSocialLinksPage（社交链接）

**功能：**
- 从19个社交平台中选择
- 添加/编辑每个平台的链接
- 删除社交链接
- 查看已添加平台数量

**支持的平台：**
- 📷 Instagram
- 🐦✖️ Twitter/X
- 💼 LinkedIn
- 👤 Facebook
- 💻 GitHub
- 📹 YouTube
- 🎵 TikTok
- 📌 Pinterest
- ✍️ Medium
- 🎨 Behance
- 🏀 Dribbble
- 🎧 Spotify
- 🎮 Twitch
- 💬 Discord
- ✈️ Telegram
- 📱 WhatsApp
- 💚 WeChat
- 🌐 Personal Website

**操作：**
1. 点击任意平台卡片
2. 输入该平台的完整URL
3. 点击"保存"或"删除"

## 🔧 开发建议

### 获取当前登录用户ID

建议创建一个 AuthController 来管理登录状态：

```dart
class AuthController extends GetxController {
  final _accountId = Rx<int?>(null);
  final _username = Rx<String?>(null);
  
  int? get currentAccountId => _accountId.value;
  String? get username => _username.value;
  
  void login(int accountId, String username) {
    _accountId.value = accountId;
    _username.value = username;
  }
  
  void logout() {
    _accountId.value = null;
    _username.value = null;
  }
}
```

### 添加路由

在 app_routes.dart 中添加路由：

```dart
class AppRoutes {
  static const String modularUserProfile = '/modular_user_profile';
  static const String editBasicInfo = '/edit_basic_info';
  static const String editSkills = '/edit_skills';
  static const String editInterests = '/edit_interests';
  static const String editSocialLinks = '/edit_social_links';
}
```

### 检查数据库表

确保在应用启动时创建了所有用户资料表：

```dart
// 在 database_initializer.dart 或类似文件中
import '../services/database/user_profile_dao.dart';

Future<void> initializeDatabase() async {
  final userProfileDao = UserProfileDao();
  await userProfileDao.createUserProfileTables();
  print('✅ 用户资料模块表创建完成');
}
```

## 🎯 测试步骤

1. **注册新用户**
   ```
   email: test@example.com
   username: testuser
   password: 123456
   ```

2. **导航到资料页面**
   ```dart
   Get.to(() => ModularUserProfilePage(accountId: <新注册的ID>));
   ```

3. **编辑基本信息**
   - 点击"基本信息"卡片
   - 填写姓名、职业、城市等
   - 点击右上角"保存"

4. **添加技能**
   - 点击"技能标签"卡片
   - 选择预定义技能或添加自定义技能
   - 自动保存

5. **添加兴趣**
   - 点击"兴趣爱好"卡片
   - 选择兴趣标签
   - 自动保存

6. **添加社交链接**
   - 点击"社交链接"卡片
   - 选择平台并输入URL
   - 点击"保存"

7. **返回主页面查看**
   - 应该看到所有数据已更新
   - 下拉刷新可重新加载数据

## 📊 数据库表结构

系统使用以下8个表：

1. `user_basic_info` - 基本信息（1:1）
2. `nomad_stats` - 统计数据（1:1）
3. `user_skills` - 技能标签（1:N）
4. `user_interests` - 兴趣爱好（1:N）
5. `user_social_links` - 社交链接（1:N）
6. `travel_plans` - 旅行计划（1:N，待实现）
7. `user_badges` - 成就徽章（1:N，待实现）
8. `travel_history` - 旅行历史（1:N，待实现）

所有表通过 `account_id` 外键关联到 `user_accounts` 表，并使用 `ON DELETE CASCADE` 确保数据一致性。

## 🐛 常见问题

### Q: 点击保存后没有反应
**A:** 检查控制台日志，确保数据库表已创建。

### Q: 数据没有显示
**A:** 确认 accountId 正确，检查数据库中是否有对应记录。

### Q: 技能/兴趣添加失败
**A:** 可能是重复添加，检查是否已存在相同名称的标签。

### Q: 头像上传按钮点击无效
**A:** 头像上传功能还在开发中，目前显示"开发中"提示。

## 📝 待实现功能

- [ ] 头像上传功能
- [ ] 旅行计划编辑页面
- [ ] 成就徽章展示页面
- [ ] 旅行历史记录页面
- [ ] 自动统计更新（Nomad Stats）
- [ ] 国际化支持（i18n）
- [ ] 数据验证和错误处理优化

## 🔗 相关文档

- **USER_PROFILE_ARCHITECTURE.md** - 完整架构文档
- **lib/models/user_profile_models.dart** - 数据模型定义
- **lib/services/database/user_profile_dao.dart** - 数据访问层

---

**最后更新：** 2024年
**状态：** ✅ 基础功能完成，可用于开发测试
