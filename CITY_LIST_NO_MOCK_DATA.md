# City List - Remove Mock Data & Add Error Handling

## 概述
移除 city_list_page 的测试数据和 mock fallback，改为在加载失败时显示错误状态和刷新按钮。

## 修改内容

### 1. 控制器 (city_list_controller.dart)

#### 新增错误状态
```dart
final RxBool hasError = false.obs;
final RxString errorMessage = ''.obs;
```

#### 移除 Fallback 逻辑
- ✅ **删除**: `_loadCitiesFromDatabase()` 方法及其调用
- ✅ **删除**: `_getWeatherFromClimate()` 辅助方法
- ✅ **删除**: `_getBadgeForCity()` 辅助方法
- ✅ **删除**: `CityDataService` 依赖

#### 优化数据加载
```dart
Future<void> loadInitialCities() async {
  isLoading.value = true;
  hasError.value = false;
  errorMessage.value = '';
  cities.clear();
  _allCities.clear();

  try {
    await _loadAllCitiesToCache();
    
    if (_allCities.isEmpty) {
      throw Exception('未能加载任何城市数据');
    }
    
    _loadNextPage();
  } catch (e) {
    hasError.value = true;
    errorMessage.value = e.toString();
    AppToast.error('加载城市数据失败');
  } finally {
    isLoading.value = false;
  }
}
```

#### 简化 API 加载
```dart
Future<void> _loadAllCitiesToCache() async {
  // 直接从 Home API 加载，失败则抛出异常
  final homeFeed = await _homeApiService.getHomeFeed(
    cityLimit: 1000,
    meetupLimit: 0,
  );

  // 添加 city.id (UUID) 到数据中
  _allCities = homeFeed.cities.map((city) {
    return {
      'id': city.id, // ✅ 使用真实 UUID
      'city': city.name,
      'country': city.country,
      // ... 其他字段
    };
  }).toList();
}
```

### 2. 页面 (city_list_page.dart)

#### 新增错误状态 UI
```dart
body: Obx(() {
  // 加载中
  if (controller.isLoading.value) {
    return const CityListSkeleton();
  }

  // 错误状态 ✅ NEW
  if (controller.hasError.value) {
    return _buildErrorState();
  }

  // 正常列表
  return Column(...);
}),
```

#### 错误状态组件
```dart
Widget _buildErrorState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 错误图标
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4458).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFFFF4458),
          ),
        ),
        
        // 错误标题
        Text(l10n.loadFailed, style: ...),
        
        // 错误信息
        Obx(() => Text(
          controller.errorMessage.value.isNotEmpty
            ? controller.errorMessage.value
            : l10n.networkError,
          style: ...,
        )),
        
        // 刷新按钮 ✅ NEW
        ElevatedButton.icon(
          onPressed: () {
            controller.loadInitialCities();
          },
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(l10n.retry),
          style: ElevatedButton.styleFrom(...),
        ),
      ],
    ),
  );
}
```

### 3. 国际化 (i18n)

#### app_en.arb
```json
{
  "loadFailed": "Load Failed",
  "networkError": "Network Error",
  "retry": "Retry"
}
```

#### app_zh.arb
```json
{
  "loadFailed": "加载失败",
  "networkError": "网络错误",
  "retry": "重试"
}
```

## 数据流

### Before (有 Fallback)
```
API 加载
  ├─ 成功 → 显示数据
  └─ 失败 → 数据库 Fallback
       ├─ 成功 → 显示 Mock 数据
       └─ 失败 → 空数据
```

### After (无 Fallback)
```
API 加载
  ├─ 成功 → 显示数据
  └─ 失败 → 错误状态 + 刷新按钮
```

## 用户体验

### 加载成功
1. 显示骨架屏 (CityListSkeleton)
2. 从 Home API 加载城市数据
3. 显示城市列表 (第一页 20 条)
4. 滚动加载更多

### 加载失败
1. 显示骨架屏
2. API 请求失败
3. 显示错误状态:
   - 错误图标 (红色圆形背景)
   - "加载失败" 标题
   - 错误详情 (或 "网络错误")
   - "重试" 按钮
4. 用户点击重试 → 重新执行 loadInitialCities()

## 优势

### 1. 更清晰的错误处理
- ✅ 用户明确知道加载失败
- ✅ 提供主动重试机制
- ✅ 显示具体错误信息

### 2. 代码简化
- ✅ 移除数据库 fallback 逻辑
- ✅ 移除 Mock 数据生成
- ✅ 减少代码复杂度

### 3. 数据一致性
- ✅ 只使用真实 API 数据
- ✅ cityId 统一为 UUID 格式
- ✅ 避免 Mock 数据混淆

### 4. 更好的调试
- ✅ 错误日志清晰
- ✅ 错误信息暴露给用户
- ✅ 便于定位问题

## 关键修复

### City ID 问题
```dart
// ✅ 现在使用真实 UUID
'id': city.id,  // 来自 API 的 UUID

// ❌ 之前可能使用城市名称
'id': city['id'] ?? city['city'],  // 可能回退到名称
```

### 刷新机制
```dart
// ✅ 用户主动刷新
ElevatedButton.icon(
  onPressed: () {
    controller.loadInitialCities(); // 重新加载
  },
  icon: const Icon(Icons.refresh),
  label: Text(l10n.retry),
)

// ❌ 之前无刷新选项，只能重启应用
```

## 测试验证

### 正常流程
1. ✅ 打开城市列表页
2. ✅ 显示骨架屏
3. ✅ 加载成功显示城市列表
4. ✅ 滚动加载更多数据
5. ✅ 点击城市进入详情页
6. ✅ 详情页正确加载 cost/review 数据

### 错误流程
1. ✅ 断开网络
2. ✅ 打开城市列表页
3. ✅ 显示骨架屏
4. ✅ 显示错误状态 + 刷新按钮
5. ✅ 恢复网络
6. ✅ 点击刷新按钮
7. ✅ 成功加载数据

## 文件清单

### 修改文件
- ✅ `lib/controllers/city_list_controller.dart`
- ✅ `lib/pages/city_list_page.dart`
- ✅ `lib/l10n/app_en.arb`
- ✅ `lib/l10n/app_zh.arb`

### 删除依赖
- ✅ `CityDataService` (从 city_list_controller.dart)
- ✅ `_loadCitiesFromDatabase()` 方法
- ✅ `_getWeatherFromClimate()` 方法
- ✅ `_getBadgeForCity()` 方法

## 下一步

### 可选优化
1. 添加离线缓存 (SharedPreferences/Hive)
2. 添加下拉刷新功能
3. 添加网络状态监听
4. 添加重试计数限制
5. 添加错误上报 (Sentry)

### 相关问题修复
- ✅ City ID 统一为 UUID
- ✅ 从 city_list 跳转到详情页数据加载正常
- ✅ 移除了 Mock 数据混淆

## 完成时间
2025年11月1日
