import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_controller.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_theme.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_empty_hint.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_error_state.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_hero_card.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_input_bar.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_message_list.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/ai_chat_streaming_status.dart';
import 'package:go_nomads_app/pages/ai_chat/widgets/openclaw_quick_actions.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/dialogs/app_loading_dialog.dart';
import 'package:intl/intl.dart';

class AiChatPage extends GetView<AiChatController> {
  final bool embeddedInBottomNav;

  const AiChatPage({super.key, this.embeddedInBottomNav = false});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;

    return Scaffold(
      backgroundColor: AiChatTheme.canvasBottom,
      appBar: _buildAppBar(context),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AiChatTheme.canvasGradient,
        ),
        child: Stack(
          children: [
            const _AiChatBackdrop(),
            SafeArea(
              child: CustomScrollView(
                controller: controller.scrollController,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(child: AiChatHeroCard(isMobile: isMobile)),
                  const SliverToBoxAdapter(child: AiChatStreamingStatus()),
                  SliverToBoxAdapter(
                    child: Obx(() => controller.showQuickActions.value
                        ? Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: OpenClawQuickActions(
                              onScenarioSelected: controller.runOpenClawScenario,
                              onCommandSubmit: controller.executeOpenClawCommand,
                            ),
                          )
                        : const SizedBox.shrink()),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 16.w : 24.w,
                        4.h,
                        isMobile ? 16.w : 24.w,
                        0,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AiChatTheme.panel,
                          borderRadius: BorderRadius.circular(28.r),
                          border: Border.all(color: AiChatTheme.line),
                          boxShadow: [
                            BoxShadow(
                              color: AiChatTheme.shadow,
                              blurRadius: 28.r,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28.r),
                          child: _buildMessageArea(isMobile),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: AiChatInputBar(isMobile: isMobile)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 8.w,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.aiChatDefaultConversationTitle,
            style: TextStyle(
              color: AiChatTheme.ink,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          Text(
            '行程、签证、远程办公一屏处理',
            style: TextStyle(
              color: AiChatTheme.inkSoft,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      leading: embeddedInBottomNav ? null : const AppBackButton(),
      actions: [
        Obx(() => controller.messages.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _buildActionButton(
                  tooltip: '新对话',
                  icon: Icons.add_comment_rounded,
                  onTap: () => _confirmResetToEmptyState(context),
                ),
              )
            : const SizedBox.shrink()),
        Obx(() => _buildActionButton(
              tooltip: controller.showQuickActions.value ? '隐藏快捷操作' : '快捷操作',
              icon: controller.showQuickActions.value ? Icons.auto_awesome_rounded : Icons.dashboard_customize_rounded,
              onTap: controller.toggleQuickActions,
            )),
        SizedBox(width: 8.w),
        _buildActionButton(
          tooltip: l10n.aiChatHistoryTooltip,
          icon: Icons.history_rounded,
          onTap: () => _showHistorySheet(context),
        ),
        SizedBox(width: 16.w),
      ],
    );
  }

  Widget _buildActionButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Ink(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AiChatTheme.line),
            ),
            child: Icon(icon, size: 20.r, color: AiChatTheme.ink),
          ),
        ),
      ),
    );
  }

  Future<void> _showHistorySheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    AppLoadingDialog.show(
      title: l10n.aiChatLoadingHistoryTitle,
      subtitle: l10n.loginPleaseWait,
    );

    try {
      await controller.loadConversationList();
    } finally {
      AppLoadingDialog.hide();
    }

    if (controller.historyConversations.isEmpty) {
      AppToast.info(l10n.aiChatNoHistoryStartNew);
      return;
    }

    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AiChatTheme.shell,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: AiChatTheme.line),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38.r,
                        height: 38.r,
                        decoration: BoxDecoration(
                          color: AiChatTheme.tealSoft.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.history_rounded, color: AiChatTheme.teal, size: 18.r),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.aiChatHistoryTitle,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: AiChatTheme.ink,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              '选择一个历史会话继续，当前正在进行的对话不会显示在这里。',
                              style: TextStyle(
                                fontSize: 11.sp,
                                height: 1.4,
                                color: AiChatTheme.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: Obx(() {
                    final items = controller.historyConversations;
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final currentId = controller.conversation.value?.id;
                        final time = item.updatedAt ?? item.createdAt;
                        final timeLabel = time == null ? '' : DateFormat('yyyy-MM-dd HH:mm').format(time);
                        final isCurrent = currentId == item.id;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18.r),
                            onTap: () async {
                              Navigator.of(sheetContext).pop();
                              await controller.selectConversation(item);
                            },
                            child: Ink(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AiChatTheme.tealSoft.withValues(alpha: 0.42)
                                    : Colors.white.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color: isCurrent ? AiChatTheme.teal.withValues(alpha: 0.35) : AiChatTheme.line,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38.r,
                                    height: 38.r,
                                    decoration: BoxDecoration(
                                      color: isCurrent ? AiChatTheme.teal : AiChatTheme.surfaceMuted,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      isCurrent ? Icons.forum_rounded : Icons.schedule_rounded,
                                      size: 18.r,
                                      color: isCurrent ? Colors.white : AiChatTheme.inkSoft,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          controller.getHistoryTitle(item),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AiChatTheme.ink,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (timeLabel.isNotEmpty) ...[
                                          SizedBox(height: 4.h),
                                          Text(
                                            timeLabel,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AiChatTheme.inkSoft,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (isCurrent) Icon(Icons.check_circle_rounded, size: 18.r, color: AiChatTheme.teal),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmResetToEmptyState(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: AiChatTheme.shell,
              borderRadius: BorderRadius.circular(26.r),
              border: Border.all(color: AiChatTheme.line),
              boxShadow: [
                BoxShadow(
                  color: AiChatTheme.shadow.withValues(alpha: 0.9),
                  blurRadius: 28.r,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: AiChatTheme.coral.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.add_comment_rounded,
                        color: AiChatTheme.coralDeep,
                        size: 20.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '开始新对话？',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AiChatTheme.ink,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '当前页面中的消息会被清空，并回到五个场景入口。历史记录不会删除，之后仍可从历史列表继续打开。',
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.45,
                              color: AiChatTheme.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AiChatTheme.line),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded, size: 16.r, color: AiChatTheme.teal),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          '仅重置当前会话视图，不影响历史会话内容。',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AiChatTheme.inkSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AiChatTheme.line),
                          foregroundColor: AiChatTheme.inkSoft,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: const Text('取消'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          controller.resetToEmptyState();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AiChatTheme.coral,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: const Text('确认新对话'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageArea(bool isMobile) {
    return Obx(() {
      if (controller.isInitializing.value) {
        return const AppSceneLoading(scene: AppLoadingScene.generic, fullScreen: true);
      }

      if (controller.hasInitError.value) {
        return AiChatErrorState(
          message: controller.initErrorMessage.value,
          onRetry: controller.retryInit,
        );
      }

      if (controller.messages.isEmpty) {
        return AiChatEmptyHint(
          onQuickCommand: controller.executeOpenClawCommand,
        );
      }

      return AiChatMessageList(isMobile: isMobile);
    });
  }
}

class _AiChatBackdrop extends StatelessWidget {
  const _AiChatBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -60.h,
            right: -20.w,
            child: _buildOrb(
              size: 180.r,
              colors: [AiChatTheme.tealSoft.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.0)],
            ),
          ),
          Positioned(
            top: 160.h,
            left: -50.w,
            child: _buildOrb(
              size: 140.r,
              colors: [AiChatTheme.coral.withValues(alpha: 0.18), Colors.white.withValues(alpha: 0.0)],
            ),
          ),
          Positioned(
            bottom: 100.h,
            right: -30.w,
            child: _buildOrb(
              size: 160.r,
              colors: [AiChatTheme.teal.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.0)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
