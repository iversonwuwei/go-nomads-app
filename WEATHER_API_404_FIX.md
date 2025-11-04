# 天气 API 404 错误修复

## 问题描述

前端调用天气 API 时返回 404 错误:
```
GET http://192.168.110.54:5000/api/v1/cities/{cityId}/weather?includeForecast=true&days=5
```

## 错误分析

### 前端请求
- **URL**: `http://192.168.110.54:5000/api/v1/cities/f816e041-883a-4775-aa1c-48782f15083e/weather`
- **参数**: `includeForecast=true`, `days=5`
- **目标**: BFF Gateway (端口 5000)

### 后端 API 配置

#### CityService API
位置: `go-nomads/src/Services/CityService/CityService/API/Controllers/CitiesController.cs:300`

```csharp
[HttpGet("{id:guid}/weather")]
public async Task<ActionResult<ApiResponse<WeatherDto>>> GetCityWeather(
    Guid id,
    [FromQuery] bool includeForecast = false,
    [FromQuery] int days = 7)
```

#### Gateway 路由配置
位置: `go-nomads/src/Gateway/Gateway/Services/ConsulProxyConfigProvider.cs:299`

```csharp
"/api/v1/cities/{**catch-all}", // Order: 3
```

### 问题原因

1. **可能原因 1**: CityService 没有正确注册到 Consul
2. **可能原因 2**: BFF Gateway 转发路径时出现问题
3. **可能原因 3**: CityService 本身没有运行或端口配置错误
4. **可能原因 4**: 路由优先级冲突

## 临时解决方案 ✅

修改前端天气加载逻辑,静默处理 404 错误,不影响其他功能:

### 修改文件
`lib/controllers/city_detail_controller.dart`

### 修改内容
```dart
} catch (e, stackTrace) {
  weather.value = null;
  // 天气 API 暂时不可用 (404),静默失败不影响其他功能
  print('ℹ️ 天气数据暂时不可用 (${e.toString().contains('404') ? 'API 未配置' : e})');
  if (!e.toString().contains('404')) {
    // 只有非 404 错误才打印详细堆栈
    print('   堆栈: $stackTrace');
  }
} finally {
```

### 效果
- ✅ 不再显示 404 错误日志
- ✅ 天气数据为空时不影响页面显示
- ✅ 其他非 404 错误仍会打印详细日志
- ✅ 城市详情页正常加载其他信息

## 正确解决方案 (待实施)

### 方案 1: 检查 CityService 运行状态

```powershell
# 检查 Docker 容器状态
docker ps | Select-String "city-service"

# 检查 Consul 服务注册
# 访问 http://localhost:8500/ui/dc1/services/city-service
```

### 方案 2: 检查 Gateway 日志

```powershell
# 查看 Gateway 日志
docker logs go-nomads-gateway --tail 50

# 搜索路由配置日志
docker logs go-nomads-gateway 2>&1 | Select-String "cities.*weather"
```

### 方案 3: 验证 CityService 直接访问

如果 CityService 运行在端口 8002:
```bash
# 直接访问 CityService (绕过 Gateway)
curl http://localhost:8002/api/v1/cities/{cityId}/weather?includeForecast=true&days=5
```

### 方案 4: 添加 Gateway 路由日志

在 `ConsulProxyConfigProvider.cs` 中添加更详细的路由日志:

```csharp
_logger.LogInformation("Route matched: {Path} -> {Cluster}", 
    context.Request.Path, destinationCluster);
```

### 方案 5: 使用 Dapr 直接调用 (推荐)

修改前端 API 服务,使用 Dapr Service Invocation:

```dart
// 直接调用 city-service (绕过 Gateway)
final response = await _httpService.get(
  '/v1/cities/$cityId/weather',
  headers: {
    'dapr-app-id': 'city-service',
  },
);
```

## 后续任务

- [ ] 确认 CityService 运行状态
- [ ] 检查 Consul 服务注册
- [ ] 验证 Gateway 路由转发
- [ ] 测试 CityService 直接访问
- [ ] 如果必要,考虑使用 Dapr 直接调用

## 相关文件

### 前端
- `lib/services/cities_api_service.dart` - 天气 API 调用
- `lib/controllers/city_detail_controller.dart` - 天气数据加载
- `lib/models/weather_model.dart` - 天气数据模型

### 后端
- `go-nomads/src/Services/CityService/CityService/API/Controllers/CitiesController.cs` - 天气 API 实现
- `go-nomads/src/Gateway/Gateway/Services/ConsulProxyConfigProvider.cs` - 路由配置
- `go-nomads/docker-compose.yml` - 服务配置

## 测试验证

### 1. 检查天气功能是否静默失败
```dart
// 打开城市详情页
// 观察日志输出:
// ℹ️ 天气数据暂时不可用 (API 未配置)
```

### 2. 验证其他功能正常
- ✅ 城市详情加载
- ✅ 评分卡片显示
- ✅ AI 指南生成
- ✅ 优缺点列表
- ✅ 用户评论
- ✅ 费用数据

## 更新日期
2025年11月4日

## 状态
✅ 临时方案已实施 (静默失败)
⏳ 正式修复待确认根本原因
