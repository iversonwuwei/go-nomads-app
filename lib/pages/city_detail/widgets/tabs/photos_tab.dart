import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:df_admin_mobile/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/city_photo_submission_page.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../city_detail_controller.dart';
import '../city_tab_cta_button.dart';

/// Photos Tab - GetView 实现
class PhotosTab extends GetView<CityDetailController> {
  const PhotosTab({super.key, required this.tag});

  @override
  final String tag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userContentController = Get.find<UserCityContentStateController>();

    return Obx(() {
      final photos = userContentController.photos;
      final isLoading = userContentController.isLoadingPhotos.value;
      final isRefreshing = controller.isRefreshingPhotos.value;

      if (isLoading && photos.isEmpty && !isRefreshing) {
        return const PhotosTabSkeleton();
      }

      if (photos.isEmpty) {
        return _EmptyPhotosState(
          tag: tag,
          l10n: l10n,
        );
      }

      final groupedList = _groupPhotos(photos, l10n);

      return _PhotosContent(
        tag: tag,
        groupedList: groupedList,
        allPhotos: photos,
        l10n: l10n,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.images, size: 56, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      'No photos yet',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to share a photo!',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 16),
                    CityTabCtaButton(
                      icon: controller.isAdmin.value || controller.isModerator.value
                          ? FontAwesomeIcons.gear
                          : FontAwesomeIcons.camera,
                      label: controller.isAdmin.value || controller.isModerator.value ? '管理' : '上传照片',
                      onPressed: () => Get.to(
                        () => CityPhotoSubmissionPage(
                          cityId: controller.cityId,
                          cityName: controller.cityName,
                        ),
                      ),
                    ),
                  ],
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.photos,
                style: const TextStyle(
                  fontSize: 18,
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
                  style: const TextStyle(
                    fontSize: 16,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
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
              style: const TextStyle(
                fontSize: 12,
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
          borderRadius: BorderRadius.circular(10),
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
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.magnifyingGlassPlus,
                    size: 14,
                    color: Colors.white,
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: Colors.black,
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
    );
  }

  Widget _buildHeader(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.xmark, color: Colors.white),
            onPressed: Get.back,
          ),
          const Spacer(),
          Text(
            '${_currentIndex + 1}/$total',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildPhotoInfo(UserCityPhoto photo, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (photo.caption?.trim().isNotEmpty ?? false) ? photo.caption!.trim() : l10n.photo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          if ((photo.location?.isNotEmpty ?? false) || photo.placeName?.isNotEmpty == true)
            Row(
              children: [
                const Icon(FontAwesomeIcons.locationDot, size: 16, color: Colors.white54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    photo.placeName?.isNotEmpty == true ? photo.placeName! : (photo.location ?? ''),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4),
          Text(
            '${l10n.uploaded} ${_formatDate(photo.createdAt)}',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
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
