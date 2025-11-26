# DDD重构快速参考指南

## 🎯 模板:如何重构一个新领域

以User领域为模板,重构任何新领域只需遵循这5个步骤:

---

## Step 1: 创建Repository接口

**文件**: `lib/features/{domain}/domain/repositories/i{domain}_repository.dart`

```dart
import '../../../../core/core.dart';
import '../entities/{domain}.dart';

abstract interface class I{Domain}Repository implements IRepository {
  // 定义领域操作,全部返回Result<T>
  Future<Result<{Domain}>> get{Domain}(String id);
  Future<Result<List<{Domain}>>> get{Domain}List({...});
  Future<Result<{Domain}>> create{Domain}({...});
  Future<Result<{Domain}>> update{Domain}(String id, {...});
  Future<Result<void>> delete{Domain}(String id);
}
```

**⚠️ 命名规范**: `i{name}_repository.dart` 不是 `i_{name}_repository.dart`

---

## Step 2: 实现Repository

**文件**: `lib/features/{domain}/infrastructure/repositories/{domain}_repository.dart`

```dart
import 'package:dio/dio.dart';
import '../../../../core/core.dart';
import '../../domain/entities/{domain}.dart';
import '../../domain/repositories/i{domain}_repository.dart';
import '../models/{domain}_dto.dart';
import '../../../../config/api_config.dart';
import '../../../../services/token_storage_service.dart';

class {Domain}Repository extends BaseRepository implements I{Domain}Repository {
  final Dio _dio;
  final TokenStorageService _tokenService;

  {Domain}Repository({
    required Dio dio,
    required TokenStorageService tokenService,
  }) : _dio = dio, _tokenService = tokenService;

  @override
  String get repositoryName => '{Domain}Repository';

  @override
  Future<Result<{Domain}>> get{Domain}(String id) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();
      
      final response = await _dio.get(
        '${ApiConfig.apiBaseUrl}/${endpoint}/$id',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final dto = {Domain}Dto.fromJson(response.data['data']);
        return dto.toDomain();
      }

      throw ServerException('获取失败', code: 'GET_{DOMAIN}_FAILED');
    });
  }

  // 实现其他方法...
}
```

**关键点**:
- ✅ 使用 `execute()` 包装所有异步操作
- ✅ JSON → DTO → Domain Entity
- ✅ 抛出领域异常 (DomainException子类)

---

## Step 3: 创建Use Cases

**文件**: `lib/features/{domain}/application/use_cases/{domain}_use_cases.dart`

```dart
import '../../../../core/core.dart';
import '../../domain/entities/{domain}.dart';
import '../../domain/repositories/i{domain}_repository.dart';

// ============================================================
// Use Case 1: Get{Domain}UseCase
// ============================================================
class Get{Domain}UseCase extends UseCase<{Domain}, Get{Domain}Params> {
  final I{Domain}Repository _repository;

  Get{Domain}UseCase(this._repository);

  @override
  Future<Result<{Domain}>> execute(Get{Domain}Params params) async {
    // 1. 参数验证
    if (params.id.isEmpty) {
      return Failure(ValidationException('ID不能为空', code: 'EMPTY_ID'));
    }

    // 2. 业务规则 (可选)
    // if (some business rule) { return Failure(...); }

    // 3. 调用Repository
    return await _repository.get{Domain}(params.id);
  }
}

class Get{Domain}Params extends UseCaseParams {
  final String id;
  const Get{Domain}Params({required this.id});
}

// ============================================================
// Use Case 2: Get{Domain}ListUseCase
// ============================================================
class Get{Domain}ListUseCase extends UseCase<List<{Domain}>, Get{Domain}ListParams> {
  final I{Domain}Repository _repository;

  Get{Domain}ListUseCase(this._repository);

  @override
  Future<Result<List<{Domain}>>> execute(Get{Domain}ListParams params) async {
    return await _repository.get{Domain}List(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class Get{Domain}ListParams extends UseCaseParams {
  final int page;
  final int pageSize;
  const Get{Domain}ListParams({this.page = 1, this.pageSize = 20});
}

// ============================================================
// Use Case 3: Create{Domain}UseCase (如果需要)
// ============================================================
class Create{Domain}UseCase extends UseCase<{Domain}, Create{Domain}Params> {
  final I{Domain}Repository _repository;

  Create{Domain}UseCase(this._repository);

  @override
  Future<Result<{Domain}>> execute(Create{Domain}Params params) async {
    // 参数验证
    if (params.data.isEmpty) {
      return Failure(ValidationException('数据不能为空', code: 'EMPTY_DATA'));
    }

    // 调用Repository
    return await _repository.create{Domain}(params.data);
  }
}

class Create{Domain}Params extends UseCaseParams {
  final Map<String, dynamic> data;
  const Create{Domain}Params({required this.data});
}

// ... 其他Use Cases (Update, Delete, Search等)
```

**Use Case设计原则**:
- ✅ 一个Use Case = 一个业务操作
- ✅ 参数封装在 `XxxParams` 类中
- ✅ 参数验证在 `execute()` 方法开头
- ✅ 返回 `Result<T>` 类型

---

## Step 4: 重构Controller

**文件**: `lib/features/{domain}/presentation/controllers/{domain}_controller.dart`

```dart
import 'package:get/get.dart';
import '../../../../core/core.dart';
import '../../domain/entities/{domain}.dart';
import '../../application/use_cases/{domain}_use_cases.dart';

class {Domain}Controller extends GetxController {
  // Use Cases注入
  final Get{Domain}UseCase _get{Domain}UseCase;
  final Get{Domain}ListUseCase _get{Domain}ListUseCase;
  final Create{Domain}UseCase _create{Domain}UseCase;

  {Domain}Controller({
    required Get{Domain}UseCase get{Domain}UseCase,
    required Get{Domain}ListUseCase get{Domain}ListUseCase,
    required Create{Domain}UseCase create{Domain}UseCase,
  })  : _get{Domain}UseCase = get{Domain}UseCase,
        _get{Domain}ListUseCase = get{Domain}ListUseCase,
        _create{Domain}UseCase = create{Domain}UseCase;

  // 状态
  final Rx<{Domain}?> current{Domain} = Rx<{Domain}?>(null);
  final RxList<{Domain}> {domain}List = <{Domain}>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load{Domain}List();
  }

  /// 加载列表
  Future<void> load{Domain}List({int page = 1}) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _get{Domain}ListUseCase(
      Get{Domain}ListParams(page: page),
    );

    result.fold(
      onSuccess: (list) {
        {domain}List.value = list;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        _handleException(exception);
      },
    );

    isLoading.value = false;
  }

  /// 获取单个
  Future<void> load{Domain}(String id) async {
    isLoading.value = true;

    final result = await _get{Domain}UseCase(
      Get{Domain}Params(id: id),
    );

    result.fold(
      onSuccess: ({domain}) {
        current{Domain}.value = {domain};
      },
      onFailure: (exception) {
        _handleException(exception);
      },
    );

    isLoading.value = false;
  }

  /// 创建
  Future<bool> create{Domain}(Map<String, dynamic> data) async {
    isLoading.value = true;

    final result = await _create{Domain}UseCase(
      Create{Domain}Params(data: data),
    );

    isLoading.value = false;

    return result.fold(
      onSuccess: ({domain}) {
        {domain}List.add({domain});
        Get.snackbar('成功', '创建成功');
        return true;
      },
      onFailure: (exception) {
        _handleException(exception);
        return false;
      },
    );
  }

  /// 统一异常处理
  void _handleException(DomainException exception) {
    String title = '错误';

    switch (exception) {
      case UnauthorizedException():
        title = '未授权';
        // 跳转登录页...
        break;
      case NetworkException():
        title = '网络错误';
        break;
      case ValidationException():
        title = '验证失败';
        break;
      default:
        title = '未知错误';
    }

    Get.snackbar(title, exception.message);
  }
}
```

**Controller职责**:
- ✅ 只管理UI状态 (不包含业务逻辑)
- ✅ 调用Use Cases
- ✅ 使用 `Result.fold()` 处理结果
- ✅ 统一异常处理

---

## Step 5: 配置依赖注入

**文件**: `lib/core/di/dependency_injection.dart`

```dart
// 在DependencyInjection类中添加:

static void _register{Domain}Domain() {
  // Repository
  Get.lazyPut<I{Domain}Repository>(
    () => {Domain}Repository(
      dio: Get.find<Dio>(),
      tokenService: Get.find<TokenStorageService>(),
    ),
  );

  // Use Cases
  Get.lazyPut(() => Get{Domain}UseCase(Get.find<I{Domain}Repository>()));
  Get.lazyPut(() => Get{Domain}ListUseCase(Get.find<I{Domain}Repository>()));
  Get.lazyPut(() => Create{Domain}UseCase(Get.find<I{Domain}Repository>()));
  Get.lazyPut(() => Update{Domain}UseCase(Get.find<I{Domain}Repository>()));
  Get.lazyPut(() => Delete{Domain}UseCase(Get.find<I{Domain}Repository>()));

  // Controller
  Get.lazyPut(
    () => {Domain}Controller(
      get{Domain}UseCase: Get.find<Get{Domain}UseCase>(),
      get{Domain}ListUseCase: Get.find<Get{Domain}ListUseCase>(),
      create{Domain}UseCase: Get.find<Create{Domain}UseCase>(),
    ),
  );
}
```

然后在 `init()` 方法中调用:

```dart
static Future<void> init() async {
  _registerInfrastructure();
  _registerUserDomain();
  _register{Domain}Domain();  // ← 添加这行
}
```

---

## 📋 检查清单

重构一个新领域时,确保完成以下所有项:

### Domain Layer
- [ ] Entity已存在 (已在之前的Model Migration中创建)
- [ ] 创建Repository接口 (`i{domain}_repository.dart`)
- [ ] 接口继承 `IRepository`
- [ ] 所有方法返回 `Result<T>`

### Infrastructure Layer
- [ ] DTO已存在 (已在之前的Model Migration中创建)
- [ ] 创建Repository实现
- [ ] 继承 `BaseRepository` 和实现接口
- [ ] 实现 `repositoryName` getter
- [ ] 使用 `execute()` 包装所有操作
- [ ] JSON → DTO → Domain转换

### Application Layer
- [ ] 创建至少3个Use Cases (Get, GetList, Create/Update)
- [ ] 每个Use Case继承 `UseCase<R, P>` 或 `NoParamsUseCase<R>`
- [ ] 参数验证
- [ ] 业务规则封装

### Presentation Layer
- [ ] Controller重构
- [ ] 依赖Use Cases (不依赖Repository)
- [ ] 使用 `Result.fold()` 处理结果
- [ ] 统一异常处理

### Dependency Injection
- [ ] 注册Repository (接口 → 实现)
- [ ] 注册所有Use Cases
- [ ] 注册Controller
- [ ] 在 `init()` 中调用注册方法

### 测试
- [ ] 编译无错误
- [ ] 手动测试基本功能
- [ ] (可选) 编写单元测试

---

## 🎯 常用Use Case模板

### 1. 获取单个实体
```dart
class Get{Entity}UseCase extends UseCase<{Entity}, Get{Entity}Params> {
  final I{Entity}Repository _repository;
  
  Get{Entity}UseCase(this._repository);
  
  @override
  Future<Result<{Entity}>> execute(Get{Entity}Params params) async {
    if (params.id.isEmpty) {
      return Failure(ValidationException('ID不能为空'));
    }
    return await _repository.get{Entity}(params.id);
  }
}

class Get{Entity}Params extends UseCaseParams {
  final String id;
  const Get{Entity}Params({required this.id});
}
```

### 2. 获取列表(分页)
```dart
class Get{Entity}ListUseCase extends UseCase<List<{Entity}>, Get{Entity}ListParams> {
  final I{Entity}Repository _repository;
  
  Get{Entity}ListUseCase(this._repository);
  
  @override
  Future<Result<List<{Entity}>>> execute(Get{Entity}ListParams params) async {
    return await _repository.get{Entity}List(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class Get{Entity}ListParams extends UseCaseParams {
  final int page;
  final int pageSize;
  const Get{Entity}ListParams({this.page = 1, this.pageSize = 20});
}
```

### 3. 创建实体
```dart
class Create{Entity}UseCase extends UseCase<{Entity}, Create{Entity}Params> {
  final I{Entity}Repository _repository;
  
  Create{Entity}UseCase(this._repository);
  
  @override
  Future<Result<{Entity}>> execute(Create{Entity}Params params) async {
    // 参数验证
    if (params.data.isEmpty) {
      return Failure(ValidationException('数据不能为空'));
    }
    
    // 业务规则验证 (示例)
    if (!params.data.containsKey('name')) {
      return Failure(ValidationException('名称必填'));
    }
    
    return await _repository.create{Entity}(params.data);
  }
}

class Create{Entity}Params extends UseCaseParams {
  final Map<String, dynamic> data;
  const Create{Entity}Params({required this.data});
}
```

### 4. 更新实体
```dart
class Update{Entity}UseCase extends UseCase<{Entity}, Update{Entity}Params> {
  final I{Entity}Repository _repository;
  
  Update{Entity}UseCase(this._repository);
  
  @override
  Future<Result<{Entity}>> execute(Update{Entity}Params params) async {
    if (params.id.isEmpty) {
      return Failure(ValidationException('ID不能为空'));
    }
    
    if (params.updates.isEmpty) {
      return Failure(ValidationException('更新内容不能为空'));
    }
    
    return await _repository.update{Entity}(params.id, params.updates);
  }
}

class Update{Entity}Params extends UseCaseParams {
  final String id;
  final Map<String, dynamic> updates;
  const Update{Entity}Params({required this.id, required this.updates});
}
```

### 5. 删除实体
```dart
class Delete{Entity}UseCase extends UseCase<void, Delete{Entity}Params> {
  final I{Entity}Repository _repository;
  
  Delete{Entity}UseCase(this._repository);
  
  @override
  Future<Result<void>> execute(Delete{Entity}Params params) async {
    if (params.id.isEmpty) {
      return Failure(ValidationException('ID不能为空'));
    }
    
    return await _repository.delete{Entity}(params.id);
  }
}

class Delete{Entity}Params extends UseCaseParams {
  final String id;
  const Delete{Entity}Params({required this.id});
}
```

### 6. 搜索
```dart
class Search{Entity}UseCase extends UseCase<List<{Entity}>, Search{Entity}Params> {
  final I{Entity}Repository _repository;
  
  Search{Entity}UseCase(this._repository);
  
  @override
  Future<Result<List<{Entity}>>> execute(Search{Entity}Params params) async {
    if (params.query.trim().isEmpty) {
      return Failure(ValidationException('搜索关键词不能为空'));
    }
    
    if (params.query.length < 2) {
      return Failure(ValidationException('搜索关键词至少需要2个字符'));
    }
    
    return await _repository.search{Entity}(
      query: params.query,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class Search{Entity}Params extends UseCaseParams {
  final String query;
  final int page;
  final int pageSize;
  const Search{Entity}Params({
    required this.query,
    this.page = 1,
    this.pageSize = 20,
  });
}
```

### 7. 无参数操作
```dart
class GetCurrentUserUseCase extends NoParamsUseCase<User> {
  final IUserRepository _repository;
  
  GetCurrentUserUseCase(this._repository);
  
  @override
  Future<Result<User>> execute(NoParams params) async {
    return await _repository.getCurrentUser();
  }
}

// 调用方式
final result = await getCurrentUserUseCase(const NoParams());
```

---

## ⚡ Result<T> 使用速查

### 基本用法
```dart
// 1. fold() - 最常用
result.fold(
  onSuccess: (data) => print('成功: $data'),
  onFailure: (exception) => print('失败: ${exception.message}'),
);

// 2. map() - 转换成功值
final stringResult = userResult.map((user) => user.name);

// 3. flatMap() - 链式调用
final result = await getUserUseCase(params)
  .then((r) => r.flatMap((user) async => updateUserUseCase(user.id)));

// 4. getOrElse() - 提供默认值
final user = result.getOrElse(() => User.empty());

// 5. onSuccess() - 只处理成功
result.onSuccess((user) => print('用户: ${user.name}'));

// 6. onFailure() - 只处理失败
result.onFailure((exception) => showError(exception));
```

### 在Controller中使用
```dart
Future<void> loadData() async {
  isLoading.value = true;

  final result = await _getDataUseCase(params);

  result.fold(
    onSuccess: (data) {
      this.data.value = data;
      errorMessage.value = '';
    },
    onFailure: (exception) {
      errorMessage.value = exception.message;
      _handleException(exception);
    },
  );

  isLoading.value = false;
}
```

### 返回bool表示成功/失败
```dart
Future<bool> saveData(Map<String, dynamic> data) async {
  final result = await _saveUseCase(SaveParams(data: data));
  
  return result.fold(
    onSuccess: (_) {
      Get.snackbar('成功', '保存成功');
      return true;
    },
    onFailure: (exception) {
      Get.snackbar('错误', exception.message);
      return false;
    },
  );
}
```

---

## 📚 参考User领域实现

完整的User领域实现请参考:
- `lib/features/user/domain/repositories/iuser_repository.dart`
- `lib/features/user/infrastructure/repositories/user_repository.dart`
- `lib/features/user/application/use_cases/user_use_cases.dart`
- `lib/features/user/presentation/controllers/user_state_controller.dart`
- `lib/core/di/dependency_injection.dart`

详细文档: `USER_DOMAIN_DDD_REFACTORING_COMPLETE.md`

---

## 🚀 下一个领域推荐顺序

1. **Auth** (依赖User)
2. **City** (核心业务)
3. **Coworking** (依赖City)
4. **Chat/Community**
5. **AsyncTask**
6. 其他...

---

**最后更新**: 2025年1月
**模板来源**: User Domain DDD Refactoring
