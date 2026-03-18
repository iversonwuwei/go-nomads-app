import 'package:flutter/material.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

/// Hotel List Skeleton - lightweight loading replacement.
class HotelListSkeleton extends StatelessWidget {
  final int itemCount;

  const HotelListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(scene: AppLoadingScene.hotel, fullScreen: true);
  }
}

/// Hotel Detail Skeleton - lightweight loading replacement.
class HotelDetailSkeleton extends StatelessWidget {
  const HotelDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(scene: AppLoadingScene.hotelDetail, fullScreen: true);
  }
}
