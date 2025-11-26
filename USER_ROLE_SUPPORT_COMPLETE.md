# Flutter 端 Role 支持完成总结

## 📋 概述
完成 Flutter 端对用户 role（角色）的完整支持，包括：
- 后端返回 role 信息
- Flutter 端存储到 SharedPreferences
- 提供便捷的权限检查方法
- 支持基于 role 的 UI 控制

## ✅ 已完成的修改

### 1. 实体层（Domain）

#### AuthUser 实体
**文件**: `lib/features/auth/domain/entities/auth_user.dart`

添加了 role 字段和权限检查方法：
```dart
class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role; // ✅ 新增：用户角色

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.role = 'user', // ✅ 默认值为 'user'
  });

  // ✅ 新增：权限检查方法
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
}
```

#### UserInfo 实体
**文件**: `lib/features/auth/domain/entities/login_response.dart`

添加了 role 字段和权限检查方法：
```dart
class UserInfo {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role; // ✅ 新增：用户角色
  final DateTime createdAt;
  final DateTime updatedAt;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'user', // ✅ 默认值为 'user'
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasPhone => phone != null && phone!.isNotEmpty;
  // ✅ 新增：权限检查方法
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
}
```

### 2. 数据层（Infrastructure）

#### AuthUserDto
**文件**: `lib/features/auth/infrastructure/models/auth_user_dto.dart`

完整支持 role 的序列化和反序列化：
```dart
class AuthUserDto {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role; // ✅ 新增

  AuthUserDto({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.role = 'user',
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'user', // ✅ 解析 role，默认 'user'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role, // ✅ 序列化 role
    };
  }

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatar: avatar,
      role: role, // ✅ 映射到实体
    );
  }

  factory AuthUserDto.fromDomain(AuthUser user) {
    return AuthUserDto(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatar: user.avatar,
      role: user.role, // ✅ 从实体映射
    );
  }
}
```

#### UserInfoDto
**文件**: `lib/features/auth/infrastructure/models/login_response_dto.dart`

添加 role 字段支持：
```dart
class UserInfoDto {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role; // ✅ 新增：用户角色
  final String createdAt;
  final String updatedAt;

  UserInfoDto({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'user', // ✅ 默认值 'user'
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserInfoDto.fromJson(Map<String, dynamic> json) {
    return UserInfoDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'user', // ✅ 解析 role
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role, // ✅ 序列化 role
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserInfo toDomain() {
    return UserInfo(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role, // ✅ 映射到实体
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
```

### 3. 存储服务（Services）

#### TokenStorageService
**文件**: `lib/services/token_storage_service.dart`

扩展为完整的用户信息存储服务：
```dart
class TokenStorageService {
  // ✅ 新增：用户信息存储键
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';

  // ✅ 新增：保存用户信息（登录/注册时调用）
  Future<void> saveUserInfo({
    required String userId,
    required String userName,
    required String userEmail,
    String userRole = 'user',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_userIdKey, userId),
      prefs.setString(_userNameKey, userName),
      prefs.setString(_userEmailKey, userEmail),
      prefs.setString(_userRoleKey, userRole),
    ]);
  }

  // ✅ 新增：获取用户 ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // ✅ 新增：获取用户名
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // ✅ 新增：获取用户邮箱
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // ✅ 新增：获取用户角色
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey) ?? 'user';
  }

  // ✅ 新增：检查是否为管理员
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  // ✅ 修改：清除所有用户信息
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_expiresInKey),
      prefs.remove(_refreshExpiresInKey),
      // ✅ 清除用户信息
      prefs.remove(_userIdKey),
      prefs.remove(_userNameKey),
      prefs.remove(_userEmailKey),
      prefs.remove(_userRoleKey),
    ]);
  }
}
```

### 4. 仓储层（Repository）

#### AuthRepository
**文件**: `lib/features/auth/infrastructure/repositories/auth_repository.dart`

登录和注册方法添加保存用户信息逻辑：
```dart
@override
Future<Result<AuthToken>> login({
  required String email,
  required String password,
}) async {
  return execute(() async {
    final response = await _httpService.post(
      ApiConfig.loginEndpoint,
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final tokenDto = AuthTokenDto.fromJson(data);
      final token = tokenDto.toDomain();

      _httpService.setAuthToken(token.accessToken);
      await persistToken(token);

      // ✅ 新增：保存用户信息到 SharedPreferences
      final userData = data['data']?['user'];
      if (userData != null) {
        await TokenStorageService().saveUserInfo(
          userId: userData['id'] as String,
          userName: userData['name'] as String,
          userEmail: userData['email'] as String,
          userRole: userData['role'] as String? ?? 'user',
        );
      }

      return token;
    } else {
      throw ServerException('登录失败');
    }
  });
}

@override
Future<Result<AuthToken>> register({
  required String name,
  required String email,
  required String password,
  String? phone,
}) async {
  return execute(() async {
    final response = await _httpService.post(
      ApiConfig.registerEndpoint,
      data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      final tokenDto = AuthTokenDto.fromJson(data);
      final token = tokenDto.toDomain();

      _httpService.setAuthToken(token.accessToken);
      await persistToken(token);

      // ✅ 新增：保存用户信息到 SharedPreferences
      final userData = data['data']?['user'];
      if (userData != null) {
        await TokenStorageService().saveUserInfo(
          userId: userData['id'] as String,
          userName: userData['name'] as String,
          userEmail: userData['email'] as String,
          userRole: userData['role'] as String? ?? 'user',
        );
      }

      return token;
    } else {
      throw ServerException('注册失败');
    }
  });
}
```

## 🔧 使用示例

### 1. 获取用户角色

```dart
// 获取当前用户角色
final role = await TokenStorageService().getUserRole();
print('当前用户角色: $role'); // user 或 admin

// 检查是否为管理员
final isAdmin = await TokenStorageService().isAdmin();
if (isAdmin) {
  print('当前用户是管理员');
}
```

### 2. 基于角色的 UI 控制

```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: TokenStorageService().isAdmin(),
      builder: (context, snapshot) {
        final isAdmin = snapshot.data ?? false;
        
        return Column(
          children: [
            ListTile(title: Text('个人设置')),
            ListTile(title: Text('修改密码')),
            
            // ✅ 仅管理员可见
            if (isAdmin) ...[
              Divider(),
              ListTile(
                title: Text('用户管理'),
                leading: Icon(Icons.admin_panel_settings),
              ),
              ListTile(
                title: Text('系统设置'),
                leading: Icon(Icons.settings),
              ),
            ],
          ],
        );
      },
    );
  }
}
```

### 3. 使用实体层的权限检查

```dart
// 在拥有 AuthUser 或 UserInfo 实体的地方
class UserProfileController extends GetxController {
  final AuthUser user = ...; // 从登录获取
  
  void showAdminFeatures() {
    // ✅ 使用实体的 isAdmin getter
    if (user.isAdmin) {
      Get.to(() => AdminPanel());
    } else {
      Get.snackbar('提示', '仅管理员可访问');
    }
  }
}
```

## 🧪 测试步骤

### 1. 重启后端服务
确保 UserService 使用最新代码（包含 role 支持）：
```bash
cd go-noma/src/Services/UserService
dapr stop --app-id user-service
dapr run --app-id user-service \
  --app-port 8001 \
  --dapr-http-port 3501 \
  --dapr-grpc-port 50001 \
  --components-path ../../../components \
  -- dotnet run
```

### 2. 测试登录流程
1. 启动 Flutter 应用
2. 使用测试账号登录（admin 或 user）
3. 检查 SharedPreferences 是否存储了 role：
```dart
// 调试代码
final role = await TokenStorageService().getUserRole();
final isAdmin = await TokenStorageService().isAdmin();
print('Role: $role, IsAdmin: $isAdmin');
```

### 3. 验证权限控制
1. 管理员账号：
   - 应显示管理功能菜单
   - `isAdmin()` 返回 true

2. 普通用户账号：
   - 隐藏管理功能
   - `isAdmin()` 返回 false

## 📝 后续建议

### 1. 添加更多角色类型
如需支持更多角色（如 moderator, premium_user），可以：
```dart
// 在 AuthUser 中添加
bool get isModerator => role == 'moderator';
bool get isPremiumUser => role == 'premium_user';

// 或者使用枚举
enum UserRole {
  user,
  admin,
  moderator,
  premium;
  
  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.user,
    );
  }
}
```

### 2. 角色权限映射
创建权限管理系统：
```dart
class PermissionManager {
  static const Map<String, List<String>> rolePermissions = {
    'admin': ['view_all', 'edit_all', 'delete_all', 'manage_users'],
    'moderator': ['view_all', 'edit_content', 'delete_content'],
    'user': ['view_own', 'edit_own'],
  };
  
  static Future<bool> hasPermission(String permission) async {
    final role = await TokenStorageService().getUserRole();
    return rolePermissions[role]?.contains(permission) ?? false;
  }
}

// 使用
if (await PermissionManager.hasPermission('manage_users')) {
  // 显示用户管理功能
}
```

### 3. 路由守卫
基于角色保护路由：
```dart
class AdminGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final isAdmin = await TokenStorageService().isAdmin();
    if (!isAdmin) {
      return RouteSettings(name: '/unauthorized');
    }
    return null;
  }
}

// 在路由中使用
GetPage(
  name: '/admin',
  page: () => AdminPage(),
  middlewares: [AdminGuard()],
)
```

## ✅ 验证清单

- [x] 后端 UserDto 包含 role 字段
- [x] 后端服务返回 role 信息（login/register）
- [x] Flutter AuthUser 实体包含 role
- [x] Flutter UserInfo 实体包含 role
- [x] AuthUserDto 支持 role 序列化
- [x] UserInfoDto 支持 role 序列化
- [x] TokenStorageService 存储 role
- [x] TokenStorageService 提供 getUserRole()
- [x] TokenStorageService 提供 isAdmin()
- [x] 登录时保存用户信息（包括 role）
- [x] 注册时保存用户信息（包括 role）
- [x] 登出时清除用户信息
- [x] 无编译错误

## 🎯 完成状态

**状态**: ✅ 完成

所有代码修改已完成并通过编译检查。现在可以：
1. 重启后端服务
2. 测试 Flutter 端登录流程
3. 验证 role 存储和权限检查功能
4. 在 UI 中实现基于角色的访问控制

---
**修改日期**: 2024-01-XX
**相关文档**: 
- 后端 Role 支持: `go-noma/USER_ROLE_BACKEND_COMPLETE.md`（如有）
- API 文档: `API_INTEGRATION_GUIDE.md`
