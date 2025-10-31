# Review 关联 Photos 集成完成

## 📋 需求
在 City Detail 页面的 Review Tab 中显示每条评论关联的照片。

## ✅ 解决方案
采用**方案1**：后端结构化返回 photoUrls 字段，保持数据独立性。

---

## 🔧 后端改动

### 1. DTO 增加字段
**文件**: `src/Services/CityService/CityService/Application/DTOs/UserCityContentDTOs.cs`

```csharp
public class UserCityReviewDto
{
    // ...原有字段
    
    /// <summary>
    /// 该用户在该城市上传的照片URL列表
    /// </summary>
    public List<string> PhotoUrls { get; set; } = new();
}
```

### 2. Service 层组装数据
**文件**: `src/Services/CityService/CityService/Application/Services/UserCityContentApplicationService.cs`

#### 2.1 GetCityReviewsAsync 方法
```csharp
public async Task<IEnumerable<UserCityReviewDto>> GetCityReviewsAsync(string cityId)
{
    var reviews = await _reviewRepository.GetByCityIdAsync(cityId);
    var result = new List<UserCityReviewDto>();
    
    foreach (var review in reviews)
    {
        var dto = MapReviewToDto(review);
        
        // ✅ 查询该用户在该城市的所有照片
        var photos = await _photoRepository.GetByCityIdAndUserIdAsync(cityId, review.UserId);
        dto.PhotoUrls = photos.Select(p => p.ImageUrl).ToList();
        
        result.Add(dto);
    }
    
    return result;
}
```

#### 2.2 GetUserReviewAsync 方法
```csharp
public async Task<UserCityReviewDto?> GetUserReviewAsync(Guid userId, string cityId)
{
    var review = await _reviewRepository.GetByCityIdAndUserIdAsync(cityId, userId);
    if (review == null) return null;
    
    var dto = MapReviewToDto(review);
    
    // ✅ 查询该用户在该城市的所有照片
    var photos = await _photoRepository.GetByCityIdAndUserIdAsync(cityId, userId);
    dto.PhotoUrls = photos.Select(p => p.ImageUrl).ToList();
    
    return dto;
}
```

---

## 📱 前端改动

### 1. 模型增加字段
**文件**: `lib/models/user_city_content_models.dart`

```dart
class UserCityReview {
  // ...原有字段
  
  /// 该用户在该城市上传的照片URL列表
  final List<String> photoUrls;

  UserCityReview({
    // ...原有参数
    this.photoUrls = const [],
  });

  factory UserCityReview.fromJson(Map<String, dynamic> json) {
    return UserCityReview(
      // ...原有字段
      photoUrls: (json['photoUrls'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}
```

### 2. 页面显示照片
**文件**: `lib/pages/city_detail_page.dart`

```dart
// 在真实用户评论卡片中添加照片显示
if (review.photoUrls.isNotEmpty) ...[
  const SizedBox(height: 12),
  SizedBox(
    height: 100,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: review.photoUrls.length,
      itemBuilder: (context, photoIndex) {
        return Container(
          width: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(review.photoUrls[photoIndex]),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    ),
  ),
],
```

---

## 🎯 数据流程

```
1. 用户进入 City Detail 页面
   ↓
2. Controller 调用 getCityReviews(cityId)
   ↓
3. 后端查询该城市的所有 reviews
   ↓
4. 对每条 review，查询该用户在该城市的 photos
   ↓
5. 组装 ReviewDto.PhotoUrls = [...photo urls]
   ↓
6. 返回给前端
   ↓
7. 前端解析 photoUrls 字段
   ↓
8. 页面使用 NetworkImage 显示照片
```

---

## ✅ 优势

1. **数据独立性**: Review 和 Photo 仍是独立存储，只在查询时组装
2. **结构清晰**: DTO 明确表达了"一条 review 关联多张 photos"的业务关系
3. **无前端污染**: 不需要前端自行过滤、拼装数据
4. **易于扩展**: 未来可以添加更多关联字段（如 expenseCount 等）

---

## 🧪 测试要点

1. ✅ 后端编译通过
2. ✅ 前端编译通过（无错误）
3. ⏳ 需要测试：
   - 提交 review 后，上传照片
   - 刷新 review tab，确认照片显示在 review 下方
   - 验证照片是该用户在该城市上传的所有照片

---

## 📅 完成时间
2025-10-31
