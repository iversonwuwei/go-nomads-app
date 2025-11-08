# Auth Database DDD 架构迁移完成

## ✅ 完成状态
- **Auth 域编译状态**: ✅ **0 错误, 0 警告**
- **数据库层创建**: ✅ 完成 (Domain, Infrastructure, Application)
- **AuthStateController 集成**: ✅ 完成 (login, register, logout 已集成数据库)
- **DI 配置**: ✅ 完成

---

## 📋 创建的新文件

### 1. Domain Layer - 数据库仓储接口
**文件**: `lib/features/auth/domain/repositories/iauth_database_repository.dart` (73 行)

**接口方法**:
- `saveTokenToDatabase(AuthToken, AuthUser)` - 保存 token + 用户信息到数据库
- `getLatestToken()` - 获取最新 token
- `getTokenByUserId(userId)` - 根据 userId 获取 token
- `isTokenExpired(userId)` - 检查 token 是否过期
- `deleteAllTokens()` - 删除所有 token
- `deleteTokenByUserId(userId)` - 删除指定用户的 token

**Value Object**:
```dart
class TokenDatabaseData {
  final String userId;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String userName;
  final String userEmail;
}
```

---

### 2. Infrastructure Layer - 数据库仓储实现
**文件**: `lib/features/auth/infrastructure/repositories/auth_database_repository.dart` (100 行)

**实现特点**:
- 封装 `TokenDao` (SQLite 操作)
- 统一错误处理: `_execute<T>()` 包装器
- 所有异常转换为 `BusinessLogicException`
- 数据映射: `_mapToTokenDatabaseData()` 转换 Map → TokenDatabaseData

**依赖**:
```dart
AuthDatabaseRepository({TokenDao? tokenDao})
  : _tokenDao = tokenDao ?? TokenDao();
```

---

### 3. Application Layer - 数据库 Use Cases
**文件**: `lib/features/auth/application/use_cases/auth_database_use_cases.dart` (164 行)

#### SaveTokenToDatabaseUseCase
```dart
execute(SaveTokenToDatabaseParams params) async {
  return _repository.saveTokenToDatabase(
    params.token, 
    params.user
  );
}
```

#### RestoreTokenFromDatabaseUseCase
**功能流程**:
1. 从数据库获取最新 token
2. 检查是否过期
3. 若过期 → 自动刷新 (`IAuthRepository.refreshToken()`)
4. 若有效 → 保存到内存 (`TokenStorageService`)
5. 返回恢复的 token

**代码逻辑**:
```dart
execute(NoParams params) async {
  // 1. 获取数据库中的 token
  final tokenData = await _databaseRepository.getLatestToken();
  
  // 2. 检查过期
  final isExpired = await _databaseRepository.isTokenExpired(userId);
  
  // 3. 过期则刷新
  if (isExpired) {
    final refreshResult = await _authRepository.refreshToken(
      RefreshTokenParams(refreshToken: tokenData.refreshToken)
    );
    return refreshResult.fold(
      onSuccess: (newToken) async {
        await _databaseRepository.saveTokenToDatabase(newToken, user);
        return Result.success(newToken);
      },
      onFailure: (_) => Result.success(null),
    );
  }
  
  // 4. 未过期则恢复到内存
  await _tokenStorage.saveAccessToken(token);
  return Result.success(token);
}
```

#### CheckLoginStatusWithDatabaseUseCase
**功能流程**:
1. **快速路径**: 先检查内存 (`IAuthRepository.isAuthenticated()`)
2. **慢速路径**: 内存无 token → 检查数据库
3. **自动恢复**: 数据库有 token → 调用 `RestoreTokenFromDatabaseUseCase`

**代码逻辑**:
```dart
execute(NoParams params) async {
  try {
    // 1. 检查内存 (快速路径)
    final isAuthInMemory = await _authRepository.isAuthenticated();
    if (isAuthInMemory) {
      return Result.success(true);
    }
    
    // 2. 检查数据库 (慢速路径)
    final tokenData = await _databaseRepository.getLatestToken();
    if (tokenData == null) {
      return Result.success(false);
    }
    
    // 3. 自动恢复
    final restoreResult = await _restoreUseCase.execute(NoParams());
    return restoreResult.fold(
      onSuccess: (token) => Result.success(token != null),
      onFailure: (_) => Result.success(false),
    );
  } catch (e) {
    throw BusinessLogicException(message: '检查登录状态失败: $e');
  }
}
```

---

## 🔄 更新的文件

### 1. AuthStateController
**文件**: `lib/features/auth/presentation/controllers/auth_state_controller.dart`

#### 新增字段
```dart
final SaveTokenToDatabaseUseCase _saveTokenToDatabaseUseCase;
final CheckLoginStatusWithDatabaseUseCase _checkLoginStatusWithDatabaseUseCase;
```

#### onInit() 修改
```dart
@override
void onInit() {
  super.onInit();
  // 优先从数据库恢复登录状态
  _checkLoginStatusWithDatabase();
}
```

#### login() 方法集成数据库
```dart
Future<bool> login({...}) async {
  // 1. 调用 LoginUseCase
  final result = await _loginUseCase.execute(...);
  
  return result.fold(
    onSuccess: (token) async {
      // 2. 设置 HttpService token
      HttpService.setAuthToken(token.accessToken);
      
      // 3. 加载当前用户
      final userResult = await _getCurrentUserUseCase.execute(NoParams());
      
      await userResult.fold(
        onSuccess: (user) async {
          // 4. 保存到数据库
          await _saveTokenToDatabaseUseCase.execute(
            SaveTokenToDatabaseParams(token: token, user: user),
          );
          
          // 5. 设置 userId
          HttpService.setUserId(user.id);
          
          currentUser.value = user;
          currentToken.value = token;
          isAuthenticated.value = true;
        },
        onFailure: (_) {},
      );
      
      return true;
    },
    onFailure: (_) => false,
  );
}
```

#### register() 方法集成数据库
```dart
Future<bool> register({...}) async {
  // 与 login() 相同的数据库集成模式
  // 1. RegisterUseCase
  // 2. HttpService.setAuthToken
  // 3. GetCurrentUserUseCase
  // 4. SaveTokenToDatabaseUseCase
  // 5. HttpService.setUserId
}
```

#### logout() 方法集成数据库
```dart
Future<void> logout() async {
  final userId = currentUser.value?.id;
  if (userId != null) {
    // 1. 删除数据库 token
    await _authDatabaseRepository.deleteTokenByUserId(userId);
  }
  
  // 2. 调用 LogoutUseCase (清除内存)
  await _logoutUseCase.execute(NoParams());
  
  // 3. 清除 HttpService
  HttpService.clearAuthToken();
  HttpService.clearUserId();
  
  // 4. 清除本地状态
  currentUser.value = null;
  currentToken.value = null;
  isAuthenticated.value = false;
}
```

---

### 2. AuthToken Entity
**文件**: `lib/features/auth/domain/entities/auth_token.dart`

**新增属性**:
```dart
final String tokenType;  // 默认 'Bearer'
final int expiresIn;     // 默认 3600 (1小时)
```

**用途**: 匹配数据库存储需求 (TokenDao.saveToken 需要这些字段)

---

### 3. Result 类增强
**文件**: `lib/core/domain/result.dart`

**新增静态工厂方法**:
```dart
static Success<T> success<T>(T data) => Success(data);
static Failure<T> failure<T>(DomainException exception) => Failure(exception);
```

**解决问题**: 修复 20+ "undefined_method" 编译错误

---

### 4. DI 配置
**文件**: `lib/core/di/dependency_injection.dart`

#### 新增导入
```dart
import '../features/auth/domain/repositories/iauth_database_repository.dart';
import '../features/auth/infrastructure/repositories/auth_database_repository.dart';
import '../features/auth/application/use_cases/auth_database_use_cases.dart'
    as auth_db_use_cases;
```

#### 新增注册
```dart
// Repository - 数据库认证
Get.lazyPut<IAuthDatabaseRepository>(
  () => AuthDatabaseRepository(),
);

// Use Cases - 数据库认证
Get.lazyPut(() => auth_db_use_cases.SaveTokenToDatabaseUseCase(
  Get.find<IAuthDatabaseRepository>(),
));
Get.lazyPut(() => auth_db_use_cases.CheckLoginStatusWithDatabaseUseCase(
  Get.find<IAuthDatabaseRepository>(),
  Get.find<IAuthRepository>(),
));

// Controller 更新
Get.lazyPut(
  () => AuthStateController(
    ...
    saveTokenToDatabaseUseCase: Get.find<auth_db_use_cases.SaveTokenToDatabaseUseCase>(),
    checkLoginStatusWithDatabaseUseCase: Get.find<auth_db_use_cases.CheckLoginStatusWithDatabaseUseCase>(),
  ),
);
```

---

## 🏗️ 架构总结

### 双层存储策略
1. **内存层 (快速访问)**:
   - `TokenStorageService` (SharedPreferences)
   - 由 `AuthRepository` 使用
   - 适用于频繁访问场景

2. **持久层 (可靠存储)**:
   - `TokenDao` (SQLite)
   - 由 `AuthDatabaseRepository` 包装
   - 适用于应用重启恢复

### 数据流向

#### Login/Register 流程
```
User Input
  ↓
LoginUseCase/RegisterUseCase (调用后端 API)
  ↓
AuthRepository.login/register → TokenStorageService (内存)
  ↓
HttpService.setAuthToken(token)
  ↓
GetCurrentUserUseCase (加载用户信息)
  ↓
SaveTokenToDatabaseUseCase → AuthDatabaseRepository → TokenDao (数据库)
  ↓
HttpService.setUserId(userId)
  ↓
AuthStateController 状态更新
```

#### 应用启动流程
```
App Start
  ↓
AuthStateController.onInit()
  ↓
CheckLoginStatusWithDatabaseUseCase
  ├─ 快速路径: IAuthRepository.isAuthenticated() (检查内存)
  │   └─ true → 已登录
  └─ 慢速路径: IAuthDatabaseRepository.getLatestToken() (检查数据库)
      └─ RestoreTokenFromDatabaseUseCase
          ├─ 检查过期 → 自动刷新
          └─ 恢复到内存 (TokenStorageService)
```

#### Logout 流程
```
User Logout
  ↓
AuthDatabaseRepository.deleteTokenByUserId(userId) (删除数据库)
  ↓
LogoutUseCase → AuthRepository (清除内存)
  ↓
HttpService.clearAuthToken() + clearUserId()
  ↓
AuthStateController 状态清除
```

---

## 🎯 下一步任务

### Task 6: 更新依赖文件 (6 个文件)

#### 高优先级
1. **lib/pages/nomads_login_page.dart**
   - 替换: `NomadsAuthService().login()` → `AuthStateController.login()`
   - 复杂度: 中 (需处理 UI 状态)

2. **lib/services/app_init_service.dart**
   - 替换: `NomadsAuthService().checkLoginStatus()` → `AuthStateController.isAuthenticated.value`
   - 复杂度: 低 (已在 onInit 中恢复)

3. **lib/middlewares/auth_middleware.dart**
   - 替换: `NomadsAuthService().isAuthenticated()` → `AuthStateController.isAuthenticated.value`
   - 复杂度: 低 (直接访问状态)

#### 中优先级
4. **lib/utils/login_debug_helper.dart**
   - 替换: `NomadsAuthService()` → `AuthStateController`
   - 复杂度: 低 (调试工具)

5. **lib/services/events_api_service.dart**
   - 替换: `NomadsAuthService()` → `AuthStateController` (可能用于获取 token)
   - 复杂度: 中 (需确认用途)

6. **lib/services/location_api_service.dart**
   - 同上
   - 复杂度: 中

### Task 7: 更新 register_page.dart
- 替换: `AuthService().register()` → `AuthStateController.register()`

### Task 8: 更新 user_profile_controller.dart
- 确认是否需要更新用户资料相关逻辑

### Task 9: 删除旧服务
- `lib/services/auth_service.dart` (263 行)
- `lib/services/nomads_auth_service.dart` (389 行)

### Task 10: 全量测试
- [ ] 登录流程 (含数据库持久化)
- [ ] 注册流程 (含数据库持久化)
- [ ] 登出流程 (含数据库清理)
- [ ] 应用重启恢复 (从数据库恢复)
- [ ] Token 自动刷新 (过期 token 处理)
- [ ] `flutter analyze` 全项目检查

---

## ✨ 技术亮点

### 1. DDD 架构分层
- Domain: 接口定义 (`IAuthDatabaseRepository`)
- Infrastructure: 实现细节 (`AuthDatabaseRepository` 封装 `TokenDao`)
- Application: 业务逻辑 (Use Cases)
- Presentation: 状态管理 (`AuthStateController`)

### 2. 错误处理统一化
- 所有异常统一转换为 `BusinessLogicException`
- `_execute<T>()` 泛型包装器确保一致性

### 3. 自动化恢复机制
- **Token 过期自动刷新**: `RestoreTokenFromDatabaseUseCase`
- **应用启动自动恢复**: `CheckLoginStatusWithDatabaseUseCase`
- **快速路径优化**: 优先检查内存,降低数据库访问

### 4. 依赖注入解耦
- 所有依赖通过 GetX 注册
- Controller 通过构造函数注入 Use Cases
- Use Cases 通过构造函数注入 Repositories

### 5. 数据库测试友好
- `AuthDatabaseRepository` 支持注入 `TokenDao` mock
- 所有 Use Cases 返回 `Result<T>` 便于测试
- `_execute<T>()` 可单独测试错误处理逻辑

---

## 📊 代码统计

### 新增代码
- **Domain Layer**: 73 行
- **Infrastructure Layer**: 100 行
- **Application Layer**: 164 行
- **总计**: **337 行**

### 修改代码
- **AuthStateController**: ~80 行修改
- **DI 配置**: ~30 行修改
- **AuthToken Entity**: +2 属性
- **Result 类**: +2 静态方法

### 删除代码
- **未使用的 Use Cases**: -2 Use Cases (CheckAuthStatusUseCase, RestoreTokenFromDatabaseUseCase 的部分使用)
- **未使用的方法**: -1 方法 (_checkAuthStatus)

---

## 📝 迁移注意事项

### 使用模式变更

#### ❌ 旧模式
```dart
final authService = NomadsAuthService();
final isLoggedIn = await authService.checkLoginStatus();
final loginResponse = await authService.login(email: ..., password: ...);
await authService.logout();
```

#### ✅ 新模式
```dart
final authController = Get.find<AuthStateController>();

// 应用启动时已自动检查 (在 onInit 中)
final isLoggedIn = authController.isAuthenticated.value;

// 登录 (自动保存到数据库)
final success = await authController.login(email: ..., password: ...);

// 登出 (自动清除数据库)
await authController.logout();
```

### 数据库持久化自动化
- ✅ 登录/注册成功 → **自动保存**到数据库
- ✅ 应用启动 → **自动恢复**数据库 token
- ✅ Token 过期 → **自动刷新**并更新数据库
- ✅ 登出 → **自动清除**数据库 token

### 依赖注入要求
- ⚠️ 必须先调用 `DependencyInjection.init()` 初始化 DI
- ⚠️ 使用前确保 `AuthStateController` 已注册 (`Get.find<AuthStateController>()`)

---

## ✅ 验证通过

```bash
flutter analyze lib/features/auth
```

**结果**: ✅ **No issues found!**

---

**创建时间**: ${DateTime.now()}
**迁移方案**: 方案 B (AuthDatabaseRepository 模式)
**编译状态**: ✅ 0 错误, 0 警告
