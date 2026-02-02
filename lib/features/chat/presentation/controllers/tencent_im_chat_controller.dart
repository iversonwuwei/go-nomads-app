import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/tencent_im.dart';
import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/tencent_im_api_service.dart';

/// 腾讯云IM私聊控制器
/// 用于DirectChatPage的消息管理
class TencentIMChatController extends GetxController {
  final TencentIMService _imService;
  late final TencentIMApiService _imApiService;

  // 目标用户信息
  String? _targetUserId;
  String? _targetUserName;
  String? _targetUserAvatar;

  // 状态
  final _isLoading = false.obs;
  final _isSending = false.obs;
  final _messages = <V2TimMessage>[].obs;
  final _replyTo = Rx<V2TimMessage?>(null);
  final _receiverImported = false.obs;

  bool get isLoading => _isLoading.value;
  bool get isSending => _isSending.value;
  List<V2TimMessage> get messages => _messages;
  V2TimMessage? get replyTo => _replyTo.value;
  String? get targetUserId => _targetUserId;
  String? get targetUserName => _targetUserName;
  String? get targetUserAvatar => _targetUserAvatar;
  bool get receiverImported => _receiverImported.value;

  StreamSubscription? _msgSubscription;

  TencentIMChatController(this._imService) {
    // 初始化API服务（使用单例模式）
    _imApiService = TencentIMApiService();
  }

  @override
  void onInit() {
    super.onInit();
    _listenMessages();
  }

  /// 监听新消息
  void _listenMessages() {
    _msgSubscription = _imService.onNewMessage.listen((message) {
      log('📩 收到消息 sender=${message.sender}, target=$_targetUserId, isSelf=${message.isSelf}');
      // 处理来自对方的消息（需要比较格式化后的ID）
      final formattedTargetId = TencentIMService.formatUserId(_targetUserId ?? '');
      if (message.sender == formattedTargetId) {
        _messages.insert(0, message);
        _messages.refresh();
        log('✅ 消息已添加到列表');
      }
    });
  }

  /// 检查接收方用户是否存在于IM系统
  Future<bool> checkReceiverExists() async {
    return _receiverImported.value;
  }

  /// 开始私聊
  Future<bool> startChat({
    required String userId,
    String? userName,
    String? userAvatar,
  }) async {
    _targetUserId = userId;
    _targetUserName = userName;
    _targetUserAvatar = userAvatar;
    _isLoading.value = true;

    try {
      // 确保SDK已初始化
      if (!_imService.isInitialized) {
        log('🔧 SDK未初始化，正在初始化...');
        await _imService.initSDK();
      }

      // 确保当前用户已登录IM
      if (!_imService.isLoggedIn) {
        final auth = Get.find<AuthStateController>();
        final currentUser = auth.currentUser.value;
        if (currentUser != null) {
          log('🔐 正在登录IM: ${currentUser.id}');

          // 先通过后端API确保当前用户存在于IM系统
          // 后端会从JWT Token的UserContext获取用户ID，并从UserService获取用户详情
          final ensureResult = await _imApiService.ensureUserExists(
            nickname: currentUser.name,
            avatarUrl: currentUser.avatar,
          );

          if (ensureResult == null) {
            log('⚠️ 无法确保当前用户存在于IM系统，尝试继续登录...');
          }

          await _imService.login(currentUser.id);
        }
      }

      // 通过后端API确保接收方用户存在于IM系统
      log('🔄 确保接收方用户存在于IM系统: $userId');
      final imported = await _imApiService.importUser(
        userId: userId,
        nickname: userName,
        avatarUrl: userAvatar,
      );
      _receiverImported.value = imported;

      if (!imported) {
        log('⚠️ 无法将接收方用户导入IM系统');
      }

      // 加载历史消息
      await _loadHistoryMessages();

      // 标记已读
      await _imService.markC2CMessageAsRead(userId);

      return true;
    } catch (e) {
      log('❌ 开始聊天失败: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 加载历史消息
  Future<void> _loadHistoryMessages() async {
    if (_targetUserId == null) return;

    final historyMessages = await _imService.getC2CHistoryMessages(
      userId: _targetUserId!,
      count: 20,
    );
    _messages.value = historyMessages;
    log('✅ 加载了 ${historyMessages.length} 条历史消息');
  }

  /// 加载更多历史消息
  Future<void> loadMoreMessages() async {
    if (_targetUserId == null || _messages.isEmpty) return;

    final moreMessages = await _imService.getC2CHistoryMessages(
      userId: _targetUserId!,
      count: 20,
      lastMsg: _messages.last,
    );
    _messages.addAll(moreMessages);
  }

  /// 发送文本消息
  Future<bool> sendTextMessage(String text) async {
    if (_targetUserId == null || text.trim().isEmpty) return false;
    _isSending.value = true;

    try {
      log('📤 发送文本消息: $text -> $_targetUserId');
      final msg = await _imService.sendC2CTextMessage(
        userId: _targetUserId!,
        text: text,
      );

      if (msg != null) {
        log('✅ 消息发送成功，msgID=${msg.msgID}');
        _messages.insert(0, msg);
        _messages.refresh();
        _replyTo.value = null;
        return true;
      } else {
        log('❌ 消息发送返回null');
        return false;
      }
    } catch (e) {
      log('❌ 发送异常: $e');
      return false;
    } finally {
      _isSending.value = false;
    }
  }

  /// 发送图片消息
  Future<bool> sendImageMessage(String imagePath) async {
    if (_targetUserId == null) return false;
    _isSending.value = true;

    try {
      log('📤 发送图片消息: $imagePath');
      final msg = await _imService.sendC2CImageMessage(
        userId: _targetUserId!,
        imagePath: imagePath,
      );
      if (msg != null) {
        _messages.insert(0, msg);
        _messages.refresh();
        return true;
      }
      return false;
    } finally {
      _isSending.value = false;
    }
  }

  /// 发送语音消息
  Future<bool> sendVoiceMessage(String soundPath, int duration) async {
    if (_targetUserId == null) return false;
    _isSending.value = true;

    try {
      log('📤 发送语音消息: ${duration}s');
      final msg = await _imService.sendC2CVoiceMessage(
        userId: _targetUserId!,
        soundPath: soundPath,
        duration: duration,
      );
      if (msg != null) {
        _messages.insert(0, msg);
        _messages.refresh();
        return true;
      }
      return false;
    } finally {
      _isSending.value = false;
    }
  }

  /// 发送文件消息
  Future<bool> sendFileMessage(String filePath, String fileName) async {
    if (_targetUserId == null) return false;
    _isSending.value = true;

    try {
      log('📤 发送文件消息: $fileName');
      final msg = await _imService.sendC2CFileMessage(
        userId: _targetUserId!,
        filePath: filePath,
        fileName: fileName,
      );
      if (msg != null) {
        _messages.insert(0, msg);
        _messages.refresh();
        return true;
      }
      return false;
    } finally {
      _isSending.value = false;
    }
  }

  /// 发送表情消息
  Future<bool> sendFaceMessage(int index, String data) async {
    if (_targetUserId == null) return false;
    _isSending.value = true;

    try {
      log('📤 发送表情消息: index=$index');
      final msg = await _imService.sendC2CFaceMessage(
        userId: _targetUserId!,
        index: index,
        data: data,
      );
      if (msg != null) {
        _messages.insert(0, msg);
        _messages.refresh();
        return true;
      }
      return false;
    } finally {
      _isSending.value = false;
    }
  }

  /// 设置回复消息
  void setReplyTo(V2TimMessage? message) {
    _replyTo.value = message;
  }

  /// 清除回复
  void clearReply() {
    _replyTo.value = null;
  }

  /// 结束聊天
  void endChat() {
    _targetUserId = null;
    _messages.clear();
    _replyTo.value = null;
  }

  @override
  void onClose() {
    _msgSubscription?.cancel();
    endChat();
    super.onClose();
  }
}
