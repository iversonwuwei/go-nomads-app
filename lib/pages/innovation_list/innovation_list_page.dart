import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/innovation_list_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/innovation_list/innovation_list_widgets.dart';
import 'package:go_nomads_app/pages/innovation_list/innovation_project_card.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

/// Innovation Projects List Page
/// 创意项目列表页面 - GetX 标准模式（StatelessWidget）
class InnovationListPage extends StatelessWidget {
  const InnovationListPage({super.key});

  static const String _controllerTag = 'InnovationListPage';

  /// 获取或创建 Controller
  InnovationListPageController get _controller {
    if (Get.isRegistered<InnovationListPageController>(tag: _controllerTag)) {
      return Get.find<InnovationListPageController>(tag: _controllerTag);
    }
    return Get.put(InnovationListPageController(), tag: _controllerTag);
  }

  @override
  Widget build(BuildContext context) {
    // 确保 controller 初始化
    final controller = _controller;
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceElevated,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(color: AppColors.textPrimary),
        title: Text(
          l10n.innovation,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Obx(() => _buildBody(controller, isMobile)),
      ),
    );
  }

  Widget _buildBody(InnovationListPageController controller, bool isMobile) {
    // 检查控制器初始化状态
    if (!controller.controllerInitialized.value) {
      return _buildContent(controller, isMobile, controller.displayProjects);
    }

    final sc = controller.stateController;
    if (sc == null) {
      return _buildContent(controller, isMobile, controller.displayProjects);
    }

    // 显式访问 projects.length 来确保响应式追踪
    final projectCount = sc.projects.length;
    debugPrint('📊 [InnovationListPage] 当前项目数量: $projectCount');

    Widget content;
    // 错误状态
    if (sc.errorMessage.value != null && projectCount == 0) {
      content = InnovationListErrorState(
        errorMessage: sc.errorMessage.value!,
        onRetry: () => controller.loadProjects(),
      );
    } else {
      content = _buildContent(controller, isMobile, sc.projects.toList());
    }

    // 首次加载中
    return AppLoadingSwitcher(
      isLoading: sc.isLoading.value && projectCount == 0,
      loading: const InnovationListSkeleton(),
      child: content,
    );
  }

  Widget _buildContent(
    InnovationListPageController controller,
    bool isMobile,
    List projects,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      itemCount: projects.isEmpty ? 2 : projects.length + 2,
      itemBuilder: (context, index) {
        // Header
        if (index == 0) {
          return InnovationListHeader(onRefresh: controller.refreshData);
        }

        // Empty state
        if (projects.isEmpty) {
          return const InnovationListEmptyState();
        }

        // Footer (loading indicator)
        if (index == projects.length + 1) {
          final stateController = controller.stateController;
          return InnovationListLoadingIndicator(
            isLoading: stateController?.isLoadingMore.value ?? false,
            hasMore: stateController?.hasMore.value ?? false,
          );
        }

        // Project card
        final projectIndex = index - 1;
        final stateController = controller.stateController;
        if (projectIndex >= projects.length - 3 && (stateController?.canLoadMore ?? false)) {
          controller.loadMoreProjects();
        }

        final project = projects[projectIndex];
        return InnovationProjectCard(
          project: project,
          controllerTag: _controllerTag,
        );
      },
    );
  }
}
