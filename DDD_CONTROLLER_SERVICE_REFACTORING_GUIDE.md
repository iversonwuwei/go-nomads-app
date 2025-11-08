# DDD重构指南 - Controller和Service层

## 📋 重构概述

### 当前架构问题
- ❌ Controllers直接调用API Services (紧耦合)
- ❌ 业务逻辑分散在Controllers中
- ❌ 缺少领域层抽象
- ❌ 难以测试和维护

### 目标DDD架构
```
lib/features/{domain}/
├── domain/                    # 领域层 - 核心业务逻辑
│   ├── entities/             ✅ 已完成 (24个域)
│   ├── repositories/         ⬅️ 需要创建 (抽象接口)
│   └── services/             ⬅️ 需要创建 (领域服务)
├── application/              # 应用层 - 用例编排
│   └── use_cases/            ⬅️ 需要创建 (业务用例)
├── infrastructure/           # 基础设施层 - 技术实现
│   ├── models/               ✅ 已完成 (DTOs)
│   ├── repositories/         ⬅️ 需要创建 (Repository实现)
│   └── api/                  ⬅️ 适配现有 *_api_service.dart
└── presentation/             # 表现层 - UI交互
    ├── controllers/          ⬅️ 需要重构 (简化为UI控制器)
    ├── pages/               (现有页面)
    └── widgets/             (现有组件)
```

## 🎯 推荐迁移策略: 混合架构

### 阶段1: 保留现有代码(0改动)
- ✅ 现有40+controllers继续工作
- ✅ 现有58+services继续工作
- ✅ 零风险

### 阶段2: 新功能使用DDD
- 🆕 新功能必须使用DDD架构
- 🆕 创建Repository接口和实现
- 🆕 创建Use Cases
- 🆕 Controller只负责UI状态

### 阶段3: 渐进式重构
- 🔄 选择重要功能逐个重构
- 🔄 优先重构复杂业务逻辑
- 🔄 保持向后兼容

## 📖 DDD层次详解

### 1️⃣ Domain Layer (领域层)
**职责**: 纯业务逻辑,不依赖任何框架

#### Entities (实体) ✅ 已完成
```dart
// lib/features/city/domain/entities/city.dart
class City {
  final String id;
  final String name;
  final double overallScore;
  
  // 业务方法
  bool get isHighRated => overallScore >= 4.0;
}
```

#### Repositories (仓储接口) ⬅️ 需要创建
```dart
// lib/features/city/domain/repositories/i_city_repository.dart
abstract class ICityRepository {
  Future<List<City>> getCities({int page, int pageSize});
  Future<City?> getCityById(String id);
}
```

#### Domain Services (领域服务) ⬅️ 需要创建
```dart
// lib/features/city/domain/services/city_domain_service.dart
class CityDomainService {
  // 跨实体的复杂业务逻辑
  List<City> recommendCitiesByPreferences({
    required List<City> cities,
    required Map<String, dynamic> preferences,
  }) {
    // 复杂推荐算法
  }
}
```

### 2️⃣ Application Layer (应用层)
**职责**: 用例编排,协调领域对象完成业务流程

#### Use Cases (用例) ⬅️ 需要创建
```dart
// lib/features/city/application/use_cases/get_cities_use_case.dart
class GetCitiesUseCase {
  final ICityRepository _repository;
  
  Future<Result<List<City>>> execute({int page = 1}) async {
    try {
      final cities = await _repository.getCities(page: page);
      return Result.success(cities);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
```

### 3️⃣ Infrastructure Layer (基础设施层)
**职责**: 技术实现,对接外部系统

#### DTOs (数据传输对象) ✅ 已完成
```dart
// lib/features/city/infrastructure/models/city_dto.dart
class CityDto {
  factory CityDto.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  City toDomain(); // 转换为领域实体
}
```

#### Repository Implementation ⬅️ 需要创建
```dart
// lib/features/city/infrastructure/repositories/city_repository.dart
class CityRepository implements ICityRepository {
  final CityApiService _apiService; // 适配现有service
  
  @override
  Future<List<City>> getCities({int page = 1, int pageSize = 20}) async {
    final response = await _apiService.getCities(page: page, pageSize: pageSize);
    final items = response['items'] as List;
    return items.map((json) => CityDto.fromJson(json).toDomain()).toList();
  }
}
```

### 4️⃣ Presentation Layer (表现层)
**职责**: UI交互和状态管理

#### Refactored Controller ⬅️ 需要简化
```dart
// lib/features/city/presentation/controllers/city_list_controller.dart
class CityListController extends GetxController {
  final GetCitiesUseCase _getCitiesUseCase;
  
  final RxList<City> cities = <City>[].obs;
  final RxBool isLoading = false.obs;
  
  Future<void> loadCities() async {
    isLoading.value = true;
    
    final result = await _getCitiesUseCase.execute(page: 1);
    
    result.when(
      success: (cities) => this.cities.value = cities,
      failure: (error) => AppToast.showError(error),
    );
    
    isLoading.value = false;
  }
}
```

## 🔧 实际迁移步骤

### Step 1: 创建Domain层
```bash
lib/features/{domain}/domain/
├── entities/           # ✅ 已完成
├── repositories/       # 创建接口
└── services/          # 创建领域服务
```

### Step 2: 创建Application层
```bash
lib/features/{domain}/application/
└── use_cases/         # 创建业务用例
```

### Step 3: 创建Infrastructure层
```bash
lib/features/{domain}/infrastructure/
├── models/            # ✅ 已完成
├── repositories/      # 实现Repository
└── api/              # 适配现有 *_api_service.dart
```

### Step 4: 重构Presentation层
```bash
lib/features/{domain}/presentation/
└── controllers/       # 简化Controller
```

## 📝 示例: City功能完整重构

### 现有架构 (需要重构)
```
lib/
├── controllers/
│   └── city_list_controller.dart    # 👎 包含业务逻辑
├── services/
│   └── city_api_service.dart        # 👎 直接返回JSON
└── models/
    └── (已删除,已迁移到features/)
```

### 目标DDD架构
```
lib/features/city/
├── domain/
│   ├── entities/
│   │   ├── city.dart                 # ✅ 需要创建基础City实体
│   │   ├── city_detail.dart         # ✅ 已创建
│   │   └── city_option.dart         # ✅ 已创建
│   ├── repositories/
│   │   └── i_city_repository.dart   # ✅ 已创建示例
│   └── services/
│       └── city_domain_service.dart # ✅ 已创建示例
├── application/
│   └── use_cases/
│       ├── get_cities_use_case.dart          # ✅ 已创建示例
│       ├── search_cities_use_case.dart       # ✅ 已创建示例
│       ├── toggle_city_favorite_use_case.dart # ✅ 已创建示例
│       └── get_recommended_cities_use_case.dart # ✅ 已创建示例
├── infrastructure/
│   ├── models/
│   │   ├── city_dto.dart            # ⬅️ 需要创建
│   │   ├── city_detail_dto.dart     # ✅ 已创建
│   │   └── city_option_dto.dart     # ✅ 已创建
│   ├── repositories/
│   │   └── city_repository.dart     # ⬅️ 需要创建
│   └── api/
│       └── city_api_service.dart    # ⬅️ 迁移现有service到这里
└── presentation/
    └── controllers/
        └── city_list_controller.dart # ⬅️ 重构简化
```

## 🎯 重构优先级

### 高优先级 (核心业务)
1. **City** - 城市列表、搜索、详情
2. **User** - 用户认证、个人资料
3. **Chat** - 聊天消息
4. **Meetup** - 活动聚会

### 中优先级 (重要功能)
5. **Coworking** - 共享办公
6. **Community** - 社区内容
7. **Hotel** - 酒店预订
8. **TravelPlan** - 旅行计划

### 低优先级 (辅助功能)
9. **Weather** - 天气数据
10. **Interest** - 兴趣管理
11. **Skill** - 技能管理
12. 其他...

## 📊 工作量估算

### 每个域完整重构工作量
- Repository接口: 30分钟
- Repository实现: 1小时
- Domain Service: 1-2小时 (视复杂度)
- Use Cases: 2-4小时 (5-10个用例)
- Controller重构: 1-2小时
- **总计**: 约1-2个工作日/域

### 全部24个域
- **总工作量**: 24-48个工作日 (约1-2个月)
- **建议**: 分阶段进行,优先重构核心域

## 🚀 快速开始示例

### 1. 创建基础City实体
见: `lib/features/city/domain/entities/city.dart` (需要创建)

### 2. 创建Repository接口
见: `lib/features/city/domain/repositories/i_city_repository.dart` ✅

### 3. 创建Repository实现
见: `lib/features/city/infrastructure/repositories/city_repository.dart` (下一步)

### 4. 创建Use Cases
见: `lib/features/city/application/use_cases/*.dart` ✅

### 5. 重构Controller
见: `lib/features/city/presentation/controllers/city_list_controller.dart` (最后)

## ⚠️ 注意事项

### 1. 依赖注入
使用GetX的依赖注入管理:
```dart
// lib/core/di/injection.dart
class DependencyInjection {
  static void init() {
    // Repository
    Get.lazyPut<ICityRepository>(() => CityRepository(Get.find()));
    
    // Use Cases
    Get.lazyPut(() => GetCitiesUseCase(Get.find()));
    
    // Controllers
    Get.lazyPut(() => CityListController(Get.find()));
  }
}
```

### 2. 错误处理
统一使用Result类型:
```dart
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;
  
  Result.success(this.data) : isSuccess = true, error = null;
  Result.failure(this.error) : isSuccess = false, data = null;
}
```

### 3. 测试
DDD架构便于单元测试:
```dart
// test/features/city/domain/services/city_domain_service_test.dart
void main() {
  test('推荐城市应根据用户偏好过滤', () {
    final service = CityDomainService();
    final cities = [...]; // 测试数据
    final preferences = {'maxBudget': 2000};
    
    final result = service.recommendCitiesByPreferences(
      cities: cities,
      userPreferences: preferences,
    );
    
    expect(result.every((c) => c.costPerMonth <= 2000), true);
  });
}
```

## 📚 下一步行动

1. ✅ 创建City基础实体
2. ✅ 创建CityDto
3. ✅ 创建CityRepository实现
4. ✅ 迁移city_api_service.dart到infrastructure/api
5. ✅ 重构CityListController
6. 🔄 重复以上步骤处理其他域

---

**重构建议**: 不要一次性重构所有代码,采用**增量迁移**,每完成一个域的重构,确保测试通过后再进行下一个。
