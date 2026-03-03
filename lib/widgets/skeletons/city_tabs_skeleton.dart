import 'package:flutter/material.dart';
import 'base_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.w,
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
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: List.generate(
            6,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
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
    return Row(
      children: [
        SkeletonBox(width: 32.w, height: 32.h, borderRadius: 6),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 100.w, height: 16.h),
              SizedBox(height: 8.h),
              SkeletonBox(width: double.infinity, height: 8.h, borderRadius: 4),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        SkeletonBox(width: 40.w, height: 20.h),
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
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // 当前天气
            _CurrentWeatherSkeleton(),
            SizedBox(height: 24.h),
            // 天气预报
            SkeletonBox(width: 100.w, height: 20.h),
            SizedBox(height: 16.h),
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          SkeletonBox(width: 80.w, height: 80.h, borderRadius: 40),
          SizedBox(height: 16.h),
          SkeletonBox(width: 100.w, height: 48.h),
          SizedBox(height: 8.h),
          SkeletonBox(width: 80.w, height: 20.h),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonBox(width: 60.w, height: 14.h),
              SizedBox(width: 24.w),
              SkeletonBox(width: 60.w, height: 14.h),
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
    return Column(
      children: [
        SkeletonBox(width: 40.w, height: 14.h),
        SizedBox(height: 8.h),
        SkeletonBox(width: 32.w, height: 32.h, borderRadius: 16),
        SizedBox(height: 8.h),
        SkeletonBox(width: 36.w, height: 14.h),
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
        padding: EdgeInsets.all(16.w),
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonCircle(size: 40.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 100.w, height: 16.h),
                    SizedBox(height: 4.h),
                    SkeletonBox(width: 80.w, height: 12.h),
                  ],
                ),
              ),
              SkeletonBox(width: 60.w, height: 20.h),
            ],
          ),
          SizedBox(height: 12.h),
          SkeletonBox(width: double.infinity, height: 14.h),
          SizedBox(height: 4.h),
          SkeletonBox(width: double.infinity, height: 14.h),
          SizedBox(height: 4.h),
          SkeletonBox(width: 200.w, height: 14.h),
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
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pros 标题
            SkeletonBox(width: 60.w, height: 20.h),
            SizedBox(height: 12.h),
            // Pros 列表
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _ProsConsItemSkeleton(isPro: true),
              ),
            ),
            SizedBox(height: 20.h),
            // Cons 标题
            SkeletonBox(width: 60.w, height: 20.h),
            SizedBox(height: 12.h),
            // Cons 列表
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 24.w, height: 24.h, borderRadius: 12),
          SizedBox(width: 12.w),
          Expanded(child: SkeletonBox(width: double.infinity, height: 16.h)),
          SizedBox(width: 12.w),
          SkeletonBox(width: 40.w, height: 20.h),
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
        padding: EdgeInsets.all(16.w),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
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
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SkeletonBox(width: double.infinity, height: 140.h, borderRadius: 12),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 180.w, height: 18.h),
                SizedBox(height: 8.h),
                SkeletonBox(width: 140.w, height: 14.h),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    SkeletonBox(width: 60.w, height: 14.h),
                    SizedBox(width: 16.w),
                    SkeletonBox(width: 80.w, height: 14.h),
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
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // 总费用卡片
            _TotalCostSkeleton(),
            SizedBox(height: 24.h),
            // 费用明细
            ...List.generate(
              6,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          SkeletonBox(width: 120.w, height: 16.h),
          SizedBox(height: 12.h),
          SkeletonBox(width: 150.w, height: 40.h),
          SizedBox(height: 8.h),
          SkeletonBox(width: 80.w, height: 14.h),
        ],
      ),
    );
  }
}

class _CostItemSkeleton extends StatelessWidget {
  const _CostItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SkeletonBox(width: 40.w, height: 40.h, borderRadius: 8),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 100.w, height: 16.h),
              SizedBox(height: 4.h),
              SkeletonBox(width: 60.w, height: 12.h),
            ],
          ),
        ),
        SkeletonBox(width: 80.w, height: 20.h),
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
        padding: EdgeInsets.all(16.w),
        itemCount: itemCount,
        separatorBuilder: (context, index) => Divider(height: 24),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 200.w, height: 18.h),
              SizedBox(height: 6.h),
              SkeletonBox(width: 150.w, height: 14.h),
              SizedBox(height: 4.h),
              SkeletonBox(width: 100.w, height: 12.h),
            ],
          ),
        ),
        SkeletonBox(width: 32.w, height: 32.h, borderRadius: 6),
      ],
    );
  }
}
