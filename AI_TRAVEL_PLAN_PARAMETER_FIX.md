# AI Travel Plan 参数验证修复

## 问题描述

Flutter 客户端调用 AI Service 的 `/api/v1/ai/travel-plan` 接口时遇到 400 错误:

```json
{
  "type": "https://tools.ietf.org/html/rfc9110#section-15.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "Budget": ["预算等级必须是 low, medium 或 high"],
    "TravelStyle": ["旅行风格必须是 adventure, relaxation, culture 或 nightlife"]
  }
}
```

## 根本原因

### 1. Budget 参数格式不匹配

**客户端发送**: `"CNY:5000"` (自定义预算格式)
**后端期望**: `"low"`, `"medium"`, 或 `"high"`

**后端验证规则** (`GenerateTravelPlanRequest.cs`):
```csharp
[Required(ErrorMessage = "预算等级不能为空")]
[RegularExpression("^(low|medium|high)$", ErrorMessage = "预算等级必须是 low, medium 或 high")]
public string Budget { get; set; } = "medium";
```

### 2. TravelStyle 参数值不支持

**客户端提供的选项**:
- ✅ `culture` (后端支持)
- ✅ `adventure` (后端支持)
- ✅ `relaxation` (后端支持)
- ❌ `food` (后端不支持)
- ✅ `nightlife` (后端支持)
- ❌ `shopping` (后端不支持)

**后端验证规则**:
```csharp
[Required(ErrorMessage = "旅行风格不能为空")]
[RegularExpression("^(adventure|relaxation|culture|nightlife)$", 
    ErrorMessage = "旅行风格必须是 adventure, relaxation, culture 或 nightlife")]
public string TravelStyle { get; set; } = "culture";
```

## 解决方案

### ✅ 修复 1: 处理自定义预算格式

**文件**: `lib/services/ai_api_service.dart`

在 `generateTravelPlan()` 方法中添加了预算格式解析逻辑:

```dart
// 处理自定义预算格式 (e.g., "CNY:5000")
String finalBudget = budget;
String? finalCurrency = currency;
double? finalCustomBudget = customBudget;

if (budget.contains(':')) {
  // 解析自定义预算格式: "CURRENCY:AMOUNT"
  final parts = budget.split(':');
  if (parts.length == 2) {
    finalCurrency = parts[0]; // e.g., "CNY"
    final amount = double.tryParse(parts[1]);
    
    if (amount != null) {
      finalCustomBudget = amount;
      
      // 根据金额范围映射到 budget 级别
      if (amount < 3000) {
        finalBudget = 'low';
      } else if (amount < 10000) {
        finalBudget = 'medium';
      } else {
        finalBudget = 'high';
      }
      
      print('   💰 解析自定义预算: $finalCurrency $finalCustomBudget → $finalBudget');
    }
  }
}
```

**映射规则**:
- 金额 < 3000: `low`
- 3000 ≤ 金额 < 10000: `medium`
- 金额 ≥ 10000: `high`

**后端字段映射**:
- `budget`: 映射后的级别 (`low`/`medium`/`high`)
- `customBudget`: 实际金额 (e.g., `5000`)
- `currency`: 货币代码 (e.g., `CNY`)

### ✅ 修复 2: 移除不支持的 TravelStyle 选项

**文件**: `lib/pages/create_travel_plan_page.dart`

移除了后端不支持的旅行风格选项:

**修改前**:
```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    _buildStyleChip(l10n.culture, 'culture', Icons.museum_outlined),
    _buildStyleChip(l10n.adventure, 'adventure', Icons.landscape_outlined),
    _buildStyleChip(l10n.relaxation, 'relaxation', Icons.spa_outlined),
    _buildStyleChip(l10n.foodie, 'food', Icons.restaurant_outlined),     // ❌ 已移除
    _buildStyleChip(l10n.nightlife, 'nightlife', Icons.nightlife_outlined),
    _buildStyleChip(l10n.shopping, 'shopping', Icons.shopping_bag_outlined), // ❌ 已移除
  ],
),
```

**修改后**:
```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    _buildStyleChip(l10n.culture, 'culture', Icons.museum_outlined),
    _buildStyleChip(l10n.adventure, 'adventure', Icons.landscape_outlined),
    _buildStyleChip(l10n.relaxation, 'relaxation', Icons.spa_outlined),
    _buildStyleChip(l10n.nightlife, 'nightlife', Icons.nightlife_outlined),
  ],
),
```

## 后端接口文档

### 端点
`POST /api/v1/ai/travel-plan`

### 返回格式
✅ **确认使用统一的 ApiResponse 格式**

```csharp
// 成功响应
return Ok(ApiResponse.Success(result, "旅行计划生成成功"));

// 错误响应
return BadRequest(ApiResponse.Fail(ex.Message));
return StatusCode(500, ApiResponse.Fail("生成旅行计划失败，请稍后重试"));
```

**ApiResponse 结构**:
```csharp
public class ApiResponse<T>
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public T? Data { get; set; }
    public List<string> Errors { get; set; } = new();
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}
```

### 匿名用户支持
✅ **AIService 已支持匿名用户访问**

```csharp
// 获取当前用户ID（可选，AIService 不强制要求认证）
var userId = this.GetUserId();

// 如果没有用户上下文，使用匿名用户ID
if (userId == Guid.Empty)
{
    userId = Guid.Parse("00000000-0000-0000-0000-000000000001"); // 匿名用户
    _logger.LogInformation("ℹ️ 匿名用户生成旅行计划");
}
```

### 请求参数

| 字段 | 类型 | 必填 | 验证规则 | 说明 |
|-----|------|------|---------|------|
| `cityId` | string | ✅ | Required | 城市ID |
| `cityName` | string | ✅ | Required | 城市名称 |
| `cityImage` | string | ❌ | - | 城市图片URL |
| `duration` | int | ✅ | 1-30 | 旅行天数 |
| `budget` | string | ✅ | `low`/`medium`/`high` | 预算级别 |
| `travelStyle` | string | ✅ | `adventure`/`relaxation`/`culture`/`nightlife` | 旅行风格 |
| `interests` | string[] | ❌ | - | 兴趣列表 |
| `departureLocation` | string | ❌ | - | 出发地 |
| `customBudget` | string | ❌ | - | 自定义预算金额 |
| `currency` | string | ❌ | - | 货币代码 (默认: USD) |
| `selectedAttractions` | string[] | ❌ | - | 选中的景点ID |

## 测试计划

### 场景 1: 使用预设预算级别
- 选择 Budget: `medium`
- 选择 TravelStyle: `culture`
- 期望: ✅ 成功生成旅行计划

### 场景 2: 使用自定义预算
- 输入自定义预算: `CNY 5000`
- 客户端处理:
  - `budget`: `"CNY:5000"` → 解析为 `"medium"`
  - `customBudget`: `"5000"`
  - `currency`: `"CNY"`
- 期望: ✅ 成功生成旅行计划

### 场景 3: 测试所有 TravelStyle 选项
- ✅ `culture`
- ✅ `adventure`
- ✅ `relaxation`
- ✅ `nightlife`
- 期望: 所有选项都能正常工作

## 验证检查清单

- [x] ✅ 移除了不支持的 TravelStyle 选项 (`food`, `shopping`)
- [x] ✅ 添加了自定义预算格式解析逻辑
- [x] ✅ Budget 参数正确映射到 `low`/`medium`/`high`
- [x] ✅ 自定义预算金额传递到 `customBudget` 字段
- [x] ✅ 货币代码传递到 `currency` 字段
- [x] ✅ 确认后端使用统一的 ApiResponse 格式
- [x] ✅ 确认后端支持匿名用户访问

## 后续改进建议

### 可选: 扩展后端支持的 TravelStyle
如果需要支持 `food` 和 `shopping` 风格,可以修改后端:

```csharp
[RegularExpression("^(adventure|relaxation|culture|nightlife|food|shopping)$", 
    ErrorMessage = "旅行风格必须是 adventure, relaxation, culture, nightlife, food 或 shopping")]
public string TravelStyle { get; set; } = "culture";
```

### 可选: 调整预算映射阈值
当前映射规则可能需要根据实际使用情况调整:

```dart
// 当前规则
if (amount < 3000) finalBudget = 'low';
else if (amount < 10000) finalBudget = 'medium';
else finalBudget = 'high';

// 可能的调整 (根据用户反馈)
if (amount < 5000) finalBudget = 'low';
else if (amount < 15000) finalBudget = 'medium';
else finalBudget = 'high';
```

## 相关文件

### 客户端 (Flutter)
- ✅ `lib/services/ai_api_service.dart` - API 调用和参数处理
- ✅ `lib/pages/create_travel_plan_page.dart` - 旅行风格选项
- `lib/pages/travel_plan_page.dart` - 旅行计划展示页面
- `lib/controllers/city_detail_controller.dart` - 城市详情控制器

### 后端 (C# / .NET)
- ✅ `src/Services/AIService/AIService/API/Controllers/ChatController.cs` - API 控制器
- ✅ `src/Services/AIService/AIService/Application/DTOs/Requests.cs` - 请求 DTO
- `src/Services/AIService/AIService/Application/Services/AIChatApplicationService.cs` - 业务逻辑

## 总结

✅ **所有问题已修复**:
1. Budget 参数格式不匹配 → 添加了自定义预算解析逻辑
2. TravelStyle 不支持的值 → 移除了 `food` 和 `shopping` 选项
3. 返回格式统一性 → 确认后端已使用 ApiResponse 格式

**现在客户端发送的所有参数都符合后端的验证规则,应该能够成功调用 AI Travel Plan 接口。**
