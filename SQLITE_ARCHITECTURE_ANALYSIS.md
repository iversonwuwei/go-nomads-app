# SQLite 架构使用情况分析

## 执行日期: 2025-11-08

## 📊 当前 SQLite 使用情况

### ✅ 仍在使用的 SQLite 功能

1. **Token 本地存储**
   - 用于保存用户登录 token
   - `TokenStorageService` 使用 `flutter_secure_storage`
   - ⚠️ 注意: 这不是 SQLite,而是 SecureStorage

2. **用户登录状态恢复** (`main.dart`)
   ```dart
   // 初始化 SQLite 数据库
   await dbInitializer.initializeDatabase(forceReset: false);
   
   // 从 SQLite 恢复登录状态  
   await AppInitService().initialize();
   ```
   - `AppInitService` 通过 `AuthStateController` 恢复登录状态
   - ⚠️ 需要确认 `AuthStateController` 是从 SQLite 还是 SecureStorage 读取

3. **测试数据初始化** (`database_initializer.dart`)
   - 插入示例用户、城市、活动数据
   - 生成 50 个中国城市数据
   - 仅在 `forceReset: false` 且数据库为空时运行

### ❌ 不再使用的 SQLite 功能

1. **本地数据缓存层** (`services/data/`)
   - `city_data_service.dart` - 仅 debug_controller 使用
   - `coworking_data_service.dart` - 零引用
   - `favorite_data_service.dart` - 零引用
   - `meetup_data_service.dart` - 零引用
   - `review_data_service.dart` - 零引用

2. **DataServiceController**
   - **已迁移到 API 架构**
   - 使用 `CityApiService`, `EventsApiService`, `LocationApiService`
   - ❌ 不再使用 SQLite DAO

3. **页面和控制器**
   - 所有页面和控制器都使用 **API Services** 或 **Repositories**
   - ❌ 没有发现直接使用 SQLite DAO 的页面

---

## 🎯 SQLite 架构决策建议

### 方案 A: 完全迁移到纯 API 架构 (推荐) ⭐

**优点:**
- ✅ 架构统一,维护简单
- ✅ 数据实时性好,无需同步
- ✅ 减少代码量 (~2000 行)
- ✅ 减少数据不一致风险

**缺点:**
- ❌ 需要网络连接
- ❌ 离线体验较差
- ❌ 无本地缓存,重复请求增加

**需要保留的文件:**
- ✅ `database_service.dart` - 如果 AuthRepository 还用 SQLite 存储 token
- ✅ `token_storage_service.dart` - Token 存储(SecureStorage)
- ❌ `database_initializer.dart` - 删除测试数据生成器
- ❌ `china_cities_generator.dart` - 删除
- ❌ `services/data/` - 删除整个目录
- ❌ `services/database/*_dao.dart` - 删除所有 DAO (除非 token 相关)

**需要修改:**
1. `main.dart` - 移除 `DatabaseInitializer` 调用
2. `AppInitService` - 确认从 SecureStorage 读取 token,而非 SQLite

---

### 方案 B: 保留 SQLite 作为离线缓存 (不推荐)

**优点:**
- ✅ 支持离线访问
- ✅ 减少重复 API 请求
- ✅ 提升响应速度

**缺点:**
- ❌ 需要实现 API ↔ SQLite 同步逻辑
- ❌ 数据不一致风险高
- ❌ 维护成本高(两套数据访问层)
- ❌ 当前代码已迁移到 API,回退成本高

**不推荐理由:**
- 项目已经完全迁移到 API 架构
- 没有发现任何使用 SQLite 数据缓存的代码
- 回退需要大量重构工作

---

## 🚀 推荐执行方案: 方案 A

### 阶段 2A: 确认 Token 存储方式

检查 `AuthRepository` 和 `AuthStateController` 是否使用 SQLite:

```bash
# 搜索 AuthRepository 和 AuthStateController 的实现
```

**如果使用 SecureStorage:**
- ✅ 可以删除所有 SQLite 相关代码

**如果使用 SQLite:**
- ⚠️ 需要保留 `database_service.dart` 和 token 相关 DAO
- 或者迁移到 `TokenStorageService` (SecureStorage)

### 阶段 2B: 删除 SQLite 数据层

1. **删除测试数据生成器:**
```bash
rm lib/services/china_cities_generator.dart
rm lib/services/database_initializer.dart
```

2. **删除 SQLite 数据访问层:**
```bash
rm -rf lib/services/data/
```

3. **删除 DAO 文件** (确认 token 不使用后):
```bash
rm lib/services/database/token_dao.dart
rm lib/services/database/user_profile_dao.dart
# ... 删除其他 DAO
```

4. **修改 main.dart:**
```dart
// 删除以下代码:
// import 'services/database_initializer.dart';

// 删除以下代码块:
/*
print('💾 初始化 SQLite 数据库...');
try {
  final dbInitializer = DatabaseInitializer();
  await dbInitializer.initializeDatabase(forceReset: false);
  print('✅ 数据库初始化成功');
} catch (e) {
  print('❌ 数据库初始化失败: $e');
}
*/
```

5. **验证:**
```bash
flutter analyze
flutter test
```

---

## ⚠️ 风险和注意事项

### 1. Token 存储迁移
- **风险**: 如果 token 存在 SQLite,删除后用户需要重新登录
- **缓解**: 
  1. 先确认 token 存储方式
  2. 如果需要迁移,提前通知用户
  3. 或实现自动迁移逻辑(从 SQLite 读取 → 写入 SecureStorage)

### 2. 测试数据丢失
- **风险**: 删除 `database_initializer.dart` 后无法生成测试数据
- **缓解**:
  1. 使用 API mock 数据
  2. 或创建专门的测试工具(移到 `test/` 目录)

### 3. debug_controller.dart 依赖
- **风险**: `debug_controller.dart` 使用 `CityDataService`
- **缓解**: 
  1. 删除 `debug_controller.dart`(临时调试文件)
  2. 或重构为使用 API Services

---

## 📝 下一步行动

1. ✅ **立即执行**: 检查 Token 存储方式
   ```bash
   # 搜索 AuthRepository 的实现
   ```

2. ⚠️ **等待确认**: 根据 Token 存储方式决定:
   - 如果是 SecureStorage → 执行完全删除
   - 如果是 SQLite → 迁移到 SecureStorage 或保留最小 SQLite 支持

3. ⚠️ **用户通知**: 如果需要迁移 Token,提前通知用户可能需要重新登录

4. ✅ **执行删除**: 按照阶段 2B 的步骤删除 SQLite 代码

你想让我:
1. **立即检查** Token 存储方式?
2. **先暂停** 等待你的决策?
3. **直接执行删除** (假设 Token 使用 SecureStorage)?
