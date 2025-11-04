import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../config/app_colors.dart';
import '../controllers/city_detail_controller.dart';
import '../controllers/coworking_controller.dart';
import '../generated/app_localizations.dart';
import '../models/city_detail_model.dart';
import '../models/coworking_space_model.dart' as coworking;
import '../models/user_city_content_models.dart';
import '../services/user_city_content_api_service.dart';
import '../widgets/app_toast.dart';
import '../widgets/skeletons/skeletons.dart';
import 'add_cost_page.dart';
import 'add_coworking_page.dart';
import 'add_review_page.dart';
import 'coworking_detail_page.dart';
import 'create_travel_plan_page.dart';
import 'hotel_list_page.dart';

/// 城市详情�?- 完整�?Nomads.com 风格标签页系�?
class CityDetailPage extends StatefulWidget {
  final String cityId;
  final String cityName;
  final String cityImage;
  final double overallScore;
  final int reviewCount;

  const CityDetailPage({
    super.key,
    this.cityId = '',
    this.cityName = '',
    this.cityImage = '',
    this.overallScore = 0.0,
    this.reviewCount = 0,
  });

  @override
  State<CityDetailPage> createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  int _currentPage = 0;

  // 添加滚动控制器和透明度状态
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

  // 从 Get.arguments 或构造函数获取参数
  late final String cityId;
  late final String cityName;
  late final String cityImage;
  late final double overallScore;
  late final int reviewCount;

  // 根据天气代码返回对应的 FontAwesome 图标
  IconData _getWeatherIcon(String weatherIcon, {bool isNight = false}) {
    // OpenWeatherMap 图标代码格式: 01d, 01n, 02d, 02n, etc.
    // 最后一个字符 'd' 表示白天, 'n' 表示夜晚
    final code = weatherIcon.replaceAll(RegExp(r'[dn]$'), '');

    switch (code) {
      case '01': // clear sky
        return isNight ? FontAwesomeIcons.moon : FontAwesomeIcons.sun;
      case '02': // few clouds
        return isNight ? FontAwesomeIcons.cloudMoon : FontAwesomeIcons.cloudSun;
      case '03': // scattered clouds
        return FontAwesomeIcons.cloud;
      case '04': // broken clouds
        return FontAwesomeIcons.cloudSun;
      case '09': // shower rain
        return FontAwesomeIcons.cloudShowersHeavy;
      case '10': // rain
        return isNight
            ? FontAwesomeIcons.cloudMoonRain
            : FontAwesomeIcons.cloudSunRain;
      case '11': // thunderstorm
        return FontAwesomeIcons.cloudBolt;
      case '13': // snow
        return FontAwesomeIcons.snowflake;
      case '50': // mist
        return FontAwesomeIcons.smog;
      default:
        return FontAwesomeIcons.cloudSun;
    }
  }

  // 主天气卡片中的迷你信息组件
  Widget _buildWeatherMiniInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 24,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherMetric({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? const Color(0xFFFF4458), size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          if (subtitle != null && subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatWeatherTime(
    DateTime utc,
    int? offsetSeconds, {
    String pattern = 'HH:mm',
  }) {
    final localized = _applyTimezoneOffset(utc, offsetSeconds);
    return DateFormat(pattern).format(localized);
  }

  DateTime _applyTimezoneOffset(DateTime utc, int? offsetSeconds) {
    final offset = Duration(seconds: offsetSeconds ?? 0);
    final adjusted = utc.add(offset);
    return DateTime.fromMillisecondsSinceEpoch(
      adjusted.millisecondsSinceEpoch,
      isUtc: false,
    );
  }

  String _formatTimezone(int? offsetSeconds) {
    if (offsetSeconds == null) {
      return 'UTC';
    }

    final totalMinutes = offsetSeconds ~/ 60;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes.abs() % 60;
    final sign = offsetSeconds >= 0 ? '+' : '-';

    return 'UTC$sign${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _formatDayName(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return l10n.today;
    } else if (difference == 1) {
      return l10n.tomorrow;
    } else {
      // 使用国际化的星期名称
      final weekday = date.weekday; // 1=Monday, 7=Sunday
      switch (weekday) {
        case DateTime.monday:
          return l10n.monday;
        case DateTime.tuesday:
          return l10n.tuesday;
        case DateTime.wednesday:
          return l10n.wednesday;
        case DateTime.thursday:
          return l10n.thursday;
        case DateTime.friday:
          return l10n.friday;
        case DateTime.saturday:
          return l10n.saturday;
        case DateTime.sunday:
          return l10n.sunday;
        default:
          return DateFormat('EEE').format(date);
      }
    }
  }

  String _describeAqi(int aqi, AppLocalizations l10n) {
    if (aqi <= 50) return l10n.aqiGood;
    if (aqi <= 100) return l10n.aqiModerate;
    if (aqi <= 150) return l10n.aqiUnhealthySensitive;
    if (aqi <= 200) return l10n.aqiUnhealthy;
    if (aqi <= 300) return l10n.aqiVeryUnhealthy;
    return l10n.aqiHazardous;
  }

  @override
  void initState() {
    super.initState();

    // 优先从 Get.arguments 获取参数,如果没有则使用构造函数参数
    final args = Get.arguments as Map<String, dynamic>?;
    cityId = args?['cityId'] ?? widget.cityId;
    cityName = args?['cityName'] ?? widget.cityName;
    cityImage = args?['cityImage'] ?? widget.cityImage;
    overallScore = args?['overallScore'] ?? widget.overallScore;
    reviewCount = args?['reviewCount'] ?? widget.reviewCount;
    final initialTab = args?['initialTab'] as int? ?? 0; // 从通知跳转时的初始 Tab

    _pageController = PageController();

    // 初始化 TabController (10个tab), 设置初始索引
    _tabController = TabController(
      length: 10,
      vsync: this,
      initialIndex: initialTab,
    );

    // 监听 tab 切换
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final controller = Get.find<CityDetailController>();
        controller.changeTab(_tabController.index);
      }
    });

    // 监听滚动，动态改变 AppBar 背景透明度
    _scrollController.addListener(() {
      // 当滚动超过 200 像素时，背景变为不透明
      final offset = _scrollController.offset;
      final newOpacity = (offset / 200).clamp(0.0, 1.0);

      if (_appBarOpacity != newOpacity) {
        setState(() {
          _appBarOpacity = newOpacity;
        });
      }
    });

    // ✅ 初始化城市数据和加载用户内容（只在初始化时调用一次）
    final controller = Get.put(CityDetailController());
    controller.initCity(cityId, cityName);
    controller.loadUserContent();
  }

  /// 显示 AI 生成进度对话框
  void _showAIGenerateProgressDialog(CityDetailController controller) {
    final progressMessage = ValueNotifier<String>('准备生成...');
    final progressValue = ValueNotifier<int>(0);

    showDialog(
      context: context,
      barrierDismissible: false, // 不允许点击外部关闭
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Color(0xFFFF4458),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'AI 正在生成旅游指南',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ValueListenableBuilder<int>(
                valueListenable: progressValue,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF4458),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<String>(
                valueListenable: progressMessage,
                builder: (context, message, child) {
                  return ValueListenableBuilder<int>(
                    valueListenable: progressValue,
                    builder: (context, value, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '$value%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            // 后台运行按钮
            TextButton.icon(
              onPressed: () {
                // 关闭对话框
                Navigator.of(dialogContext).pop();

                // 启动后台任务
                controller.generateGuideInBackground();

                // 清理 ValueNotifier
                progressMessage.dispose();
                progressValue.dispose();
              },
              icon: const Icon(Icons.cloud_queue),
              label: const Text('后台运行'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF4458),
              ),
            ),
          ],
        );
      },
    );

    // 调用异步任务队列 API (推荐方式)
    controller.generateGuideWithAIAsync(
      onProgress: (progress, message) {
        progressMessage.value = message;
        progressValue.value = progress;
      },
    ).then((taskId) {
      // 关闭进度对话框
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (taskId != null) {
        AppToast.success('AI 旅游指南生成成功!');
      }

      // 清理 ValueNotifier
      progressMessage.dispose();
      progressValue.dispose();
    }).catchError((error) {
      // 关闭进度对话框
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      AppToast.error('生成失败: $error');
      // 清理 ValueNotifier
      progressMessage.dispose();
      progressValue.dispose();
    });
  }

  // 获取城市展示图片列表
  List<String> _getCityImages() {
    // 基于城市主图片生成多张展示图�?
    // 使用不同的Unsplash参数来获取该城市的不同视角图�?
    final baseImage = cityImage;

    // 如果主图片是Unsplash链接，生成系列图�?
    if (baseImage.contains('unsplash.com')) {
      // 提取图片ID
      final uri = Uri.parse(baseImage);
      final photoId = uri.pathSegments
          .lastWhere(
            (segment) => segment.startsWith('photo-'),
            orElse: () => 'photo-default',
          )
          .replaceAll('photo-', '');

      return [
        baseImage, // 主图�?
        'https://images.unsplash.com/$photoId?w=800&h=600&fit=crop&crop=entropy&q=80',
        'https://images.unsplash.com/$photoId?w=800&h=600&fit=crop&crop=edges&q=80',
        'https://images.unsplash.com/$photoId?w=800&h=600&fit=crop&crop=faces&q=80',
      ];
    }

    // 如果不是Unsplash，返回主图片和一些通用城市图片
    return [
      baseImage,
      'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800',
      'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=800',
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<CityDetailController>();

    return Scaffold(
      body: Stack(
        children: [
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // 大图 Banner - 现代化设计
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  elevation: _appBarOpacity > 0 ? 4 : 0,
                  backgroundColor: Color.lerp(
                    Colors.transparent,
                    Colors.white,
                    _appBarOpacity,
                  ),
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _appBarOpacity > 0.5
                          ? Colors.grey.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: _appBarOpacity > 0.5
                            ? Colors.black87
                            : Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _appBarOpacity > 0.5
                            ? Colors.grey.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.share,
                          color: _appBarOpacity > 0.5
                              ? Colors.black87
                              : Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          // TODO: 实现分享功能
                        },
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    title: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: _appBarOpacity > 0.5
                            ? null
                            : LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.6),
                                  Colors.black.withValues(alpha: 0.3),
                                ],
                              ),
                        color: _appBarOpacity > 0.5 ? Colors.transparent : null,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cityName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: _appBarOpacity > 0.5
                              ? const Color(0xFFFF4458)
                              : Colors.white,
                          shadows: _appBarOpacity > 0.5
                              ? []
                              : const [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black54,
                                  ),
                                ],
                        ),
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // PageView carousel - 城市图片轮播
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: _getCityImages().length,
                          itemBuilder: (context, index) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                // 城市图片
                                Image.network(
                                  _getCityImages()[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                          color: const Color(0xFFFF4458),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // 增强渐变遮罩 - 更现代的三层渐变
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.3),
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.8),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        // 现代化轮播指示器
                        Positioned(
                          bottom: 24,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _getCityImages().length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: _currentPage == index
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 现代化评分信息卡片
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 评分徽章
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF4458)
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                overallScore.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$reviewCount reviews',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'From digital nomads',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 收藏按钮 - 动态状态
                        Obx(() {
                          final controller = Get.find<CityDetailController>();
                          final isFavorited = controller.isFavorited.value;
                          final isToggling =
                              controller.isTogglingFavorite.value;

                          return Container(
                            decoration: BoxDecoration(
                              color: isFavorited
                                  ? const Color(0xFFFF4458)
                                      .withValues(alpha: 0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isToggling
                                ? const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Color(0xFFFF4458),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: Icon(
                                      isFavorited
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorited
                                          ? const Color(0xFFFF4458)
                                          : Colors.grey[700],
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      controller.toggleFavorite();
                                    },
                                  ),
                          );
                        }),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.share_outlined,
                                color: Colors.grey[700], size: 22),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 现代化标签页导航
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: const Color(0xFFFF4458),
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFFF4458),
                            width: 3,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.scores),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _showShareScoreDialog(),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(Icons.add_circle, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(text: l10n.guide),
                        Tab(text: l10n.prosAndCons),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.reviews),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _showShareReviewDialog(),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(Icons.add_circle, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.cost),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _showShareCostDialog(),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(Icons.add_circle, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.photos),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _showSharePhotoDialog(),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(Icons.add_circle, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(text: l10n.weather),
                        Tab(text: l10n.hotels),
                        Tab(text: l10n.neighborhoods),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.coworking),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _showAddCoworkingPage(),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(Icons.add_circle, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Obx(() {
              if (controller.isLoading.value) {
                return const CityDetailSkeleton();
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildScoresTab(context, controller),
                  _buildGuideTab(controller),
                  _buildProsConsTab(controller),
                  _buildReviewsTab(controller),
                  _buildCostTab(controller),
                  _buildPhotosTab(controller),
                  _buildWeatherTab(controller),
                  _buildHotelsTab(controller),
                  _buildNeighborhoodsTab(controller),
                  _buildCoworkingTab(controller),
                ],
              );
            }),
          ),

          // Floating AI Travel Plan Button
          Positioned(
            bottom: 16,
            right: 16,
            child: Material(
              elevation: 6,
              shadowColor: const Color(0xFFFF4458).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                onTap: () {
                  // 跳转到创建旅行计划页�?
                  Get.to(
                    () => CreateTravelPlanPage(
                      cityId: cityId,
                      cityName: cityName,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'AI Travel Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Scores 标签
  Widget _buildScoresTab(
      BuildContext context, CityDetailController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      // 显示加载状态
      if (controller.isLoadingScores.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final scores = controller.scores.value;
      if (scores == null) {
        return Center(child: Text(l10n.noData));
      }

      final scoreItems = [
        {'icon': Icons.star, 'label': l10n.overall, 'value': scores.overall},
        {
          'icon': Icons.favorite,
          'label': l10n.qualityOfLife,
          'value': scores.qualityOfLife
        },
        {
          'icon': Icons.family_restroom,
          'label': l10n.familyScore,
          'value': scores.familyScore
        },
        {
          'icon': Icons.people,
          'label': l10n.community,
          'value': scores.communityScore
        },
        {
          'icon': Icons.security,
          'label': l10n.safety,
          'value': scores.safetyScore
        },
        {
          'icon': Icons.female,
          'label': l10n.womenSafety,
          'value': scores.womenSafety
        },
        {
          'icon': Icons.flag,
          'label': l10n.lgbtqSafety,
          'value': scores.lgbtqSafety
        },
        {
          'icon': Icons.celebration,
          'label': l10n.fun,
          'value': scores.funScore
        },
        {
          'icon': Icons.directions_walk,
          'label': l10n.walkability,
          'value': scores.walkability
        },
        {
          'icon': Icons.nightlife,
          'label': l10n.nightlife,
          'value': scores.nightlife
        },
        {
          'icon': Icons.language,
          'label': l10n.englishSpeaking,
          'value': scores.englishSpeaking
        },
        {
          'icon': Icons.restaurant,
          'label': l10n.foodSafety,
          'value': scores.foodSafety
        },
        {'icon': Icons.wifi, 'label': l10n.freeWiFi, 'value': scores.freeWiFi},
        {
          'icon': Icons.laptop,
          'label': l10n.placesToWork,
          'value': scores.placesToWork
        },
        {
          'icon': Icons.local_hospital,
          'label': l10n.hospitals,
          'value': scores.hospitals
        },
      ];

      return ListView.builder(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
        itemCount: scoreItems.length,
        itemBuilder: (context, index) {
          final item = scoreItems[index];
          return _buildScoreItem(
            icon: item['icon'] as IconData,
            label: item['label'] as String,
            score: item['value'] as double,
          );
        },
      );
    });
  }

  Widget _buildScoreItem({
    required IconData icon,
    required String label,
    required double score,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF4458), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: score / 5,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF4458),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Digital Nomad Guide 标签
  Widget _buildGuideTab(CityDetailController controller) {
    return Obx(() {
      print(
          '🔍 [GuideTab] Rebuilding... isLoading=${controller.isLoadingGuide.value}, guide=${controller.guide.value != null}');

      // 显示加载状态
      if (controller.isLoadingGuide.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                '🤖 AI 正在生成旅游指南...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      final guide = controller.guide.value;
      if (guide == null) {
        print('⚠️ [GuideTab] Guide is null, showing empty state');
        // 显示空状态,带有"AI 生成"按钮
        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.loadingGuide,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAIGenerateProgressDialog(controller),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('AI 生成旅游指南'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      print('✅ [GuideTab] Showing guide content');
      return _buildGuideContent(context, guide, controller);
    });
  }

  Widget _buildGuideContent(
      BuildContext context, guide, CityDetailController controller) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      children: [
        // AI 重新生成按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => _showAIGenerateProgressDialog(controller),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('AI 重新生成'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF4458),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.overview,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          guide.overview,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Best Areas to Stay',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...guide.bestAreas.map((area) => _buildBestAreaCard(area)),
        const SizedBox(height: 24),
        const Text(
          'Essential Tips',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...guide.tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡',
                      style: TextStyle(fontSize: 18, color: Color(0xFFFF4458))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // Pros & Cons 标签
  Widget _buildProsConsTab(CityDetailController controller) {
    return Obx(() {
      // 显示加载状态
      if (controller.isLoadingProsCons.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
        children: [
          const Text(
            'Pros',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.prosList.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.text,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      Column(
                        children: [
                          const Icon(Icons.arrow_upward,
                              size: 16, color: Color(0xFFFF4458)),
                          Text(
                            '${item.upvotes}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 24),
          const Text(
            'Cons',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.consList.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.text,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      Column(
                        children: [
                          const Icon(Icons.arrow_upward,
                              size: 16, color: Color(0xFFFF4458)),
                          Text(
                            '${item.upvotes}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      );
    });
  }

  // Reviews 标签
  Widget _buildReviewsTab(CityDetailController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final realUserReviews = controller.userReviews; // ✅ 只使用后端真实评论

      // 如果正在加载
      if (controller.isLoadingReviews.value && realUserReviews.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      // 如果为空
      if (realUserReviews.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rate_review, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No reviews yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to write a review!',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshReviews,
        child: ListView.builder(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
          itemCount: realUserReviews.length, // ✅ 只显示真实评论
          itemBuilder: (context, index) {
            final review = realUserReviews[index]; // ✅ 直接使用真实评论
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // ✅ 有头像显示头像,没有头像显示用户名首字母
                        CircleAvatar(
                          backgroundColor: const Color(0xFFFF4458),
                          backgroundImage: review.userAvatar != null &&
                                  review.userAvatar!.isNotEmpty
                              ? NetworkImage(review.userAvatar!)
                              : null,
                          child: review.userAvatar == null ||
                                  review.userAvatar!.isEmpty
                              ? Text(
                                  review.username.isNotEmpty
                                      ? review.username
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : '?',
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.username, // ✅ 使用真实用户名
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              if (review.visitDate != null)
                                Text(
                                  '${l10n.visited} ${_formatDate(review.visitDate!, l10n)}',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            Text(' ${review.rating}'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.content,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    // ✅ 始终显示图片区域（有图显示图片，无图显示占位符）
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: review.photoUrls.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: review.photoUrls.length,
                              itemBuilder: (context, photoIndex) {
                                return Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          review.photoUrls[photoIndex]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.posted} ${_formatDate(review.createdAt, l10n)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // Cost of Living 标签
  Widget _buildCostTab(CityDetailController controller) {
    final l10n = AppLocalizations.of(context)!; // ✅ 添加国际化
    return Obx(() {
      final communityCost = controller.communityCostSummary.value; // ✅ 使用后端真实数据

      // 如果数据还在加载中
      if (controller.isLoadingCost.value && communityCost == null) {
        return const Center(child: CircularProgressIndicator());
      }

      // 使用默认值（如果为 null）
      final total = communityCost?.total ?? 0.0;
      final contributorCount = communityCost?.contributorCount ?? 0;
      final totalExpenseCount = communityCost?.totalExpenseCount ?? 0;
      final accommodation = communityCost?.accommodation ?? 0.0;
      final food = communityCost?.food ?? 0.0;
      final transportation = communityCost?.transportation ?? 0.0;
      final activity = communityCost?.activity ?? 0.0;
      final shopping = communityCost?.shopping ?? 0.0;
      final other = communityCost?.other ?? 0.0;

      return ListView(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
        children: [
          // ✅ 社区综合费用统计 - 标题左侧,贡献者右侧
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.communityCostSummary,
                style: const TextStyle(
                  fontSize: 18, // 缩小字号以适应小屏幕
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$contributorCount ${contributorCount != 1 ? l10n.contributors : l10n.contributor}',
                  style: TextStyle(
                    fontSize: 11, // 缩小字号
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B73FF), Color(0xFF000DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  l10n.averageCommunityCost,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.basedOnRealExpenses(
                      totalExpenseCount, totalExpenseCount != 1 ? 's' : ''),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 费用分类明细 - 始终显示所有分类（即使为 0）
          _buildCostCategoryCard(
            category: l10n.accommodation,
            amount: accommodation,
            icon: Icons.hotel,
            color: Colors.purple,
          ),
          _buildCostCategoryCard(
            category: l10n.food,
            amount: food,
            icon: Icons.restaurant,
            color: Colors.orange,
          ),
          _buildCostCategoryCard(
            category: l10n.transportation,
            amount: transportation,
            icon: Icons.directions_car,
            color: Colors.blue,
          ),
          _buildCostCategoryCard(
            category: l10n.activity,
            amount: activity,
            icon: Icons.local_activity,
            color: Colors.green,
          ),
          _buildCostCategoryCard(
            category: l10n.shopping,
            amount: shopping,
            icon: Icons.shopping_bag,
            color: Colors.pink,
          ),
          _buildCostCategoryCard(
            category: 'Other',
            amount: other,
            icon: Icons.more_horiz,
            color: Colors.grey,
          ),
          const SizedBox(height: 32),
        ], // children 数组闭合
      ); // ListView 闭合
    }); // Obx 闭合
  }

  // 费用分类卡片 - 参照 Recent Community Expenses 的设计
  Widget _buildCostCategoryCard({
    required String category,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF4458),
          ),
        ),
      ),
    );
  }

  // Photos 标签
  Widget _buildPhotosTab(CityDetailController controller) {
    return Obx(() {
      final realUserPhotos = controller.userPhotos; // ✅ 只使用后端真实照片

      // 如果正在加载
      if (controller.isLoadingPhotos.value && realUserPhotos.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      // 如果为空
      if (realUserPhotos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No photos yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to share a photo!',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshPhotos,
        child: GridView.builder(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 96),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: realUserPhotos.length, // ✅ 只显示真实照片
          itemBuilder: (context, index) {
            final photo = realUserPhotos[index]; // ✅ 直接使用真实照片
            return GestureDetector(
              onTap: () => _showPhotoDetail(photo),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(photo.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // 用户头像标识
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  /// 显示照片详情对话框
  void _showPhotoDetail(UserCityPhoto photo) {
    final l10n = AppLocalizations.of(context)!;

    Get.dialog(
      Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 照片
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                photo.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // 信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photo.caption != null) ...[
                    Text(
                      photo.caption!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (photo.location != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          photo.location!,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    '${l10n.uploaded} ${_formatDate(photo.createdAt, l10n)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Weather 标签
  Widget _buildWeatherTab(CityDetailController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      // 显示加载状态
      if (controller.isLoadingWeather.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final weather = controller.weather.value;
      if (weather == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.noData,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }

      final rawDescription = weather.weatherDescription.trim();
      final description = rawDescription.isEmpty
          ? weather.weather
          : rawDescription[0].toUpperCase() + rawDescription.substring(1);
      final timezone = _formatTimezone(weather.timezoneOffset);
      final sunrise =
          _formatWeatherTime(weather.sunrise, weather.timezoneOffset);
      final sunset = _formatWeatherTime(weather.sunset, weather.timezoneOffset);
      final updatedAt = _formatWeatherTime(
        weather.updatedAt,
        weather.timezoneOffset,
        pattern: 'MMM d, HH:mm',
      );
      final windSpeedKmh = (weather.windSpeed * 3.6).toStringAsFixed(1);
      final visibilityKm = (weather.visibility / 1000).toStringAsFixed(1);
      final windSubtitle = weather.windDirectionDescription?.isNotEmpty == true
          ? weather.windDirectionDescription!
          : '${weather.windDirection}°';

      final metrics = <Widget>[
        _buildWeatherMetric(
          icon: FontAwesomeIcons.temperatureHalf,
          label: l10n.feelsLike,
          value: '${weather.feelsLike.toStringAsFixed(1)}°C',
        ),
        _buildWeatherMetric(
          icon: FontAwesomeIcons.droplet,
          label: l10n.humidity,
          value: '${weather.humidity}%',
        ),
        _buildWeatherMetric(
          icon: FontAwesomeIcons.wind,
          label: l10n.wind,
          value: '$windSpeedKmh km/h',
          subtitle: windSubtitle,
        ),
        _buildWeatherMetric(
          icon: FontAwesomeIcons.gaugeHigh,
          label: l10n.pressure,
          value: '${weather.pressure} hPa',
        ),
        _buildWeatherMetric(
          icon: FontAwesomeIcons.cloud,
          label: l10n.cloudiness,
          value: '${weather.cloudiness}%',
        ),
        _buildWeatherMetric(
          icon: FontAwesomeIcons.eye,
          label: l10n.visibility,
          value: '$visibilityKm km',
        ),
      ];

      if (weather.airQualityIndex != null) {
        metrics.add(
          _buildWeatherMetric(
            icon: FontAwesomeIcons.lungs,
            label: l10n.airQuality,
            value: '${weather.airQualityIndex}',
            subtitle: _describeAqi(weather.airQualityIndex!, l10n),
          ),
        );
      }

      if (weather.uvIndex != null) {
        metrics.add(
          _buildWeatherMetric(
            icon: FontAwesomeIcons.sun,
            label: l10n.uvIndex,
            value: weather.uvIndex!.toStringAsFixed(1),
            iconColor: Colors.amber[700],
          ),
        );
      }

      return ListView(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 96),
        children: [
          // 🌡️ 现代化主天气卡片
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4458).withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 温度显示
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weather.temperature.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 72,
                                  fontWeight: FontWeight.bold,
                                  height: 0.95,
                                  letterSpacing: -2,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  '°C',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 天气描述
                          Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // 城市名称
                          if (controller.currentCityName.value.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  controller.currentCityName.value,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    // 天气图标
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: FaIcon(
                        _getWeatherIcon(
                          weather.weatherIcon,
                          isNight: weather.weatherIcon.endsWith('n'),
                        ),
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 分隔线
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 附加信息行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherMiniInfo(
                      icon: Icons.thermostat_rounded,
                      label: l10n.feelsLike,
                      value: '${weather.feelsLike.toStringAsFixed(0)}°',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    _buildWeatherMiniInfo(
                      icon: Icons.water_drop_rounded,
                      label: l10n.humidity,
                      value: '${weather.humidity}%',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    _buildWeatherMiniInfo(
                      icon: Icons.air_rounded,
                      label: l10n.wind,
                      value:
                          '${(weather.windSpeed * 3.6).toStringAsFixed(0)} km/h',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 更新时间
                Text(
                  '$timezone • ${l10n.updated} $updatedAt',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              // 计算每行可以放置的卡片数量
              final screenWidth = constraints.maxWidth;
              final spacing = 16.0;

              // 计算可以放置的卡片数量(2或3列)
              int crossAxisCount = 2;
              if (screenWidth > 600) {
                crossAxisCount = 3;
              }

              // 计算每个卡片的宽度
              final totalSpacing = spacing * (crossAxisCount - 1);
              final cardWidth = (screenWidth - totalSpacing) / crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: metrics.map((metric) {
                  return SizedBox(
                    width: cardWidth,
                    child: metric,
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sunriseSunset,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.solidSun,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.sunrise,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      sunrise,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.solidMoon,
                        color: Color(0xFF5B6FD8), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.sunset,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      sunset,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 🌤️ 现代化5天预报卡片
          if (weather.forecast?.daily.isNotEmpty == true) ...[
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.fiveDayForecast,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: weather.forecast!.daily.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final day = weather.forecast!.daily[index];
                  final isToday = index == 0;
                  final dayName =
                      isToday ? l10n.today : _formatDayName(day.date, l10n);

                  return Container(
                    width: 140,
                    margin: EdgeInsets.only(
                        right: index < weather.forecast!.daily.length - 1
                            ? 16
                            : 0),
                    decoration: BoxDecoration(
                      gradient: isToday
                          ? const LinearGradient(
                              colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [Colors.white, Colors.grey.shade50],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                      borderRadius: BorderRadius.circular(24),
                      border: isToday
                          ? null
                          : Border.all(
                              color: Colors.grey.shade200,
                              width: 1.5,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: isToday
                              ? const Color(0xFFFF4458).withValues(alpha: 0.35)
                              : Colors.black.withValues(alpha: 0.06),
                          blurRadius: isToday ? 20 : 12,
                          offset: Offset(0, isToday ? 8 : 4),
                          spreadRadius: isToday ? 2 : 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 日期标签
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : const Color(0xFFFF4458)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isToday
                                    ? Colors.white
                                    : const Color(0xFFFF4458),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // 天气图标
                          FaIcon(
                            _getWeatherIcon(
                              day.weatherIcon,
                              isNight: false,
                            ),
                            color:
                                isToday ? Colors.white : Colors.orange.shade600,
                            size: 48,
                          ),
                          // 温度显示
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    day.tempMax.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: isToday
                                          ? Colors.white
                                          : Colors.grey.shade900,
                                      height: 1.0,
                                    ),
                                  ),
                                  Text(
                                    '°',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isToday
                                          ? Colors.white.withValues(alpha: 0.9)
                                          : Colors.grey.shade700,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    size: 12,
                                    color: isToday
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    day.tempMin.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isToday
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    '°',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isToday
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : Colors.grey.shade500,
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
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dataSource,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  weather.dataSource ?? 'OpenWeatherMap',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.timezone}: $timezone',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // Neighborhoods 标签
  Widget _buildNeighborhoodsTab(CityDetailController controller) {
    return Obx(() {
      // 显示加载状态
      if (controller.isLoadingNeighborhoods.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
        itemCount: controller.neighborhoods.length,
        itemBuilder: (context, index) {
          final neighborhood = controller.neighborhoods[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    neighborhood.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        neighborhood.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        neighborhood.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.security,
                              size: 16, color: Color(0xFFFF4458)),
                          const SizedBox(width: 4),
                          Text(
                              '${AppLocalizations.of(context)!.safety}: ${neighborhood.safetyScore}'),
                          const SizedBox(width: 16),
                          const Icon(Icons.attach_money,
                              size: 16, color: Color(0xFFFF4458)),
                          const SizedBox(width: 4),
                          Text(
                              '\$${neighborhood.rentPrice.toStringAsFixed(0)}/mo'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  /// Coworking 标签�?
  Widget _buildCoworkingTab(CityDetailController controller) {
    final coworkingController = Get.put(CoworkingController());

    // 延迟执行筛�?避免�?build 期间修改状�?
    WidgetsBinding.instance.addPostFrameCallback((_) {
      coworkingController.filterByCity(cityName);
    });

    return Obx(() {
      if (coworkingController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (coworkingController.filteredSpaces.isEmpty) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Elegant illustration
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF4458).withValues(alpha: 0.08),
                        const Color(0xFFFF4458).withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circles
                      Positioned(
                        top: 40,
                        right: 40,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF4458).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: 30,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF4458).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Main icon
                      Icon(
                        Icons.wb_sunny_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'No coworking spaces yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[800],
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Help build the community',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Minimalist add button
                InkWell(
                  onTap: _showAddCoworkingPage,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add First Space',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
        itemCount: coworkingController.filteredSpaces.length,
        itemBuilder: (context, index) {
          final space = coworkingController.filteredSpaces[index];
          return _buildCoworkingSpaceCard(space);
        },
      );
    });
  }

  Widget _buildCoworkingSpaceCard(coworking.CoworkingSpace space) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => CoworkingDetailPage(space: space));
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 空间图片
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      space.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.business, size: 48),
                        );
                      },
                    ),
                  ),
                ),
                // Verified 徽章
                if (space.isVerified)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // 空间信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称和评�?
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          space.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 评分
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              space.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 地址
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          space.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 关键指标
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildCoworkingInfoChip(
                        Icons.wifi,
                        '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? '0'} Mbps',
                        Colors.blue,
                      ),
                      if (space.pricing.monthlyRate != null)
                        _buildCoworkingInfoChip(
                          Icons.attach_money,
                          '\$${space.pricing.monthlyRate!.toStringAsFixed(0)}/mo',
                          Colors.green,
                        ),
                      if (space.amenities.has24HourAccess)
                        _buildCoworkingInfoChip(
                          Icons.access_time,
                          '24/7',
                          Colors.orange,
                        ),
                      if (space.pricing.hasFreeTrial)
                        _buildCoworkingInfoChip(
                          Icons.local_offer,
                          'Free Trial',
                          const Color(0xFFFF4458),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hotels Tab - 显示城市的酒店列表
  Widget _buildHotelsTab(CityDetailController controller) {
    final parsedCityId = int.tryParse(cityId);
    print(
        '🏨 Hotels Tab - cityId: $cityId, parsed: $parsedCityId, cityName: $cityName');

    return HotelListPage(
      cityId: parsedCityId,
      cityName: cityName,
    );
  }

  Widget _buildCoworkingInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ========== 分享对话框方�?==========

  /// 分享评分信息
  void _showShareScoreDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Color(0xFFFF4458), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Share Your Scores',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Help the community by rating different aspects of $cityName',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    AppToast.info(
                      'Score submission feature will be available soon!',
                      title: 'Coming Soon',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.startRating),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 分享指南信息
  /// 分享评论 - 跳转到独立页面
  void _showShareReviewDialog() async {
    final result = await Get.to(() => AddReviewPage(
          cityId: cityId,
          cityName: cityName,
        ));

    // 如果提交成功,刷新评论列表
    if (result != null && result['success'] == true) {
      final controller = Get.find<CityDetailController>();
      controller.loadUserContent();

      print('Review submitted successfully: ${result['review']}');
    }
  }

  /// 分享费用信息
  void _showShareCostDialog() async {
    final result = await Get.to(
      () => AddCostPage(
        cityId: cityId,
        cityName: cityName,
      ),
    );

    // 如果提交成功,刷新费用列表
    if (result != null && result['success'] == true) {
      final controller = Get.find<CityDetailController>();
      controller.loadUserContent();

      print('Expenses submitted successfully: ${result['expenses']}');
    }
  }

  /// 分享照片
  void _showSharePhotoDialog() async {
    // 显示选择对话框
    final source = await Get.dialog<ImageSource>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_camera,
                  color: Color(0xFFFF4458), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Upload Photos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Share your favorite photos from $cityName',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.back(result: ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: Text(AppLocalizations.of(context)!.camera),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF4458),
                        side: const BorderSide(color: Color(0xFFFF4458)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.back(result: ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: Text(AppLocalizations.of(context)!.gallery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4458),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    await _pickAndUploadImage(source);
  }

  /// 选择并上传图片
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // TODO: 实现图片上传功能
        // 1. 上传图片到存储服务 (Supabase Storage 或 CDN)
        // 2. 获取图片URL
        // 3. 调用 API 保存照片记录

        // 临时实现: 使用占位符 URL
        final apiService = UserCityContentApiService();
        await apiService.addCityPhoto(
          cityId: cityId,
          imageUrl:
              'https://via.placeholder.com/800x600.png?text=${Uri.encodeComponent(image.name)}',
          caption: null,
          location: null,
          takenAt: null,
        );

        // 刷新照片列表
        final controller = Get.find<CityDetailController>();
        await controller.refreshPhotos();

        AppToast.success(
          'Photo uploaded successfully!',
          title: 'Success',
        );
      }
    } catch (e) {
      AppToast.error(
        'Failed to upload photo: $e',
        title: 'Error',
      );
    }
  }

  /// 构建 Best Area 卡片 (包含娱乐、旅游、经济、文化四个维度)
  Widget _buildBestAreaCard(BestArea area) {
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
            // 区域标题
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFFF4458),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    area.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 区域描述
            Text(
              area.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // 四个维度评分
            _buildScoreDimension(
              icon: Icons.nightlife,
              label: '娱乐',
              score: area.entertainmentScore,
              description: area.entertainmentDescription,
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildScoreDimension(
              icon: Icons.attractions,
              label: '旅游',
              score: area.tourismScore,
              description: area.tourismDescription,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildScoreDimension(
              icon: Icons.attach_money,
              label: '经济',
              score: area.economyScore,
              description: area.economyDescription,
              color: Colors.green,
              isReversed: true, // 经济评分越低越好
            ),
            const SizedBox(height: 12),
            _buildScoreDimension(
              icon: Icons.palette,
              label: '文化',
              score: area.cultureScore,
              description: area.cultureDescription,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单个评分维度
  Widget _buildScoreDimension({
    required IconData icon,
    required String label,
    required double score,
    required String description,
    required Color color,
    bool isReversed = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            // 星级评分
            ...List.generate(5, (index) {
              final starValue = index + 1;
              final isFilled = starValue <= score;
              return Icon(
                isFilled ? Icons.star : Icons.star_border,
                size: 16,
                color: color,
              );
            }),
            const SizedBox(width: 6),
            Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return l10n.weeksAgo(weeks);
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return l10n.monthsAgo(months);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  /// 添加 Coworking Space
  void _showAddCoworkingPage() async {
    final result = await Get.to(() => AddCoworkingPage(
          cityName: cityName,
          cityId: cityId,
        ));
    if (result != null) {
      AppToast.success(
        'Your coworking space will be reviewed and added soon!',
        title: 'Success',
      );
    }
  }

  /// 分享社区信息
}

// SliverAppBarDelegate for pinned tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
