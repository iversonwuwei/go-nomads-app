import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/hotel/domain/entities/hotel_review.dart';
import 'package:go_nomads_app/features/hotel/domain/repositories/i_hotel_repository.dart';
import 'package:go_nomads_app/features/hotel/domain/repositories/i_hotel_review_repository.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/add_hotel_page.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/edit_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/map_app_launcher.dart';
import '../domain/entities/hotel.dart';

class HotelDetailPage extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailPage({super.key, required this.hotel});

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  late Hotel _hotel;

  // 数据变更标记 - 用于返回时通知列表页面更新缓存
  bool _hasDataChanged = false;

  // 评论列表状态
  List<HotelReview> _reviews = [];
  bool _isLoadingReviews = false;
  bool _hasMoreReviews = true;
  int _reviewsPage = 1;
  static const int _reviewsPageSize = 10;

  Hotel get hotel => _hotel;

  @override
  void initState() {
    super.initState();
    _hotel = widget.hotel;
    // 加载完整详情数据（包括房型）
    _reloadHotelDetail();
    // 加载评论列表
    _loadReviews();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 统一处理返回逻辑
  void _handleBack() {
    Navigator.pop(context, _hasDataChanged ? _hotel : null);
  }

  /// 检查当前用户是否有权限编辑酒店
  /// 只有酒店创建者或管理员可以编辑
  bool _canEditHotel() {
    final authController = Get.find<AuthStateController>();
    final currentUser = authController.currentUser.value;
    final currentUserId = currentUser?.id;
    final isAdmin = currentUser?.role == 'admin';

    // 管理员可以编辑任何酒店
    if (isAdmin) return true;

    // 创建者可以编辑自己的酒店
    if (currentUserId != null && _hotel.createdBy == currentUserId) return true;

    return false;
  }

  /// 重新加载酒店详情数据
  Future<void> _reloadHotelDetail() async {
    try {
      final repository = Get.find<IHotelRepository>();
      final result = await repository.getHotelById(_hotel.id);

      result.fold(
        onSuccess: (updatedHotel) {
          if (mounted) {
            setState(() {
              _hotel = updatedHotel;
            });
            log('✅ [HotelDetail] 重新加载详情成功');
          }
        },
        onFailure: (exception) {
          log('❌ [HotelDetail] 重新加载详情失败: ${exception.message}');
        },
      );
    } catch (e) {
      log('❌ [HotelDetail] 重新加载详情异常: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfoSection(),
                  _buildPricingSection(),
                  // 房型区域
                  if (hotel.roomTypes.isNotEmpty) _buildRoomTypesSection(),
                  _buildNomadFeaturesSection(),
                  _buildAmenitiesSection(),
                  _buildContactSection(),
                  // 评论区域
                  _buildReviewsSection(),
                  SizedBox(height: 100.h), // 底部间距
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  /// 构建 SliverAppBar 和图片轮播
  Widget _buildSliverAppBar() {
    final images = hotel.images;
    final hasImages = images.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: hasImages ? Colors.white : null,
      leading: SliverBackButton(onPressed: _handleBack),
      actions: [
        // 编辑按钮 - 只有创建者或管理员可见
        if (_canEditHotel())
          SliverEditButton(
            onPressed: () async {
              await NavigationUtil.toWithCallback<bool>(
                page: () => AddHotelPage(
                  editingHotel: _hotel,
                  cityId: _hotel.cityId,
                  cityName: _hotel.cityName,
                  countryName: _hotel.country,
                ),
                onResult: (result) async {
                  if (result.needsRefresh && mounted) {
                    // 标记数据已变更，下次返回时通知列表页面
                    _hasDataChanged = true;
                    // 重新加载酒店详情
                    await _reloadHotelDetail();
                  }
                },
              );
            },
            size: 18.r,
          ),
        // 图片计数器
        if (images.length > 1)
          Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 6.h,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${images.length}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: hasImages
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // 图片轮播
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _currentImageIndex = index);
                        }
                      });
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.hotel, size: 64.r, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  // 渐变遮罩
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 图片指示器
                  if (images.length > 1)
                    Positioned(
                      bottom: 16.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            width: index == _currentImageIndex ? 24 : 8,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: index == _currentImageIndex ? Colors.white : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              )
            : Container(
                color: Colors.grey[200],
                child: Icon(Icons.hotel, size: 64.r, color: Colors.grey),
              ),
      ),
    );
  }

  /// 基本信息区域：名称、评分、地址、分类标签
  Widget _buildBasicInfoSection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 酒店名称
          Text(
            hotel.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8.h),
          // 评分和星级
          Row(
            children: [
              if (hotel.starRating != null) ...[
                ...List.generate(
                  hotel.starRating!,
                  (index) => Icon(Icons.star, color: Colors.amber, size: 18.r),
                ),
                SizedBox(width: 8.w),
              ],
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  hotel.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                _getRatingText(hotel.rating),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // 地址
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 18.r, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  hotel.address,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // 分类标签
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: [
              _buildTag(hotel.category, Icons.hotel),
              if (hotel.nomadScore >= 70)
                _buildTag(AppLocalizations.of(context)!.nomadFriendly, Icons.laptop_mac, isHighlight: true),
              if (hotel.hasCoworkingSpace) _buildTag(AppLocalizations.of(context)!.coworkingSpace, Icons.business),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建标签
  Widget _buildTag(String text, IconData icon, {bool isHighlight = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isHighlight ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16.r),
        border: isHighlight ? Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.r,
            color: isHighlight ? Theme.of(context).colorScheme.primary : Colors.grey[600],
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: isHighlight ? Theme.of(context).colorScheme.primary : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  /// 根据评分获取文字描述
  String _getRatingText(double rating) {
    final l10n = AppLocalizations.of(context)!;
    if (rating >= 4.5) return l10n.ratingExcellent;
    if (rating >= 4.0) return l10n.ratingVeryGood;
    if (rating >= 3.5) return l10n.ratingGood;
    if (rating >= 3.0) return l10n.ratingAverage;
    return l10n.ratingPoor;
  }

  /// 价格区域
  Widget _buildPricingSection() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.priceLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildPriceItem(
                  l10n.perNightLabel,
                  '${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(0)}',
                  Icons.nights_stay,
                ),
              ),
              if (hotel.hasLongStayDiscount && hotel.longStayDiscountPercent != null) ...[
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildPriceItem(
                    l10n.longStayDiscount,
                    '-${hotel.longStayDiscountPercent!.toStringAsFixed(0)}%',
                    Icons.discount,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 构建价格项
  Widget _buildPriceItem(String label, String price, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20.r),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
            Text(
              price,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 数字游民特性区域
  Widget _buildNomadFeaturesSection() {
    final l10n = AppLocalizations.of(context)!;
    final hasAnyFeature = hotel.hasWifi || hotel.wifiSpeed != null || hotel.hasWorkDesk || hotel.hasCoworkingSpace;

    if (!hasAnyFeature) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.nomadFeatures,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 12.w;
              final cardWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: 12.w,
                children: [
                  if (hotel.hasWifi)
                    _buildFeatureCard(
                      icon: Icons.wifi,
                      title: 'WiFi',
                      subtitle: hotel.wifiSpeed != null ? '${hotel.wifiSpeed} Mbps' : l10n.available,
                      color: Colors.blue,
                      cardWidth: cardWidth,
                    ),
                  if (hotel.hasWorkDesk)
                    _buildFeatureCard(
                      icon: Icons.desk,
                      title: l10n.workDesk,
                      subtitle: l10n.available,
                      color: Colors.green,
                      cardWidth: cardWidth,
                    ),
                  if (hotel.hasCoworkingSpace)
                    _buildFeatureCard(
                      icon: Icons.business,
                      title: l10n.coworkingSpace,
                      subtitle: l10n.coworkingSpaceIncluded,
                      color: Colors.orange,
                      cardWidth: cardWidth,
                    ),
                  if (hotel.hasAirConditioning)
                    _buildFeatureCard(
                      icon: Icons.ac_unit,
                      title: l10n.airConditioning,
                      subtitle: l10n.available,
                      color: Colors.cyan,
                      cardWidth: cardWidth,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建特性卡片
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required double cardWidth,
  }) {
    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.r),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 设施区域
  Widget _buildAmenitiesSection() {
    final l10n = AppLocalizations.of(context)!;
    final amenities = hotel.amenities;
    if (amenities.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.facilities,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: amenities.map((amenity) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getAmenityIcon(amenity),
                      size: 16.r,
                      color: Colors.grey[700],
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      amenity,
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 根据设施名称获取图标
  IconData _getAmenityIcon(String amenity) {
    final lowerAmenity = amenity.toLowerCase();
    if (lowerAmenity.contains('wifi') || lowerAmenity.contains('网络')) return Icons.wifi;
    if (lowerAmenity.contains('空调')) return Icons.ac_unit;
    if (lowerAmenity.contains('早餐')) return Icons.free_breakfast;
    if (lowerAmenity.contains('停车')) return Icons.local_parking;
    if (lowerAmenity.contains('泳池') || lowerAmenity.contains('游泳')) return Icons.pool;
    if (lowerAmenity.contains('健身')) return Icons.fitness_center;
    if (lowerAmenity.contains('餐厅') || lowerAmenity.contains('餐饮')) return Icons.restaurant;
    if (lowerAmenity.contains('洗衣')) return Icons.local_laundry_service;
    if (lowerAmenity.contains('电梯')) return Icons.elevator;
    if (lowerAmenity.contains('24小时')) return Icons.access_time;
    if (lowerAmenity.contains('行李')) return Icons.luggage;
    if (lowerAmenity.contains('机场')) return Icons.flight;
    return Icons.check_circle_outline;
  }

  /// 联系方式区域
  Widget _buildContactSection() {
    final l10n = AppLocalizations.of(context)!;
    final hasContact = hotel.phone != null || hotel.email != null || hotel.website != null;
    if (!hasContact) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.contactInfo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12.h),
          if (hotel.phone != null)
            _buildContactItem(
              icon: Icons.phone,
              label: l10n.phone,
              value: hotel.phone!,
              onTap: () => _launchUrl('tel:${hotel.phone}'),
            ),
          if (hotel.email != null)
            _buildContactItem(
              icon: Icons.email,
              label: l10n.emailLabel,
              value: hotel.email!,
              onTap: () => _launchUrl('mailto:${hotel.email}'),
            ),
          if (hotel.website != null)
            _buildContactItem(
              icon: Icons.language,
              label: l10n.website,
              value: hotel.website!,
              onTap: () => _launchUrl(hotel.website!),
            ),
        ],
      ),
    );
  }

  /// 构建联系方式项
  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                size: 20.r,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  /// 打开URL
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// 底部导航栏
  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 第一行：查看房型和写评论按钮
            Row(
              children: [
                // 查看房型按钮
                if (hotel.roomTypes.isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showRoomTypesModal,
                      icon: Icon(Icons.bed, size: 20.r),
                      label: Text(l10n.roomTypes(hotel.roomTypes.length.toString())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                if (hotel.roomTypes.isNotEmpty) SizedBox(width: 12.w),
                // 写评论按钮
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showWriteReviewDialog,
                    icon: Icon(Icons.rate_review, size: 20.r),
                    label: Text(l10n.writeReview),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // 第二行：路线导航和访问网站
            Row(
              children: [
                // 路线导航按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onNavigationPressed,
                    icon: const Icon(Icons.directions),
                    label: Text(l10n.directions),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                // 访问网站按钮
                if (hotel.website != null) ...[
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(hotel.website!),
                      icon: const Icon(Icons.language),
                      label: Text(l10n.visitWebsite),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 显示房型模态框
  void _showRoomTypesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // 拖动条
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // 标题
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.roomTypeList,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // 房型列表
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(16.w),
                  itemCount: hotel.roomTypes.length,
                  itemBuilder: (context, index) {
                    final roomType = hotel.roomTypes[index];
                    return _buildRoomTypeCard(roomType);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 房型卡片
  Widget _buildRoomTypeCard(RoomType roomType) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 房型图片
            if (roomType.images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: roomType.images.first,
                  height: 150.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 150.h,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150.h,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 48.r, color: Colors.grey),
                  ),
                ),
              ),
            SizedBox(height: 12.h),
            // 房型名称和状态
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    roomType.name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!roomType.isAvailable)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.soldOut,
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            // 房型描述
            if (roomType.description.isNotEmpty)
              Text(
                roomType.description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: 12.h),
            // 房型信息
            Wrap(
              spacing: 12.w,
              runSpacing: 8.w,
              children: [
                _buildRoomInfoChip(Icons.bed, roomType.bedType),
                _buildRoomInfoChip(
                    Icons.people, AppLocalizations.of(context)!.maxOccupancy(roomType.maxOccupancy.toString())),
                if (roomType.size > 0) _buildRoomInfoChip(Icons.square_foot, '${roomType.size.toInt()}㎡'),
              ],
            ),
            SizedBox(height: 12.h),
            // 价格
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 设施标签
                Wrap(
                  spacing: 4.w,
                  children: roomType.amenities.take(3).map((amenity) {
                    return Chip(
                      label: Text(amenity, style: TextStyle(fontSize: 10.sp)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                // 价格
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${roomType.currency} ${roomType.pricePerNight.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.perNight,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 房型信息标签
  Widget _buildRoomInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: Colors.grey[700]),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  /// 显示写评论对话框
  void _showWriteReviewDialog() {
    final l10n = AppLocalizations.of(context)!;
    // 检查用户是否已登录
    final authController = Get.find<AuthStateController>();
    if (!authController.isAuthenticated.value) {
      AppToast.info(l10n.pleaseLoginToReview);
      return;
    }

    final titleController = TextEditingController();
    final contentController = TextEditingController();
    double rating = 0;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            padding: EdgeInsets.all(20.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 拖动条
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // 标题
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.writeReview,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // 评分
                  Text(
                    l10n.rating,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => rating = index + 1.0);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40.r,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      _getReviewRatingText(rating),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // 标题输入
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: l10n.reviewTitleOptional,
                      hintText: l10n.reviewTitleHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // 内容输入
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.reviewContent,
                      hintText: l10n.reviewContentHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // 提交按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (rating == 0) {
                                AppToast.info(l10n.selectRating);
                                return;
                              }
                              if (contentController.text.trim().isEmpty) {
                                AppToast.info(l10n.enterReviewContent);
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              await _submitReview(
                                rating: rating.toInt(),
                                title: titleController.text.trim().isNotEmpty ? titleController.text.trim() : null,
                                content: contentController.text.trim(),
                                onSuccess: () {
                                  Navigator.pop(context);
                                  AppToast.success(l10n.reviewSubmitSuccess);
                                  // 标记数据已变更并重新加载酒店详情
                                  _hasDataChanged = true;
                                  _reloadHotelDetail();
                                },
                                onError: (String message) {
                                  setModalState(() => isSubmitting = false);
                                  AppToast.error(message);
                                },
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: isSubmitting
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(l10n.submitReview),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 提交评论到后端
  Future<void> _submitReview({
    required int rating,
    String? title,
    required String content,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    try {
      final reviewRepository = Get.find<IHotelReviewRepository>();
      final request = CreateHotelReviewRequest(
        rating: rating,
        title: title,
        content: content,
      );

      final result = await reviewRepository.createReview(
        hotelId: _hotel.id,
        request: request,
      );

      result.fold(
        onSuccess: (review) {
          log('✅ 评论创建成功: ${review.id}');
          // 刷新评论列表
          _loadReviews(refresh: true);
          // 重新加载酒店详情（更新评分和评论数）
          _reloadHotelDetail();
          onSuccess();
        },
        onFailure: (exception) {
          log('❌ 评论创建失败: ${exception.message}');
          String errorMessage = AppLocalizations.of(Get.context!)!.reviewSubmitFailed;
          if (exception.message.contains('已经评论过')) {
            errorMessage = AppLocalizations.of(Get.context!)!.alreadyReviewed;
          }
          onError(errorMessage);
        },
      );
    } catch (e) {
      log('❌ 评论创建异常: $e');
      onError(AppLocalizations.of(Get.context!)!.reviewSubmitFailedRetry);
    }
  }

  /// 获取评论评分文字
  String _getReviewRatingText(double rating) {
    final l10n = AppLocalizations.of(context)!;
    if (rating == 0) return l10n.tapToRate;
    if (rating == 1) return l10n.ratingVeryPoor;
    if (rating == 2) return l10n.ratingFair;
    if (rating == 3) return l10n.ratingNice;
    if (rating == 4) return l10n.ratingGreat;
    return l10n.ratingExcellentReview;
  }

  /// 加载评论列表
  Future<void> _loadReviews({bool refresh = false}) async {
    if (_isLoadingReviews) return;
    if (!refresh && !_hasMoreReviews) return;

    if (refresh) {
      _reviewsPage = 1;
      _hasMoreReviews = true;
    }

    setState(() => _isLoadingReviews = true);

    try {
      final reviewRepository = Get.find<IHotelReviewRepository>();
      final result = await reviewRepository.getHotelReviews(
        hotelId: _hotel.id,
        page: _reviewsPage,
        pageSize: _reviewsPageSize,
      );

      result.fold(
        onSuccess: (response) {
          if (mounted) {
            setState(() {
              if (refresh) {
                _reviews = response.reviews;
              } else {
                _reviews.addAll(response.reviews);
              }
              _hasMoreReviews = _reviewsPage < response.totalPages;
              _reviewsPage++;
              _isLoadingReviews = false;
            });
            log('✅ [HotelDetail] 加载评论成功: ${response.reviews.length} 条, 总计: ${response.totalCount}');
          }
        },
        onFailure: (exception) {
          if (mounted) {
            setState(() => _isLoadingReviews = false);
          }
          log('❌ [HotelDetail] 加载评论失败: ${exception.message}');
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
      log('❌ [HotelDetail] 加载评论异常: $e');
    }
  }

  /// 房型区域
  Widget _buildRoomTypesSection() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bed,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.roomTypeList,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _showRoomTypesModal,
                child: Text(l10n.viewAll(hotel.roomTypes.length.toString())),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // 显示前2个房型简介
          ...hotel.roomTypes.take(2).map((roomType) => _buildRoomTypeSummary(roomType)),
        ],
      ),
    );
  }

  /// 房型简介卡片
  Widget _buildRoomTypeSummary(RoomType roomType) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // 房型图片
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: roomType.images.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: roomType.images.first,
                    width: 60.w,
                    height: 60.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60.w,
                      height: 60.h,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60.w,
                      height: 60.h,
                      color: Colors.grey[200],
                      child: const Icon(Icons.bed, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 60.w,
                    height: 60.h,
                    color: Colors.grey[200],
                    child: const Icon(Icons.bed, color: Colors.grey),
                  ),
          ),
          SizedBox(width: 12.w),
          // 房型信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomType.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${roomType.bedType} · ${l10n.maxOccupancy(roomType.maxOccupancy.toString())}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // 价格
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${roomType.currency} ${roomType.pricePerNight.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                l10n.perNight,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 评论区域
  Widget _buildReviewsSection() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.rate_review,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.userReviews,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // 评分显示
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getRatingColor(hotel.rating),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 16.r),
                    SizedBox(width: 4.w),
                    Text(
                      hotel.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // 评论统计
          Row(
            children: [
              Text(
                l10n.reviewCount(hotel.reviewCount.toString()),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                _getRatingDescription(hotel.rating),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _getRatingColor(hotel.rating),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // 暂无评论提示或评论列表
          if (hotel.reviewCount == 0)
            Center(
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48.r, color: Colors.grey[300]),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.noReviews,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextButton.icon(
                    onPressed: _showWriteReviewDialog,
                    icon: Icon(Icons.edit, size: 16.r),
                    label: Text(l10n.beFirstReviewer),
                  ),
                ],
              ),
            )
          else
            // 评论列表
            Column(
              children: [
                // 写评论按钮
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _showWriteReviewDialog,
                    icon: Icon(Icons.edit, size: 16.r),
                    label: Text(l10n.writeReview),
                  ),
                ),
                SizedBox(height: 8.h),
                // 评论列表
                if (_isLoadingReviews && _reviews.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_reviews.isEmpty)
                  Center(
                    child: Text(
                      l10n.noReviews,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      ..._reviews.map((review) => _buildReviewItem(review)),
                      // 加载更多按钮
                      if (_hasMoreReviews)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: _isLoadingReviews
                              ? Center(
                                  child: SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : TextButton(
                                  onPressed: _loadReviews,
                                  child: Text(l10n.loadMoreReviews),
                                ),
                        ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }

  /// 构建单个评论项
  Widget _buildReviewItem(HotelReview review) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息和评分
          Row(
            children: [
              // 用户头像
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[300],
                backgroundImage: review.userAvatar != null ? CachedNetworkImageProvider(review.userAvatar!) : null,
                child: review.userAvatar == null
                    ? Text(
                        review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              // 用户名和时间
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (review.isVerified) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.verified,
                            size: 14.r,
                            color: Colors.blue[400],
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatReviewDate(review.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              // 评分
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getRatingColor(review.rating.toDouble()),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 14.r),
                    SizedBox(width: 2.w),
                    Text(
                      review.rating.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // 评论标题
          if (review.title != null && review.title!.isNotEmpty) ...[
            Text(
              review.title!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
          ],
          // 评论内容
          Text(
            review.content,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          // 评论图片
          if (review.photoUrls.isNotEmpty) ...[
            SizedBox(height: 10.h),
            SizedBox(
              height: 80.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.photoUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: review.photoUrls[index],
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image, size: 24.r),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          // 有用数
          if (review.helpfulCount > 0) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 14.r, color: Colors.grey[500]),
                SizedBox(width: 4.w),
                Text(
                  l10n.helpfulCount(review.helpfulCount.toString()),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 格式化评论日期
  String _formatReviewDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return l10n.minutesAgo(difference.inMinutes.toString());
      }
      return l10n.hoursAgo(difference.inHours.toString());
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays.toString());
    } else if (difference.inDays < 30) {
      return l10n.weeksAgo((difference.inDays / 7).floor().toString());
    } else if (difference.inDays < 365) {
      return l10n.monthsAgo((difference.inDays / 30).floor().toString());
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  /// 获取评分颜色
  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.0) return Colors.orange;
    if (rating >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  /// 获取评分描述
  String _getRatingDescription(double rating) {
    final l10n = AppLocalizations.of(context)!;
    if (rating >= 4.5) return l10n.ratingDescExcellent;
    if (rating >= 4.0) return l10n.ratingDescVeryGood;
    if (rating >= 3.0) return l10n.ratingDescGood;
    if (rating >= 2.0) return l10n.ratingDescAverage;
    return l10n.ratingDescPoor;
  }

  /// 点击导航按钮
  void _onNavigationPressed() {
    MapAppLauncher.showMapSelectionDialog(
      context: context,
      latitude: hotel.latitude,
      longitude: hotel.longitude,
      destinationName: hotel.name,
    );
  }
}
