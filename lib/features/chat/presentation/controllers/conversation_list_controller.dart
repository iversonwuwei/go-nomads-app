import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/tencent_im_api_service.dart';
import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/tencent_im_service.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';

/// 会话列表控制器 — 微信风格消息列表
/// 通过腾讯云IM的会话管理API获取所有C2C会话
class ConversationListController extends GetxController {
  static const int _pageSize = 20;

  // ==================== 状态 ====================

  /// 会话列表
  final conversations = <V2TimConversation>[].obs;

  /// 加载状态
  final isLoading = true.obs;

  /// 是否已初始化IM
  final isIMReady = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  /// 总未读消息数
  final totalUnreadCount = 0.obs;

  /// 错误信息
  final errorMessage = Rx<String?>(null);

  // ==================== 私有变量 ====================

  TencentIMService? _imService;
  Timer? _refreshTimer;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _conversationChangedSubscription;
  StreamSubscription? _newConversationSubscription;
  StreamSubscription? _syncFinishSubscription;
  Worker? _currentUserWorker;
  bool _isInitializing = false;
  String _nextSeq = '0';

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
    _conversationChangedSubscription?.cancel();
    _newConversationSubscription?.cancel();
    _syncFinishSubscription?.cancel();
    _currentUserWorker?.dispose();
    super.onClose();
  }

  // ==================== 初始化 ====================

  /// 初始化腾讯云IM并加载会话列表
  Future<void> _initIM() async {
    if (_isInitializing || isIMReady.value) {
      return;
    }

    try {
      _isInitializing = true;
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
        log('⏳ ConversationListController: 当前用户尚未加载，等待用户信息后重试');
        _waitForCurrentUser(authController);
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

      // 监听会话变更事件（实时更新列表）
      _setupConversationListeners();

      // 监听新消息以刷新列表
      _setupMessageListener();

      // 首次加载会话列表
      await loadConversations(forceRefresh: true);

      // SDK 登录后会话数据可能尚未从服务端同步完成，
      // 如果首次拉取为空，延迟 2 秒后重试一次
      if (conversations.isEmpty) {
        Future.delayed(const Duration(seconds: 2), () {
          if (conversations.isEmpty && _imService != null && _imService!.isLoggedIn) {
            log('💬 首次加载为空，延迟重新拉取会话列表');
            loadConversations(forceRefresh: true);
          }
        });
      }

      // 保底定期刷新（60秒，降低频率因为已有监听器实时更新）
      _refreshTimer = Timer.periodic(
        const Duration(seconds: 60),
        (_) => loadConversations(forceRefresh: true),
      );
    } catch (e) {
      log('❌ ConversationListController 初始化异常: $e');
      errorMessage.value = '初始化失败，请稍后重试';
      isLoading.value = false;
    } finally {
      _isInitializing = false;
    }
  }

  void _waitForCurrentUser(AuthStateController authController) {
    _currentUserWorker?.dispose();
    _currentUserWorker = ever(authController.currentUser, (user) {
      if (user != null) {
        log('✅ ConversationListController: 当前用户已就绪，继续初始化消息模块');
        _currentUserWorker?.dispose();
        _currentUserWorker = null;
        unawaited(_initIM());
      }
    });
  }

  // ==================== 会话监听 ====================

  /// 监听会话变更事件以实时更新列表
  /// - onSyncServerFinish: 服务端会话数据同步完成，此时拉取最完整
  /// - onNewConversation: 有新会话产生（自己发起的或别人发来新对话）
  /// - onConversationChanged: 已有会话内容变更（新消息、已读变更等）
  void _setupConversationListeners() {
    if (_imService == null) return;

    _syncFinishSubscription = _imService!.onSyncServerFinish.listen((_) {
      log('💬 ConversationList: 服务端同步完成，刷新列表');
      loadConversations(forceRefresh: true);
    });

    _newConversationSubscription = _imService!.onNewConversation.listen((_) {
      log('💬 ConversationList: 新会话，刷新列表');
      loadConversations(forceRefresh: true);
    });

    _conversationChangedSubscription = _imService!.onConversationChanged.listen((_) {
      log('💬 ConversationList: 会话变更，刷新列表');
      loadConversations(forceRefresh: true);
    });
  }

  // ==================== 数据加载 ====================

  /// 加载会话列表（只显示与当前用户聊过天的会话）
  Future<void> loadConversations({bool forceRefresh = false}) async {
    if (_imService == null || !_imService!.isLoggedIn) {
      return;
    }

    if (forceRefresh) {
      isLoading.value = true;
      _nextSeq = '0';
      hasMore.value = true;
    } else {
      if (isLoadingMore.value || !hasMore.value) {
        return;
      }
      isLoadingMore.value = true;
    }

    try {
      final page = await _imService!.getConversationPage(
        count: _pageSize,
        nextSeq: _nextSeq,
      );

      final convList = page.conversations;
      _nextSeq = page.nextSeq;
      hasMore.value = !page.isFinished && page.nextSeq != '0';

      // 按最后消息时间倒序排列
      convList.sort((a, b) {
        final aTime = a.lastMessage?.timestamp ?? 0;
        final bTime = b.lastMessage?.timestamp ?? 0;
        return bTime.compareTo(aTime);
      });

      if (forceRefresh) {
        conversations.value = convList;
      } else {
        final existingIds = conversations.map((item) => item.conversationID).toSet();
        final appended = convList.where((item) => !existingIds.contains(item.conversationID)).toList();
        conversations.addAll(appended);
        conversations.sort((a, b) {
          final aTime = a.lastMessage?.timestamp ?? 0;
          final bTime = b.lastMessage?.timestamp ?? 0;
          return bTime.compareTo(aTime);
        });
        hasMore.value = hasMore.value && appended.isNotEmpty;
      }

      // 计算总未读数
      int unread = 0;
      for (final conv in conversations) {
        unread += conv.unreadCount ?? 0;
      }
      totalUnreadCount.value = unread;

      errorMessage.value = null;
    } catch (e) {
      log('❌ 加载会话列表异常: $e');
    } finally {
      if (forceRefresh) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMoreConversations() async {
    await loadConversations(forceRefresh: false);
  }

  /// 下拉刷新
  Future<void> onRefresh() async {
    await loadConversations(forceRefresh: true);
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
    await loadConversations(forceRefresh: true);
  }

  // ==================== 消息监听 ====================

  /// 监听新消息以自动刷新列表
  void _setupMessageListener() {
    if (_imService == null) return;

    _messageSubscription = _imService!.onNewMessage.listen((_) {
      log('💬 ConversationList: 收到新消息，刷新列表');
      loadConversations(forceRefresh: true);
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
