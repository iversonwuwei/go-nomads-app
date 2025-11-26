# City Content Management Optimization TODO

## 目标
为 admin/版主提供数据管理功能,同时保持普通用户的添加功能。

## 当前状态

### ✅ 已完成
1. **Pros & Cons** (`pros_and_cons_add_page.dart`)
   - ✅ 数据加载 (`_loadData()`)
   - ✅ 删除功能 (`deletePros()`, `deleteCons()`)
   - ✅ 权限控制 (`canDelete`)
   - ✅ 列表显示with删除按钮

2. **City Detail Page** (`city_detail_page.dart`)
   - ✅ 按钮图标改为 `Icons.edit_note` (管理图标)
   - ✅ 只对 admin/版主显示

### ⏳ 待实现

#### 1. Reviews (`add_review_page.dart`)
需要添加:
- [ ] 数据加载功能
- [ ] 底部Tab显示已有reviews列表
- [ ] 删除按钮(admin/版主可见)
- [ ] 删除确认对话框
- [ ] 使用 `userContentController.deleteMyReview()`

#### 2. Cost (`add_cost_page.dart`)
需要添加:
- [ ] 数据加载功能
- [ ] 显示已有expenses列表
- [ ] 删除按钮(admin/版主可见)
- [ ] 删除确认对话框
- [ ] 使用 `userContentController.deleteExpense()`

#### 3. Photos (使用对话框,可能不需要改造)
- [ ] 评估是否需要单独的管理页面
- [ ] 如果需要,创建类似的列表页面

#### 4. Coworking (`add_coworking_page.dart`)
需要添加:
- [ ] 数据加载功能
- [ ] 显示已有coworking spaces列表
- [ ] 删除按钮(admin/版主可见)
- [ ] 删除确认对话框
- [ ] 后端需要添加删除API

## 实现模式 (参考 pros_and_cons_add_page.dart)

```dart
// 1. 状态变量
final RxBool canDelete = false.obs;
final RxBool isLoading = false.obs;
final RxList<dynamic> dataList = <dynamic>[].obs;

// 2. initState
@override
void initState() {
  super.initState();
  _checkPermissions();
  _loadData();
}

// 3. 权限检查
Future<void> _checkPermissions() async {
  final isAdmin = await TokenStorageService().isAdmin();
  canDelete.value = isAdmin;
}

// 4. 数据加载
Future<void> _loadData() async {
  isLoading.value = true;
  final controller = Get.find<Controller>();
  await controller.loadData(cityId);
  // 同步到本地列表
  dataList.value = controller.list.map(...).toList();
  isLoading.value = false;
}

// 5. 删除功能
Future<void> _deleteItem(String id) async {
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('确认删除'),
      content: const Text('确定要删除吗？'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('取消')),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('删除'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  final controller = Get.find<Controller>();
  final success = await controller.deleteItem(cityId, id);
  
  if (success) {
    Get.snackbar('成功', '已删除', backgroundColor: Colors.green[100]);
    await _loadData();
  }
}

// 6. 列表UI with删除按钮
ListView.builder(
  itemBuilder: (context, index) {
    final item = dataList[index];
    return Card(
      child: ListTile(
        title: Text(item['text']),
        trailing: canDelete.value
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteItem(item['id']),
              )
            : null,
      ),
    );
  },
)
```

## 优先级
1. 高: Reviews (用户评论很重要)
2. 中: Cost (费用信息管理)
3. 低: Coworking (需要先添加后端删除API)
4. 待定: Photos (对话框形式可能不需要)

## 后端需求
- [ ] Coworking 删除API (`DELETE /api/v1/cities/{cityId}/coworking/{id}`)
- [ ] 其他资源的逻辑删除字段和索引

---
更新时间: 2024-11-14
