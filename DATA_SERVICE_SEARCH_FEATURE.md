# DataService 搜索功能完善

## 功能概述

用户可以在搜索框中输入城市名称,点击 "Search" 按钮后从后端服务获取匹配的城市列表并显示。

## 修改内容

### 1. DataServiceController 新增搜索方法

**文件**: `lib/controllers/data_service_controller.dart`

添加了 `searchCities()` 方法:

```dart
/// 搜索城市(从后端获取)
Future<void> searchCities(String searchKeyword) async {
  if (searchKeyword.trim().isEmpty) {
    // 如果搜索关键词为空,重新加载所有城市
    await refreshCities();
    return;
  }

  print('🔍 搜索城市: $searchKeyword');
  isLoadingCities.value = true;

  try {
    final response = await _cityApiService.getCities(
      page: 1,
      pageSize: 100, // 搜索时加载更多结果
      search: searchKeyword,
    );

    // 转换并显示搜索结果
    // ... 数据转换逻辑 ...

    if (convertedCities.isEmpty) {
      AppToast.info('未找到匹配的城市');
    } else {
      AppToast.success('找到 ${convertedCities.length} 个城市');
    }
  } catch (e) {
    AppToast.error('搜索失败,请重试');
  } finally {
    isLoadingCities.value = false;
  }
}
```

**特性**:
- ✅ 调用后端 `CityApiService.getCities(search: keyword)` API
- ✅ 自动转换城市数据格式
- ✅ 处理 `weather` 字段的对象/字符串类型
- ✅ 搜索时加载最多 100 条结果
- ✅ 显示加载状态和结果提示
- ✅ 空关键词时重置为显示所有城市

### 2. DataServicePage 搜索栏改进

**文件**: `lib/pages/data_service_page.dart`

#### 添加 TextEditingController

```dart
class _DataServicePageState extends State<DataServicePage>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  // ...
}
```

#### 更新 _buildSearchBar 方法

**新功能**:

1. **搜索输入框**
   - 使用 `_searchController` 管理输入
   - 提示文本: "Search cities..."
   - 支持回车键触发搜索

2. **Search 按钮**
   ```dart
   InkWell(
     onTap: () {
       final searchText = _searchController.text.trim();
       if (searchText.isNotEmpty) {
         controller.searchCities(searchText);
       } else {
         controller.refreshCities();
       }
     },
     child: Container(
       // 红色按钮样式
       child: Text('Search'),
     ),
   )
   ```

3. **清除按钮** (动态显示)
   - 仅在有输入内容时显示
   - 点击清除输入并重新加载所有城市
   ```dart
   if (_searchController.text.isNotEmpty) ...[
     InkWell(
       onTap: () {
         _searchController.clear();
         controller.refreshCities();
         setState(() {});
       },
       child: Icon(Icons.clear),
     ),
   ]
   ```

#### 监听搜索框变化

```dart
@override
void initState() {
  super.initState();
  _searchController.addListener(() {
    setState(() {}); // 更新清除按钮显示
  });
}
```

## 用户交互流程

```
用户输入城市名称
  ↓
点击 "Search" 按钮 (或按回车键)
  ↓
DataServiceController.searchCities()
  ↓
调用 CityApiService.getCities(search: keyword)
  ↓
后端返回匹配的城市列表
  ↓
转换数据格式并更新 dataItems
  ↓
UI 自动更新显示搜索结果
  ↓
显示成功提示: "找到 N 个城市"
```

## 特殊情况处理

### 空搜索
```dart
if (searchKeyword.trim().isEmpty) {
  await refreshCities(); // 显示所有城市
  return;
}
```

### 无结果
```dart
if (convertedCities.isEmpty) {
  AppToast.info('未找到匹配的城市');
}
```

### 搜索失败
```dart
catch (e) {
  AppToast.error('搜索失败,请重试');
}
```

## API 调用示例

**请求**:
```http
GET /api/v1/cities?page=1&pageSize=100&search=Bangkok
```

**响应**:
```json
{
  "items": [
    {
      "id": "1",
      "name": "Bangkok",
      "country": "Thailand",
      "temperature": 32,
      "weather": "sunny",
      // ... 其他字段
    }
  ],
  "totalCount": 1
}
```

## UI 展示

### 搜索栏布局

```
┌─────────────────────────────────────────────┐
│ 🔍  [Search cities...]  [Search]  [×]      │
└─────────────────────────────────────────────┘
```

**组件说明**:
- 🔍 搜索图标 (装饰)
- 输入框 (可编辑)
- `[Search]` 按钮 (红色,点击触发搜索)
- `[×]` 清除按钮 (有内容时显示,点击清空并重置)

### 加载状态

搜索时城市列表区域显示:
```
        🔄
     Loading...
```

## 测试场景

1. **正常搜索**
   - 输入 "Bangkok" → 点击 Search → 显示曼谷相关城市

2. **无结果搜索**
   - 输入 "XXXXXXX" → 点击 Search → 提示 "未找到匹配的城市"

3. **清除搜索**
   - 有搜索结果 → 点击 × → 清空输入 → 显示所有城市

4. **空搜索**
   - 输入框为空 → 点击 Search → 刷新显示所有城市

5. **回车搜索**
   - 输入 "Tokyo" → 按回车键 → 触发搜索

## 性能优化

- ✅ 搜索时加载 100 条结果(而非默认 20 条)
- ✅ 独立加载状态 `isLoadingCities` 避免全页刷新
- ✅ 错误处理确保搜索失败不影响现有数据
- ✅ 使用 `setState()` 最小化重建范围

## 相关文档

- [DATA_SERVICE_REFACTORING_COMPLETE.md](./DATA_SERVICE_REFACTORING_COMPLETE.md) - DataService 重构
- [EVENTS_API_AUTH_FIX.md](./EVENTS_API_AUTH_FIX.md) - API 认证修复

---

**实现时间**: 2025-01-04
**功能状态**: ✅ 完成
