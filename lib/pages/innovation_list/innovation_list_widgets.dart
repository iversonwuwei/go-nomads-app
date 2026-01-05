import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/add_innovation/add_innovation_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Innovation List Header Section
/// 创意项目列表 - 头部区域（创建按钮和标题）
class InnovationListHeader extends StatelessWidget {
  final VoidCallback? onRefresh;

  const InnovationListHeader({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Create Project Button
        _buildCreateButton(context, l10n),

        const SizedBox(height: 24),

        // Section Title
        _buildSectionTitle(l10n),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () async {
          debugPrint('🚀 [InnovationListHeader] 打开添加页面...');
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddInnovationPage(),
            ),
          );

          debugPrint('🔙 [InnovationListHeader] 添加页面返回, result: $result');
          // 如果添加成功,刷新数据
          if (result == true) {
            debugPrint('🔄 [InnovationListHeader] 调用 onRefresh 刷新数据...');
            onRefresh?.call();
          }
        },
        icon: const Icon(FontAwesomeIcons.circlePlus, size: 24),
        label: Text(
          l10n.createMyInnovation,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(
          FontAwesomeIcons.compass,
          color: Color(0xFF8B5CF6),
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.exploreInnovations,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

/// Innovation List Empty State
/// 创意项目列表 - 空状态组件
class InnovationListEmptyState extends StatelessWidget {
  const InnovationListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(FontAwesomeIcons.lightbulb, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '暂无创意项目',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '成为第一个分享创意的人吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

/// Innovation List Error State
/// 创意项目列表 - 错误状态组件
class InnovationListErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const InnovationListErrorState({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.circleExclamation, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}

/// Innovation List Loading Indicator
/// 创意项目列表 - 加载更多指示器
class InnovationListLoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;

  const InnovationListLoadingIndicator({
    super.key,
    required this.isLoading,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            '已加载全部项目',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
      );
    }

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
