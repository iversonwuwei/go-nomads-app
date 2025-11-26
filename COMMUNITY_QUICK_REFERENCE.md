# Community Domain Quick Reference 🚀

## 快速导入

```dart
// Domain Entities
import 'package:df_admin_mobile/features/community/domain/entities/trip_report.dart';

// Repository Interface
import 'package:df_admin_mobile/features/community/domain/repositories/i_community_repository.dart';

// State Controller
import 'package:df_admin_mobile/features/community/presentation/controllers/community_state_controller.dart';
```

## 在 UI 中使用

### 获取 Controller
```dart
// 在 Widget 中
final controller = Get.find<CommunityStateController>();
```

### 访问数据
```dart
// 旅行报告
Obx(() => ListView.builder(
  itemCount: controller.tripReports.length,
  itemBuilder: (context, index) {
    final report = controller.tripReports[index];
    return Text(report.title);
  },
));

// 城市推荐 (带过滤)
Obx(() => GridView.builder(
  itemCount: controller.filteredRecommendations.length,
  itemBuilder: (context, index) {
    final rec = controller.filteredRecommendations[index];
    return Text(rec.name);
  },
));

// 问题列表
Obx(() => ListView.builder(
  itemCount: controller.questions.length,
  itemBuilder: (context, index) {
    final question = controller.questions[index];
    return Text(question.title);
  },
));
```

### 用户操作
```dart
// 切换点赞
ElevatedButton(
  onPressed: () => controller.toggleLikeTripReport(report.id),
  child: Icon(report.isLiked ? Icons.favorite : Icons.favorite_border),
);

// 切换点踩
IconButton(
  onPressed: () => controller.toggleUpvoteQuestion(question.id),
  icon: Icon(question.isUpvoted ? Icons.arrow_upward : Icons.arrow_upward_outlined),
);

// 改变类别过滤
DropdownButton<String>(
  value: controller.selectedCategory.value,
  onChanged: (value) => controller.changeCategory(value!),
  items: controller.categories.map((category) {
    return DropdownMenuItem(value: category, child: Text(category));
  }).toList(),
);

// 改变城市过滤 (会重新加载数据)
DropdownButton<String>(
  value: controller.selectedCity.value,
  onChanged: (value) => controller.changeCity(value!),
  items: [...],
);

// 刷新数据
RefreshIndicator(
  onRefresh: controller.refresh,
  child: ListView(...),
);
```

## 实体属性

### TripReport
```dart
report.id
report.userName
report.city
report.country
report.title
report.content
report.overallRating
report.ratings // Map<String, double>
report.photos // List<String>
report.pros // List<String>
report.cons // List<String>
report.likes
report.comments
report.isLiked // ✅ 直接从实体读取

// Business Logic
report.tripDuration
report.isLongTrip
report.isPopular
report.isHighlyRated
```

### CityRecommendation
```dart
rec.id
rec.city
rec.name
rec.category // Restaurant, Cafe, Coworking, Activity
rec.description
rec.rating
rec.reviewCount
rec.priceRange // $, $$, $$$
rec.address
rec.photos // List<String>
rec.website
rec.tags // List<String>

// Business Logic
rec.isHighlyRated
rec.isPopular
rec.isRestaurant / isCafe / isCoworking / isActivity
rec.priceLevel // budget, moderate, expensive, luxury
```

### Question
```dart
question.id
question.userName
question.city
question.title
question.content
question.tags // List<String>
question.upvotes
question.answerCount
question.hasAcceptedAnswer
question.isUpvoted // ✅ 直接从实体读取

// Business Logic
question.hasAnswers
question.isResolved
question.needsAnswer
question.isPopular
question.isRecent
```

### Answer
```dart
answer.id
answer.questionId
answer.userName
answer.content
answer.upvotes
answer.isAccepted
answer.isUpvoted

// Business Logic
answer.isHelpful
answer.isRecent
```

## Computed Properties

```dart
// 根据选中类别过滤的推荐
controller.filteredRecommendations

// 热门旅行报告
controller.popularTripReports

// 最近的问题
controller.recentQuestions

// 未解决的问题
controller.unresolvedQuestions
```

## State Management

### Loading State
```dart
Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }
  return YourContent();
});
```

### Selected Category
```dart
Obx(() => Text('Category: ${controller.selectedCategory.value}'));
```

### Selected City
```dart
Obx(() => Text('City: ${controller.selectedCity.value}'));
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:df_admin_mobile/features/community/domain/entities/trip_report.dart';
import 'package:df_admin_mobile/features/community/presentation/controllers/community_state_controller.dart';

class MyCommunityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityStateController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Community'),
        actions: [
          // 城市过滤
          Obx(() => DropdownButton<String>(
            value: controller.selectedCity.value,
            onChanged: (city) => controller.changeCity(city!),
            items: ['All Cities', 'Chiang Mai', 'Lisbon', 'Bangkok']
                .map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    ))
                .toList(),
          )),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // Trip Reports List
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            itemCount: controller.tripReports.length,
            itemBuilder: (context, index) {
              final report = controller.tripReports[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(report.userAvatar ?? ''),
                  ),
                  title: Text(report.title),
                  subtitle: Text(
                    '${report.city} - ${report.overallRating} ⭐',
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      report.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: report.isLiked ? Colors.red : Colors.grey,
                    ),
                    onPressed: () =>
                        controller.toggleLikeTripReport(report.id),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
```

## Mock 数据说明

Community Domain 目前使用 Mock 数据,包含:
- ✅ 2 个旅行报告 (Chiang Mai, Lisbon)
- ✅ 4 个城市推荐 (Punspace Nimman, Ristr8to Lab, Second Home Lisboa, Or Tor Kor Market)
- ✅ 3 个问题 (区域选择, 签证, 物价)
- ✅ Mock 答案

未来替换为真实 API 时,只需要修改 `CommunityRepository` 实现,UI 层无需改动。

## 依赖注入

Community Domain 已在 `dependency_injection.dart` 中注册:

```dart
static void _registerCommunityDomain() {
  // Repository
  Get.lazyPut<ICommunityRepository>(() => CommunityRepository());

  // Controller
  Get.lazyPut(() => CommunityStateController(
    repository: Get.find<ICommunityRepository>(),
  ));
}
```

在 `main.dart` 中调用 `DependencyInjection.init()` 后,所有 Community 功能即可使用。

## 常见问题

### Q: 如何添加新的推荐类别?
A: 在 `CommunityStateController` 的 `categories` 列表中添加,UI 会自动更新。

### Q: 如何加载某个问题的答案?
A: 调用 `controller.loadAnswers(questionId)`,然后从 `controller.answers[questionId]` 读取。

### Q: 如何实现分页加载?
A: 修改 `ICommunityRepository` 接口,添加 `page` 和 `pageSize` 参数,然后在 `CommunityRepository` 和 `CommunityStateController` 中实现。

### Q: 如何替换为真实 API?
A: 创建新的 `CommunityApiRepository implements ICommunityRepository`,然后在 `dependency_injection.dart` 中替换实现。

---

**文档版本**: v1.0
**最后更新**: 2024-01 (Community DDD Migration)
