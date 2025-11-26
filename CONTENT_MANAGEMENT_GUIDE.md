# 内容管理页面改造指南

## 改造目标
将现有的"添加"页面改造为"添加+管理"页面,支持:
1. 所有用户可以添加数据
2. Admin/版主可以查看所有数据并删除(逻辑删除)
3. 使用Tab结构分隔"添加"和"列表"

## 核心修改步骤

### 1. 添加必要的导入
```dart
import '../services/token_storage_service.dart';
import '../features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
```

### 2. 修改State类,添加TabController
```dart
class _AddReviewPageState extends State<AddReviewPage>
    with SingleTickerProviderStateMixin {  // 添加这个
  
  late TabController _tabController;  // 添加
  final RxBool canDelete = false.obs;  // 添加
  final RxBool isLoadingList = false.obs;  // 添加
  
  // ... 原有变量 ...
```

### 3. 修改initState
```dart
@override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);
  _checkPermissions();
  _loadData();
  // ... 原有初始化 ...
}

@override
void dispose() {
  _tabController.dispose();
  // ... 原有dispose ...
  super.dispose();
}

Future<void> _checkPermissions() async {
  final isAdmin = await TokenStorageService().isAdmin();
  canDelete.value = isAdmin;
}

Future<void> _loadData() async {
  isLoadingList.value = true;
  try {
    final controller = Get.find<UserCityContentStateController>();
    await controller.loadCityReviews(widget.cityId);
  } finally {
    isLoadingList.value = false;
  }
}
```

### 4. 修改Scaffold,添加TabBar
```dart
return Scaffold(
  appBar: AppBar(
    title: Text('${widget.cityName} - Reviews'),
    bottom: TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: '添加评论', icon: Icon(Icons.add)),
        Tab(text: '所有评论', icon: Icon(Icons.list)),
      ],
    ),
  ),
  body: TabBarView(
    controller: _tabController,
    children: [
      _buildAddTab(),    // 原有的添加表单
      _buildListTab(),   // 新增的列表
    ],
  ),
);
```

### 5. 将原有body内容包装为_buildAddTab()
```dart
Widget _buildAddTab() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          // ... 原有的表单内容 ...
        ),
      ),
    ),
  );
}
```

### 6. 创建_buildListTab()
```dart
Widget _buildListTab() {
  final controller = Get.find<UserCityContentStateController>();
  
  return Obx(() {
    if (isLoadingList.value) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (controller.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('暂无评论', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.reviews.length,
      itemBuilder: (context, index) {
        final review = controller.reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Text('${review.rating}', style: const TextStyle(color: Colors.white)),
            ),
            title: Text(review.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '创建于: ${_formatDate(review.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: canDelete.value
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteReview(review.id),
                  )
                : null,
          ),
        );
      },
    );
  });
}
```

### 7. 添加删除方法
```dart
Future<void> _deleteReview(String reviewId) async {
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('确认删除'),
      content: const Text('确定要删除这条评论吗？此操作可以恢复。'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('删除'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    final controller = Get.find<UserCityContentStateController>();
    final success = await controller.deleteMyReview(widget.cityId);

    if (success) {
      Get.snackbar('成功', '评论已删除', backgroundColor: Colors.green[100]);
      await _loadData();
    } else {
      Get.snackbar('失败', '删除失败，请重试');
    }
  } catch (e) {
    Get.snackbar('错误', '删除失败: $e');
  }
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
```

## 适配各个页面

### Reviews (`add_review_page.dart`)
- Controller: `UserCityContentStateController`
- 列表: `controller.reviews`
- 加载: `controller.loadCityReviews(cityId)`
- 删除: `controller.deleteMyReview(cityId)` ⚠️ 注意:这个方法只能删除自己的

### Cost (`add_cost_page.dart`)
- Controller: `UserCityContentStateController`
- 列表: `controller.expenses`
- 加载: `controller.loadCityExpenses(cityId)`
- 删除: `controller.deleteExpense(cityId, expenseId)` ✅ 支持任意删除

### Coworking (`add_coworking_page.dart`)
- Controller: `CoworkingController`
- 列表: 需要检查
- 加载: 需要检查
- 删除: ❌ 后端API不存在,需要先实现

## 注意事项

1. **Reviews删除限制**: 当前API只支持删除自己的review (`deleteMyReview`),不支持admin删除其他人的。需要后端添加admin删除接口。

2. **Photos特殊情况**: 使用对话框添加,可能不需要改造成Tab结构。

3. **后端逻辑删除**: 所有删除操作都应该是逻辑删除(设置 `is_deleted = true`),而不是物理删除。

4. **权限验证**: 前端使用 `TokenStorageService().isAdmin()` 控制UI,但后端也必须验证权限。

## 测试检查清单

对每个改造后的页面:
- [ ] 普通用户可以看到"添加"和"列表"两个Tab
- [ ] Admin可以在列表中看到删除按钮
- [ ] 普通用户看不到删除按钮
- [ ] 删除前弹出确认对话框
- [ ] 删除成功后列表自动刷新
- [ ] 删除成功后显示成功提示
- [ ] 数据库中记录被标记为 `is_deleted = true`
