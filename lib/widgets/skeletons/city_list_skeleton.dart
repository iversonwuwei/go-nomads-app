import 'package:flutter/material.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

/// Legacy compatibility wrapper for city-list loading.
class CityListSkeleton extends StatelessWidget {
  const CityListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(
      scene: AppLoadingScene.cityList,
      fullScreen: true,
    );
  }
}
