# AppToast 使用指南

## 简介

`AppToast` 是一个现代化的 Toast 通知组件,用于替换项目中所有的 `Get.snackbar` 调用,提供更好的用户体验和统一的视觉风格。

---

## 特性

✨ **四种预设类型**:
- ✅ Success (成功) - 绿色
- ❌ Error (错误) - 红色
- ⚠️ Warning (警告) - 橙色
- ℹ️ Info (信息) - 蓝色

🎨 **现代化设计**:
- 圆角卡片设计
- 柔和的阴影效果
- 流畅的动画过渡
- 左侧指示器条
- 图标 + 文字组合

📱 **响应式交互**:
- 顶部显示(更符合现代设计)
- 可左右滑动关闭
- 3秒自动消失(可自定义)
- 支持多个 Toast 队列

---

## 基本用法

### 1. 导入组件

```dart
import '../widgets/app_toast.dart';
```

### 2. 成功提示

```dart
// 简单用法
AppToast.success('操作成功');

// 带自定义标题
AppToast.success('数据已保存', title: '保存成功');
```

### 3. 错误提示

```dart
// 简单用法
AppToast.error('操作失败,请重试');

// 带自定义标题
AppToast.error('无法连接到服务器', title: '网络错误');
```

### 4. 警告提示

```dart
// 简单用法
AppToast.warning('您需要先登录');

// 带自定义标题
AppToast.warning('权限不足', title: '访问受限');
```

### 5. 信息提示

```dart
// 简单用法
AppToast.info('功能开发中');

// 带自定义标题
AppToast.info('即将推出更多功能', title: '敬请期待');
```

### 6. 自定义 Toast

```dart
AppToast.custom(
  title: '🎉 恭喜',
  message: '您获得了新徽章!',
  backgroundColor: Colors.purple,
  textColor: Colors.white,
  icon: Icons.star_rounded,
  duration: Duration(seconds: 5),
);
```

---

## 迁移指南

### 从 Get.snackbar 迁移

#### **成功提示**

**之前**:
```dart
Get.snackbar(
  '✅ Joined!',
  'You have successfully joined this meetup',
  backgroundColor: Colors.green,
  colorText: Colors.white,
  snackPosition: SnackPosition.BOTTOM,
  duration: const Duration(seconds: 2),
);
```

**之后**:
```dart
AppToast.success('You have successfully joined this meetup', title: 'Joined!');
```

---

#### **错误提示**

**之前**:
```dart
Get.snackbar(
  '❌ Error',
  'Please fill in all required fields',
  backgroundColor: Colors.red,
  colorText: Colors.white,
  snackPosition: SnackPosition.BOTTOM,
);
```

**之后**:
```dart
AppToast.error('Please fill in all required fields');
```

---

#### **警告提示**

**之前**:
```dart
Get.snackbar(
  '⚠️ Join Required',
  'You need to join this meetup before you can access the group chat',
  backgroundColor: Colors.orange,
  colorText: Colors.white,
  snackPosition: SnackPosition.BOTTOM,
  duration: const Duration(seconds: 3),
);
```

**之后**:
```dart
AppToast.warning(
  'You need to join this meetup before you can access the group chat',
  title: 'Join Required',
);
```

---

#### **信息提示**

**之前**:
```dart
Get.snackbar(
  'ℹ️ Info',
  'Feature coming soon!',
  backgroundColor: Colors.blue,
  colorText: Colors.white,
);
```

**之后**:
```dart
AppToast.info('Feature coming soon!');
```

---

## 完整迁移示例

### 示例 1: Meetup Detail Page

**之前 (meetup_detail_page.dart)**:
```dart
void _toggleJoin() {
  final updated = _meetup.value.copyWith(
    isJoined: !_meetup.value.isJoined,
  );
  _meetup.value = updated;

  Get.snackbar(
    updated.isJoined ? '✅ Joined!' : '👋 Left meetup',
    updated.isJoined
        ? 'You have successfully joined this meetup'
        : 'You left this meetup',
    backgroundColor: updated.isJoined ? Colors.green : AppColors.textSecondary,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 2),
  );
}
```

**之后**:
```dart
void _toggleJoin() {
  final updated = _meetup.value.copyWith(
    isJoined: !_meetup.value.isJoined,
  );
  _meetup.value = updated;

  if (updated.isJoined) {
    AppToast.success('You have successfully joined this meetup', title: 'Joined!');
  } else {
    AppToast.info('You left this meetup', title: 'Left meetup');
  }
}
```

---

### 示例 2: Create Meetup Page

**之前 (create_meetup_page.dart)**:
```dart
if (_titleController.text.trim().isEmpty) {
  Get.snackbar(
    '⚠️ Missing Information',
    'Please enter a meetup title',
    backgroundColor: Colors.orange,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );
  return;
}
```

**之后**:
```dart
if (_titleController.text.trim().isEmpty) {
  AppToast.warning('Please enter a meetup title', title: 'Missing Information');
  return;
}
```

---

### 示例 3: Data Service Controller

**之前 (data_service_controller.dart)**:
```dart
void toggleRSVP(int meetupId) {
  if (rsvpedMeetups.contains(meetupId)) {
    rsvpedMeetups.remove(meetupId);
    Get.snackbar(
      '👋 RSVP Cancelled',
      'You have cancelled your RSVP for this meetup',
      backgroundColor: AppColors.textSecondary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  } else {
    rsvpedMeetups.add(meetupId);
    Get.snackbar(
      '✅ RSVP Confirmed',
      'You have successfully RSVP\'d for this meetup',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
```

**之后**:
```dart
void toggleRSVP(int meetupId) {
  if (rsvpedMeetups.contains(meetupId)) {
    rsvpedMeetups.remove(meetupId);
    AppToast.info(
      'You have cancelled your RSVP for this meetup',
      title: 'RSVP Cancelled',
    );
  } else {
    rsvpedMeetups.add(meetupId);
    AppToast.success(
      'You have successfully RSVP\'d for this meetup',
      title: 'RSVP Confirmed',
    );
  }
}
```

---

## 批量替换步骤

### 方法 1: 手动替换(推荐)

1. **搜索所有 Get.snackbar**
   - 在 VS Code 中按 `Ctrl+Shift+F`
   - 搜索: `Get.snackbar`
   - 按文件逐个替换

2. **根据颜色判断类型**
   - `backgroundColor: Colors.green` → `AppToast.success()`
   - `backgroundColor: Colors.red` → `AppToast.error()`
   - `backgroundColor: Colors.orange` → `AppToast.warning()`
   - `backgroundColor: Colors.blue` → `AppToast.info()`
   - 其他颜色 → `AppToast.custom()`

3. **添加导入**
   ```dart
   import '../widgets/app_toast.dart';
   ```

---

### 方法 2: 使用脚本辅助

创建一个 Python 脚本 `migrate_toast.py`:

```python
import os
import re

def migrate_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 检查是否包含 Get.snackbar
    if 'Get.snackbar' not in content:
        return False
    
    # 添加导入(如果还没有)
    if "import '../widgets/app_toast.dart';" not in content:
        # 在其他 import 后添加
        import_pattern = r"(import '[^']+';[\n\s]*)"
        last_import = list(re.finditer(import_pattern, content))
        if last_import:
            insert_pos = last_import[-1].end()
            content = content[:insert_pos] + "import '../widgets/app_toast.dart';\n" + content[insert_pos:]
    
    # 保存修改
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return True

# 遍历 lib 目录
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            file_path = os.path.join(root, file)
            if migrate_file(file_path):
                print(f'已处理: {file_path}')
```

---

## 设计规范

### 颜色方案

| 类型 | 背景色 | 指示器色 | 图标 |
|------|--------|---------|------|
| Success | #10B981 | #059669 | check_circle_rounded |
| Error | #EF4444 | #DC2626 | error_rounded |
| Warning | #F59E0B | #D97706 | warning_rounded |
| Info | #3B82F6 | #2563EB | info_rounded |

### 动画

- **进入动画**: `Curves.easeOutBack` (500ms)
- **退出动画**: `Curves.easeInBack` (500ms)
- **显示时长**: 3秒(默认)
- **位置**: 顶部

### 布局

- **边距**: 16px
- **圆角**: 12px
- **阴影**: 12px blur, 4px offset
- **图标大小**: 20px
- **标题字号**: 16px (粗体)
- **消息字号**: 14px

---

## 最佳实践

### 1. 选择合适的类型

```dart
// ✅ 正确
AppToast.success('Profile updated successfully');

// ❌ 错误 - 不要用 error 显示成功信息
AppToast.error('Profile updated successfully');
```

### 2. 保持消息简洁

```dart
// ✅ 正确
AppToast.error('Invalid email address');

// ❌ 错误 - 过长
AppToast.error('The email address you entered is not valid. Please check the format and try again.');
```

### 3. 标题可选

```dart
// 消息已经很清晰,可以省略标题
AppToast.success('Meetup created successfully');

// 需要额外上下文时使用标题
AppToast.warning('Please verify your email', title: 'Email Verification Required');
```

### 4. 避免滥用

```dart
// ❌ 错误 - 不要对每个小操作都显示 Toast
onButtonPressed() {
  AppToast.info('Button pressed');
}

// ✅ 正确 - 只对重要操作显示反馈
onSavePressed() {
  AppToast.success('Changes saved');
}
```

---

## 需要替换的文件清单

根据搜索结果,以下文件包含 `Get.snackbar`:

### 高优先级(用户交互频繁)
- [ ] `lib/pages/meetup_detail_page.dart` (4处)
- [ ] `lib/pages/create_meetup_page.dart` (10处)
- [ ] `lib/pages/data_service_page.dart` (1处)
- [ ] `lib/controllers/data_service_controller.dart` (1处)
- [ ] `lib/pages/city_detail_page.dart` (4处)
- [ ] `lib/pages/meetups_list_page.dart` (2处)

### 中优先级(常用功能)
- [ ] `lib/pages/add_review_page.dart` (4处)
- [ ] `lib/pages/user_profile_page.dart` (3处)
- [ ] `lib/pages/city_chat_page.dart` (4处)
- [ ] `lib/pages/nomads_login_page.dart` (4处)
- [ ] `lib/pages/register_page.dart` (3处)
- [ ] `lib/pages/add_coworking_page.dart` (3处)

### 低优先级(辅助功能)
- [ ] `lib/pages/home_page.dart` (4处)
- [ ] `lib/pages/profile_page.dart` (2处)
- [ ] `lib/pages/language_settings_page.dart` (2处)
- [ ] `lib/pages/api_marketplace_page.dart` (5处)
- [ ] `lib/services/location_service.dart` (4处)
- [ ] 其他页面...

---

## 测试清单

替换后请测试以下场景:

- [ ] 成功 Toast 正常显示(绿色)
- [ ] 错误 Toast 正常显示(红色)
- [ ] 警告 Toast 正常显示(橙色)
- [ ] 信息 Toast 正常显示(蓝色)
- [ ] Toast 在顶部显示
- [ ] Toast 可以左右滑动关闭
- [ ] Toast 3秒后自动消失
- [ ] 多个 Toast 可以排队显示
- [ ] 动画流畅自然
- [ ] 文字清晰可读
- [ ] 图标显示正确

---

## FAQ

### Q: 为什么 Toast 显示在顶部而不是底部?

A: 根据现代设计规范,顶部通知更符合用户习惯,且不会遮挡底部导航栏。

### Q: 可以自定义显示时长吗?

A: 可以,所有方法都支持传入 `duration` 参数(需要修改 API):

```dart
AppToast.success('Message', duration: Duration(seconds: 5));
```

### Q: 如何一次性关闭所有 Toast?

A: 使用 GetX 提供的方法:

```dart
Get.closeAllSnackbars();
```

### Q: Toast 是否支持国际化?

A: 支持,只需传入已翻译的文本:

```dart
final l10n = AppLocalizations.of(context)!;
AppToast.success(l10n.saveSuccess);
```

---

## 总结

✅ **优势**:
- 统一的视觉风格
- 更好的用户体验
- 简化的 API 调用
- 现代化的动画效果
- 易于维护和扩展

📊 **对比**:

| 特性 | Get.snackbar | AppToast |
|------|-------------|----------|
| 代码行数 | 6-8行 | 1-2行 |
| 视觉风格 | 不统一 | 统一 |
| 动画效果 | 基础 | 流畅 |
| 图标支持 | 手动添加 | 内置 |
| 类型安全 | 否 | 是 |

🚀 **下一步**:
1. 开始从高优先级文件迁移
2. 每完成一个文件就测试
3. 记录任何问题或改进建议
4. 完成后删除旧的 snackbar 代码
