import 'package:flutter/material.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

/// Innovation List Skeleton - lightweight loading replacement.
class InnovationListSkeleton extends StatelessWidget {
  final int itemCount;

  const InnovationListSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(scene: AppLoadingScene.innovation, fullScreen: true);
  }
}

/// Innovation Detail Skeleton - lightweight loading replacement.
class InnovationDetailSkeleton extends StatelessWidget {
  const InnovationDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(scene: AppLoadingScene.innovationDetail, fullScreen: true);
  }
}
