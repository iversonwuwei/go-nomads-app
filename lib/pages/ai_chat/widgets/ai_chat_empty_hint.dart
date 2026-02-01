import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/config/app_colors.dart';

/// AI Chat 空状态提示
class AiChatEmptyHint extends StatelessWidget {
  const AiChatEmptyHint({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(height: 18),
          const Text(
            '还没有对话，向 AI 提问试试',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const FaIcon(
        FontAwesomeIcons.solidComments,
        color: AppColors.cityPrimary,
        size: 28,
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: onStart,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: const Text('开始对话'),
    );
  }
}
