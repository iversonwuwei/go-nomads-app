import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/tencent_im_service.dart';
import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/tencent_im_api_service.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';

/// 会话列表控制器 — 微信风格消息列表
/// 通过腾讯云IM的会话管理API获取所有C2C会话
class ConversationListController extends GetxController {
  // ==================== 状态 ====================

  /// 会话列表
  final conversations = <V2TimConversation>[].obs;

  /// 加载状态
  final isLoading = true.obs;

  /// 是否已初始化IM
  final isIMReady = false.obs;

  /// 总未读消息数
  final totalUnreadCount = 0.obs;

  /// 错误信息
  final errorMessage = Rx<String?>(null);

  // ==================== 私有变量 ====================

  TencentIMService? _imService;
  Timer? _refreshTimer;
  StreamSubscription? _messageSubscription;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    log('💬 ConversationListController: onInit');
    _initIM();
  }

  @override
  void onClose() {
    log('💬 ConversationListController: onClose');
    _refreshTimer?.cancel();
    _messageSubscription?.cancel();
    super.onClose();
  }

  // ==================== 初始化 ====================

  /// 初始化腾讯云IM并加载会话列表
  Future<void> _initIM() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // 获取当前用户
      final authController = Get.find<AuthStateController>();
      if (!authController.isAuthenticated.value) {
        errorMessage.value = '请先登录';
        isLoading.value = false;
        return;
      }

      final currentUser = authController.currentUser.value;
      if (currentUser == null) {
        errorMessage.value = '用户信息不可用';
        isLoading.value = false;
        return;
      }

      // 获取或创建 TencentIMService
      if (!Get.isRegistered<TencentIMService>()) {
        _imService = Get.put(TencentIMService(), permanent: true);
      } else {
        _imService = Get.find<TencentIMService>();
      }

      // 初始化SDK
      final sdkReady = await _imService!.initSDK();
      if (!sdkReady) {
        errorMessage.value = 'IM SDK 初始化失败';
        isLoading.value = false;
        return;
      }

      // 确保用户存在并登录
      final apiService = TencentIMApiService();
      await apiService.ensureUserExists();
      await _imService!.login(currentUser.id);

      isIMReady.value = true;

      // 加载会话列表
      await loadConversations();

      // 监听新消息以刷新列表
      _setupMessageListener();

      // 定期刷新（30秒）
      _refreshTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => loadConversations(),
      );
    } catch (e) {
      log('❌ ConversationListController 初始化异常: $e');
      errorMessage.value = '初始化失败，请稍后重试';
      isLoading.value = false;
    }
  }

  // ==================== 数据加载 ====================

  /// 加载会话列表
  Future<void> loadConversations() async {
    if (_imService == null || !_imService!.isLoggedIn) {
      return;
    }

    try {
      final list = await _imService!.getConversationList(count: 100);

      // 按最后消息时间排序（最新在前）
      list.sort((a, b) {
        final aTime = a.lastMessage?.timestamp ?? 0;
        final bTime = b.lastMessage?.timestamp ?? 0;
        return bTime.compareTo(aTime);
      });

      conversations.value = list;

      // 计算总未读数
      int unread = 0;
      for (final conv in list) {
        unread += conv.unreadCount ?? 0;
      }
      totalUnreadCount.value = unread;

      errorMessage.value = null;
    } catch (e) {
      log('❌ 加载会话列表异常: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 下拉刷新
  Future<void> onRefresh() async {
    await loadConversations();
  }

  // ==================== 会话操作 ====================

  /// 删除会话
  Future<void> deleteConversation(String conversationId) async {
    if (_imService == null) return;

    final success = await _imService!.deleteConversation(conversationId);
    if (success) {
      conversations.removeWhere((c) => c.conversationID == conversationId);
      log('✅ 删除会话成功: $conversationId');
    }
  }

  /// 标记会话已读
  Future<void> markAsRead(String userId) async {
    if (_imService == null) return;

    await _imService!.markC2CMessageAsRead(userId);
    // 刷新列表以更新未读数
    await loadConversations();
  }

  // ==================== 消息监听 ====================

  /// 监听新消息以自动刷新列表
  void _setupMessageListener() {
    if (_imService == null) return;

    _messageSubscription = _imService!.onNewMessage.listen((_) {
      log('💬 ConversationList: 收到新消息，刷新列表');
      loadConversations();
    });
  }

  /// 从 conversationID 中提取 userId
  /// 格式: c2c_user_xxx -> xxx
  String? extractUserId(String? conversationId) {
    if (conversationId == null) return null;
    // conversationID 格式: c2c_user_{uuid}
    if (conversationId.startsWith('c2c_user_')) {
      return conversationId.substring('c2c_user_'.length);
    }
    if (conversationId.startsWith('c2c_')) {
      return conversationId.substring('c2c_'.length);
    }
    return null;
  }
}
