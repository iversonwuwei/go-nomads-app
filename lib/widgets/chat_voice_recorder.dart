import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// 语音录制配置
class VoiceRecorderConfig {
  /// 主题色
  final Color primaryColor;

  /// 最大录音时长（秒）
  final int maxDuration;

  /// 最小录音时长（秒）
  final int minDuration;

  const VoiceRecorderConfig({
    this.primaryColor = const Color(0xFF07C160),
    this.maxDuration = 60,
    this.minDuration = 1,
  });

  /// 微信风格（绿色主题）
  static const wechat = VoiceRecorderConfig(
    primaryColor: Color(0xFF07C160),
  );

  /// Snapchat风格（红色主题）
  static const snapchat = VoiceRecorderConfig(
    primaryColor: Color(0xFFFF3838),
  );
}

/// 语音录制按钮组件（按住说话）
class ChatVoiceRecorderButton extends StatefulWidget {
  /// 发送语音回调
  final void Function(String path, int duration) onSendVoice;

  /// 配置
  final VoiceRecorderConfig config;

  const ChatVoiceRecorderButton({
    super.key,
    required this.onSendVoice,
    this.config = VoiceRecorderConfig.wechat,
  });

  @override
  State<ChatVoiceRecorderButton> createState() => _ChatVoiceRecorderButtonState();
}

class _ChatVoiceRecorderButtonState extends State<ChatVoiceRecorderButton> with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isCancelArea = false;
  int _recordDuration = 0;
  Timer? _recordTimer;
  String? _recordingPath;
  double _startY = 0;

  // 动画控制器（波纹效果）
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _animationController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _recordingPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordingPath!,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });

        // 开始波纹动画
        _animationController.repeat(reverse: true);

        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordDuration++;
          });
          if (_recordDuration >= widget.config.maxDuration) {
            _stopRecording(send: true);
          }
        });

        HapticFeedback.mediumImpact();
      } else {
        AppToast.error('请允许录音权限');
      }
    } catch (e) {
      AppToast.error('录音失败: $e');
    }
  }

  Future<void> _stopRecording({bool send = false}) async {
    _recordTimer?.cancel();
    _animationController.stop();
    _animationController.reset();

    if (!_isRecording) return;

    try {
      final path = await _recorder.stop();

      setState(() {
        _isRecording = false;
        _isCancelArea = false;
      });

      if (send && path != null && _recordDuration >= widget.config.minDuration) {
        widget.onSendVoice(path, _recordDuration);
      } else if (_recordDuration < widget.config.minDuration) {
        AppToast.info('说话时间太短');
        if (path != null) {
          try {
            await File(path).delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('停止录音失败: $e');
    }
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    _animationController.stop();
    _animationController.reset();

    if (!_isRecording) return;

    try {
      final path = await _recorder.stop();

      setState(() {
        _isRecording = false;
        _isCancelArea = false;
      });

      HapticFeedback.lightImpact();
      AppToast.info('已取消');

      if (path != null) {
        try {
          await File(path).delete();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('取消录音失败: $e');
    }
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.config.primaryColor;

    return GestureDetector(
      onLongPressStart: (details) {
        _startY = details.globalPosition.dy;
        _startRecording();
      },
      onLongPressMoveUpdate: (details) {
        final deltaY = _startY - details.globalPosition.dy;
        final newCancelArea = deltaY > 50;
        if (newCancelArea != _isCancelArea) {
          HapticFeedback.selectionClick();
        }
        setState(() {
          _isCancelArea = newCancelArea;
        });
      },
      onLongPressEnd: (details) {
        if (_isCancelArea) {
          _cancelRecording();
        } else {
          _stopRecording(send: true);
        }
      },
      onLongPressCancel: () {
        _cancelRecording();
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            height: 36,
            decoration: BoxDecoration(
              color: _isRecording
                  ? (_isCancelArea ? Colors.red.withValues(alpha: 0.15) : primaryColor.withValues(alpha: 0.15))
                  : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: _isRecording
                  ? Border.all(
                      color: _isCancelArea ? Colors.red : primaryColor,
                      width: 1.5,
                    )
                  : null,
              boxShadow: _isRecording
                  ? [
                      BoxShadow(
                        color: (_isCancelArea ? Colors.red : primaryColor)
                            .withValues(alpha: 0.3 * (_pulseAnimation.value - 1) * 5),
                        blurRadius: 8 * _pulseAnimation.value,
                        spreadRadius: 2 * (_pulseAnimation.value - 1),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: _isRecording ? _buildRecordingContent() : _buildIdleContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIdleContent() {
    return const Text(
      '按住 说话',
      style: TextStyle(
        color: Color(0xFF999999),
        fontSize: 15,
      ),
    );
  }

  Widget _buildRecordingContent() {
    final color = _isCancelArea ? Colors.red : widget.config.primaryColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 录音图标或取消图标
        Icon(
          _isCancelArea ? FontAwesomeIcons.trash : FontAwesomeIcons.microphone,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 8),
        // 时间和提示
        Text(
          _isCancelArea ? '松开取消' : '${_formatDuration(_recordDuration)} ↑ 取消',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// 全屏语音录制面板（更好的用户体验）
class ChatVoiceRecorderPanel extends StatefulWidget {
  /// 发送语音回调
  final void Function(String path, int duration) onSendVoice;

  /// 配置
  final VoiceRecorderConfig config;

  const ChatVoiceRecorderPanel({
    super.key,
    required this.onSendVoice,
    this.config = VoiceRecorderConfig.wechat,
  });

  /// 显示语音录制面板
  static void show({
    required void Function(String path, int duration) onSendVoice,
    VoiceRecorderConfig config = VoiceRecorderConfig.wechat,
  }) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => ChatVoiceRecorderPanel(
        onSendVoice: onSendVoice,
        config: config,
      ),
    );
  }

  @override
  State<ChatVoiceRecorderPanel> createState() => _ChatVoiceRecorderPanelState();
}

class _ChatVoiceRecorderPanelState extends State<ChatVoiceRecorderPanel> with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isCancelArea = false;
  int _recordDuration = 0;
  Timer? _recordTimer;
  String? _recordingPath;
  double _startY = 0;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _waveController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _recordingPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordingPath!,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });

        _waveController.repeat(reverse: true);

        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordDuration++;
          });
          if (_recordDuration >= widget.config.maxDuration) {
            _stopRecording(send: true);
          }
        });

        HapticFeedback.mediumImpact();
      } else {
        AppToast.error('请允许录音权限');
      }
    } catch (e) {
      AppToast.error('录音失败: $e');
    }
  }

  Future<void> _stopRecording({bool send = false}) async {
    _recordTimer?.cancel();
    _waveController.stop();

    if (!_isRecording) return;

    try {
      final path = await _recorder.stop();

      setState(() {
        _isRecording = false;
        _isCancelArea = false;
      });

      if (send && path != null && _recordDuration >= widget.config.minDuration) {
        Navigator.of(context).pop();
        widget.onSendVoice(path, _recordDuration);
      } else if (_recordDuration < widget.config.minDuration) {
        AppToast.info('说话时间太短');
        if (path != null) {
          try {
            await File(path).delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('停止录音失败: $e');
    }
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    _waveController.stop();

    if (!_isRecording) return;

    try {
      final path = await _recorder.stop();

      setState(() {
        _isRecording = false;
        _isCancelArea = false;
      });

      if (path != null) {
        try {
          await File(path).delete();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('取消录音失败: $e');
    }
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.config.primaryColor;

    return Container(
      height: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 顶部拖动条
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // 录音状态显示
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 波形动画
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? (_isCancelArea
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : primaryColor.withValues(alpha: 0.1))
                              : Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _isCancelArea ? FontAwesomeIcons.trash : FontAwesomeIcons.microphone,
                            size: 32,
                            color: _isRecording ? (_isCancelArea ? Colors.red : primaryColor) : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // 时间显示
                  Text(
                    _isRecording ? _formatDuration(_recordDuration) : '按住下方按钮开始录音',
                    style: TextStyle(
                      fontSize: _isRecording ? 24 : 14,
                      fontWeight: _isRecording ? FontWeight.bold : FontWeight.normal,
                      color: _isRecording ? (_isCancelArea ? Colors.red : primaryColor) : const Color(0xFF999999),
                    ),
                  ),
                  if (_isRecording) ...[
                    const SizedBox(height: 8),
                    Text(
                      _isCancelArea ? '松开手指，取消发送' : '上滑取消',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isCancelArea ? Colors.red : const Color(0xFF999999),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 底部录音按钮
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onLongPressStart: (details) {
                  _startY = details.globalPosition.dy;
                  _startRecording();
                },
                onLongPressMoveUpdate: (details) {
                  final deltaY = _startY - details.globalPosition.dy;
                  setState(() {
                    _isCancelArea = deltaY > 50;
                  });
                },
                onLongPressEnd: (details) {
                  if (_isCancelArea) {
                    _cancelRecording();
                  } else {
                    _stopRecording(send: true);
                  }
                },
                onLongPressCancel: () {
                  _cancelRecording();
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? (_isCancelArea ? Colors.red.withValues(alpha: 0.15) : primaryColor.withValues(alpha: 0.15))
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(25),
                    border: _isRecording
                        ? Border.all(
                            color: _isCancelArea ? Colors.red : primaryColor,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isRecording
                              ? (_isCancelArea ? FontAwesomeIcons.xmark : FontAwesomeIcons.microphone)
                              : FontAwesomeIcons.microphone,
                          color: _isRecording ? (_isCancelArea ? Colors.red : primaryColor) : const Color(0xFF666666),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isRecording ? (_isCancelArea ? '松开取消' : '正在录音...') : '按住说话',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _isRecording ? (_isCancelArea ? Colors.red : primaryColor) : const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
