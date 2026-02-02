import 'package:flutter/material.dart';
import 'base_skeleton.dart';

/// City Tab Skeleton Base - 城市详情 Tab 骨架屏基类
class CityTabSkeleton extends StatelessWidget {
  final Widget child;

  const CityTabSkeleton({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: child,
    );
  }
}

/// Photos Tab Skeleton - 照片 Tab 骨架屏
class PhotosTabSkeleton extends StatelessWidget {
  const PhotosTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          return SkeletonBox(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 8,
          );
        },
      ),
    );
  }
}

/// Scores Tab Skeleton - 评分 Tab 骨架屏
class ScoresTabSkeleton extends StatelessWidget {
  const ScoresTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ScoreItemSkeleton(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreItemSkeleton extends StatelessWidget {
  const _ScoreItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(width: 32, height: 32, borderRadius: 6),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 100, height: 16),
              SizedBox(height: 8),
              SkeletonBox(width: double.infinity, height: 8, borderRadius: 4),
            ],
          ),
        ),
        SizedBox(width: 12),
        SkeletonBox(width: 40, height: 20),
      ],
    );
  }
}

/// Weather Tab Skeleton - 天气 Tab 骨架屏
class WeatherTabSkeleton extends StatelessWidget {
  const WeatherTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 当前天气
            _CurrentWeatherSkeleton(),
            SizedBox(height: 24),
            // 天气预报
            SkeletonBox(width: 100, height: 20),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DayForecastSkeleton(),
                _DayForecastSkeleton(),
                _DayForecastSkeleton(),
                _DayForecastSkeleton(),
                _DayForecastSkeleton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentWeatherSkeleton extends StatelessWidget {
  const _CurrentWeatherSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          SkeletonBox(width: 80, height: 80, borderRadius: 40),
          SizedBox(height: 16),
          SkeletonBox(width: 100, height: 48),
          SizedBox(height: 8),
          SkeletonBox(width: 80, height: 20),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonBox(width: 60, height: 14),
              SizedBox(width: 24),
              SkeletonBox(width: 60, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayForecastSkeleton extends StatelessWidget {
  const _DayForecastSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonBox(width: 40, height: 14),
        SizedBox(height: 8),
        SkeletonBox(width: 32, height: 32, borderRadius: 16),
        SizedBox(height: 8),
        SkeletonBox(width: 36, height: 14),
      ],
    );
  }
}

/// Reviews Tab Skeleton - 评论 Tab 骨架屏
class ReviewsTabSkeleton extends StatelessWidget {
  final int itemCount;

  const ReviewsTabSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _ReviewItemSkeleton();
        },
      ),
    );
  }
}

class _ReviewItemSkeleton extends StatelessWidget {
  const _ReviewItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonCircle(size: 40),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 100, height: 16),
                    SizedBox(height: 4),
                    SkeletonBox(width: 80, height: 12),
                  ],
                ),
              ),
              SkeletonBox(width: 60, height: 20),
            ],
          ),
          SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 14),
          SizedBox(height: 4),
          SkeletonBox(width: double.infinity, height: 14),
          SizedBox(height: 4),
          SkeletonBox(width: 200, height: 14),
        ],
      ),
    );
  }
}

/// Pros Cons Tab Skeleton - 优缺点 Tab 骨架屏
class ProsConsTabSkeleton extends StatelessWidget {
  const ProsConsTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pros 标题
            SkeletonBox(width: 60, height: 20),
            SizedBox(height: 12),
            // Pros 列表
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProsConsItemSkeleton(isPro: true),
              ),
            ),
            SizedBox(height: 20),
            // Cons 标题
            SkeletonBox(width: 60, height: 20),
            SizedBox(height: 12),
            // Cons 列表
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProsConsItemSkeleton(isPro: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProsConsItemSkeleton extends StatelessWidget {
  final bool isPro;

  const _ProsConsItemSkeleton({required this.isPro});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 24, height: 24, borderRadius: 12),
          SizedBox(width: 12),
          Expanded(child: SkeletonBox(width: double.infinity, height: 16)),
          SizedBox(width: 12),
          SkeletonBox(width: 40, height: 20),
        ],
      ),
    );
  }
}

/// Coworking Tab Skeleton - Coworking Tab 骨架屏
class CoworkingTabSkeleton extends StatelessWidget {
  final int itemCount;

  const CoworkingTabSkeleton({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _CoworkingItemSkeleton(),
          );
        },
      ),
    );
  }
}

class _CoworkingItemSkeleton extends StatelessWidget {
  const _CoworkingItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          SkeletonBox(width: double.infinity, height: 140, borderRadius: 12),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 180, height: 18),
                SizedBox(height: 8),
                SkeletonBox(width: 140, height: 14),
                SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonBox(width: 60, height: 14),
                    SizedBox(width: 16),
                    SkeletonBox(width: 80, height: 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cost Tab Skeleton - 花费 Tab 骨架屏
class CostTabSkeleton extends StatelessWidget {
  const CostTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 总费用卡片
            _TotalCostSkeleton(),
            SizedBox(height: 24),
            // 费用明细
            ...List.generate(
              6,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CostItemSkeleton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalCostSkeleton extends StatelessWidget {
  const _TotalCostSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          SkeletonBox(width: 120, height: 16),
          SizedBox(height: 12),
          SkeletonBox(width: 150, height: 40),
          SizedBox(height: 8),
          SkeletonBox(width: 80, height: 14),
        ],
      ),
    );
  }
}

class _CostItemSkeleton extends StatelessWidget {
  const _CostItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(width: 40, height: 40, borderRadius: 8),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 100, height: 16),
              SizedBox(height: 4),
              SkeletonBox(width: 60, height: 12),
            ],
          ),
        ),
        SkeletonBox(width: 80, height: 20),
      ],
    );
  }
}

/// Manage List Skeleton - 管理列表骨架屏（通用）
class ManageListSkeleton extends StatelessWidget {
  final int itemCount;

  const ManageListSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return SafeShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const Divider(height: 24),
        itemBuilder: (context, index) {
          return _ManageItemSkeleton();
        },
      ),
    );
  }
}

class _ManageItemSkeleton extends StatelessWidget {
  const _ManageItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 200, height: 18),
              SizedBox(height: 6),
              SkeletonBox(width: 150, height: 14),
              SizedBox(height: 4),
              SkeletonBox(width: 100, height: 12),
            ],
          ),
        ),
        SkeletonBox(width: 32, height: 32, borderRadius: 6),
      ],
    );
  }
}
