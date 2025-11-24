# Flutter 评分数据列表加载问题诊断

## 问题描述
Flutter 应用中的城市评分数据列表默认应该加载已有的评分项列表，但目前没有显示任何评分项。

## 诊断步骤

### 1. 检查后端数据库
运行以下 SQL 查询检查评分项数据：

```sql
-- 检查评分项数据
SELECT 
    id,
    name,
    name_en,
    icon,
    is_default,
    is_active,
    display_order,
    created_at
FROM city_rating_categories
WHERE is_active = true
ORDER BY display_order;
```

**预期结果**：应该有 10 个默认评分项：
1. 生活成本 (Cost of Living)
2. 气候舒适度 (Climate)
3. 交通便利度 (Transportation)
4. 美食 (Food)
5. 安全 (Safety)
6. 互联网 (Internet)
7. 娱乐活动 (Entertainment)
8. 医疗 (Healthcare)
9. 友好度 (Friendliness)
10. 英语普及度 (English Level)

**如果没有数据**：执行 `/database/migrations/city_rating_system.sql` 中的插入语句。

### 2. 检查后端 API 响应
调用 API 查看返回数据：

```bash
curl -X GET "http://localhost:5002/api/v1/cities/{cityId}/ratings" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**预期响应**：
```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "id": "uuid",
        "name": "生活成本",
        "nameEn": "Cost of Living",
        "icon": "attach_money",
        "isDefault": true,
        "displayOrder": 1
      },
      ...
    ],
    "statistics": [
      {
        "categoryId": "uuid",
        "categoryName": "生活成本",
        "averageRating": 0,
        "ratingCount": 0,
        "userRating": null
      },
      ...
    ],
    "overallScore": 0
  }
}
```

### 3. 检查前端日志
运行 Flutter 应用并查看控制台日志：

```
🔍 [CityRatingController] 开始加载评分数据: cityId=...
📡 [CityRatingRepository] 发送请求: GET /cities/{cityId}/ratings
📦 [CityRatingRepository] 收到响应: 200
📄 [CityRatingRepository] 响应数据: [success, data, message]
✅ [CityRatingRepository] 解析成功:
  - categories: 10
  - statistics: 10
  - overallScore: 0.0
📊 [CityRatingController] API 返回数据:
  - categories: 10 项
  - statistics: 10 项
  - overallScore: 0.0
```

## 可能的原因

### 1. 数据库中没有默认评分项
**解决方案**：执行数据库迁移脚本
```bash
cd /Users/walden/Workspaces/WaldenProjects/go-noma/database/migrations
./execute_migration.sh
```

或手动在 Supabase 中执行：
```sql
INSERT INTO city_rating_categories (name, name_en, description, icon, is_default, display_order) VALUES
('生活成本', 'Cost of Living', '城市的整体生活成本', 'attach_money', true, 1),
('气候舒适度', 'Climate', '城市的气候和天气舒适度', 'wb_sunny', true, 2),
('交通便利度', 'Transportation', '公共交通和出行便利程度', 'directions_bus', true, 3),
('美食', 'Food', '餐饮选择和美食质量', 'restaurant', true, 4),
('安全', 'Safety', '城市治安和安全水平', 'security', true, 5),
('互联网', 'Internet', '网络速度和稳定性', 'wifi', true, 6),
('娱乐活动', 'Entertainment', '娱乐和休闲活动丰富度', 'local_activity', true, 7),
('医疗', 'Healthcare', '医疗设施和服务质量', 'local_hospital', true, 8),
('友好度', 'Friendliness', '当地人友好程度', 'people', true, 9),
('英语普及度', 'English Level', '英语使用和沟通便利度', 'language', true, 10)
ON CONFLICT DO NOTHING;
```

### 2. API 调用失败
**检查**：
- 网络连接是否正常
- API 基础 URL 是否正确
- 认证 Token 是否有效

**解决方案**：查看前端日志中的错误信息

### 3. JSON 解析失败
**检查**：后端返回的字段名和前端期望的是否匹配

**常见问题**：
- C# 默认 PascalCase vs Dart camelCase
- ASP.NET Core 应该配置了 camelCase 序列化

### 4. 数据加载逻辑问题
**检查**：
- `CityRatingsCard` 是否正确调用了 `loadCityRatings`
- 数据加载是否被缓存逻辑阻止

## 修复代码

### 已添加调试日志
1. **CityRatingController** - 详细的加载流程日志
2. **CityRatingRepository** - API 请求和响应日志

### 检查点
- ✅ 后端 API 返回正确的数据结构
- ✅ HttpService 自动解包 ApiResponse
- ✅ DTO 解析逻辑正确
- ❓ 数据库中是否有默认评分项

## 下一步操作

1. **运行 Flutter 应用**，查看控制台日志
2. **检查日志输出**：
   - 如果看到 "categories: 10 项" - 数据加载成功，可能是 UI 渲染问题
   - 如果看到 "categories: 0 项" - 后端没有返回数据，检查数据库
   - 如果看到错误信息 - 根据错误类型修复

3. **验证数据库**：
```bash
# 连接到 Supabase 并运行 check_rating_categories.sql
```

4. **测试 API**：
```bash
# 使用 curl 或 Postman 测试 API 端点
```

## 参考文档
- 后端实现：`/go-noma/src/Services/CityService/CityService/API/Controllers/CityRatingsController.cs`
- 前端 Controller：`/open-platform-app/lib/features/city/presentation/controllers/city_rating_controller.dart`
- 数据库迁移：`/go-noma/database/migrations/city_rating_system.sql`
