# 用户城市内容系统集成 - 完成状态

## ✅ 已完成 (Flutter 前端)

### 1. 数据模型 (`lib/models/user_city_content_models.dart`)

#### UserCityPhoto - 城市照片
```dart
- id: String (主键)
- userId: String (用户ID)
- cityId: String (城市ID)
- imageUrl: String (图片URL)
- caption: String? (说明文字)
- location: String? (拍摄地点)
- takenAt: DateTime? (拍摄时间)
- createdAt: DateTime (创建时间)
```

#### UserCityExpense - 城市费用
```dart
- id: String
- userId: String
- cityId: String
- category: ExpenseCategory (分类枚举)
- amount: double (金额)
- currency: String (货币，默认USD)
- description: String? (描述)
- date: DateTime (消费日期)
- createdAt: DateTime
```

**费用分类 (ExpenseCategory):**
- `food` - Food & Dining
- `transport` - Transportation
- `accommodation` - Accommodation
- `activity` - Activities
- `shopping` - Shopping
- `other` - Other

#### UserCityReview - 城市评论
```dart
- id: String
- userId: String
- cityId: String
- rating: int (1-5星评分)
- title: String (标题)
- content: String (内容)
- visitDate: DateTime? (访问日期)
- createdAt: DateTime
- updatedAt: DateTime
```

**重要约束:** 每个用户每个城市只能有一个评论（upsert模式）

#### CityUserContentStats - 统计数据
```dart
- cityId: String
- photoCount: int (照片数量)
- expenseCount: int (费用记录数)
- reviewCount: int (评论数)
- averageRating: double (平均评分)
- photoContributors: int (照片贡献者数)
- expenseContributors: int (费用贡献者数)
- reviewContributors: int (评论贡献者数)
```

### 2. API 服务 (`lib/services/user_city_content_api_service.dart`)

**单例模式:** `UserCityContentApiService()`

#### 照片接口
```dart
// 添加照片
Future<UserCityPhoto> addCityPhoto({
  required String cityId,
  required String imageUrl,
  String? caption,
  String? location,
  DateTime? takenAt,
})

// 获取城市照片 (可选只看自己的)
Future<List<UserCityPhoto>> getCityPhotos({
  required String cityId,
  bool onlyMine = false,
})

// 删除照片
Future<void> deleteCityPhoto({
  required String cityId,
  required String photoId,
})

// 获取我的所有照片（跨城市）
Future<List<UserCityPhoto>> getMyPhotos()
```

#### 费用接口
```dart
// 添加费用
Future<UserCityExpense> addCityExpense({
  required String cityId,
  required ExpenseCategory category,
  required double amount,
  String currency = 'USD',
  String? description,
  required DateTime date,
})

// 获取城市费用
Future<List<UserCityExpense>> getCityExpenses({
  required String cityId,
  bool onlyMine = false,
})

// 删除费用
Future<void> deleteCityExpense({
  required String cityId,
  required String expenseId,
})

// 获取我的所有费用
Future<List<UserCityExpense>> getMyExpenses()
```

#### 评论接口
```dart
// 创建或更新评论 (Upsert)
Future<UserCityReview> upsertCityReview({
  required String cityId,
  required int rating,
  required String title,
  required String content,
  DateTime? visitDate,
})

// 获取城市评论（公开）
Future<List<UserCityReview>> getCityReviews(String cityId)

// 获取我的评论
Future<UserCityReview?> getMyCityReview(String cityId)

// 删除我的评论
Future<void> deleteMyCityReview(String cityId)
```

#### 统计接口
```dart
// 获取城市内容统计（公开）
Future<CityUserContentStats> getCityStats(String cityId)
```

---

## ⚠️ 待完成 (后端)

### 1. 数据库迁移
**文件:** `/Users/walden/Workspaces/WaldenProjects/go-noma/create_user_city_content_tables.sql`

**需要执行:** 
在 Supabase 数据库运行此 SQL 文件以创建：
- `user_city_photos` 表
- `user_city_expenses` 表
- `user_city_reviews` 表
- RLS 安全策略
- 索引优化
- `user_city_content_stats` 视图

### 2. BFF Service 代码集成

**已创建文件 (未部署):**
- `UserCityContentDTOs.cs` - 数据传输对象
- `UserCityContentService.cs` - 业务逻辑服务
- `UserCityContentController.cs` - API 控制器

**需要完成:**
1. 找到/创建 BFF Service 的 `Program.cs`
2. 注册服务到 DI 容器:
   ```csharp
   builder.Services.AddScoped<IUserCityContentService, UserCityContentService>();
   ```
3. 配置数据库连接字符串 (Supabase PostgreSQL)
4. 构建并发布 BFF Service
5. 重启 Docker 容器

### 3. API 端点列表 (后端)

**UserCityContentController (`/api/cities/{cityId}/user-content`)**

#### 照片
- `POST /photos` - 添加照片 (需认证)
- `GET /photos?onlyMine={bool}` - 获取照片列表 (需认证)
- `DELETE /photos/{photoId}` - 删除照片 (需认证)

#### 费用
- `POST /expenses` - 添加费用 (需认证)
- `GET /expenses?onlyMine={bool}` - 获取费用列表 (需认证)
- `DELETE /expenses/{expenseId}` - 删除费用 (需认证)

#### 评论
- `POST /reviews` - 创建/更新评论 (需认证，Upsert)
- `GET /reviews` - 获取评论列表 (公开)
- `GET /reviews/mine` - 获取我的评论 (需认证)
- `DELETE /reviews` - 删除我的评论 (需认证)

#### 统计
- `GET /stats` - 获取统计数据 (公开)

**MyContentController (`/api/user/city-content`)**
- `GET /photos` - 我的所有照片 (需认证)
- `GET /expenses` - 我的所有费用 (需认证)

---

## ⏭️ 下一步 (Flutter UI)

### 1. 创建添加页面
- `lib/pages/city/add_photo_page.dart` - 添加照片页面
  - 图片选择器 (image_picker)
  - 说明文字输入
  - 地点输入
  - 拍摄时间选择
  
- `lib/pages/city/add_expense_page.dart` - 添加费用页面
  - 分类下拉选择
  - 金额输入
  - 货币选择
  - 日期选择
  - 描述输入

- `lib/pages/city/add_review_page.dart` - 添加评论页面
  - 星级评分选择器
  - 标题输入
  - 内容输入 (多行)
  - 访问日期选择

### 2. 集成到 city_detail_page.dart

在 `Photos`、`Expenses`、`Reviews` 三个 Tab 中：

**添加功能:**
- FloatingActionButton 导航到对应的添加页面
- 显示用户自己的内容
- 编辑/删除按钮
- 下拉刷新

**示例集成 (Photos Tab):**
```dart
// 在 city_detail_page.dart 的 Photos Tab
floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final result = await Get.to(() => AddPhotoPage(cityId: city.id));
    if (result == true) {
      _refreshPhotos(); // 刷新照片列表
    }
  },
  child: Icon(Icons.add_photo_alternate),
),
```

---

## 🔒 安全性

### RLS (Row Level Security)
- ✅ 用户只能增删改自己的内容
- ✅ 所有用户可以查看他人的评论（公开）
- ✅ 照片和费用可选择只看自己的或所有的

### JWT 认证
- ✅ 所有写操作需要认证
- ✅ 读操作部分公开（评论、统计）
- ✅ 使用 `ClaimTypes.NameIdentifier` 提取用户 ID

---

## 📊 数据库索引优化

已为以下字段创建索引：
- `user_id` (单列索引) - 快速查询用户内容
- `city_id` (单列索引) - 快速查询城市内容
- `(user_id, city_id)` (复合索引) - 快速查询特定用户在特定城市的内容
- `created_at` / `date` (排序索引) - 时间排序查询

---

## 🚀 部署步骤

1. **执行数据库迁移**
   ```bash
   # 在 Supabase SQL Editor 中运行
   # /Users/walden/Workspaces/WaldenProjects/go-noma/create_user_city_content_tables.sql
   ```

2. **配置 BFF Service**
   - 找到 Program.cs
   - 注册 IUserCityContentService
   - 配置连接字符串

3. **构建并部署后端**
   ```bash
   cd /Users/walden/Workspaces/WaldenProjects/go-noma/src/Services/BFFService
   dotnet build --configuration Release
   dotnet publish
   # 重启 Docker 容器
   ```

4. **测试 API 端点**
   ```bash
   # 测试添加照片
   curl -X POST http://localhost:8080/api/cities/{cityId}/user-content/photos \
     -H "Authorization: Bearer {token}" \
     -H "Content-Type: application/json" \
     -d '{"imageUrl": "https://example.com/photo.jpg", "caption": "Beautiful view"}'
   ```

5. **开发 Flutter UI**
   - 创建添加页面
   - 集成到 city_detail_page
   - 测试完整流程

---

## 📝 代码示例

### 使用 API 服务
```dart
import 'package:get/get.dart';
import '../services/user_city_content_api_service.dart';
import '../models/user_city_content_models.dart';

// 添加照片
final service = UserCityContentApiService();
try {
  final photo = await service.addCityPhoto(
    cityId: 'bangkok-thailand',
    imageUrl: 'https://example.com/photo.jpg',
    caption: 'Amazing temple!',
    location: 'Wat Pho',
    takenAt: DateTime.now(),
  );
  Get.snackbar('Success', 'Photo added!');
} catch (e) {
  Get.snackbar('Error', e.toString());
}

// 获取城市照片
final photos = await service.getCityPhotos(
  cityId: 'bangkok-thailand',
  onlyMine: false, // false = 看所有人的, true = 只看自己的
);

// 添加费用
final expense = await service.addCityExpense(
  cityId: 'bangkok-thailand',
  category: ExpenseCategory.food,
  amount: 25.50,
  currency: 'USD',
  description: 'Lunch at local restaurant',
  date: DateTime.now(),
);

// 添加/更新评论
final review = await service.upsertCityReview(
  cityId: 'bangkok-thailand',
  rating: 5,
  title: 'Amazing city!',
  content: 'Bangkok is incredible. The food, culture, and people are wonderful.',
  visitDate: DateTime(2025, 10, 1),
);

// 获取统计
final stats = await service.getCityStats('bangkok-thailand');
print('Average Rating: ${stats.averageRating}');
print('Total Photos: ${stats.photoCount}');
```

---

## ✅ 检查清单

### 后端
- [ ] 执行数据库迁移
- [ ] 找到/创建 Program.cs
- [ ] 注册服务到 DI
- [ ] 配置连接字符串
- [ ] 构建并发布
- [ ] 重启容器
- [ ] 测试 API 端点

### Flutter
- [x] 创建数据模型
- [x] 创建 API 服务
- [ ] 创建添加照片页面
- [ ] 创建添加费用页面
- [ ] 创建添加评论页面
- [ ] 集成到 city_detail_page
- [ ] 实现图片上传
- [ ] 测试完整流程

---

**当前状态:** Flutter 前端数据模型和 API 服务已完成，等待后端部署后进行 UI 开发。
