# Skills & Interests UI 组件使用指南

## 📋 概述
已创建完整的技能和兴趣选择器 UI 组件，可用于用户注册流程或个人资料编辑。

**创建时间**: 2025-11-02  
**状态**: ✅ UI 组件完成

---

## 🎨 已创建的组件

### 1. SkillsSelector Widget
**路径**: `lib/widgets/skills_selector.dart`

**功能**:
- ✅ 按类别分组显示技能
- ✅ 搜索和筛选功能
- ✅ Chip-based 多选界面
- ✅ 熟练度选择对话框
- ✅ 经验年限滑块（0-20年）
- ✅ 最大选择数量限制
- ✅ 实时显示已选择项

**使用示例**:
```dart
SkillsSelector(
  selectedSkillIds: selectedSkillIds,
  onChanged: (skills) {
    // 处理选择变化
    setState(() => _selectedSkills = skills);
  },
  showProficiency: true,  // 是否显示熟练度选择
  maxSelection: 10,        // 最多选择10个（0=无限制）
)
```

**熟练度级别**:
- Beginner (初学者)
- Intermediate (中级)
- Advanced (高级)
- Expert (专家)

### 2. InterestsSelector Widget
**路径**: `lib/widgets/interests_selector.dart`

**功能**:
- ✅ 按类别分组显示兴趣
- ✅ 搜索和筛选功能
- ✅ Chip-based 多选界面
- ✅ 喜爱程度选择对话框
- ✅ 最大选择数量限制
- ✅ 实时显示已选择项

**使用示例**:
```dart
InterestsSelector(
  selectedInterestIds: selectedInterestIds,
  onChanged: (interests) {
    // 处理选择变化
    setState(() => _selectedInterests = interests);
  },
  showIntensity: true,     // 是否显示喜爱程度选择
  maxSelection: 15,         // 最多选择15个（0=无限制）
)
```

**喜爱程度级别**:
- Low (一般)
- Medium (喜欢)
- High (热爱)

### 3. SkillsInterestsPage
**路径**: `lib/pages/skills_interests_page.dart`

**功能**:
- ✅ Tab 切换（技能/兴趣）
- ✅ 批量保存功能
- ✅ 底部统计栏
- ✅ 保存按钮（带加载状态）
- ✅ 错误处理和提示

**使用示例**:
```dart
// 导航到选择页面
Get.to(() => const SkillsInterestsPage());
```

---

## 🎯 集成方案

### 方案 1: 注册流程集成

在用户注册流程中添加可选的技能和兴趣选择步骤。

**步骤**:
1. 找到注册流程文件（通常在 `lib/pages/registration/` 或 `lib/pages/auth/`）
2. 在基本信息页面之后添加技能兴趣选择
3. 设置为可跳过的步骤

**示例代码**:
```dart
// registration_controller.dart
class RegistrationController extends GetxController {
  // ... 现有字段
  List<UserSkill> selectedSkills = [];
  List<UserInterest> selectedInterests = [];
  
  void goToSkillsInterestsStep() {
    Get.to(() => const SkillsInterestsPage());
  }
  
  void skipSkillsInterests() {
    // 跳过此步骤，直接进入下一步
    completeRegistration();
  }
  
  Future<void> completeRegistration() async {
    // 保存用户信息
    // 如果有选择技能/兴趣，一并保存
  }
}
```

### 方案 2: 个人资料页面集成

在个人资料编辑页面添加技能和兴趣管理功能。

**步骤**:
1. 在个人资料页面添加"编辑技能和兴趣"按钮
2. 点击后打开 `SkillsInterestsPage`
3. 保存后刷新个人资料显示

**示例代码**:
```dart
// profile_edit_page.dart
ListTile(
  leading: const Icon(Icons.psychology_outlined),
  title: const Text('技能与兴趣'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () async {
    // 导航到选择页面
    await Get.to(() => const SkillsInterestsPage());
    
    // 返回后刷新数据
    _loadUserProfile();
  },
)
```

### 方案 3: 独立使用选择器

在自定义页面中单独使用选择器组件。

**示例代码**:
```dart
class CustomPage extends StatefulWidget {
  @override
  State<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  List<UserSkill> _skills = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择技能')),
      body: SkillsSelector(
        selectedSkillIds: _skills.map((s) => s.skillId).toList(),
        onChanged: (skills) {
          setState(() => _skills = skills);
        },
        showProficiency: true,
        maxSelection: 5,
      ),
    );
  }
}
```

---

## 🎨 UI 特性

### 视觉设计
- ✅ 使用 AppColors 统一配色
- ✅ FilterChip 和 ChoiceChip 组件
- ✅ Emoji 图标展示
- ✅ 类别筛选标签
- ✅ 搜索框
- ✅ 已选择项实时预览

### 交互设计
- ✅ 点击 Chip 选择/取消
- ✅ 弹窗设置熟练度/喜爱程度
- ✅ 滑块调整经验年限
- ✅ 搜索实时过滤
- ✅ 类别切换
- ✅ 达到上限提示

### 用户体验
- ✅ 加载状态显示
- ✅ 错误提示
- ✅ 保存成功提示
- ✅ 空状态提示
- ✅ 选择计数显示

---

## 📱 路由配置

如需添加到应用路由：

```dart
// routes/app_routes.dart
class AppRoutes {
  // ... 现有路由
  static const skillsInterests = '/skills-interests';
  
  static final getPages = [
    // ... 现有页面
    GetPage(
      name: skillsInterests,
      page: () => const SkillsInterestsPage(),
    ),
  ];
}

// 使用
Get.toNamed(AppRoutes.skillsInterests);
```

---

## 🔧 自定义选项

### SkillsSelector 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| selectedSkillIds | List\<String\> | required | 已选择的技能ID列表 |
| onChanged | Function(List\<UserSkill\>) | required | 选择变化回调 |
| showProficiency | bool | true | 是否显示熟练度选择 |
| maxSelection | int | 0 | 最大选择数量（0=无限制） |

### InterestsSelector 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| selectedInterestIds | List\<String\> | required | 已选择的兴趣ID列表 |
| onChanged | Function(List\<UserInterest\>) | required | 选择变化回调 |
| showIntensity | bool | true | 是否显示喜爱程度选择 |
| maxSelection | int | 0 | 最大选择数量（0=无限制） |

---

## 🎯 后端对接

### 保存技能示例
```dart
final skillsService = SkillsApiService();

// 单个保存
final request = AddUserSkillRequest(
  skillId: skill.skillId,
  proficiencyLevel: 'Intermediate',
  yearsOfExperience: 3,
);
await skillsService.addCurrentUserSkill(request);

// 批量保存
final requests = selectedSkills.map((skill) {
  return AddUserSkillRequest(
    skillId: skill.skillId,
    proficiencyLevel: skill.proficiencyLevel,
    yearsOfExperience: skill.yearsOfExperience,
  );
}).toList();
await skillsService.addUserSkillsBatch(requests);
```

### 获取用户技能示例
```dart
final skillsService = SkillsApiService();

// 获取当前用户技能
final userSkills = await skillsService.getCurrentUserSkills();

// 获取指定用户技能
final skills = await skillsService.getUserSkills(userId);
```

---

## 🐛 常见问题

### Q1: 如何禁用熟练度选择？
```dart
SkillsSelector(
  // ...
  showProficiency: false,  // 设置为 false
)
```

### Q2: 如何设置选择数量上限？
```dart
SkillsSelector(
  // ...
  maxSelection: 10,  // 最多10个
)
```

### Q3: 如何自定义类别文本？
修改 `_getCategoryText()` 方法中的映射：
```dart
const categoryMap = {
  'Programming': '编程开发',  // 自定义文本
  // ...
};
```

### Q4: 如何获取已选择的技能ID？
```dart
final skillIds = selectedSkills.map((s) => s.skillId).toList();
```

---

## 🎨 样式自定义

### 修改主题色
在 `app_colors.dart` 中修改：
```dart
static const Color accent = Color(0xFF1976D2); // 修改为你的品牌色
```

### 修改 Chip 样式
在选择器组件中修改 `FilterChip` 或 `ChoiceChip` 的样式属性。

---

## 📝 下一步开发建议

### 高优先级
1. ✅ 在注册流程中集成（可选步骤）
2. ✅ 在个人资料页面集成
3. ✅ 添加用户技能/兴趣展示组件

### 中优先级
1. 🔄 添加编辑功能（修改熟练度/强度）
2. 🔄 添加推荐功能（基于选择推荐相关技能/兴趣）
3. 🔄 添加统计功能（显示热门技能/兴趣）

### 低优先级
1. ⏳ 添加自定义技能/兴趣功能
2. ⏳ 添加技能认证功能
3. ⏳ 添加社交匹配功能

---

## 📄 相关文件

### Models
- `lib/models/skill_model.dart`
- `lib/models/interest_model.dart`

### Services
- `lib/services/skills_api_service.dart`
- `lib/services/interests_api_service.dart`

### Widgets
- `lib/widgets/skills_selector.dart`
- `lib/widgets/interests_selector.dart`

### Pages
- `lib/pages/skills_interests_page.dart`

### Backend
- `go-noma/UserService/API/Controllers/SkillsController.cs`
- `go-noma/UserService/API/Controllers/InterestsController.cs`

---

## ✨ 测试建议

### 功能测试
1. ✅ 测试技能选择和取消
2. ✅ 测试兴趣选择和取消
3. ✅ 测试搜索功能
4. ✅ 测试类别筛选
5. ✅ 测试熟练度/强度选择
6. ✅ 测试最大数量限制
7. ✅ 测试批量保存

### UI 测试
1. ✅ 测试不同屏幕尺寸
2. ✅ 测试滚动性能
3. ✅ 测试加载状态
4. ✅ 测试空状态
5. ✅ 测试错误提示

---

**完成状态**: ✅ UI 组件已完成，可直接使用
**下一步**: 集成到注册流程或个人资料页面
