# AI旅行计划集成 - 快速参考

## ✅ 已完成的工作

### 前端 (Flutter)
1. ✅ Days滑动条可视化改进 - 显示当前天数
2. ✅ 创建AI API服务 (`ai_api_service.dart`)
3. ✅ 集成到CityDetailController
4. ✅ 移除模拟数据,使用真实API

### 后端 (AIService)
1. ✅ 创建Request/Response DTOs (8个类)
2. ✅ 实现AI服务方法 (433行代码)
3. ✅ 添加API端点 `POST /api/v1/ai/travel-plan`
4. ✅ JWT认证集成
5. ✅ 完整错误处理

## 🚀 如何测试

### 启动后端服务
```powershell
cd e:\Workspaces\WaldenProjects\go-nomads
.\deploy-services-local.ps1
```

### 运行Flutter应用
```bash
cd e:\Workspaces\WaldenProjects\df_admin_mobile
flutter run
```

### 测试步骤
1. 登录应用
2. 选择一个城市
3. 进入城市详情页
4. 点击"AI Travel Planner"按钮
5. 填写旅行参数:
   - Days: 拖动滑块选择天数
   - Budget: low/medium/high
   - Travel Style: 选择风格
   - Interests: 添加兴趣标签
6. 点击"Generate Plan"
7. 等待AI生成(约10-30秒)
8. 查看生成的旅行计划

## 📡 API端点

**端点**: `POST /api/v1/ai/travel-plan`

**请求头**:
```
Content-Type: application/json
Authorization: Bearer {JWT_TOKEN}
```

**请求体**:
```json
{
  "cityId": "string",
  "cityName": "string",
  "cityImage": "string",
  "duration": 7,
  "budget": "medium",
  "travelStyle": "culture",
  "interests": ["temples", "food", "markets"],
  "departureLocation": "北京" // 可选
}
```

**响应**:
```json
{
  "success": true,
  "message": "旅行计划生成成功",
  "data": {
    "id": "plan_xxx",
    "cityId": "1",
    "cityName": "曼谷",
    "duration": 7,
    "transportation": { ... },
    "accommodation": { ... },
    "dailyItineraries": [ ... ],
    "attractions": [ ... ],
    "restaurants": [ ... ],
    "budgetBreakdown": { ... }
  }
}
```

## 🔧 配置要求

### 后端配置
检查 `appsettings.json`:
```json
{
  "DeepSeek": {
    "ApiKey": "YOUR_API_KEY",
    "ModelId": "deepseek-chat",
    "Endpoint": "https://api.deepseek.com"
  }
}
```

### 前端配置
检查 `lib/config/api_config.dart`:
- Android模拟器: `http://10.0.2.2:5173`
- iOS模拟器: `http://localhost:5173`
- 真机: 设置 `physicalDeviceUrl` 为电脑局域网IP

## 🐛 常见问题

### 1. 401 Unauthorized
**原因**: 未登录或token过期
**解决**: 重新登录获取新token

### 2. 超时错误
**原因**: AI生成时间较长
**解决**: 已设置60秒超时,正常等待即可

### 3. JSON解析错误
**原因**: AI返回格式不符合预期
**解决**: 检查后端日志,优化提示词

### 4. 网络连接失败
**原因**: 
- 后端服务未启动
- API地址配置错误
- 防火墙阻止

**解决**:
1. 确认后端服务运行: `http://localhost:5173/api/v1/ai/health`
2. 检查API配置
3. 关闭防火墙或添加例外

## 📝 代码位置

### 后端
- DTOs: `AIService/Application/DTOs/`
- 服务: `AIService/Application/Services/AIChatApplicationService.cs`
- 控制器: `AIService/API/Controllers/ChatController.cs`

### 前端
- AI服务: `lib/services/ai_api_service.dart`
- 控制器: `lib/controllers/city_detail_controller.dart`
- UI页面: `lib/pages/create_travel_plan_page.dart`
- 结果页: `lib/pages/travel_plan_page.dart`

## 🎯 数据流

```
CreateTravelPlanPage (用户输入)
    ↓
CityDetailController.generateTravelPlan()
    ↓
AiApiService.generateTravelPlan()
    ↓
HttpService (自动添加JWT, 解包响应)
    ↓
POST /api/v1/ai/travel-plan
    ↓
ChatController (验证用户)
    ↓
AIChatApplicationService (调用DeepSeek)
    ↓
DeepSeek AI (生成JSON)
    ↓
解析并返回TravelPlanResponse
    ↓
Flutter解析为TravelPlan模型
    ↓
TravelPlanPage (显示结果)
```

## 🔍 调试技巧

### 后端日志
查看AIService日志:
- 🗺️ 开始生成旅行计划
- 🤖 正在调用 AI 生成旅行计划
- ⏱️ AI 生成耗时
- ✅ 旅行计划生成成功

### 前端日志
在Flutter DevTools或控制台查看:
- 🎯 开始调用AI服务生成旅行计划
- 🤖 正在生成AI旅行计划
- 📡 正在获取...
- ✅ AI旅行计划生成成功

### 使用curl测试
```bash
curl -X POST http://localhost:5173/api/v1/ai/travel-plan \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d @test-travel-plan.json
```

## ⚡ 性能优化建议

1. **缓存已生成的计划** - 避免重复生成
2. **流式响应** - 逐步显示生成进度
3. **后台生成** - 异步生成,完成后通知
4. **本地存储** - 离线查看已生成计划

## 🔐 安全注意事项

- ✅ 所有请求需要JWT认证
- ✅ 用户只能生成自己的计划
- ✅ 输入验证 (天数1-30, 预算枚举值)
- ⚠️ 未实现速率限制 (建议添加)
- ⚠️ 未实现配额管理 (建议添加)

---

**状态**: ✅ 开发完成,待集成测试
**最后更新**: 2024
