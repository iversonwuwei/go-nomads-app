import 'package:flutter/material.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

/// Notification List Skeleton - lightweight loading replacement.
class NotificationListSkeleton extends StatelessWidget {
  final int itemCount;

  const NotificationListSkeleton({
    super.key,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(scene: AppLoadingScene.notifications, fullScreen: true);
  }
}

/// User Profile Skeleton - lightweight loading replacement.
class UserProfileSkeleton extends StatelessWidget {
  const UserProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(scene: AppLoadingScene.profile, fullScreen: true);
  }
}

/// Edit Form Skeleton - lightweight loading replacement.
class EditFormSkeleton extends StatelessWidget {
  final int fieldCount;

  const EditFormSkeleton({
    super.key,
    this.fieldCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(scene: AppLoadingScene.form, fullScreen: true);
  }
}

/// Tags Selector Skeleton - lightweight loading replacement.
class TagsSelectorSkeleton extends StatelessWidget {
  const TagsSelectorSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(scene: AppLoadingScene.tags, fullScreen: true);
  }
}
