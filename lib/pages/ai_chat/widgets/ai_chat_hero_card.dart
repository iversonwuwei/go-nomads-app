import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// AI Chat 顶部 Hero 卡片
class AiChatHeroCard extends StatelessWidget {
  const AiChatHeroCard({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 12, isMobile ? 16 : 24, 10),
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(width: 12),
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      height: isMobile ? 48 : 56,
      width: isMobile ? 48 : 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: FaIcon(FontAwesomeIcons.robot, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '行途 AI 智能助手',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '用流式对话聊攻略、问路线、生成行程草稿。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.86),
          ),
        ),
      ],
    );
  }
}
