import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart' as models;
import 'package:go_nomads_app/features/chat/presentation/controllers/tencent_im_chat_controller.dart';
import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/tencent_im.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/chat_voice.dart';
import 'package:image_picker/image_picker.dart';

/// 腾讯云IM私聊页面
class TencentIMDirectChatPage extends StatefulWidget {
  final models.User user;

  const TencentIMDirectChatPage({super.key, required this.user});

  @override
  State<TencentIMDirectChatPage> createState() => _TencentIMDirectChatPageState();
}

class _TencentIMDirectChatPageState extends State<TencentIMDirectChatPage> {
  late final TencentIMChatController _controller;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isConnecting = true;
  bool _isVoiceMode = false;
  bool _showEmojiPanel = false;

  // 表情列表
  static const List<String> _emojis = [
    '😀',
    '😁',
    '😂',
    '🤣',
    '😃',
    '😄',
    '😅',
    '😆',
    '😉',
    '😊',
    '😋',
    '😎',
    '😍',
    '😘',
    '🥰',
    '😗',
    '😙',
    '😚',
    '🙂',
    '🤗',
    '🤩',
    '🤔',
    '🤨',
    '😐',
    '😑',
    '😶',
    '🙄',
    '😏',
    '😣',
    '😥',
    '😮',
    '🤐',
    '😯',
    '😪',
    '😫',
    '🥱',
    '😴',
    '😌',
    '😛',
    '😜',
    '😝',
    '🤤',
    '😒',
    '😓',
    '😔',
    '😕',
    '🙃',
    '🤑',
    '👍',
    '👎',
    '👏',
    '🙌',
    '🤝',
    '❤️',
    '🔥',
    '✨',
  ];

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final imService = Get.find<TencentIMService>();
    _controller = Get.put(TencentIMChatController(imService));

    final success = await _controller.startChat(
      userId: widget.user.id,
      userName: widget.user.name,
      userAvatar: widget.user.avatarUrl,
    );

    if (mounted) {
      setState(() => _isConnecting = false);
      if (!success) {
        AppToast.error('连接失败，请重试');
      } else if (!_controller.receiverImported) {
        // 如果后端API导入失败，显示警告
        AppToast.warning('用户导入失败，消息可能无法送达');
      }
    }
  }

  @override
  void dispose() {
    _controller.endChat();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnecting) {
      return _buildLoadingView();
    }
    return _buildChatView();
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(widget.user.name),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF3838)),
      ),
    );
  }

  Widget _buildChatView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
          if (_showEmojiPanel) _buildEmojiPanel(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const AppBackButton(),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: widget.user.avatarUrl != null ? NetworkImage(widget.user.avatarUrl!) : null,
            child: widget.user.avatarUrl == null ? Text(widget.user.name[0].toUpperCase()) : null,
          ),
          const SizedBox(width: 10),
          Text(
            widget.user.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      final messages = _controller.messages;
      if (messages.isEmpty) {
        return const Center(
          child: Text('暂无消息', style: TextStyle(color: Colors.grey)),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return _buildMessageBubble(messages[index]);
        },
      );
    });
  }

  Widget _buildMessageBubble(V2TimMessage message) {
    final isSelf = message.isSelf ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSelf) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.user.avatarUrl != null ? NetworkImage(widget.user.avatarUrl!) : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelf ? const Color(0xFFFF3838) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMessageContent(message, isSelf),
            ),
          ),
          if (isSelf) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageContent(V2TimMessage message, bool isSelf) {
    final textColor = isSelf ? Colors.white : Colors.black87;

    switch (message.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return Text(
          message.textElem?.text ?? '',
          style: TextStyle(fontSize: 15, color: textColor),
        );

      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        final imageUrl = message.imageElem?.imageList?.first?.url;
        if (imageUrl != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 150,
              fit: BoxFit.cover,
            ),
          );
        }
        return Text('[图片]', style: TextStyle(color: textColor));

      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        final duration = message.soundElem?.duration ?? 0;
        return GestureDetector(
          onTap: () => _playVoice(message),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FontAwesomeIcons.microphone, size: 14, color: textColor),
              const SizedBox(width: 8),
              Text('$duration"', style: TextStyle(color: textColor)),
            ],
          ),
        );

      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        final fileName = message.fileElem?.fileName ?? '文件';
        return GestureDetector(
          onTap: () => _openFile(message),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FontAwesomeIcons.file, size: 14, color: textColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  fileName,
                  style: TextStyle(color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        final data = message.faceElem?.data ?? '';
        return Text(data, style: const TextStyle(fontSize: 32));

      default:
        return Text('[消息]', style: TextStyle(color: textColor));
    }
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          // 语音/键盘切换
          IconButton(
            icon: Icon(
              _isVoiceMode ? FontAwesomeIcons.keyboard : FontAwesomeIcons.microphone,
              size: 20,
            ),
            color: const Color(0xFF666666),
            onPressed: () => setState(() => _isVoiceMode = !_isVoiceMode),
          ),
          // 输入区域
          Expanded(
            child: _isVoiceMode ? _buildVoiceButton() : _buildTextInput(),
          ),
          // 表情按钮
          IconButton(
            icon: Icon(
              _showEmojiPanel ? FontAwesomeIcons.keyboard : FontAwesomeIcons.faceSmile,
              size: 20,
            ),
            color: const Color(0xFF666666),
            onPressed: () => setState(() => _showEmojiPanel = !_showEmojiPanel),
          ),
          // 更多按钮（图片、文件）
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus, size: 20),
            color: const Color(0xFF666666),
            onPressed: _showMoreOptions,
          ),
          // 发送按钮
          if (!_isVoiceMode && _messageController.text.trim().isNotEmpty)
            GestureDetector(
              onTap: () => _sendTextMessage(_messageController.text),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3838),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  FontAwesomeIcons.paperPlane,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _messageController,
      decoration: InputDecoration(
        hintText: '输入消息...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onChanged: (_) => setState(() {}),
      onSubmitted: _sendTextMessage,
    );
  }

  Widget _buildVoiceButton() {
    return ChatVoiceRecorderButton(
      onSendVoice: (path, duration) {
        _controller.sendVoiceMessage(path, duration);
      },
    );
  }

  Widget _buildEmojiPanel() {
    return Container(
      height: 200,
      color: Colors.white,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _emojis.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _insertEmoji(_emojis[index]),
            child: Center(
              child: Text(_emojis[index], style: const TextStyle(fontSize: 24)),
            ),
          );
        },
      ),
    );
  }

  void _insertEmoji(String emoji) {
    final text = _messageController.text;
    final selection = _messageController.selection;

    // 如果selection无效（TextField没有焦点），直接在末尾插入
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, emoji);
    _messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
    setState(() {});
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  icon: FontAwesomeIcons.image,
                  label: '图片',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                _buildOptionButton(
                  icon: FontAwesomeIcons.camera,
                  label: '拍照',
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                _buildOptionButton(
                  icon: FontAwesomeIcons.file,
                  label: '文件',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFile();
                  },
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF666666)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _sendTextMessage(String text) {
    if (text.trim().isEmpty) return;
    _controller.sendTextMessage(text);
    _messageController.clear();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _controller.sendImageMessage(image.path);
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _controller.sendImageMessage(image.path);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      await _controller.sendFileMessage(file.path!, file.name);
    }
  }

  void _playVoice(V2TimMessage message) {
    // TODO: 实现语音播放
    AppToast.info('播放语音');
  }

  void _openFile(V2TimMessage message) {
    // TODO: 实现文件打开
    AppToast.info('打开文件');
  }
}
