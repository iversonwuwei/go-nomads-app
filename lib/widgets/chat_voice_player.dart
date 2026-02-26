import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 语音消息播放器
///
/// 全局单例管理，确保同时只有一个语音在播放
/// 支持下载缓存，解决 Supabase Storage 流式播放问题
class VoicePlayerManager {
  static final VoicePlayerManager _instance = VoicePlayerManager._internal();
  factory VoicePlayerManager() => _instance;
  VoicePlayerManager._internal() {
    _setupPlayerListeners();
  }

  final AudioPlayer _player = AudioPlayer();
  String? _currentPlayingUrl;
  final _playingUrlNotifier = ValueNotifier<String?>(null);
  final _loadingUrlNotifier = ValueNotifier<String?>(null);
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateSubscription;

  // 本地缓存目录
  Directory? _cacheDir;

  // 已缓存的文件映射 (url -> localPath)
  final Map<String, String> _cachedFiles = {};

  ValueNotifier<String?> get playingUrlNotifier => _playingUrlNotifier;
  ValueNotifier<String?> get loadingUrlNotifier => _loadingUrlNotifier;

  bool isPlaying(String url) => _currentPlayingUrl == url && _playingUrlNotifier.value == url;
  bool isLoading(String url) => _loadingUrlNotifier.value == url;

  /// 设置播放器监听
  void _setupPlayerListeners() {
    _playerCompleteSubscription?.cancel();
    _playerStateSubscription?.cancel();

    _playerCompleteSubscription = _player.onPlayerComplete.listen((_) {
      debugPrint('🔊 语音播放完成');
      _currentPlayingUrl = null;
      _playingUrlNotifier.value = null;
    });

    _playerStateSubscription = _player.onPlayerStateChanged.listen((state) {
      debugPrint('🔊 播放器状态变化: $state');
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        if (_currentPlayingUrl != null) {
          _currentPlayingUrl = null;
          _playingUrlNotifier.value = null;
        }
      }
    });
  }

  /// 初始化缓存目录
  Future<void> _ensureCacheDir() async {
    if (_cacheDir != null) return;
    final tempDir = await getTemporaryDirectory();
    _cacheDir = Directory('${tempDir.path}/voice_cache');
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
  }

  /// 获取缓存文件路径
  String _getCacheFilePath(String url) {
    // 使用 URL 的 hash 作为文件名
    final hash = url.hashCode.abs().toString();
    final ext = url.contains('.m4a') ? '.m4a' : '.aac';
    return '${_cacheDir!.path}/voice_$hash$ext';
  }

  /// 下载并缓存语音文件
  Future<String?> _downloadAndCache(String url) async {
    try {
      await _ensureCacheDir();

      // 检查是否已缓存
      if (_cachedFiles.containsKey(url)) {
        final cachedPath = _cachedFiles[url]!;
        if (await File(cachedPath).exists()) {
          return cachedPath;
        }
      }

      // 下载文件
      debugPrint('📥 下载语音文件: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final localPath = _getCacheFilePath(url);
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        _cachedFiles[url] = localPath;
        debugPrint('✅ 语音文件已缓存: $localPath');
        return localPath;
      } else {
        debugPrint('❌ 下载语音文件失败: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ 下载语音文件异常: $e');
      return null;
    }
  }

  Future<void> play(String url) async {
    try {
      // 如果正在播放同一个，则暂停
      if (_currentPlayingUrl == url) {
        await stop();
        return;
      }

      // 停止当前播放
      await stop();

      // 设置加载状态
      _loadingUrlNotifier.value = url;

      // 下载并缓存语音文件
      final localPath = await _downloadAndCache(url);

      // 清除加载状态
      _loadingUrlNotifier.value = null;

      if (localPath == null) {
        debugPrint('❌ 无法播放语音：下载失败');
        return;
      }

      // 开始新的播放
      _currentPlayingUrl = url;
      _playingUrlNotifier.value = url;

      debugPrint('🔊 开始播放语音: $localPath');
      await _player.play(DeviceFileSource(localPath));
      debugPrint('🔊 播放命令已发送');
    } catch (e) {
      debugPrint('❌ 播放语音失败: $e');
      _currentPlayingUrl = null;
      _playingUrlNotifier.value = null;
      _loadingUrlNotifier.value = null;
    }
  }

  Future<void> stop() async {
    debugPrint('🔊 停止播放');
    await _player.stop();
    _currentPlayingUrl = null;
    _playingUrlNotifier.value = null;
  }

  /// 清理缓存
  Future<void> clearCache() async {
    try {
      await _ensureCacheDir();
      if (await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create(recursive: true);
      }
      _cachedFiles.clear();
      debugPrint('✅ 语音缓存已清理');
    } catch (e) {
      debugPrint('❌ 清理语音缓存失败: $e');
    }
  }

  void dispose() {
    _playerCompleteSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _player.dispose();
  }
}

/// 语音消息气泡组件
class ChatVoiceMessageBubble extends StatefulWidget {
  /// 语音URL
  final String voiceUrl;

  /// 语音时长（秒）
  final int duration;

  /// 是否是自己发送的消息
  final bool isMe;

  /// 主题色
  final Color primaryColor;

  /// 气泡背景色
  final Color? backgroundColor;

  const ChatVoiceMessageBubble({
    super.key,
    required this.voiceUrl,
    required this.duration,
    required this.isMe,
    this.primaryColor = const Color(0xFF07C160),
    this.backgroundColor,
  });

  @override
  State<ChatVoiceMessageBubble> createState() => _ChatVoiceMessageBubbleState();
}

class _ChatVoiceMessageBubbleState extends State<ChatVoiceMessageBubble> with SingleTickerProviderStateMixin {
  final _playerManager = VoicePlayerManager();
  late AnimationController _waveController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 监听全局播放状态
    _playerManager.playingUrlNotifier.addListener(_onPlayingChanged);
  }

  void _onPlayingChanged() {
    final isPlaying = _playerManager.isPlaying(widget.voiceUrl);
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
      if (isPlaying) {
        _waveController.repeat();
      } else {
        _waveController.stop();
        _waveController.reset();
      }
    }
  }

  @override
  void dispose() {
    _playerManager.playingUrlNotifier.removeListener(_onPlayingChanged);
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    _playerManager.play(widget.voiceUrl);
  }

  @override
  Widget build(BuildContext context) {
    // 根据时长计算宽度
    final width = (80 + widget.duration * 3).clamp(80, 200).toDouble();
    final bgColor = widget.backgroundColor ?? (widget.isMe ? widget.primaryColor : const Color(0xFFF5F5F5));
    final contentColor = widget.isMe ? Colors.white : const Color(0xFF333333);
    final iconColor = widget.isMe ? Colors.white70 : widget.primaryColor;

    return GestureDetector(
      onTap: _togglePlay,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.isMe ? 16 : 4),
            topRight: Radius.circular(widget.isMe ? 4 : 16),
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.isMe
              ? [
                  // 时长
                  Text(
                    '${widget.duration}"',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: contentColor,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // 波形
                  Expanded(child: _buildWaveform(iconColor, true)),
                  SizedBox(width: 8.w),
                  // 播放图标
                  _buildPlayIcon(iconColor),
                ]
              : [
                  // 播放图标
                  _buildPlayIcon(iconColor),
                  SizedBox(width: 8.w),
                  // 波形
                  Expanded(child: _buildWaveform(iconColor, false)),
                  SizedBox(width: 8.w),
                  // 时长
                  Text(
                    '${widget.duration}"',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: contentColor,
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  Widget _buildPlayIcon(Color color) {
    return Icon(
      _isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
      color: color,
      size: 14.r,
    );
  }

  Widget _buildWaveform(Color color, bool reverse) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            // 计算动画偏移
            double animValue = 0;
            if (_isPlaying) {
              final offset = reverse ? (4 - index) : index;
              animValue = ((_waveController.value + offset * 0.15) % 1.0);
            }

            // 基础高度 + 动画高度
            final baseHeights = [6.0, 10.0, 14.0, 10.0, 6.0];
            final animatedHeight = baseHeights[index] + (animValue * 6);

            return Container(
              width: 3.w,
              height: animatedHeight.clamp(4.0, 20.0),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(1.5.r),
              ),
            );
          }),
        );
      },
    );
  }
}

/// 简化版语音消息（带音频波形动画和时间显示）
class ChatVoiceMessageSimple extends StatefulWidget {
  /// 语音URL
  final String voiceUrl;

  /// 语音时长（秒）
  final int duration;

  /// 是否是自己发送的消息
  final bool isMe;

  /// 文字颜色
  final Color textColor;

  /// 图标颜色
  final Color iconColor;

  const ChatVoiceMessageSimple({
    super.key,
    required this.voiceUrl,
    required this.duration,
    required this.isMe,
    this.textColor = Colors.black87,
    this.iconColor = const Color(0xFF07C160),
  });

  @override
  State<ChatVoiceMessageSimple> createState() => _ChatVoiceMessageSimpleState();
}

class _ChatVoiceMessageSimpleState extends State<ChatVoiceMessageSimple> with SingleTickerProviderStateMixin {
  final _playerManager = VoicePlayerManager();
  late AnimationController _waveController;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _playerManager.playingUrlNotifier.addListener(_onPlayingChanged);
    _playerManager.loadingUrlNotifier.addListener(_onLoadingChanged);
  }

  void _onPlayingChanged() {
    final isPlaying = _playerManager.isPlaying(widget.voiceUrl);
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
      if (isPlaying) {
        _waveController.repeat();
      } else {
        _waveController.stop();
        _waveController.reset();
      }
    }
  }

  void _onLoadingChanged() {
    final isLoading = _playerManager.isLoading(widget.voiceUrl);
    if (isLoading != _isLoading) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

  @override
  void dispose() {
    _playerManager.playingUrlNotifier.removeListener(_onPlayingChanged);
    _playerManager.loadingUrlNotifier.removeListener(_onLoadingChanged);
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_isLoading) {
      _playerManager.play(widget.voiceUrl);
    }
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    if (mins > 0) {
      return '$mins:${secs.toString().padLeft(2, '0')}';
    }
    return '0:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final width = (120 + widget.duration * 5).clamp(140, 220).toDouble();

    return GestureDetector(
      onTap: _togglePlay,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.isMe ? _buildRightAlignedContent() : _buildLeftAlignedContent(),
        ),
      ),
    );
  }

  /// 左对齐内容（对方消息）
  List<Widget> _buildLeftAlignedContent() {
    return [
      // 播放/暂停按钮
      _buildPlayButton(),
      SizedBox(width: 10.w),
      // 音频波形
      Expanded(child: _buildWaveform()),
      SizedBox(width: 10.w),
      // 时长
      _buildDuration(),
    ];
  }

  /// 右对齐内容（自己消息）
  List<Widget> _buildRightAlignedContent() {
    return [
      // 时长
      _buildDuration(),
      SizedBox(width: 10.w),
      // 音频波形
      Expanded(child: _buildWaveform()),
      SizedBox(width: 10.w),
      // 播放/暂停按钮
      _buildPlayButton(),
    ];
  }

  /// 构建播放按钮
  Widget _buildPlayButton() {
    if (_isLoading) {
      return SizedBox(
        width: 24.w,
        height: 24.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(widget.iconColor),
        ),
      );
    }

    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: widget.iconColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          _isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
          color: widget.iconColor,
          size: 14.r,
        ),
      ),
    );
  }

  /// 构建音频波形动画
  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return SizedBox(
          height: 24.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(8, (index) {
              // 预设的基础高度模式（模拟音频波形）
              final baseHeights = [6.0, 10.0, 14.0, 18.0, 16.0, 12.0, 8.0, 5.0];

              // 计算动画偏移
              double animValue = 0;
              if (_isPlaying) {
                // 波浪效果：每个条形以不同相位波动
                final phase = index * 0.12;
                animValue = (((_waveController.value + phase) % 1.0) * 2 - 1).abs();
              }

              // 基础高度 + 动画高度变化
              final animatedHeight = baseHeights[index] + (animValue * 8);

              return Container(
                width: 3.w,
                height: animatedHeight.clamp(4.0, 24.0),
                decoration: BoxDecoration(
                  color: widget.iconColor.withValues(alpha: _isPlaying ? 1.0 : 0.7),
                  borderRadius: BorderRadius.circular(1.5.r),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  /// 构建时长显示
  Widget _buildDuration() {
    return Text(
      _formatDuration(widget.duration),
      style: TextStyle(
        fontSize: 13.sp,
        color: widget.textColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
