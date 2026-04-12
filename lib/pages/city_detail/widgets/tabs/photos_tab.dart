import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:go_nomads_app/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

import '../../city_detail_controller.dart';

/// Photos Tab - GetView 实现
class PhotosTab extends GetView<CityDetailController> {
  const PhotosTab({super.key, required String tag}) : _tag = tag;

  final String _tag;

  @override
  String? get tag => _tag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userContentController = Get.find<UserCityContentStateController>();
    final currentTag = tag ?? '';

    return Obx(() {
      final photos = userContentController.photos;
      final isLoading = userContentController.isLoadingPhotos.value;
      final isRefreshing = controller.isRefreshingPhotos.value;
      final showInitialLoading = isLoading && photos.isEmpty && !isRefreshing;

      final content = photos.isEmpty
          ? _EmptyPhotosState(
              tag: currentTag,
              l10n: l10n,
            )
          : _PhotosContent(
              tag: currentTag,
              groupedList: _groupPhotos(photos, l10n),
              allPhotos: photos,
              l10n: l10n,
            );

      return AppLoadingSwitcher(
        isLoading: showInitialLoading,
        loading: const PhotosTabSkeleton(),
        child: content,
      );
    });
  }

  List<_PhotoGroup> _groupPhotos(List<UserCityPhoto> photos, AppLocalizations l10n) {
    final groupedMap = <String, _PhotoGroup>{};
    for (final photo in photos) {
      final resolvedTitle = _resolvePhotoTitle(photo, l10n);
      final groupKey = '${photo.userId}::$resolvedTitle';
      final group = groupedMap.putIfAbsent(
        groupKey,
        () => _PhotoGroup(
          title: resolvedTitle,
          uploaderId: photo.userId,
        ),
      );
      group.photos.add(photo);
      if (photo.createdAt.isAfter(group.latestUpload)) {
        group.latestUpload = photo.createdAt;
      }
    }

    return groupedMap.values.toList()..sort((a, b) => b.latestUpload.compareTo(a.latestUpload));
  }

  String _resolvePhotoTitle(UserCityPhoto photo, AppLocalizations l10n) {
    if (photo.caption?.trim().isNotEmpty ?? false) {
      return photo.caption!.trim();
    }
    final id = photo.id;
    if (id.length <= 8) {
      return '${l10n.photo} $id';
    }
    return '${l10n.photo} ${id.substring(0, 4)}...${id.substring(id.length - 4)}';
  }
}

/// 空状态组件
class _EmptyPhotosState extends GetView<CityDetailController> {
  const _EmptyPhotosState({
    required String tag,
    required this.l10n,
  }) : _photoTag = tag;

  final String _photoTag;
  final AppLocalizations l10n;

  @override
  String? get tag => _photoTag;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _handleRefreshPhotos(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: AppUiTokens.softFloatingShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72.w,
                        height: 72.w,
                        decoration: BoxDecoration(
                          color: AppColors.travelSky.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(FontAwesomeIcons.images, size: 28.r, color: AppColors.travelSky),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'No photos yet',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Be the first to share a photo!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRefreshPhotos() async {
    final userContentController = Get.find<UserCityContentStateController>();
    controller.isRefreshingPhotos.value = true;
    await userContentController.loadCityPhotos(controller.cityId);
    controller.isRefreshingPhotos.value = false;
  }
}

/// 照片内容组件
class _PhotosContent extends GetView<CityDetailController> {
  const _PhotosContent({
    required String tag,
    required this.groupedList,
    required this.allPhotos,
    required this.l10n,
  }) : _photoTag = tag;

  final String _photoTag;
  final List<_PhotoGroup> groupedList;
  final List<UserCityPhoto> allPhotos;
  final AppLocalizations l10n;

  @override
  String? get tag => _photoTag;

  @override
  Widget build(BuildContext context) {
    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.photos,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    for (var i = 0; i < groupedList.length; i++) {
      final group = groupedList[i];
      final uploaderName = _resolveUploaderName(group.uploaderId);

      // 分组标题
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, i == 0 ? 8 : 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // 照片网格
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.w,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final photo = group.photos[index];
                final globalIndex = allPhotos.indexWhere((e) => e.id == photo.id);
                final initialIndex = globalIndex >= 0 ? globalIndex : 0;

                return _PhotoGridItem(
                  photo: photo,
                  onTap: () => _showPhotoGallery(context, allPhotos, initialIndex),
                );
              },
              childCount: group.photos.length,
            ),
          ),
        ),
      );

      // 上传者信息
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              i == groupedList.length - 1 ? 96 : 16,
            ),
            child: Text(
              '$uploaderName | ${l10n.uploaded} ${_formatDate(group.latestUpload)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _handleRefreshPhotos(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: slivers,
      ),
    );
  }

  String _resolveUploaderName(String uploaderId) {
    final userContentController = Get.find<UserCityContentStateController>();
    final cachedName = userContentController.photoUploaderNames[uploaderId];
    if (cachedName != null && cachedName.trim().isNotEmpty) {
      return cachedName.trim();
    }
    return _formatUploaderId(uploaderId);
  }

  String _formatUploaderId(String userId) {
    if (userId.length <= 8) {
      return userId;
    }
    return '${userId.substring(0, 4)}...${userId.substring(userId.length - 4)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _handleRefreshPhotos() async {
    final userContentController = Get.find<UserCityContentStateController>();
    controller.isRefreshingPhotos.value = true;
    await userContentController.loadCityPhotos(controller.cityId);
    controller.isRefreshingPhotos.value = false;
  }

  void _showPhotoGallery(BuildContext context, List<UserCityPhoto> photos, int initialIndex) {
    if (photos.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    Get.dialog(
      _PhotoGalleryDialog(
        photos: photos,
        initialIndex: initialIndex,
        l10n: l10n,
      ),
      barrierColor: Colors.black87,
    );
  }
}

/// 照片网格项
class _PhotoGridItem extends StatelessWidget {
  const _PhotoGridItem({
    required this.photo,
    required this.onTap,
  });

  final UserCityPhoto photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'city-photo-${photo.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.network(
                  photo.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 6.h,
                right: 6.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.9)),
                  ),
                  child: Icon(
                    FontAwesomeIcons.magnifyingGlassPlus,
                    size: 14.r,
                      color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 照片画廊弹窗
class _PhotoGalleryDialog extends StatefulWidget {
  const _PhotoGalleryDialog({
    required this.photos,
    required this.initialIndex,
    required this.l10n,
  });

  final List<UserCityPhoto> photos;
  final int initialIndex;
  final AppLocalizations l10n;

  @override
  State<_PhotoGalleryDialog> createState() => _PhotoGalleryDialogState();
}

class _PhotoGalleryDialogState extends State<_PhotoGalleryDialog> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    final l10n = widget.l10n;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Container(
          color: const Color(0xFF101418),
          child: Column(
            children: [
              _buildHeader(photos.length),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() {
                    _currentIndex = value;
                  }),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return Hero(
                      tag: 'city-photo-${photo.id}',
                      child: InteractiveViewer(
                        minScale: 0.9,
                        maxScale: 4,
                        child: Center(
                          child: Image.network(
                            photo.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildPhotoInfo(photos[_currentIndex], l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int total) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 4.h),
      child: Row(
        children: [
          _GalleryActionButton(
            icon: FontAwesomeIcons.xmark,
            onTap: Get.back,
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Text(
              '${_currentIndex + 1}/$total',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoInfo(UserCityPhoto photo, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (photo.caption?.trim().isNotEmpty ?? false) ? photo.caption!.trim() : l10n.photo,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          if ((photo.location?.isNotEmpty ?? false) || photo.placeName?.isNotEmpty == true)
            Row(
              children: [
                Icon(FontAwesomeIcons.locationDot, size: 16.r, color: Colors.white54),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    photo.placeName?.isNotEmpty == true ? photo.placeName! : (photo.location ?? ''),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 4.h),
          Text(
            '${l10n.uploaded} ${_formatDate(photo.createdAt)}',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// 照片分组数据类
class _PhotoGroup {
  _PhotoGroup({required this.title, required this.uploaderId})
      : photos = [],
        latestUpload = DateTime.fromMillisecondsSinceEpoch(0);

  final String title;
  final String uploaderId;
  final List<UserCityPhoto> photos;
  DateTime latestUpload;
}

class _GalleryActionButton extends StatelessWidget {
  const _GalleryActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Icon(icon, color: Colors.white, size: 18.r),
        ),
      ),
    );
  }
}
