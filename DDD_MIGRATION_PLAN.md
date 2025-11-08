# DDD 架构迁移计划# 全域 DDD 架构迁移计划



## 迁移目标## 📋 目标

将 `lib/services` 文件夹中的业务逻辑迁移到 DDD 架构的各个领域模块，保留必要的基础设施服务。

将整个项目从 Service-based 架构迁移到 DDD (Domain-Driven Design) 架构,参照 **Auth 域**和 **User 域**的成功模式。

## 当前错误统计

- **总错误数**: 419---

- **主要错误来源**:

  - city_chat_page.dart: 51 errors## 🏗️ DDD 标准结构

  - city_detail_page.dart: 39 errors  

  - coworking_detail_page.dart: 27 errors每个域应包含以下层次:

  - meetup_detail_page.dart: 24 errors

  - meetups_list_page.dart: 23 errors```

  - innovation_list_page.dart: 23 errorsfeatures/{domain}/

├── domain/                    # 领域层

## Services 分类和迁移策略│   ├── entities/             # 实体 (纯粹的业务对象)

│   ├── repositories/         # 仓储接口 (I{Domain}Repository)

### 1. 基础设施层 - **保留**（不迁移）│   └── services/             # 领域服务 (可选)

这些是纯技术基础设施，应该保留在 services 文件夹中：├── application/               # 应用层

│   └── use_cases/            # 用例 (UseCase<R, P>)

- ✅ **http_service.dart** - HTTP 客户端封装├── infrastructure/            # 基础设施层

- ✅ **database_service.dart** - 数据库连接管理│   ├── models/               # DTO (数据传输对象)

- ✅ **database_initializer.dart** - 数据库初始化│   └── repositories/         # 仓储实现 ({Domain}Repository)

- ✅ **database/** - 数据库相关（DAO等）└── presentation/              # 表示层

- ✅ **token_storage_service.dart** - Token 存储    └── controllers/          # 状态控制器 ({Domain}StateController)

- ✅ **notification_service.dart** - 推送通知```

- ✅ **location_service.dart** - 位置服务

- ✅ **amap_native_service.dart** - 高德地图原生服务---

- ✅ **signalr_service.dart** - SignalR 实时通信

- ✅ **background_task_service.dart** - 后台任务## ✅ 已完成的域

- ✅ **app_init_service.dart** - 应用初始化

### 1. Auth 域 ✅ (100%)

### 2. 业务逻辑层 - **需要迁移**- ✅ Domain: AuthUser, AuthToken 实体

- ✅ Application: LoginUseCase, RegisterUseCase, LogoutUseCase, etc.

#### Phase 1: 核心依赖模块（优先级最高）- ✅ Infrastructure: AuthRepository, AuthDatabaseRepository

- ✅ Presentation: AuthStateController

##### 2.1 Country & City Data Service

**文件**: `cities_api_service.dart`, `city_api_service.dart`, `location_api_service.dart`### 2. User 域 ✅ (100%)

**目标**: `lib/features/location/` (新建)- ✅ Domain: User, UserFavoriteCity 实体, IUserRepository 接口

**原因**: 被 create_meetup, add_coworking, global_map 等多个页面依赖- ✅ Application: GetCurrentUserUseCase, UpdateUserUseCase, etc.

- ✅ Infrastructure: UserRepository

**迁移步骤**:- ✅ Presentation: 已集成到 UserProfileController

```

1. 创建 features/location/domain/---

   - entities/country.dart

   - entities/city_option.dart  ## 🚧 待迁移的域 (优先级排序)

   - repositories/ilocation_repository.dart

   ### 优先级 1: 核心业务域 (高频使用)

2. 创建 features/location/infrastructure/

   - repositories/location_repository.dart#### 1. City 域 (部分完成,需完善)

   - models/country_dto.dart**现状**:

   - models/city_dto.dart- ✅ Domain: CityOption, CityDetail 实体, ICityRepository 接口

   - ⚠️ Application: Use Cases 使用自定义 Result,需改为标准 Result<T>

3. 创建 features/location/application/- ❌ Infrastructure: 缺少 CityRepository 实现

   - use_cases/get_countries_use_case.dart- ❌ Presentation: CityListController, CityDetailController 仍使用 CitiesApiService

   - use_cases/get_cities_by_country_use_case.dart

   **需要完成**:

4. 创建 features/location/presentation/1. 创建统一的 City 实体 (或明确 CityOption vs CityDetail 的使用场景)

   - controllers/location_state_controller.dart2. 重构 Use Cases 使用标准 `Result<T>` 和 `UseCase<R, P>` 基类

   3. 创建 CityRepository 实现 (从 cities_api_service.dart 迁移)

5. 在 dependency_injection.dart 中注册4. 创建 CityStateController 替代 city_list_controller

```5. 创建 CityDetailStateController 替代 city_detail_controller



##### 2.2 User Authentication  **影响的 Controllers**:

**文件**: `nomads_auth_service.dart`- `lib/controllers/city_list_controller.dart` (450 行)

**目标**: 已有 `features/auth/`- `lib/controllers/city_detail_controller.dart` (大文件,依赖多个 services)

**迁移步骤**: 检查并整合到现有 auth_repository.dart

**影响的 Services**:

##### 2.3 AI Services- `lib/services/cities_api_service.dart` (206 行)

**文件**: `ai_api_service.dart`- `lib/services/city_api_service.dart`

**目标**: `features/ai/infrastructure/repositories/ai_repository.dart`

**状态**: ✅ 已有结构，需移除 service 层---



##### 2.4 Coworking Management#### 2. Coworking 域 (未开始)

**文件**: `coworking_api_service.dart`**现状**:

**目标**: `features/coworking/`- ✅ Domain: CoworkingSpace 实体存在

**迁移步骤**: 添加创建/编辑 use cases 和扩展 controller- ❌ Application: 无 Use Cases

- ❌ Infrastructure: 无 Repository

##### 2.5 Events/Meetups- ❌ Presentation: CoworkingController 使用 coworking_api_service

**文件**: `events_api_service.dart`

**目标**: `features/meetup/infrastructure/`**需要创建**:

**状态**: ✅ 已有结构1. Domain: ICoworkingRepository 接口

2. Application: GetCoworkingSpacesUseCase, SearchCoworkingUseCase, AddCoworkingUseCase

##### 2.6 User City Content3. Infrastructure: CoworkingRepository (从 coworking_api_service 迁移)

**文件**: `user_city_content_api_service.dart`4. Presentation: CoworkingStateController

**目标**: `features/user_city_content/infrastructure/`

**问题**: 类型不匹配，需添加转换层**影响的 Controllers**:

- `lib/controllers/coworking_controller.dart`

##### 2.7 Skills & Interests- `lib/controllers/add_coworking_controller.dart`

**文件**: `skills_api_service.dart`, `interests_api_service.dart`

**目标**: 新建 `features/taxonomy/`**影响的 Services**:

- `lib/services/coworking_api_service.dart`

##### 2.8 User Favorites

**文件**: `user_favorite_city_api_service.dart`---

**目标**: 整合到 `features/user_profile/`

### 优先级 2: 社交和互动域

##### 2.9 Async Tasks

**文件**: `async_task_service.dart`#### 3. Chat 域 (未开始)

**目标**: `features/async_task/infrastructure/`**现状**:

- ✅ Domain: Chat 实体存在

## 迁移执行顺序- ❌ Application: 无 Use Cases

- ❌ Infrastructure: 无 Repository

### Stage 1: 核心依赖- ❌ Presentation: ChatController 依赖 SignalR Service

1. ✅ 修复 AI repository legacy model 错误

2. ✅ 修复 async_task, country DTO imports  **需要创建**:

3. 🔄 创建 Location 模块（Country/City）1. Domain: ChatMessage, Conversation 实体, IChatRepository

4. 修复 UserCityContent 类型转换2. Application: SendMessageUseCase, GetChatHistoryUseCase, CreateChatUseCase

3. Infrastructure: ChatRepository (集成 SignalR + HTTP)

### Stage 2-5: 按页面错误数量逐步修复4. Presentation: ChatStateController

详见完整计划文档...

**影响的 Controllers**:

## 下一步行动- `lib/controllers/chat_controller.dart`

**立即开始**: 创建 Location 模块（Country/City）

**影响的 Services**:
- `lib/services/signalr_service.dart` (保留作为基础设施)

---

#### 4. Community 域 (未开始)
**现状**:
- ✅ Domain: TripReport 实体存在
- ❌ Application: 无 Use Cases
- ❌ Infrastructure: 无 Repository
- ❌ Presentation: CommunityController 使用 events_api_service

**需要创建**:
1. Domain: Post, Event 实体, ICommunityRepository
2. Application: GetPostsUseCase, CreatePostUseCase, GetEventsUseCase
3. Infrastructure: CommunityRepository (从 events_api_service 迁移)
4. Presentation: CommunityStateController

**影响的 Controllers**:
- `lib/controllers/community_controller.dart`

**影响的 Services**:
- `lib/services/events_api_service.dart`

---

### 优先级 3: 辅助功能域

#### 5. Location 域 ✅ (已完成)
**现状**:
- ✅ Domain: CountryOption, CityOption 实体 (重用现有)
- ✅ Application: GetCountriesUseCase, GetCitiesByCountryUseCase, SearchCitiesUseCase
- ✅ Infrastructure: LocationRepository (整合 CitiesApiService)
- ✅ Presentation: LocationStateController

**已创建文件**:
1. `lib/features/location/domain/entities/country.dart` (re-export CountryOption)
2. `lib/features/location/domain/entities/city.dart` (re-export CityOption)
3. `lib/features/location/domain/repositories/ilocation_repository.dart`
4. `lib/features/location/infrastructure/repositories/location_repository.dart`
5. `lib/features/location/infrastructure/models/country_dto.dart`
6. `lib/features/location/infrastructure/models/city_dto.dart`
7. `lib/features/location/application/use_cases/get_countries_use_case.dart`
8. `lib/features/location/application/use_cases/get_cities_by_country_use_case.dart`
9. `lib/features/location/application/use_cases/search_cities_use_case.dart`
10. `lib/features/location/presentation/controllers/location_state_controller.dart`

**DI 注册**: ✅ 已在 `dependency_injection.dart` 中注册

**要替换的旧代码**:
- `lib/controllers/data_service_controller.dart` (国家/城市功能)
- `lib/controllers/add_coworking_controller.dart` (国家/城市选择)

**影响的页面** (待更新):
- `lib/pages/create_meetup_page.dart`
- `lib/pages/add_coworking_page.dart`
- `lib/pages/global_map_page.dart`

---

#### 6. Interest & Skill 域 (未开始)
**现状**:
- ✅ Domain: Interest, Skill 实体存在
- ❌ Application: 无 Use Cases
- ❌ Infrastructure: 无 Repository
- ❌ Presentation: 无专用控制器,散落在其他地方

**需要创建**:
1. Domain: IInterestRepository, ISkillRepository
2. Application: GetInterestsUseCase, GetSkillsUseCase, UpdateUserInterestsUseCase
3. Infrastructure: InterestRepository, SkillRepository
4. Presentation: 可集成到 UserProfileController 或创建独立控制器

**影响的 Services**:
- `lib/services/interests_api_service.dart`
- `lib/services/skills_api_service.dart`

---

#### 7. AI Chat 域 (未开始)
**现状**:
- ❌ Domain: 无 AI 实体
- ❌ Application: 无 Use Cases
- ❌ Presentation: AIChatController 使用 ai_api_service

**需要创建**:
1. Domain: AIMessage, AIConversation 实体, IAIRepository
2. Application: SendAIMessageUseCase, GetAIResponseUseCase, CreateConversationUseCase
3. Infrastructure: AIRepository (从 ai_api_service 迁移)
4. Presentation: AIChatStateController

**影响的 Controllers**:
- `lib/controllers/ai_chat_controller.dart`

**影响的 Services**:
- `lib/services/ai_api_service.dart`

---

### 优先级 4: 数据支持域

#### 8. Weather 域 (未开始)
**现状**:
- ✅ Domain: Weather 实体存在
- ❌ Application: 无 Use Cases
- ❌ Infrastructure: 无 Repository
- ❌ Presentation: 无专用控制器

**需要创建**:
1. Domain: IWeatherRepository
2. Application: GetWeatherUseCase, GetForecastUseCase
3. Infrastructure: WeatherRepository
4. Presentation: WeatherStateController (或集成到 CityDetailController)

---

#### 9. Hotel 域 (未开始)
**现状**:
- ✅ Domain: Hotel 实体存在
- ❌ Application: 无 Use Cases
- ❌ Infrastructure: 无 Repository
- ❌ Presentation: 无专用控制器

**需要创建**:
1. Domain: IHotelRepository
2. Application: SearchHotelsUseCase, GetHotelDetailsUseCase
3. Infrastructure: HotelRepository
4. Presentation: HotelStateController (或集成到 CityDetailController)

---

#### 10. Travel Plan 域 (未开始)
**现状**:
- ✅ Domain: TravelPlan 实体存在
- ❌ Application: 无 Use Cases
- ❌ Infrastructure: 无 Repository
- ❌ Presentation: 无专用控制器

**需要创建**:
1. Domain: ITravelPlanRepository
2. Application: CreateTravelPlanUseCase, GetTravelPlansUseCase, UpdateTravelPlanUseCase
3. Infrastructure: TravelPlanRepository
4. Presentation: TravelPlanStateController

---

## 🗑️ 需要删除的旧代码

### Controllers (迁移后删除)
- `lib/controllers/city_list_controller.dart`
- `lib/controllers/city_detail_controller.dart`
- `lib/controllers/coworking_controller.dart`
- `lib/controllers/add_coworking_controller.dart`
- `lib/controllers/chat_controller.dart`
- `lib/controllers/community_controller.dart`
- `lib/controllers/location_controller.dart`
- `lib/controllers/ai_chat_controller.dart`

### Services (迁移后删除)
- `lib/services/cities_api_service.dart`
- `lib/services/city_api_service.dart`
- `lib/services/coworking_api_service.dart`
- `lib/services/events_api_service.dart`
- `lib/services/location_api_service.dart`
- `lib/services/interests_api_service.dart`
- `lib/services/skills_api_service.dart`
- `lib/services/ai_api_service.dart`
- `lib/services/user_city_content_api_service.dart`
- `lib/services/user_favorite_city_api_service.dart`

### 保留的核心服务 (不删除)
- `lib/services/http_service.dart` (核心 HTTP 客户端)
- `lib/services/database_service.dart` (核心数据库服务)
- `lib/services/location_service.dart` (设备位置服务)
- `lib/services/signalr_service.dart` (实时通信基础设施)
- `lib/services/notification_service.dart` (通知基础设施)
- `lib/services/async_task_service.dart` (后台任务管理)

---

## 📝 迁移标准模式

### 1. UseCase 标准

```dart
import '../../../../core/core.dart';

class GetCitiesUseCase extends UseCase<List<City>, GetCitiesParams> {
  final ICityRepository _repository;

  GetCitiesUseCase(this._repository);

  @override
  Future<Result<List<City>>> execute(GetCitiesParams params) async {
    // 参数验证
    if (params.pageSize <= 0) {
      return Failure(ValidationException('页大小必须大于0'));
    }

    // 调用 Repository
    return await _repository.getCities(
      page: params.page,
      pageSize: params.pageSize,
      search: params.search,
    );
  }
}

class GetCitiesParams extends UseCaseParams {
  final int page;
  final int pageSize;
  final String? search;

  const GetCitiesParams({
    required this.page,
    required this.pageSize,
    this.search,
  });
}
```

### 2. Repository 接口标准

```dart
import '../../../../core/core.dart';
import '../entities/city.dart';

abstract class ICityRepository implements IRepository {
  Future<Result<List<City>>> getCities({
    required int page,
    required int pageSize,
    String? search,
  });

  Future<Result<City>> getCityById(String id);
}
```

### 3. Repository 实现标准

```dart
import '../../../../core/core.dart';
import '../../domain/entities/city.dart';
import '../../domain/repositories/i_city_repository.dart';

class CityRepository implements ICityRepository {
  final HttpService _httpService;

  CityRepository(this._httpService);

  @override
  Future<Result<List<City>>> getCities({
    required int page,
    required int pageSize,
    String? search,
  }) async {
    try {
      final response = await _httpService.get('/cities', queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search != null) 'search': search,
      });

      final cities = (response.data['items'] as List)
          .map((json) => City.fromJson(json))
          .toList();

      return Success(cities);
    } on HttpException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }
}
```

### 4. StateController 标准

```dart
import 'package:get/get.dart';
import '../../../core/core.dart';
import '../../application/use_cases/city_use_cases.dart';
import '../../domain/entities/city.dart';

class CityStateController extends GetxController {
  final GetCitiesUseCase _getCitiesUseCase;

  CityStateController(this._getCitiesUseCase);

  final RxBool isLoading = false.obs;
  final RxList<City> cities = <City>[].obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  Future<void> loadCities({int page = 1, int pageSize = 20}) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getCitiesUseCase.execute(
      GetCitiesParams(page: page, pageSize: pageSize),
    );

    result.fold(
      onSuccess: (data) {
        cities.value = data;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }
}
```

---

## 🎯 执行计划

### Phase 1: City 域完善 (最高优先级)
1. ✅ 分析现有 City 结构
2. 🔄 统一 City 实体 (CityOption vs CityDetail)
3. 🔄 重构 Use Cases 使用标准 Result<T>
4. 🔄 创建 CityRepository 实现
5. 🔄 创建 CityStateController
6. 🔄 迁移 city_list_controller
7. 🔄 迁移 city_detail_controller
8. 🔄 验证和测试

### Phase 2: Coworking & Location 域
- Coworking 域完整实现
- Location 域完整实现

### Phase 3: Chat & Community 域
- Chat 域完整实现
- Community 域完整实现

### Phase 4: Interest, Skill, AI 域
- Interest & Skill 域实现
- AI Chat 域实现

### Phase 5: 数据支持域
- Weather 域实现
- Hotel 域实现
- Travel Plan 域实现

### Phase 6: 清理和验证
- 删除所有旧 Services
- 删除所有旧 Controllers
- 全项目编译验证
- 手动测试所有功能

---

## 📚 参考资料

- **成功案例**: `lib/features/auth/` (Auth 域)
- **成功案例**: `lib/features/user/` (User 域)
- **核心抽象**: `lib/core/` (Result, UseCase, Repository 基类)
