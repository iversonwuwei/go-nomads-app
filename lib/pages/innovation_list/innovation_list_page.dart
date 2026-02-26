import 'package:go_nomads_app/controllers/innovation_list_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/innovation_list/innovation_list_widgets.dart';
import 'package:go_nomads_app/pages/innovation_list/innovation_project_card.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(color: Color(0xFF1a1a1a)),
        title: Text(
          l10n.innovation,
          style: TextStyle(
            color: Color(0xFF1a1a1a),
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

    // 首次加载中
    if (sc.isLoading.value && projectCount == 0) {
      return const InnovationListSkeleton();
    }

    // 错误状态
    if (sc.errorMessage.value != null && projectCount == 0) {
      return InnovationListErrorState(
        errorMessage: sc.errorMessage.value!,
        onRetry: () => controller.loadProjects(),
      );
    }

    return _buildContent(controller, isMobile, sc.projects.toList());
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
          return InnovationListLoadingIndicator(
            isLoading: controller.stateController?.isLoading.value ?? false,
            hasMore: false,
          );
        }

        // Project card
        final project = projects[index - 1];
        return InnovationProjectCard(
          project: project,
          controllerTag: _controllerTag,
        );
      },
    );
  }
}
