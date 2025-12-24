import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/hotel/domain/repositories/i_hotel_repository.dart';
import 'package:df_admin_mobile/pages/add_hotel_page.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/edit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

  Hotel get hotel => _hotel;

  @override
  void initState() {
    super.initState();
    _hotel = widget.hotel;
    // 加载完整详情数据（包括房型）
    _reloadHotelDetail();
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
                  const SizedBox(height: 100), // 底部间距
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
        // 编辑按钮
        SliverEditButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddHotelPage(
                  editingHotel: _hotel,
                  cityId: _hotel.cityId,
                  cityName: _hotel.cityName,
                  countryName: _hotel.country,
                ),
              ),
            );
            if (result == true && mounted) {
              // 标记数据已变更，下次返回时通知列表页面
              _hasDataChanged = true;
              // 重新加载酒店详情
              await _reloadHotelDetail();
            }
          },
          size: 18,
        ),
        // 图片计数器
        if (images.length > 1)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
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
                          child: const Icon(Icons.hotel, size: 64, color: Colors.grey),
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
                      height: 80,
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
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: index == _currentImageIndex ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == _currentImageIndex ? Colors.white : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              )
            : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.hotel, size: 64, color: Colors.grey),
              ),
      ),
    );
  }

  /// 基本信息区域：名称、评分、地址、分类标签
  Widget _buildBasicInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 8),
          // 评分和星级
          Row(
            children: [
              if (hotel.starRating != null) ...[
                ...List.generate(
                  hotel.starRating!,
                  (index) => const Icon(Icons.star, color: Colors.amber, size: 18),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  hotel.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getRatingText(hotel.rating),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 地址
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  hotel.address,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 分类标签
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag(hotel.category, Icons.hotel),
              if (hotel.nomadScore >= 70) _buildTag('数字游民友好', Icons.laptop_mac, isHighlight: true),
              if (hotel.hasCoworkingSpace) _buildTag('配套共享空间', Icons.business),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建标签
  Widget _buildTag(String text, IconData icon, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlight ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: isHighlight ? Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isHighlight ? Theme.of(context).colorScheme.primary : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isHighlight ? Theme.of(context).colorScheme.primary : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  /// 根据评分获取文字描述
  String _getRatingText(double rating) {
    if (rating >= 4.5) return '极好';
    if (rating >= 4.0) return '很好';
    if (rating >= 3.5) return '不错';
    if (rating >= 3.0) return '一般';
    return '较差';
  }

  /// 价格区域
  Widget _buildPricingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '价格',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPriceItem(
                  '每晚',
                  '${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(0)}',
                  Icons.nights_stay,
                ),
              ),
              if (hotel.hasLongStayDiscount && hotel.longStayDiscountPercent != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPriceItem(
                    '长住优惠',
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
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(
              price,
              style: TextStyle(
                fontSize: 18,
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
    final hasAnyFeature = hotel.hasWifi || hotel.wifiSpeed != null || hotel.hasWorkDesk || hotel.hasCoworkingSpace;

    if (!hasAnyFeature) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '数字游民特性',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (hotel.hasWifi)
                _buildFeatureCard(
                  icon: Icons.wifi,
                  title: 'WiFi',
                  subtitle: hotel.wifiSpeed != null ? '${hotel.wifiSpeed} Mbps' : '有',
                  color: Colors.blue,
                ),
              if (hotel.hasWorkDesk)
                _buildFeatureCard(
                  icon: Icons.desk,
                  title: '工作桌',
                  subtitle: '有',
                  color: Colors.green,
                ),
              if (hotel.hasCoworkingSpace)
                _buildFeatureCard(
                  icon: Icons.business,
                  title: '共享空间',
                  subtitle: '配套',
                  color: Colors.orange,
                ),
              if (hotel.hasAirConditioning)
                _buildFeatureCard(
                  icon: Icons.ac_unit,
                  title: '空调',
                  subtitle: '有',
                  color: Colors.cyan,
                ),
            ],
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
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
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
    final amenities = hotel.amenities;
    if (amenities.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '设施服务',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities.map((amenity) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getAmenityIcon(amenity),
                      size: 16,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      amenity,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
    final hasContact = hotel.phone != null || hotel.email != null || hotel.website != null;
    if (!hasContact) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '联系方式',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (hotel.phone != null)
            _buildContactItem(
              icon: Icons.phone,
              label: '电话',
              value: hotel.phone!,
              onTap: () => _launchUrl('tel:${hotel.phone}'),
            ),
          if (hotel.email != null)
            _buildContactItem(
              icon: Icons.email,
              label: '邮箱',
              value: hotel.email!,
              onTap: () => _launchUrl('mailto:${hotel.email}'),
            ),
          if (hotel.website != null)
            _buildContactItem(
              icon: Icons.language,
              label: '网站',
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
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
                      icon: const Icon(Icons.bed, size: 20),
                      label: Text('房型 (${hotel.roomTypes.length})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (hotel.roomTypes.isNotEmpty) const SizedBox(width: 12),
                // 写评论按钮
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showWriteReviewDialog,
                    icon: const Icon(Icons.rate_review, size: 20),
                    label: const Text('写评论'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 第二行：路线导航和访问网站
            Row(
              children: [
                // 路线导航按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onNavigationPressed,
                    icon: const Icon(Icons.directions),
                    label: const Text('路线导航'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                // 访问网站按钮
                if (hotel.website != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(hotel.website!),
                      icon: const Icon(Icons.language),
                      label: const Text('访问网站'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 拖动条
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '房型列表',
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
                  padding: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 房型图片
            if (roomType.images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: roomType.images.first,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '已满',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 12),
            // 房型信息
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildRoomInfoChip(Icons.bed, roomType.bedType),
                _buildRoomInfoChip(Icons.people, '最多${roomType.maxOccupancy}人'),
                if (roomType.size > 0) _buildRoomInfoChip(Icons.square_foot, '${roomType.size.toInt()}㎡'),
              ],
            ),
            const SizedBox(height: 12),
            // 价格
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 设施标签
                Wrap(
                  spacing: 4,
                  children: roomType.amenities.take(3).map((amenity) {
                    return Chip(
                      label: Text(amenity, style: const TextStyle(fontSize: 10)),
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
                      '/晚',
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
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
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    double rating = 0;

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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 拖动条
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 标题
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '写评论',
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
                  const SizedBox(height: 16),
                  // 评分
                  Text(
                    '评分',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => rating = index + 1.0);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _getReviewRatingText(rating),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 标题输入
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: '标题',
                      hintText: '给您的评论起个标题',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 内容输入
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: '评论内容',
                      hintText: '分享您的入住体验...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 提交按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (rating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请选择评分')),
                          );
                          return;
                        }
                        if (contentController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请输入评论内容')),
                          );
                          return;
                        }
                        // TODO: 提交评论到后端
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('评论功能即将上线')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('提交评论'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 获取评论评分文字
  String _getReviewRatingText(double rating) {
    if (rating == 0) return '点击星星评分';
    if (rating == 1) return '很差';
    if (rating == 2) return '较差';
    if (rating == 3) return '一般';
    if (rating == 4) return '很好';
    return '非常好';
  }

  /// 房型区域
  Widget _buildRoomTypesSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
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
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '房型',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _showRoomTypesModal,
                child: Text('查看全部 (${hotel.roomTypes.length})'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 显示前2个房型简介
          ...hotel.roomTypes.take(2).map((roomType) => _buildRoomTypeSummary(roomType)),
        ],
      ),
    );
  }

  /// 房型简介卡片
  Widget _buildRoomTypeSummary(RoomType roomType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 房型图片
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: roomType.images.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: roomType.images.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.bed, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.bed, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  '${roomType.bedType} · 最多${roomType.maxOccupancy}人',
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
                '/晚',
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
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
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '用户评论',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // 评分显示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRatingColor(hotel.rating),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
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
          const SizedBox(height: 12),
          // 评论统计
          Row(
            children: [
              Text(
                '${hotel.reviewCount} 条评论',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
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
          const SizedBox(height: 16),
          // 暂无评论提示或评论列表
          if (hotel.reviewCount == 0)
            Center(
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text(
                    '暂无评论',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _showWriteReviewDialog,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('成为第一个评论的人'),
                  ),
                ],
              ),
            )
          else
            // TODO: 显示评论列表
            Center(
              child: TextButton.icon(
                onPressed: _showWriteReviewDialog,
                icon: const Icon(Icons.add),
                label: const Text('写评论'),
              ),
            ),
        ],
      ),
    );
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
    if (rating >= 4.5) return '优秀';
    if (rating >= 4.0) return '很好';
    if (rating >= 3.0) return '良好';
    if (rating >= 2.0) return '一般';
    return '较差';
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
