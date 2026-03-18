import 'package:flutter/material.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

/// Meetup List Skeleton - lightweight loading replacement.
class MeetupListSkeleton extends StatelessWidget {
  final int itemCount;

  const MeetupListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(scene: AppLoadingScene.meetup, fullScreen: true);
  }
}

/// Meetup Detail Skeleton - lightweight loading replacement.
class MeetupDetailSkeleton extends StatelessWidget {
  const MeetupDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(scene: AppLoadingScene.meetupDetail, fullScreen: true);
  }
}

/// My Meetups Skeleton - lightweight loading replacement.
class MyMeetupsSkeleton extends StatelessWidget {
  final int itemCount;

  const MyMeetupsSkeleton({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(scene: AppLoadingScene.meetup, fullScreen: true);
  }
}
