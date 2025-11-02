# 技能和兴趣删除及高亮显示功能修复

## 问题描述

1. **删除 tag 未同步到数据库**: 点击技能或兴趣的删除按钮时,虽然页面上删除了,但刷新后还会出现,说明没有同步到数据库
2. **drawer 中已选项未高亮**: 打开选择技能/兴趣的 drawer 时,用户已有的技能/爱好没有高亮显示,容易导致重复选择

## 解决方案

### 1. 删除功能同步到数据库

#### 后端修改

**新增 API 接口**:

1. `DELETE /api/v1/skills/me/by-name/{skillName}` - 按技能名称删除当前用户的技能
2. `DELETE /api/v1/interests/me/by-name/{interestName}` - 按兴趣名称删除当前用户的兴趣

**修改的文件**:

- `src/Services/UserService/UserService/API/Controllers/SkillsController.cs`
  - 添加 `RemoveCurrentUserSkillByName` 方法

- `src/Services/UserService/UserService/API/Controllers/InterestsController.cs`
  - 添加 `RemoveCurrentUserInterestByName` 方法

- `src/Services/UserService/UserService/Application/Services/ISkillService.cs`
  - 添加 `RemoveUserSkillByNameAsync` 接口方法

- `src/Services/UserService/UserService/Application/Services/IInterestService.cs`
  - 添加 `RemoveUserInterestByNameAsync` 接口方法

- `src/Services/UserService/UserService/Infrastructure/Services/SkillService.cs`
  - 实现 `RemoveUserSkillByNameAsync` 方法
  - 逻辑: 先根据名称查找技能ID,然后删除用户技能记录

- `src/Services/UserService/UserService/Infrastructure/Services/InterestService.cs`
  - 实现 `RemoveUserInterestByNameAsync` 方法
  - 逻辑: 先根据名称查找兴趣ID,然后删除用户兴趣记录

#### 前端修改

**修改的文件**: `lib/controllers/user_profile_controller.dart`

修改 `removeSkill` 和 `removeInterest` 方法,使其调用后端 API:

```dart
// 移除技能
Future<void> removeSkill(String skillName) async {
  if (currentUser.value == null) return;

  try {
    // 先从本地移除（立即更新UI）
    final updatedSkills = currentUser.value!.skills.where((s) => s != skillName).toList();
    currentUser.value = UserModel(..., skills: updatedSkills, ...);

    // 调用后端 API 删除
    final response = await HttpService.delete('/api/v1/skills/me/by-name/$skillName');
    
    if (response['success'] == true) {
      print('✅ 技能已从数据库删除: $skillName');
    } else {
      // 如果失败，重新加载以保持一致性
      await loadUserProfile();
    }
  } catch (e) {
    print('❌ 删除技能出错: $e');
    // 如果出错，重新加载以恢复数据
    await loadUserProfile();
  }
}

// 移除兴趣爱好 - 同样的逻辑
Future<void> removeInterest(String interestName) async { ... }
```

**优点**:
- 立即更新 UI (乐观更新)
- 如果 API 调用失败,自动重新加载恢复数据
- 用户体验流畅

### 2. Drawer 中高亮已选项

#### 修改的文件: `lib/pages/profile_edit_page.dart`

**传递当前技能/兴趣到 Drawer**:

```dart
void _showSkillsBottomSheet(UserProfileController profileController) {
  final SkillsApiService skillsService = SkillsApiService();
  final currentSkills = profileController.currentUser.value?.skills ?? [];
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SkillsBottomSheet(
      skillsService: skillsService,
      currentSkills: currentSkills,  // 传递当前技能
      onSave: (selectedSkills) async { ... },
    ),
  );
}

// 兴趣 drawer 同理
void _showInterestsBottomSheet(UserProfileController profileController) {
  final currentInterests = profileController.currentUser.value?.interests ?? [];
  // ...
  builder: (context) => _InterestsBottomSheet(
    currentInterests: currentInterests,  // 传递当前兴趣
    // ...
  ),
}
```

**更新 Drawer 组件构造函数**:

```dart
class _SkillsBottomSheet extends StatefulWidget {
  final SkillsApiService skillsService;
  final List<String> currentSkills;  // 新增参数
  final Function(List<UserSkill>) onSave;

  const _SkillsBottomSheet({
    required this.skillsService,
    required this.currentSkills,  // 新增参数
    required this.onSave,
  });
}

// 兴趣 drawer 同理
class _InterestsBottomSheet extends StatefulWidget {
  final List<String> currentInterests;  // 新增参数
  // ...
}
```

**预选择当前技能/兴趣**:

在 `_loadSkills()` 和 `_loadInterests()` 方法中,加载完数据后调用预选择方法:

```dart
Future<void> _loadSkills() async {
  setState(() => _isLoading = true);

  try {
    final skillsByCategory = await widget.skillsService.getSkillsByCategory();
    setState(() {
      _skillsByCategory = skillsByCategory;
      _isLoading = false;
      // 预填充当前用户已有的技能
      _preselectCurrentSkills();
    });
  } catch (e) {
    // ...
  }
}

void _preselectCurrentSkills() {
  // 预填充用户已有的技能
  for (var skillName in widget.currentSkills) {
    for (var category in _skillsByCategory) {
      final skill = category.skills.firstWhere(
        (s) => s.name == skillName,
        orElse: () => Skill(id: '', name: '', category: '', icon: ''),
      );
      
      if (skill.id.isNotEmpty && !_selectedSkills.any((s) => s.skillId == skill.id)) {
        _selectedSkills.add(UserSkill(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: '',
          skillId: skill.id,
          skillName: skill.name,
          category: skill.category,
          icon: skill.icon,
          proficiencyLevel: 'Intermediate',
          yearsOfExperience: null,
          createdAt: DateTime.now(),
        ));
      }
    }
  }
}

// 兴趣的 _preselectCurrentInterests() 方法同理
```

## 部署状态

✅ **后端**: 所有服务已重新构建并部署
- user-service 部署成功 (http://localhost:5001)
- 新增的按名称删除 API 已生效

✅ **前端**: 代码已修改
- removeSkill/removeInterest 方法已更新为异步调用 API
- Drawer 组件已添加预选择逻辑

## 测试步骤

### 测试删除功能

1. 打开个人资料编辑页面
2. 点击某个技能或兴趣 tag 的删除按钮
3. 观察 tag 立即消失
4. **刷新页面**
5. ✅ 验证: 该 tag 不再出现 (已从数据库删除)

### 测试高亮显示

1. 打开个人资料编辑页面
2. 确保已有一些技能或兴趣
3. 点击 "技能" 或 "兴趣爱好" 的编辑按钮
4. ✅ 验证: drawer 打开时,已选择的技能/兴趣在 `_selectedSkills` 或 `_selectedInterests` 列表中
5. ✅ 验证: 底部显示的已选数量正确 (例如: "确定 (3)")
6. 点击已选择的项目可以取消选择
7. 点击未选择的项目可以添加选择

## API 使用示例

### 删除技能

```bash
DELETE http://localhost:5000/api/v1/skills/me/by-name/Python
Authorization: Bearer {token}
```

**响应**:
```json
{
  "success": true,
  "message": "User skill removed successfully"
}
```

### 删除兴趣

```bash
DELETE http://localhost:5000/api/v1/interests/me/by-name/Hiking
Authorization: Bearer {token}
```

**响应**:
```json
{
  "success": true,
  "message": "User interest removed successfully"
}
```

## 技术细节

### 为什么按名称删除而不是按ID?

在 Flutter 前端,用户资料中只存储了技能和兴趣的**名称**列表 (`List<String>`),而不是完整的对象。因此:

1. 当用户点击删除时,我们只能获取到名称
2. 后端需要先根据名称查找对应的 skill_id 或 interest_id
3. 然后使用 ID 在 user_skills 或 user_interests 表中删除记录

### 乐观更新策略

前端采用"乐观更新"策略:

1. **立即更新 UI**: 用户点击删除后,立即从本地状态移除
2. **异步调用 API**: 后台调用删除 API
3. **失败回滚**: 如果 API 调用失败,重新加载用户资料以恢复数据

这确保了流畅的用户体验,同时保持数据一致性。

## 后续优化建议

1. **批量删除**: 如果需要一次删除多个技能/兴趣,可以添加批量删除 API
2. **撤销功能**: 删除后显示 "撤销" 按钮,在一定时间内可以恢复
3. **加载状态**: 在调用删除 API 期间显示 loading 指示器
4. **错误提示**: API 调用失败时显示更友好的错误消息

## 相关文档

- [SKILLS_INTERESTS_QUICK_REFERENCE.md](./SKILLS_INTERESTS_QUICK_REFERENCE.md) - 技能和兴趣功能快速参考
- [SKILLS_INTERESTS_API_COMPLETE.md](../go-noma/SKILLS_INTERESTS_API_COMPLETE.md) - 技能和兴趣 API 完整文档
