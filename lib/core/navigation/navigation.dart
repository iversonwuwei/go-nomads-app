/// 统一导航和刷新模块
///
/// 提供页面间导航、数据传递和刷新的统一解决方案
///
/// ## 核心组件
///
/// - [NavigationResult]: 统一的导航结果模型
/// - [IRefreshableList]: 可刷新列表接口
/// - [NavigationUtil]: 导航工具类，提供跳转和返回方法
///
/// ## 设计理念
///
/// 使用泛型和接口（而非 Mixin）来减少重复代码：
/// - Controller 实现 `IRefreshableList<T>` 接口
/// - NavigationUtil 自动根据返回值类型处理刷新逻辑
///
/// ## 使用示例
///
/// ### 1. 列表页 Controller 实现接口
/// ```dart
/// class MyMeetupsController extends GetxController
///     implements IRefreshableList<Meetup> {
///   final RxList<Meetup> meetups = <Meetup>[].obs;
///
///   @override
///   String getItemId(Meetup item) => item.id;
///
///   @override
///   Future<void> refreshList() => loadMeetups();
///
///   @override
///   void addItem(Meetup item) => meetups.insert(0, item);
///
///   @override
///   void updateItem(Meetup item) {
///     final idx = meetups.indexWhere((m) => m.id == item.id);
///     if (idx != -1) meetups[idx] = item;
///   }
///
///   @override
///   void removeItemById(String id) => meetups.removeWhere((m) => m.id == id);
/// }
/// ```
///
/// ### 2. 列表页跳转（自动处理刷新）
/// ```dart
/// // 一行代码完成跳转和刷新处理！
/// await NavigationUtil.toAndRefresh<Meetup>(
///   page: () => CreateMeetupPage(),
///   refresher: controller, // 实现了 IRefreshableList<Meetup>
/// );
/// ```
///
/// ### 3. 详情页返回
/// ```dart
/// NavigationUtil.backFromDetail<Meetup>(
///   entity: meetup.value,
///   hasChanged: hasDataChanged.value,
///   context: context,
/// );
/// ```
///
/// ### 4. 创建/编辑页返回
/// ```dart
/// // 创建成功
/// await NavigationUtil.backAfterSave(newMeetup, isNew: true, context: context);
///
/// // 编辑成功
/// await NavigationUtil.backAfterSave(updatedMeetup, isNew: false, context: context);
///
/// // 只需要刷新
/// await NavigationUtil.backWithRefresh(context: context);
/// ```
///
/// ### 5. 删除后返回
/// ```dart
/// await NavigationUtil.backAfterDelete(entityId: meetup.id, context: context);
/// ```
///
/// ## 自动处理逻辑
///
/// 当使用 `toAndRefresh` 时，NavigationUtil 会根据返回值自动执行：
/// - `NavigationResult.created(entity)` → `refresher.addItem(entity)`
/// - `NavigationResult.updated(entity)` → `refresher.updateItem(entity)`
/// - `NavigationResult.deleted(entityId)` → `refresher.removeItemById(entityId)`
/// - `NavigationResult.forceRefresh()` → `refresher.refreshList()`
/// - 旧式 `true` / `entity` / `'deleted'` → 自动转换并处理
library;

export 'navigation_result.dart';
