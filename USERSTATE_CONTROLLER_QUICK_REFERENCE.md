# UserStateController (DDD) - 快速参考

> **最新版本**: lib/features/user/presentation/controllers/user_state_controller.dart  
> **更新日期**: 2025-01-XX  
> **状态**: ✅ 已增强 (合并 UserProfileController 功能)

---

## 📋 核心功能

### 1️⃣ 用户加载与管理
```dart
final controller = Get.find<UserStateController>();

// 加载当前用户
await controller.loadCurrentUser();
// 或使用别名 (兼容旧API)
await controller.loadUserProfile();

// 获取当前用户
final user = controller.currentUser.value;

// 检查登录状态
if (controller.isLoggedIn) {
  // 用户已登录
}

// 清除用户状态 (登出)
controller.clearUser();
```

### 2️⃣ 编辑模式 (🆕 合并自 UserProfileController)
```dart
// 获取编辑模式状态
Obx(() {
  if (controller.isEditMode.value) {
    return EditProfileButton();
  } else {
    return ViewProfileButton();
  }
})

// 切换编辑模式
controller.toggleEditMode();
```

### 3️⃣ 登录状态变化通知 (🆕 合并自 UserProfileController)
```dart
// 监听登录状态变化
ever(controller.loginStateChanged, (_) {
  print('🔔 用户登录状态已变化');
  // 重新加载数据
  loadUserData();
});

// 状态变化会在以下情况触发:
// - loadCurrentUser() 成功加载用户
// - clearUser() 清除用户状态
```

### 4️⃣ 收藏城市管理
```dart
// 加载收藏城市ID列表
await controller.loadFavoriteCityIds();

// 检查城市是否已收藏
bool isFavorite = controller.isFavoriteCityId('city-123');

// 切换收藏状态
await controller.toggleFavoriteCity('city-123');

// 获取所有收藏城市ID
Set<String> favoriteIds = controller.favoriteCityIds.toSet();
```

### 5️⃣ 用户信息更新
```dart
// 更新用户信息
bool success = await controller.updateUser({
  'bio': '新的个人简介',
  'location': 'Tokyo, Japan',
  'website': 'https://example.com',
});

if (success) {
  print('✅ 更新成功');
} else {
  print('❌ 更新失败: ${controller.errorMessage.value}');
}
```

---

## 🎨 UI 集成示例

### 示例 1: 个人资料页面
```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserStateController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          // 编辑按钮
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: controller.toggleEditMode,
          ),
        ],
      ),
      body: Obx(() {
        // 显示加载状态
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        // 检查登录状态
        if (!controller.isLoggedIn) {
          return LoginPrompt();
        }
        
        final user = controller.currentUser.value!;
        
        return SingleChildScrollView(
          child: Column(
            children: [
              // 用户头像
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.avatarUrl ?? ''),
              ),
              
              // 用户名 (编辑模式)
              if (controller.isEditMode.value)
                TextField(
                  controller: TextEditingController(text: user.username),
                  decoration: InputDecoration(labelText: 'Username'),
                )
              else
                Text(user.username, style: TextStyle(fontSize: 24)),
              
              // 保存按钮 (仅编辑模式)
              if (controller.isEditMode.value)
                ElevatedButton(
                  onPressed: () async {
                    await controller.updateUser({
                      'username': nameController.text,
                    });
                    controller.toggleEditMode();
                  },
                  child: Text('Save'),
                ),
            ],
          ),
        );
      }),
    );
  }
}
```

### 示例 2: 登录状态监听
```dart
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Get.find<UserStateController>();
  
  @override
  void initState() {
    super.initState();
    
    // 监听登录状态变化
    ever(controller.loginStateChanged, (_) {
      print('🔔 登录状态已变化，重新加载推荐内容...');
      _loadRecommendations();
    });
  }
  
  void _loadRecommendations() {
    // 根据登录状态加载不同内容
    if (controller.isLoggedIn) {
      // 加载个性化推荐
      loadPersonalizedContent();
    } else {
      // 加载通用推荐
      loadGeneralContent();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          Obx(() => controller.isLoggedIn
            ? UserAvatar(user: controller.currentUser.value!)
            : LoginButton(),
          ),
        ],
      ),
      body: _buildContent(),
    );
  }
}
```

### 示例 3: 收藏功能
```dart
class CityCard extends StatelessWidget {
  final String cityId;
  final String cityName;
  
  const CityCard({required this.cityId, required this.cityName});
  
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserStateController>();
    
    return Card(
      child: Column(
        children: [
          Text(cityName, style: TextStyle(fontSize: 18)),
          
          // 收藏按钮
          Obx(() {
            final isFavorite = controller.isFavoriteCityId(cityId);
            
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () async {
                await controller.toggleFavoriteCity(cityId);
                
                // 显示提示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFavorite ? 'Removed from favorites' : 'Added to favorites',
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
```

---

## 📊 状态属性

| 属性 | 类型 | 说明 | 用途 |
|------|------|------|------|
| `currentUser` | `Rx<User?>` | 当前用户对象 | 获取用户信息 |
| `isLoading` | `RxBool` | 加载状态 | 显示加载指示器 |
| `errorMessage` | `RxString` | 错误信息 | 显示错误提示 |
| `favoriteCityIds` | `RxSet<String>` | 收藏城市ID集合 | 管理收藏城市 |
| `isEditMode` | `RxBool` | 🆕 编辑模式状态 | 切换编辑/查看模式 |
| `loginStateChanged` | `RxBool` | 🆕 登录状态变化通知 | 监听登录/登出事件 |

---

## 🔑 核心方法

### 用户加载
```dart
// 加载当前用户 (推荐使用)
Future<void> loadCurrentUser()

// 加载用户资料 (别名,兼容旧API)
Future<void> loadUserProfile()

// 刷新用户信息
Future<void> refresh()
```

### 用户管理
```dart
// 更新用户信息
Future<bool> updateUser(Map<String, dynamic> updates)

// 清除用户状态 (登出)
void clearUser()
```

### 编辑模式 (🆕)
```dart
// 切换编辑模式
void toggleEditMode()
```

### 收藏城市
```dart
// 加载收藏城市ID列表
Future<void> loadFavoriteCityIds()

// 检查城市是否已收藏
bool isFavoriteCityId(String cityId)

// 切换收藏状态
Future<void> toggleFavoriteCity(String cityId)
```

### 计算属性
```dart
// 是否已登录
bool get isLoggedIn

// 是否已完成资料
bool get hasCompletedProfile

// 是否活跃游民
bool get isActiveNomad

// 经验等级
int get experienceLevel
```

---

## 🎯 最佳实践

### ✅ 推荐做法
```dart
// 1. 使用 Obx 包裹响应式 UI
Obx(() {
  if (controller.isLoggedIn) {
    return Text('Welcome, ${controller.currentUser.value!.username}');
  }
  return Text('Please login');
})

// 2. 检查加载状态
if (controller.isLoading.value) {
  return CircularProgressIndicator();
}

// 3. 使用 ever 监听状态变化
ever(controller.loginStateChanged, (_) {
  loadUserData();
});

// 4. 显示错误信息
if (controller.errorMessage.value.isNotEmpty) {
  showSnackbar(controller.errorMessage.value);
}

// 5. 使用 isLoggedIn getter
if (controller.isLoggedIn) {
  // 已登录逻辑
}
```

### ❌ 避免做法
```dart
// ❌ 不要直接修改 currentUser
controller.currentUser.value = user;  // 使用 loadCurrentUser() 代替

// ❌ 不要在没有 Obx 的情况下访问 .value
Text(controller.currentUser.value.username);  // 用 Obx 包裹

// ❌ 不要忘记处理 null 情况
final user = controller.currentUser.value!;  // 先检查 isLoggedIn

// ❌ 不要使用旧版 API (已删除)
controller.login(accountId, username);  // ❌ 不存在
controller.logout();  // ❌ 使用 clearUser() 代替
controller.username;  // ❌ 使用 currentUser.value?.username
controller.currentAccountId;  // ❌ 使用 currentUser.value?.id
```

---

## 🆚 API 变化对比

### 旧版 UserStateController (已删除)
```dart
// ❌ 旧版 API (lib/controllers/user_state_controller.dart)
userStateController.login(accountId, username, email: email);
userStateController.logout();
userStateController.username;
userStateController.currentAccountId;
userStateController.isLoggedIn;
```

### DDD UserStateController (当前版本)
```dart
// ✅ 新版 API (lib/features/user/presentation/controllers/user_state_controller.dart)
await controller.loadCurrentUser();
controller.clearUser();
controller.currentUser.value?.username;
controller.currentUser.value?.id;
controller.isLoggedIn;

// 🆕 新增功能
controller.isEditMode.value;
controller.toggleEditMode();
controller.loginStateChanged;
await controller.loadUserProfile();
```

---

## 🔄 迁移指南

### 从旧版 UserStateController 迁移
```dart
// 步骤 1: 更新导入
// ❌ import '../controllers/user_state_controller.dart';
// ✅ import '../features/user/presentation/controllers/user_state_controller.dart';

// 步骤 2: 替换 login() 调用
// ❌ userStateController.login(accountId, username);
// ✅ await authController.login(email, password);
//    // 登录后 UserStateController 会自动加载用户

// 步骤 3: 替换 logout() 调用
// ❌ userStateController.logout();
// ✅ controller.clearUser();
//    await authController.logout();

// 步骤 4: 替换属性访问
// ❌ userStateController.username
// ✅ controller.currentUser.value?.username

// ❌ userStateController.currentAccountId
// ✅ controller.currentUser.value?.id
```

---

## 📚 相关文档
- `USER_PROFILE_MERGER_COMPLETE.md` - 迁移完成报告
- `CONTROLLERS_ANALYSIS_COMPLETE.md` - 控制器分析报告
- `lib/features/user/domain/entities/user.dart` - User 实体定义
- `lib/features/user/application/use_cases/` - 用户相关 Use Cases

---

**版本**: 2.0 (Enhanced with UserProfileController features)  
**维护**: GitHub Copilot  
**最后更新**: 2025-01-XX
