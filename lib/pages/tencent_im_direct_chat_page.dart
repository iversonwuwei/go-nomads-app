import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/tencent_im.dart';
import 'package:go_nomads_app/features/chat/presentation/controllers/tencent_im_chat_controller.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart' as models;
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/chat_voice.dart';
import 'package:go_nomads_app/widgets/report_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';

import 'member_detail_page.dart';

/// 上传中的图片信息
class _UploadingImage {
  final String id;
  final String localPath;
  double progress;
  String? errorMessage;

  _UploadingImage({
    required this.id,
    required this.localPath,
    this.progress = 0,
  });
}

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
  final _inputScrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _isConnecting = true;
  bool _isVoiceMode = false;
  bool _showEmojiPanel = false;

  /// 上传中的图片列表（参考群聊实现，提供本地预览 + 进度遮罩）
  final List<_UploadingImage> _uploadingImages = [];

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
    _focusNode.addListener(_onFocusChange);
    _initController();
  }

  /// 表情面板打开时，输入框获得焦点后自动隐藏系统键盘（保留焦点和光标）
  void _onFocusChange() {
    if (_focusNode.hasFocus && _showEmojiPanel) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
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
    _focusNode.removeListener(_onFocusChange);
    _controller.endChat();
    _messageController.dispose();
    _scrollController.dispose();
    _inputScrollController.dispose();
    _focusNode.dispose();
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
          Expanded(
            child: GestureDetector(
              onTap: () {
                // 点击消息列表：关闭键盘 + 关闭表情面板
                _focusNode.unfocus();
                if (_showEmojiPanel) {
                  setState(() => _showEmojiPanel = false);
                }
              },
              child: _buildMessageList(),
            ),
          ),
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
      title: GestureDetector(
        onTap: () {
          Get.to(() => MemberDetailPage(user: widget.user));
        },
        child: Row(
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
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(FontAwesomeIcons.ellipsisVertical, color: Colors.black),
          onSelected: (value) {
            if (value == 'report') {
              ReportDialog.show(
                context: context,
                contentType: ReportContentType.user,
                targetId: widget.user.id,
                targetName: widget.user.name,
              );
            }
          },
          itemBuilder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.flag, size: 20, color: Colors.orange),
                    const SizedBox(width: 12),
                    Text(l10n.reportUser, style: const TextStyle(color: Colors.orange)),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      final messages = _controller.messages;
      final totalCount = messages.length + _uploadingImages.length;

      if (totalCount == 0) {
        return const Center(
          child: Text('暂无消息', style: TextStyle(color: Colors.grey)),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.all(16),
        itemCount: totalCount,
        itemBuilder: (context, index) {
          // 先显示上传中的图片（在最底部/最新位置）
          if (index < _uploadingImages.length) {
            final uploadingImage = _uploadingImages[_uploadingImages.length - 1 - index];
            return _buildUploadingImageBubble(uploadingImage);
          }
          // 然后显示已发送的消息
          final messageIndex = index - _uploadingImages.length;
          return _buildMessageBubble(messages[messageIndex]);
        },
      );
    });
  }

  Widget _buildMessageBubble(V2TimMessage message) {
    final isSelf = message.isSelf ?? false;
    final isImage = message.elemType == MessageElemType.V2TIM_ELEM_TYPE_IMAGE;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSelf) ...[
            GestureDetector(
              onTap: () {
                Get.to(() => MemberDetailPage(user: widget.user));
              },
              child: CircleAvatar(
                radius: 16,
                backgroundImage: widget.user.avatarUrl != null ? NetworkImage(widget.user.avatarUrl!) : null,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            // 图片消息不需要气泡背景，直接渲染
            child: isImage
                ? _buildMessageContent(message, isSelf)
                : Container(
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
        return _buildImageMessage(message);

      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        final duration = message.soundElem?.duration ?? 0;
        final soundUrl = message.soundElem?.url ?? '';
        return ChatVoiceMessageSimple(
          voiceUrl: soundUrl,
          duration: duration,
          isMe: isSelf,
          textColor: textColor,
          iconColor: isSelf ? Colors.white70 : const Color(0xFFFF3838),
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

  /// 图片消息 — 参考群聊实现，支持加载状态、错误状态、点击全屏查看
  Widget _buildImageMessage(V2TimMessage message) {
    final imageUrl = message.imageElem?.imageList?.first?.url;
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Text('[图片]', style: TextStyle(color: Colors.black87));
    }

    return GestureDetector(
      onTap: () => _showFullScreenImage(imageUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 200,
            maxHeight: 300,
          ),
          child: _buildNetworkImage(imageUrl),
        ),
      ),
    );
  }

  /// 构建网络图片（加载时显示灰色占位框）— 参考群聊 _buildNetworkImage
  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        // 显示灰色占位框，带图片图标
        return Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              FontAwesomeIcons.image,
              color: Colors.grey,
              size: 40,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.image, color: Colors.grey, size: 40),
              SizedBox(height: 8),
              Text('加载失败', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }

  /// 显示全屏图片
  void _showFullScreenImage(String imageUrl) {
    Get.to(
      () => _FullScreenImageViewer(imagePath: imageUrl),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 200),
    );
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
            onPressed: () {
              setState(() {
                _isVoiceMode = !_isVoiceMode;
                if (_isVoiceMode) {
                  // 切换到语音：关闭键盘 + 关闭表情面板
                  _showEmojiPanel = false;
                  _focusNode.unfocus();
                } else {
                  // 切换回文字：弹出键盘
                  _focusNode.requestFocus();
                }
              });
            },
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
            onPressed: () {
              if (_showEmojiPanel) {
                // 表情面板 → 键盘：显示系统键盘
                setState(() => _showEmojiPanel = false);
                if (_focusNode.hasFocus) {
                  SystemChannels.textInput.invokeMethod('TextInput.show');
                } else {
                  _focusNode.requestFocus();
                }
              } else {
                // 键盘/空闲 → 表情面板：隐藏键盘但保留焦点（光标位置不丢失）
                setState(() {
                  _showEmojiPanel = true;
                  _isVoiceMode = false;
                });
                if (_focusNode.hasFocus) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                } else {
                  _focusNode.requestFocus();
                  // _onFocusChange 会在获得焦点后自动隐藏键盘
                }
              }
            },
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
      focusNode: _focusNode,
      scrollController: _inputScrollController,
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
      onTap: () {
        // 点击输入框：关闭表情面板，显示系统键盘
        if (_showEmojiPanel) {
          setState(() => _showEmojiPanel = false);
        }
        SystemChannels.textInput.invokeMethod('TextInput.show');
      },
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
      height: 260,
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

    // 焦点保留在 TextField 上，selection 始终有效
    final start = selection.baseOffset >= 0 ? selection.start : text.length;
    final end = selection.baseOffset >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, emoji);
    final newCursorPos = start + emoji.length;

    _messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
    setState(() {});

    // 确保输入框滚动到光标位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_inputScrollController.hasClients) {
        _inputScrollController.jumpTo(_inputScrollController.position.maxScrollExtent);
      }
    });
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

  Future<void> _sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;
    final success = await _controller.sendTextMessage(text);
    if (success) {
      _messageController.clear();
    }
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _sendImage(image.path);
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _sendImage(image.path);
    }
  }

  /// 发送图片 — 参考群聊实现，先显示本地预览 + 进度遮罩，SDK完成后无缝切换
  Future<void> _sendImage(String imagePath) async {
    final uploadId = DateTime.now().millisecondsSinceEpoch.toString();
    final uploadingImage = _UploadingImage(
      id: uploadId,
      localPath: imagePath,
      progress: 0,
    );

    // 添加到上传列表，显示在聊天中
    setState(() {
      _uploadingImages.add(uploadingImage);
    });

    // 模拟进度更新（腾讯IM SDK 不支持进度回调）
    _simulateUploadProgress(uploadId);

    try {
      final success = await _controller.sendImageMessage(imagePath);
      if (success) {
        // 获取刚发送的消息的图片URL，预加载网络图片
        final messages = _controller.messages;
        if (messages.isNotEmpty) {
          final latestMsg = messages.first;
          final imageUrl = latestMsg.imageElem?.imageList?.first?.url;
          if (imageUrl != null && mounted) {
            _preloadAndRemoveUploadingImage(imageUrl, uploadId);
            return;
          }
        }
      }
      // 发送失败或无法获取URL，标记错误
      if (mounted) {
        setState(() {
          final index = _uploadingImages.indexWhere((img) => img.id == uploadId);
          if (index != -1) {
            _uploadingImages[index].errorMessage = '发送失败';
            _uploadingImages[index].progress = 0;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final index = _uploadingImages.indexWhere((img) => img.id == uploadId);
          if (index != -1) {
            _uploadingImages[index].errorMessage = '发送失败';
            _uploadingImages[index].progress = 0;
          }
        });
      }
    }
  }

  /// 模拟上传进度（因为 SDK 不支持进度回调）
  void _simulateUploadProgress(String uploadId) {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));

      final index = _uploadingImages.indexWhere((img) => img.id == uploadId);
      if (index == -1) return false; // 已完成或已移除

      if (_uploadingImages[index].progress < 0.9) {
        if (mounted) {
          setState(() {
            _uploadingImages[index].progress += 0.1;
          });
        }
        return true;
      }
      return false;
    });
  }

  /// 预加载网络图片，加载完成后移除上传中的预览
  void _preloadAndRemoveUploadingImage(String imageUrl, String uploadId) {
    final imageProvider = NetworkImage(imageUrl);
    precacheImage(imageProvider, context).then((_) {
      if (mounted) {
        setState(() {
          _uploadingImages.removeWhere((img) => img.id == uploadId);
        });
      }
    }).catchError((_) {
      // 预加载失败，仍然移除（网络图片会显示自己的加载状态）
      if (mounted) {
        setState(() {
          _uploadingImages.removeWhere((img) => img.id == uploadId);
        });
      }
    });
  }

  /// 重试上传失败的图片
  void _retryUpload(_UploadingImage uploadingImage) {
    setState(() {
      _uploadingImages.removeWhere((img) => img.id == uploadingImage.id);
    });
    _sendImage(uploadingImage.localPath);
  }

  /// 移除上传失败的图片
  void _removeUploadingImage(String uploadId) {
    setState(() {
      _uploadingImages.removeWhere((img) => img.id == uploadId);
    });
  }

  /// 构建上传中图片的气泡 — 参考群聊 _buildUploadingImageBubble
  Widget _buildUploadingImageBubble(_UploadingImage uploadingImage) {
    final hasError = uploadingImage.errorMessage != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 200,
                    maxHeight: 200,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3838).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // 本地图片预览
                        Image.file(
                          File(uploadingImage.localPath),
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                        ),
                        // 上传进度遮罩
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: hasError ? 0.6 : 0.4),
                            child: Center(
                              child: hasError
                                  ? _buildUploadErrorOverlay(uploadingImage)
                                  : _buildUploadProgressOverlay(uploadingImage),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasError ? uploadingImage.errorMessage! : '发送中...',
                  style: TextStyle(
                    fontSize: 11,
                    color: hasError ? const Color(0xFFFF3838) : const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            hasError ? FontAwesomeIcons.circleExclamation : FontAwesomeIcons.cloudArrowUp,
            size: 16,
            color: hasError
                ? const Color(0xFFFF3838).withValues(alpha: 0.8)
                : const Color(0xFFFF3838).withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  /// 构建上传进度遮罩
  Widget _buildUploadProgressOverlay(_UploadingImage uploadingImage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: uploadingImage.progress,
                strokeWidth: 3,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              Text(
                '${(uploadingImage.progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建上传错误遮罩
  Widget _buildUploadErrorOverlay(_UploadingImage uploadingImage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(FontAwesomeIcons.circleExclamation, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _retryUpload(uploadingImage),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '重试',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removeUploadingImage(uploadingImage.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '取消',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      await _controller.sendFileMessage(file.path!, file.name);
    }
  }

  void _openFile(V2TimMessage message) {
    // TODO: 实现文件打开
    AppToast.info('打开文件');
  }
}

// ============================================================================
// 全屏图片查看器 — 参考群聊 _FullScreenImageViewer
// ============================================================================

class _FullScreenImageViewer extends StatefulWidget {
  final String imagePath;

  const _FullScreenImageViewer({required this.imagePath});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() => _currentScale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (_currentScale != 1.0)
            IconButton(
              icon: const Icon(Icons.zoom_out_map, color: Colors.white),
              onPressed: _resetZoom,
              tooltip: '重置缩放',
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            onInteractionEnd: (details) {
              setState(() {
                _currentScale = _transformationController.value.getMaxScaleOnAxis();
              });
            },
            child: _buildFullScreenImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenImage() {
    return Image.network(
      widget.imagePath,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.white,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.image, color: Colors.grey, size: 60),
            SizedBox(height: 16),
            Text('图片加载失败', style: TextStyle(color: Colors.grey)),
          ],
        );
      },
    );
  }
}
