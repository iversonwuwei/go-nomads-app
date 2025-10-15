# 如何找到语言切换入口

## 📱 操作步骤

### 方法 1：从 User Profile 页面访问

1. **打开应用**
2. **导航到 Profile（个人资料）页面**
   - 如果应用有底部导航栏，点击"Profile"或"我的"
   - 或者从侧边菜单选择"Profile"
   
3. **向下滚动到 Preferences（偏好设置）部分**
   - 这个部分包含多个设置选项
   - 位于 Activity（活动统计）之后
   
4. **找到 Language（语言）选项**
   - 图标：🌐 地球图标（橙色）
   - 显示内容：
     * 标题：**"语言"** 或 **"Language"**（根据当前语言）
     * 副标题：**"中文"** 或 **"English"**（当前选择的语言）
   - 右侧有向右箭头 ➡️

5. **点击 Language 选项**
   - 会跳转到语言设置页面
   - 可以选择"简体中文"或"English"

### 方法 2：直接导航（如果集成到其他页面）

如果您在其他页面（如设置页面），可以通过代码直接跳转：

```dart
Get.toNamed(AppRoutes.languageSettings);
```

或

```dart
Navigator.pushNamed(context, '/language-settings');
```

## 🎯 语言选项位置

User Profile 页面结构：

```
┌─────────────────────────────────────┐
│  Profile                            │
├─────────────────────────────────────┤
│                                     │
│  [用户头像和信息]                    │
│                                     │
│  Activity (统计信息)                 │
│  ├─ Favorites: 12                   │
│  └─ Visited: 8                      │
│                                     │
│  Preferences (偏好设置)              │
│  ├─ 🔔 Notifications               │
│  ├─ 💰 Currency: USD               │
│  ├─ 🌡️  Temperature Unit: Celsius  │
│  └─ 🌐 Language: 中文 / English ⬅️  │  👈 在这里！
│                                     │
│  Account (账户)                      │
│  ├─ Privacy Settings               │
│  ├─ Help & Support                 │
│  └─ About                          │
│                                     │
│  [Logout 按钮]                      │
│                                     │
└─────────────────────────────────────┘
```

## ✨ 视觉特征

语言选项具有以下特征，便于识别：

- **图标**：🌐 橙色地球/语言图标
- **标题**：粗体白色文字 "语言" 或 "Language"
- **当前语言**：浅色文字显示当前选择（"中文" 或 "English"）
- **箭头**：右侧有灰色向右箭头
- **分隔线**：上方有一条分隔线，与其他设置项分开
- **可点击**：整个区域都可以点击

## 🔄 使用流程

```
打开应用
   ↓
进入 Profile 页面
   ↓
滚动到 Preferences 部分
   ↓
找到 "Language" 选项（带🌐图标）
   ↓
点击
   ↓
进入语言设置页面
   ↓
选择语言（中文/English）
   ↓
应用立即切换语言
```

## 💡 提示

1. **如果看不到 Language 选项**：
   - 确保应用已完全重启（关闭后重新打开）
   - 检查是否滚动到了 Preferences 部分的底部
   - Language 选项在 Temperature Unit 下方

2. **Language 选项的特点**：
   - 它是 Preferences 部分的最后一项
   - 与 Currency 和 Temperature Unit 样式相似
   - 但 Language 可以点击跳转，不是下拉菜单

3. **实时更新**：
   - 切换语言后，Profile 页面的 Language 选项会自动更新显示
   - 不需要手动刷新页面

## 🎨 UI 截图参考位置

```
┌────────────────────────┐
│  Preferences           │
├────────────────────────┤
│                        │
│  🔔 Notifications      │  ← 第一项
│     Receive updates... │
│  ──────────────────    │
│  💰 Currency     [USD▼]│  ← 第二项
│  ──────────────────    │
│  🌡️  Temperature [C▼]  │  ← 第三项
│  ──────────────────    │
│  🌐 Language        ➡️ │  ← 第四项（新增）
│     中文 / English     │     👈 就在这里！
└────────────────────────┘
```

## ✅ 确认已成功添加

语言切换功能已确认添加到：
- ✅ 文件：`lib/pages/user_profile_page.dart`
- ✅ 位置：Preferences 部分的最后一项
- ✅ 功能：点击跳转到语言设置页面
- ✅ 显示：实时显示当前语言

应用已重新运行，现在打开 Profile 页面即可看到 Language 选项！🎉

---

**注意**：如果之前应用在后台运行，建议完全关闭应用后重新打开，以确保看到最新的更改。
