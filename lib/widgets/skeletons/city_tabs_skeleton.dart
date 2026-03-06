import 'package:flutter/material.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

/// City Tab Skeleton Base - 城市详情 Tab 骨架屏基类
class CityTabSkeleton extends StatelessWidget {
  final Widget child;

  const CityTabSkeleton({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Photos Tab Skeleton - 照片 Tab 骨架屏
class PhotosTabSkeleton extends StatelessWidget {
  const PhotosTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const AppSceneLoading(scene: AppLoadingScene.cityList, fullScreen: true);
}

/// Scores Tab Skeleton - 评分 Tab 骨架屏
class ScoresTabSkeleton extends StatelessWidget {
  const ScoresTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const AppSceneLoading(scene: AppLoadingScene.generic, fullScreen: true);
}

/// Weather Tab Skeleton - 天气 Tab 骨架屏
class WeatherTabSkeleton extends StatelessWidget {
  const WeatherTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const AppSceneLoading(scene: AppLoadingScene.weather, fullScreen: true);
}

/// Reviews Tab Skeleton - 评论 Tab 骨架屏
class ReviewsTabSkeleton extends StatelessWidget {
  final int itemCount;

  const ReviewsTabSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) => const AppSceneLoading(scene: AppLoadingScene.reviews, fullScreen: true);
}

/// Pros Cons Tab Skeleton - 优缺点 Tab 骨架屏
class ProsConsTabSkeleton extends StatelessWidget {
  const ProsConsTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const AppSceneLoading(scene: AppLoadingScene.generic, fullScreen: true);
}

/// Coworking Tab Skeleton - Coworking Tab 骨架屏
class CoworkingTabSkeleton extends StatelessWidget {
  final int itemCount;

  const CoworkingTabSkeleton({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) => const AppSceneLoading(scene: AppLoadingScene.coworkingList, fullScreen: true);
}

/// Cost Tab Skeleton - 花费 Tab 骨架屏
class CostTabSkeleton extends StatelessWidget {
  const CostTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const AppSceneLoading(scene: AppLoadingScene.costs, fullScreen: true);
}

/// Manage List Skeleton - 管理列表骨架屏（通用）
class ManageListSkeleton extends StatelessWidget {
  final int itemCount;

  const ManageListSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) => const AppSceneLoading(scene: AppLoadingScene.generic, fullScreen: true);
}
