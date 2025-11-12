# Guide 生成权限控制优化

## 📋 功能说明

优化了城市详情页（City Detail Page）中 AI 旅游指南的生成权限控制，确保只有管理员才能触发 AI 生成功能。

## 🔐 权限控制

### 权限规则
- ✅ **管理员（admin）**：可以生成/重新生成 AI 旅游指南
- ❌ **普通用户（user）**：无法生成，会看到友好的权限提示

### 受保护的操作
1. **前台生成按钮**：点击时检查权限
2. **后台生成按钮**：点击时检查权限
3. **重新生成菜单**：选择时检查权限

## 🎨 用户体验

### 权限不足时的提示
当普通用户尝试生成指南时，会看到一个友好的对话框：

```
┌─────────────────────────────────────┐
│  🔒 权限不足                         │
├─────────────────────────────────────┤
│  抱歉，只有管理员才能生成 AI 旅游    │
│  指南。                              │
│                                     │
│  ℹ️ 想要成为版主？                  │
│  贡献优质内容即可获得审核资格！      │
├─────────────────────────────────────┤
│  [我知道了]  [申请成为版主]         │
└─────────────────────────────────────┘
```

### 对话框特性
- 🔒 **图标**：使用锁图标表示权限限制
- 💡 **提示信息**：清晰说明权限要求
- 🎯 **引导行动**：提供"申请成为版主"按钮
- 🎨 **视觉优化**：使用蓝色信息框突出提示

## 🛠️ 技术实现

### 1. 权限检查方法
```dart
Future<bool> _checkGeneratePermission() async {
  final isAdmin = await TokenStorageService().isAdmin();
  
  if (!isAdmin) {
    _showNoPermissionDialog();
    return false;
  }
  
  return true;
}
```

### 2. 无权限对话框
```dart
void _showNoPermissionDialog() {
  // 显示友好的权限提示对话框
  // 包含：权限说明 + 成为版主的引导
}
```

### 3. 按钮集成
所有生成按钮在执行前都会先调用权限检查：

```dart
// 前台生成按钮
onPressed: () => _showAIGenerateProgressDialog(controller)
// 内部会先调用 _checkGeneratePermission()

// 后台生成按钮
onPressed: () async {
  if (await _checkGeneratePermission()) {
    controller.generateDigitalNomadGuideInBackground(...);
  }
}

// 重新生成菜单
onSelected: (value) async {
  if (!await _checkGeneratePermission()) {
    return;
  }
  // 执行生成操作
}
```

## 📍 修改位置

### 文件：`lib/pages/city_detail_page.dart`

#### 1. 新增导入
```dart
import '../services/token_storage_service.dart';
```

#### 2. 新增方法（第 333 行后）
- `_checkGeneratePermission()` - 权限检查
- `_showNoPermissionDialog()` - 无权限对话框

#### 3. 修改按钮
- **前台生成按钮**（第 1444 行）：添加权限检查
- **后台生成按钮**（第 1461 行）：添加权限检查
- **重新生成菜单**（第 1551 行）：添加权限检查

## 🧪 测试场景

### 管理员账号测试
1. ✅ 登录管理员账号
2. ✅ 进入城市详情页的 Guide 标签
3. ✅ 点击"前台生成"按钮 → 正常弹出生成进度对话框
4. ✅ 点击"后台生成"按钮 → 正常触发后台生成
5. ✅ 点击重新生成菜单 → 正常显示选项并执行

### 普通用户测试
1. ✅ 登录普通用户账号
2. ✅ 进入城市详情页的 Guide 标签
3. ✅ 点击"前台生成"按钮 → 弹出权限不足对话框
4. ✅ 点击"后台生成"按钮 → 弹出权限不足对话框
5. ✅ 点击重新生成菜单 → 弹出权限不足对话框
6. ✅ 点击"申请成为版主"按钮 → 显示提示（功能待实现）

## 🎯 后续优化建议

### 1. 实现"申请成为版主"功能
```dart
// TODO: 实现版主申请页面
onPressed: () {
  Navigator.of(context).pop();
  Get.to(() => ApplyModeratorPage());
}
```

### 2. 添加版主审核流程
- 用户提交申请（填写申请理由、贡献内容等）
- 管理员审核申请
- 通过后自动升级为版主角色

### 3. 权限等级细化
考虑引入更多角色：
- `user` - 普通用户：浏览内容
- `moderator` - 版主：生成指南、审核内容
- `admin` - 管理员：完全权限

### 4. 批量操作权限控制
为其他管理功能也添加类似的权限控制：
- 删除评论
- 编辑城市信息
- 管理用户举报

## 📊 权限控制流程图

```
用户点击生成按钮
    ↓
调用 _checkGeneratePermission()
    ↓
TokenStorageService.isAdmin()
    ↓
    ├─→ true (管理员)
    │   └─→ 执行生成操作
    │
    └─→ false (普通用户)
        └─→ 显示 _showNoPermissionDialog()
            ├─→ [我知道了] → 关闭对话框
            └─→ [申请成为版主] → 跳转申请页面（待实现）
```

## ✅ 完成状态

- ✅ 权限检查方法实现
- ✅ 无权限对话框实现
- ✅ 前台生成按钮集成
- ✅ 后台生成按钮集成
- ✅ 重新生成菜单集成
- ✅ 用户友好的提示信息
- ✅ 引导用户申请版主
- ⏳ 版主申请功能（待实现）

---
**修改日期**: 2025-01-12  
**相关文档**: 
- 用户角色支持: `USER_ROLE_SUPPORT_COMPLETE.md`
- 存储架构: `USER_DATA_STORAGE_ARCHITECTURE.md`
