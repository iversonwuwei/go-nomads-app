import 'dart:developer';

import 'package:go_nomads_app/features/meetup/domain/entities/event_type.dart';
import 'package:go_nomads_app/features/meetup/domain/repositories/i_event_type_repository.dart';
import 'package:go_nomads_app/features/meetup/infrastructure/repositories/event_type_repository.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:get/get.dart';

/// 事件类型状态控制器
/// 使用 GetX 进行全局状态管理，提供事件类型的缓存和加载功能
class EventTypeController extends GetxController {
  late final IEventTypeRepository _repository;

  // 可观察的状态
  final RxList<EventType> eventTypes = <EventType>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // 是否已经加载过数据（用于避免重复请求）
  bool _hasLoaded = false;

  @override
  void onInit() {
    super.onInit();
    _repository = EventTypeRepository(HttpService());
  }

  /// 加载事件类型列表
  /// [forceRefresh] 是否强制刷新，默认 false（使用缓存）
  Future<void> loadEventTypes({bool forceRefresh = false}) async {
    // 如果已经加载过且不强制刷新，直接返回
    if (_hasLoaded && !forceRefresh && eventTypes.isNotEmpty) {
      log('✅ 使用缓存的事件类型列表 (${eventTypes.length} 项)');
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      log('🔄 正在从后端加载事件类型列表...');
      final types = await _repository.getEventTypes();
      
      eventTypes.value = types;
      _hasLoaded = true;
      
      log('✅ 成功加载 ${types.length} 个事件类型');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      log('❌ 加载事件类型失败: $e');
      
      // 失败时使用后备方案（最小默认集合）
      _loadFallbackTypes();
    } finally {
      isLoading.value = false;
    }
  }

  /// 根据 ID 获取事件类型
  EventType? getEventTypeById(String id) {
    try {
      return eventTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 根据名称搜索事件类型（支持中英文）
  List<EventType> searchEventTypes(String query) {
    if (query.isEmpty) return eventTypes;
    
    final lowerQuery = query.toLowerCase();
    return eventTypes.where((type) {
      return type.name.toLowerCase().contains(lowerQuery) ||
          type.enName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 获取本地化的显示名称列表
  List<String> getDisplayNames(String locale) {
    return eventTypes.map((type) => type.getDisplayName(locale)).toList();
  }

  /// 清除缓存并重新加载
  @override
  Future<void> refresh() async {
    _hasLoaded = false;
    await loadEventTypes(forceRefresh: true);
  }

  /// 加载后备类型（当 API 失败时使用）
  void _loadFallbackTypes() {
    log('⚠️ 使用后备事件类型列表');
    
    // 创建最小的默认类型集合
    final fallbackTypes = [
      EventType(
        id: 'fallback-networking',
        name: '社交聚会',
        enName: 'Networking',
        sortOrder: 1,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      EventType(
        id: 'fallback-social',
        name: '休闲活动',
        enName: 'Social Gathering',
        sortOrder: 2,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      EventType(
        id: 'fallback-workshop',
        name: '工作坊',
        enName: 'Workshop',
        sortOrder: 3,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    eventTypes.value = fallbackTypes;
  }

  /// 重置状态
  void reset() {
    eventTypes.clear();
    isLoading.value = false;
    hasError.value = false;
    errorMessage.value = '';
    _hasLoaded = false;
  }
}
