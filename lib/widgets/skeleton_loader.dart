import 'package:flutter/material.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

/// Legacy compatibility loader.
/// Kept to avoid breaking old call sites that still use SkeletonLoader/SkeletonType.
class SkeletonLoader extends StatelessWidget {
  final SkeletonType type;
  final Widget? customSkeleton;

  const SkeletonLoader({
    super.key,
    this.type = SkeletonType.list,
    this.customSkeleton,
  });

  @override
  Widget build(BuildContext context) {
    if (customSkeleton != null) return customSkeleton!;

    return AppSceneLoading(
      fullScreen: true,
      scene: _sceneFor(type),
    );
  }

  AppLoadingScene _sceneFor(SkeletonType type) {
    switch (type) {
      case SkeletonType.list:
        return AppLoadingScene.generic;
      case SkeletonType.grid:
        return AppLoadingScene.cityList;
      case SkeletonType.detail:
        return AppLoadingScene.hotelDetail;
      case SkeletonType.profile:
        return AppLoadingScene.profile;
      case SkeletonType.card:
        return AppLoadingScene.generic;
      case SkeletonType.home:
        return AppLoadingScene.cityList;
      case SkeletonType.chat:
        return AppLoadingScene.meetup;
      case SkeletonType.community:
        return AppLoadingScene.innovation;
      case SkeletonType.messages:
        return AppLoadingScene.notifications;
    }
  }
}

enum SkeletonType {
  list,
  grid,
  detail,
  profile,
  card,
  home,
  chat,
  community,
  messages,
}
