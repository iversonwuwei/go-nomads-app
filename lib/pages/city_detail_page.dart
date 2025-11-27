import 'dart:async';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:df_admin_mobile/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_detail.dart' hide BestArea;
import 'package:df_admin_mobile/features/city/domain/entities/city_rating_item.dart';
import 'package:df_admin_mobile/features/city/domain/entities/digital_nomad_guide.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_rating_controller.dart';
import 'package:df_admin_mobile/features/city/presentation/widgets/city_ratings_card.dart';
import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_space.dart' as coworking;
import 'package:df_admin_mobile/features/coworking/presentation/controllers/coworking_state_controller.dart';
import 'package:df_admin_mobile/features/notification/domain/entities/app_notification.dart';
import 'package:df_admin_mobile/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/repositories/iuser_city_content_repository.dart';
import 'package:df_admin_mobile/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:df_admin_mobile/features/weather/presentation/controllers/weather_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/routes/route_refresh_observer.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/coworking_verification_badge.dart';
import 'package:df_admin_mobile/widgets/rating_item_dialog.dart';
import 'package:df_admin_mobile/widgets/share_bottom_sheet.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'add_cost_page.dart';
import 'add_coworking_page.dart';
import 'add_review_page.dart';
import 'assign_moderator_page.dart';
import 'city_photo_submission_page.dart';
import 'coworking_detail_page.dart';
import 'create_travel_plan_page.dart';
import 'hotel_list_page.dart';
import 'manage_city_ratings_page.dart';
import 'manage_cost_page.dart';
import 'manage_pros_cons_page.dart';
import 'manage_reviews_page.dart';
import 'pros_and_cons_add_page.dart';

/// 城市详情页 - 完整的 Nomads.com 风格标签页系统
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
    with SingleTickerProviderStateMixin, RouteAwareRefreshMixin<CityDetailPage> {
  late PageController _pageController;
  late TabController _tabController;
  int _currentPage = 0;

  // 添加滚动控制器和透明度状态
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

  // 下拉刷新状态标志
  bool _isRefreshingReviews = false;
  bool _isRefreshingPhotos = false;

  // Guide Tab 初始化标志，防止滚动时重复请求
  bool _hasInitializedGuide = false;
  String? _lastGuideLoadedCityId;

  // 从 Get.arguments 或构造函数获取参数
  late final String cityId;
  late final String cityName;
  late final String cityImage;
  late final double overallScore;
  late final int reviewCount;
  List<CityRatingItem> _customRatingItems = [];

  String _generateRatingId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'rating_${timestamp}_${_customRatingItems.length}';
  }

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
        return isNight ? FontAwesomeIcons.cloudMoonRain : FontAwesomeIcons.cloudSunRain;
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

  /// 构建版主管理蒙层
  Widget _buildModeratorManagementOverlay(CityDetailStateController controller) {
    return Obx(() {
      final city = controller.currentCity.value;
      if (city == null) return const SizedBox.shrink();

      // 检查是否有版主
      final hasModerator = city.moderatorId != null;

      // 直接使用后端返回的权限字段
      final isAdmin = city.isCurrentUserAdmin;
      final isModerator = city.isCurrentUserModerator;

      // 调试日志
      print('🔍 [版主管理] hasModerator: $hasModerator');
      print('🔍 [版主管理] isAdmin: $isAdmin');
      print('🔍 [版主管理] isModerator: $isModerator');
      print('🔍 [版主管理] moderatorId: ${city.moderatorId}');
      print('🔍 [版主管理] moderator: ${city.moderator?.name}');

      // 如果已有版主且当前用户不是管理员也不是该城市版主，只显示版主信息
      if (hasModerator && !isAdmin && !isModerator) {
        print('✅ [版主管理] 显示只读版主信息');
        return _buildModeratorInfoBanner(city.moderator!);
      }

      // 如果已有版主且当前用户是管理员或该城市版主，显示版主信息+更换按钮
      if (hasModerator && (isAdmin || isModerator)) {
        print('✅ [版主管理] 显示版主信息+管理按钮');
        return _buildModeratorInfoWithChange(city.moderator!);
      }

      // 如果没有版主，根据用户角色显示不同按钮
      if (isAdmin) {
        print('✅ [版主管理] 显示指定版主按钮（管理员）');
        return _buildAssignModeratorButton();
      } else {
        print('✅ [版主管理] 显示申请成为版主按钮（普通用户）');
        return _buildApplyModeratorButton();
      }
    });
  }

  /// 版主信息横幅（只读）
  Widget _buildModeratorInfoBanner(Moderator moderator) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.9),
            Colors.blue.shade700.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: _safeNetworkImage(moderator.avatar),
            child: _safeNetworkImage(moderator.avatar) == null
                ? const Icon(FontAwesomeIcons.user, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModeratorHeader(moderator, label: '城市版主：'),
                if (moderator.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    moderator.email!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 版主信息+更换按钮（管理员可见）
  Widget _buildModeratorInfoWithChange(Moderator moderator) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.9),
            Colors.blue.shade700.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: _safeNetworkImage(moderator.avatar),
            child: _safeNetworkImage(moderator.avatar) == null
                ? const Icon(FontAwesomeIcons.user, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModeratorHeader(moderator, label: '版主：'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAssignModeratorDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('更换版主', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildModeratorHeader(Moderator moderator, {required String label}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(FontAwesomeIcons.circleCheck, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              _buildModeratorNameLink(moderator),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeratorNameLink(Moderator moderator) {
    return GestureDetector(
      onTap: () => _openModeratorProfile(moderator),
      behavior: HitTestBehavior.translucent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            moderator.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            FontAwesomeIcons.upRightFromSquare,
            size: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ],
      ),
    );
  }

  void _openModeratorProfile(Moderator moderator) {
    if (moderator.id.isEmpty) {
      AppToast.info('无法打开用户资料');
      return;
    }

    Get.toNamed(
      AppRoutes.userProfile,
      arguments: {
        'userId': moderator.id,
        'username': moderator.name,
        if (moderator.avatar != null) 'avatarUrl': moderator.avatar,
        if (moderator.email != null) 'email': moderator.email,
      },
    );
  }

  /// 申请成为版主按钮（普通用户）
  Widget _buildApplyModeratorButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF4458).withValues(alpha: 0.9),
            Colors.deepOrange.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.handHoldingHeart, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '成为城市版主，管理社区内容',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _showApplyModeratorDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFFF4458),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('立即申请', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  /// 指定版主按钮（管理员）
  Widget _buildAssignModeratorButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.9),
            Colors.deepOrange.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.userShield, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '该城市暂无版主',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAssignModeratorDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('指定版主', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  /// 申请成为版主对话框
  void _showApplyModeratorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(FontAwesomeIcons.handHoldingHeart, color: Color(0xFFFF4458), size: 28),
            SizedBox(width: 12),
            Text('申请成为版主'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '您确定要申请成为 $cityName 的版主吗？',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '版主权限：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionItem('管理城市内容和评论'),
                  _buildPermissionItem('审核用户提交的信息'),
                  _buildPermissionItem('组织社区活动'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => _handleApplyModerator(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
            ),
            child: const Text('确认申请'),
          ),
        ],
      ),
    );
  }

  /// 指定版主 - 跳转到专门的指定版主页面
  void _showAssignModeratorDialog() async {
    final result = await Get.to(() => AssignModeratorPage(
          cityId: cityId,
          cityName: cityName,
        ));

    // 如果指定成功,只需要刷新城市基本信息(更新ModeratorId字段)
    if (result == true) {
      print('✅ [CityDetail] 版主指定成功，强制刷新城市基本信息');
      final cityDetailController = Get.find<CityDetailStateController>();
      await cityDetailController.loadCityDetail(cityId, forceRefresh: true);
    }
    // 用户点击返回按钮,不需要刷新(没有任何更改)
  }

  Widget _buildPermissionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.circleCheck, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  /// 处理申请版主
  Future<void> _handleApplyModerator() async {
    Navigator.of(context).pop(); // 关闭对话框

    // 显示加载提示
    AppToast.info('正在提交申请...');

    try {
      final controller = Get.find<CityDetailStateController>();

      // 通过 Get.find 获取 repository
      final repository = Get.find<ICityRepository>();

      final result = await repository.applyModerator(cityId);

      result.fold(
        onSuccess: (success) async {
          AppToast.success('申请已提交！我们会尽快审核');

          // 发送通知给所有管理员
          if (Get.isRegistered<NotificationStateController>()) {
            final notificationController = Get.find<NotificationStateController>();
            final city = controller.currentCity.value;

            await notificationController.sendToAdmins(
              title: '新的版主申请',
              message: '用户申请成为 ${city?.name ?? '某城市'} 的版主，请及时审核',
              type: NotificationType.moderatorApplication,
              relatedId: cityId,
              metadata: {
                'cityName': city?.name ?? '',
                'cityId': cityId,
              },
            );
          }

          // 刷新城市信息
          controller.loadCityDetail(cityId);
        },
        onFailure: (error) {
          AppToast.error('申请失败：${error.message}');
        },
      );
    } catch (e) {
      AppToast.error('申请失败：${e.toString()}');
    }
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

    // 初始化 TabController (10个tab,包含ProsCons), 设置初始索引
    _tabController = TabController(
      length: 10,
      vsync: this,
      initialIndex: initialTab,
    );

    // 监听 tab 切换
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Tab切换逻辑可以保留在UI层面,不需要通知controller
        setState(() {
          _currentPage = _tabController.index;
        });

        // 当切换到 Weather tab (索引 6) 时，加载天气数据（利用controller内部缓存）
        if (_tabController.index == 6) {
          final weatherController = Get.find<WeatherStateController>();
          // 不使用forceRefresh，让controller内部缓存机制决定是否需要加载
          weatherController.loadCityWeather(
            cityId,
            includeForecast: true,
            days: 7,
          );
        }

        // 当切换到 Coworking tab (索引 9) 时，检查缓存后再决定是否加载
        if (_tabController.index == 9) {
          final coworkingController = Get.find<CoworkingStateController>();
          // 只有在城市ID不同或数据为空时才重新加载
          if (coworkingController.currentCityId.value != cityId) {
            coworkingController.loadCoworkingSpacesByCity(cityId);
            print('🔄 [TabSwitch] 切换到 Coworking tab，加载新城市数据');
          }
        }
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

    // ✅ 异步初始化城市数据,不阻塞页面显示
    Future.microtask(() async {
      final cityDetailController = Get.find<CityDetailStateController>();
      final userContentController = Get.find<UserCityContentStateController>();
      final prosConsController = Get.find<ProsConsStateController>();

      // 加载城市详情
      cityDetailController.loadCityDetail(cityId);

      // 检查登录状态
      final tokenService = TokenStorageService();
      final token = await tokenService.getAccessToken();
      final isLoggedIn = token != null && token.isNotEmpty;

      if (isLoggedIn) {
        // 登录用户:加载所有用户生成内容
        userContentController.loadCityPhotos(cityId);
        userContentController.loadCityExpenses(cityId);
        userContentController.loadCityReviews(cityId);
        userContentController.loadCityCostSummary(cityId);
        prosConsController.loadCityProsCons(cityId);
      } else {
        // 未登录用户:仅加载基本信息,跳过需要认证的内容
        print('⚠️ [CityDetail] 用户未登录,跳过加载用户生成内容');
      }
    });
  }

  /// 当页面重新可见时重新加载数据
  Future<void> reloadCityData() async {
    print('🔄 [CityDetail] 重新加载城市数据: $cityId');

    final cityDetailController = Get.find<CityDetailStateController>();
    final userContentController = Get.find<UserCityContentStateController>();
    final prosConsController = Get.find<ProsConsStateController>();

    // 重新加载城市详情（强制刷新）
    await cityDetailController.loadCityDetail(cityId);

    // 检查登录状态
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    final isLoggedIn = token != null && token.isNotEmpty;

    if (isLoggedIn) {
      // 登录用户:加载所有用户生成内容
      userContentController.loadCityPhotos(cityId);
      userContentController.loadCityExpenses(cityId);
      userContentController.loadCityReviews(cityId);
      userContentController.loadCityCostSummary(cityId);
      prosConsController.loadCityProsCons(cityId);
    } else {
      print('⚠️ [CityDetail] 用户未登录,跳过加载用户生成内容');
    }
  }

  @override
  Future<void> onRouteResume() async {
    await reloadCityData();
  }

  /// 检查用户是否有权限生成指南（管理员或当前城市版主）
  Future<bool> _checkGeneratePermission() async {
    print('🔐 [权限检查] 开始检查生成权限...');

    try {
      final cityDetailController = Get.find<CityDetailStateController>();
      final city = cityDetailController.currentCity.value;

      if (city != null) {
        print('🔐 [权限检查] 城市信息:');
        print('   cityId: ${city.id}');
        print('   cityName: ${city.name}');
        print('   isCurrentUserAdmin: ${city.isCurrentUserAdmin}');
        print('   isCurrentUserModerator: ${city.isCurrentUserModerator}');
        print('   moderatorId: ${city.moderatorId}');

        // 检查是否是管理员或该城市的版主
        if (city.isCurrentUserAdmin) {
          print('✅ [权限检查] 当前用户是管理员，允许生成');
          return true;
        }

        if (city.isCurrentUserModerator) {
          print('✅ [权限检查] 当前用户是该城市版主，允许生成');
          return true;
        }

        print('❌ [权限检查] 当前用户既不是管理员也不是该城市版主');
        _showNoPermissionDialog();
        return false;
      } else {
        print('⚠️ [权限检查] 城市信息为空');
      }
    } catch (e) {
      print('❌ [权限检查] 获取城市信息异常: $e');
    }

    // 如果无法获取城市信息，从 token 获取角色（仅检查 admin）
    print('🔐 [权限检查] 从 token 获取角色信息...');
    final tokenService = TokenStorageService();
    final role = await tokenService.getUserRole();
    print('   用户角色: $role');

    if (role == 'admin') {
      print('✅ [权限检查] 用户是管理员，允许生成');
      return true;
    }

    print('❌ [权限检查] 用户无权限生成指南');
    _showNoPermissionDialog();
    return false;
  }

  /// 显示无权限对话框
  void _showNoPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                FontAwesomeIcons.lock,
                color: Colors.orange[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                '权限不足',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '抱歉，只有管理员或该城市的版主才能生成 AI 旅游指南。',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.circleInfo,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '想要成为版主？贡献优质内容即可获得审核资格！',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('我知道了'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: 跳转到申请成为版主的页面
                AppToast.info('申请版主功能即将上线');
              },
              icon: const Icon(FontAwesomeIcons.handHoldingHeart, size: 18),
              label: const Text('申请成为版主'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 显示 AI 生成进度对话框
  void _showAIGenerateProgressDialog(AiStateController controller) async {
    // 先检查权限
    if (!await _checkGeneratePermission()) {
      return;
    }

    print('🎬 [ProgressDialog] 准备显示对话框');
    print('   当前状态: isGenerating=${controller.isGeneratingGuide}, progress=${controller.guideGenerationProgress}%');

    // 在显示对话框之前设置监听器
    Worker? statusWorker;

    // 显示对话框
    showDialog(
      context: context,
      barrierDismissible: false, // 不允许点击外部关闭
      builder: (BuildContext dialogContext) {
        // 🎯 在对话框显示后立即设置监听器
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (statusWorker == null) {
            print('🔧 [ProgressDialog] 设置 ever 监听器');
            print('   当前 isGuideCompleted 值: ${controller.isGuideCompleted}');

            statusWorker = ever(
              controller.isGuideCompletedRx,
              (completed) {
                print('🔔 [ProgressDialog] ever 回调被触发！completed=$completed');

                if (completed) {
                  print('🎉 [ProgressDialog] 任务已完成，800ms后关闭对话框');

                  Future.delayed(const Duration(milliseconds: 800), () {
                    print('🚪 [ProgressDialog] 执行关闭操作');

                    if (Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                      print('✅ [ProgressDialog] 对话框已关闭');

                      // 清理监听器
                      statusWorker?.dispose();
                      statusWorker = null;

                      // 延迟500ms加载最新guide数据
                      Future.delayed(const Duration(milliseconds: 500), () {
                        print('🔄 [ProgressDialog] 重新加载 guide 数据');
                        controller.loadCityGuide(
                          cityId: cityId,
                          cityName: cityName,
                        );

                        if (controller.currentGuide != null) {
                          AppToast.success('AI 旅游指南生成成功!');
                        } else if (controller.guideError != null) {
                          AppToast.error('生成失败: ${controller.guideError}');
                        }
                      });
                    } else {
                      print('❌ [ProgressDialog] 无法关闭 - canPop=false');
                    }
                  });
                }
              },
            );
          }
        });

        return Obx(() {
          print(
              '🔄 [ProgressDialog] Obx rebuild - progress=${controller.guideGenerationProgress}%, completed=${controller.isGuideCompleted}');

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  FontAwesomeIcons.wandMagicSparkles,
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
                LinearProgressIndicator(
                  value: controller.guideGenerationProgress / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF4458),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        controller.guideGenerationMessage.isEmpty ? '准备开始生成...' : controller.guideGenerationMessage,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '${controller.guideGenerationProgress}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // 后端运行按钮 - 只在生成中时显示
              if (controller.isGeneratingGuide)
                TextButton(
                  onPressed: () {
                    print('❌ [ProgressDialog] 用户取消');
                    statusWorker?.dispose();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('后端运行'),
                ),
            ],
          );
        });
      },
    );

    // 启动异步生成任务
    print('🚀 [ProgressDialog] 启动生成任务');
    controller.generateDigitalNomadGuideStream(
      cityId: cityId,
      cityName: cityName,
    );
  }

  // 获取城市展示图片列表

  // 安全的创建 NetworkImage,处理空字符串和 null
  ImageProvider? _safeNetworkImage(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }
    return NetworkImage(url);
  }

  List<String> _getCityImages() {
    // 基于城市主图片生成多张展示图片
    // 使用不同的Unsplash参数来获取该城市的不同视角图片
    final baseImage = cityImage;

    // 检查图片 URL 是否有效
    if (baseImage.isEmpty) {
      // 返回默认通用城市图片
      return [
        'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800',
        'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=800',
        'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=800',
      ];
    }

    // 如果主图片是Unsplash链接，生成系列图片
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
        baseImage, // 主图片
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

  // 刷新包装方法
  Future<void> _handleRefreshReviews(UserCityContentStateController controller) async {
    _isRefreshingReviews = true;
    await controller.loadCityReviews(cityId);
    _isRefreshingReviews = false;
  }

  Future<void> _handleRefreshPhotos(UserCityContentStateController controller) async {
    _isRefreshingPhotos = true;
    await controller.loadCityPhotos(cityId);
    _isRefreshingPhotos = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _tabController.dispose();

    // 🔥 页面销毁时清空指南状态,防止显示错误的城市指南
    try {
      final aiController = Get.find<AiStateController>();
      aiController.resetGuideState();
      print('🧹 [CityDetailPage] 页面销毁,已清空指南状态');
    } catch (e) {
      print('⚠️ [CityDetailPage] 清空指南状态失败: $e');
    }

    // 🔥 清空评分数据,防止跳转到其他城市时显示旧数据
    try {
      final ratingController = Get.find<CityRatingController>();
      ratingController.statistics.clear();
      ratingController.categories.clear();
      ratingController.overallScore.value = 0.0;
      print('🧹 [CityDetailPage] 页面销毁,已清空评分数据');
    } catch (e) {
      print('⚠️ [CityDetailPage] 清空评分数据失败: $e');
    }

    super.dispose();
  }

  /// 检查用户是否有权限管理内容（admin 或当前城市的版主）
  Future<bool> _canUserManageContent() async {
    final tokenService = TokenStorageService();
    final role = await tokenService.getUserRole();

    // 1. 检查是否为全局管理员
    if (role == 'admin') {
      return true;
    }

    // 2. 检查是否为当前城市的版主
    final cityDetailController = Get.find<CityDetailStateController>();
    final city = cityDetailController.currentCity.value;
    if (city != null && city.isCurrentUserModerator) {
      return true;
    }

    return false;
  }

  /// 检查用户是否为管理员或版主（用于区分跳转行为）
  Future<bool> _isAdminOrModerator() async {
    try {
      final cityDetailController = Get.find<CityDetailStateController>();
      final city = cityDetailController.currentCity.value;
      if (city != null) {
        return city.isCurrentUserAdmin || city.isCurrentUserModerator;
      }
    } catch (_) {
      // 如果当前城市信息尚未加载，退回到 Token 判断逻辑
    }

    final tokenService = TokenStorageService();
    final role = await tokenService.getUserRole();
    return role == 'admin' || role == 'moderator';
  }

  /// 检查用户是否已登录
  Future<bool> _isUserLoggedIn() async {
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _handleScoreAddAction() async {
    final isAdminOrMod = await _isAdminOrModerator();
    if (!mounted) return;

    if (isAdminOrMod) {
      await Get.to(
        () => ManageCityRatingsPage(
          cityId: cityId,
          cityName: cityName,
        ),
      );
      return;
    }

    final newItem = await showRatingItemDialog(
      context: context,
      idBuilder: _generateRatingId,
    );
    if (!mounted) return;

    if (newItem != null) {
      setState(() => _customRatingItems = [..._customRatingItems, newItem]);
      AppToast.success('感谢你的评分贡献！');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 获取所有需要的State Controllers
    final cityDetailController = Get.find<CityDetailStateController>();
    final weatherController = Get.find<WeatherStateController>();
    final coworkingController = Get.find<CoworkingStateController>();
    final userContentController = Get.find<UserCityContentStateController>();
    final aiController = Get.find<AiStateController>();
    final prosConsController = Get.find<ProsConsStateController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        // 🎨 加载时显示完整骨架屏
        if (cityDetailController.isLoading.value) {
          return const CityDetailSkeleton();
        }

        // 显示实际内容
        return Stack(
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
                          FontAwesomeIcons.arrowLeft,
                          color: _appBarOpacity > 0.5 ? Colors.black87 : Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    actions: [
                      // 添加按钮 - 所有登录用户都可见，但跳转行为不同
                      AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, child) {
                          return FutureBuilder<bool>(
                            future: _isUserLoggedIn(),
                            builder: (context, snapshot) {
                              if (snapshot.data != true) {
                                return const SizedBox.shrink();
                              }

                              final currentTab = _tabController.index;
                              IconData icon;
                              VoidCallback? onPressed;

                              // 根据当前标签页显示对应的按钮
                              if (currentTab == 0) {
                                // Scores - 权限控制: 普通用户弹窗, 管理角色前往数据列表
                                icon = FontAwesomeIcons.star;
                                onPressed = () => _handleScoreAddAction();
                              } else if (currentTab == 2) {
                                // Pros & Cons
                                icon = FontAwesomeIcons.penToSquare;
                                onPressed = () async {
                                  final isAdminOrMod = await _isAdminOrModerator();
                                  if (isAdminOrMod) {
                                    // Admin/Moderator: 跳转到管理列表页面
                                    await Get.to(() => ManageProsConsPage(
                                          cityId: cityId,
                                          cityName: cityName,
                                        ));
                                    prosConsController.loadCityProsCons(cityId);
                                  } else {
                                    // 普通用户: 直接跳转到添加页面
                                    await Get.to(() => ProsAndConsAddPage(
                                          cityId: cityId,
                                          cityName: cityName,
                                        ));
                                    prosConsController.loadCityProsCons(cityId);
                                  }
                                };
                              } else if (currentTab == 3) {
                                // Reviews
                                icon = FontAwesomeIcons.penToSquare;
                                onPressed = () async {
                                  final isAdminOrMod = await _isAdminOrModerator();
                                  if (isAdminOrMod) {
                                    // Admin/Moderator: 跳转到管理列表页面
                                    await Get.to(() => ManageReviewsPage(
                                          cityId: cityId,
                                          cityName: cityName,
                                        ));
                                    userContentController.loadCityReviews(cityId);
                                  } else {
                                    // 普通用户: 直接跳转到添加页面
                                    await Get.to(() => AddReviewPage(
                                          cityId: cityId,
                                          cityName: cityName,
                                        ));
                                    userContentController.loadCityReviews(cityId);
                                  }
                                };
                              } else if (currentTab == 4) {
                                // Cost
                                icon = FontAwesomeIcons.penToSquare;
                                onPressed = () async {
                                  final isAdminOrMod = await _isAdminOrModerator();
                                  if (isAdminOrMod) {
                                    // Admin/Moderator: 跳转到管理列表页面
                                    await Get.to(() => ManageCostPage(
                                          cityId: cityId,
                                          cityName: cityName,
                                        ));
                                    userContentController.loadCityExpenses(cityId);
                                    userContentController.loadCityCostSummary(cityId);
                                  } else {
                                    // 普通用户: 直接跳转到添加页面
                                    await Get.to(() => AddCostPage(
                                          cityId: cityId,
                                          cityName: cityName,
                                        ));
                                    userContentController.loadCityExpenses(cityId);
                                    userContentController.loadCityCostSummary(cityId);
                                  }
                                };
                              } else if (currentTab == 5) {
                                // Photos - 所有用户都用对话框形式
                                icon = FontAwesomeIcons.photoFilm;
                                onPressed = () async {
                                  final result = await Get.to(
                                    () => CityPhotoSubmissionPage(
                                      cityId: cityId,
                                      cityName: cityName,
                                    ),
                                  );
                                  if (result != null && result is Map && result['uploaded'] == true) {
                                    userContentController.loadCityPhotos(cityId);
                                  }
                                };
                              } else if (currentTab == 9) {
                                // Coworking
                                icon = FontAwesomeIcons.briefcase;
                                onPressed = () async {
                                  // 所有用户都直接跳转到添加页面
                                  final cityDetailController = Get.find<CityDetailStateController>();
                                  final city = cityDetailController.currentCity.value;

                                  final result = await Get.to(() => AddCoworkingPage(
                                        cityId: cityId,
                                        cityName: cityName,
                                        countryName: city?.country,
                                      ));
                                  if (result != null && result['success'] == true) {
                                    coworkingController.loadCoworkingSpacesByCity(cityId);
                                  }
                                };
                              } else {
                                return const SizedBox.shrink();
                              }

                              return Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(icon, color: Colors.white, size: 20),
                                  onPressed: onPressed,
                                  tooltip: 'Add content',
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 4),
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
                            FontAwesomeIcons.shareNodes,
                            color: _appBarOpacity > 0.5 ? Colors.black87 : Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            // 分享城市信息
                            _shareCityInfo();
                          },
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      titlePadding: const EdgeInsets.only(bottom: 16),
                      title: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            color: _appBarOpacity > 0.5 ? const Color(0xFFFF4458) : Colors.white,
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
                                            FontAwesomeIcons.imagePortrait,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
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
                            top: 24,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _getCityImages().length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentPage == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: _currentPage == index ? Colors.white : Colors.white.withValues(alpha: 0.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 版主管理蒙层 - 在城市名称上方
                          Positioned(
                            bottom: 70,
                            left: 16,
                            right: 16,
                            child: _buildModeratorManagementOverlay(cityDetailController),
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
                          // 评分徽章 - 从 CityRatingController 动态获取
                          Obx(() {
                            final ratingController = Get.find<CityRatingController>();
                            final score = ratingController.overallScore.value;

                            return Container(
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
                                    color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.star,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    score.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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
                            final cityController = Get.find<CityDetailStateController>();
                            final isFavorited = cityController.isFavorited.value;
                            final isToggling = cityController.isTogglingFavorite.value;

                            return Container(
                              decoration: BoxDecoration(
                                color: isFavorited ? const Color(0xFFFF4458).withValues(alpha: 0.1) : Colors.grey[100],
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
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Color(0xFFFF4458),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        isFavorited ? FontAwesomeIcons.heart : FontAwesomeIcons.heart,
                                        color: isFavorited ? const Color(0xFFFF4458) : Colors.grey[700],
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        cityController.toggleFavorite();
                                      },
                                    ),
                            );
                          }),
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
                          Tab(text: l10n.scores),
                          Tab(text: l10n.guide),
                          Tab(text: l10n.prosAndCons),
                          Tab(text: l10n.reviews),
                          Tab(text: l10n.cost),
                          Tab(text: l10n.photos),
                          Tab(text: l10n.weather),
                          Tab(text: l10n.hotels),
                          Tab(text: l10n.neighborhoods),
                          Tab(text: l10n.coworking),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildScoresTab(context, cityDetailController),
                  _buildGuideTab(aiController),
                  _buildProsConsTab(prosConsController),
                  _buildReviewsTab(userContentController),
                  _buildCostTab(userContentController),
                  _buildPhotosTab(userContentController),
                  _buildWeatherTab(weatherController),
                  _buildHotelsTab(cityDetailController),
                  _buildNeighborhoodsTab(cityDetailController),
                  _buildCoworkingTab(coworkingController),
                ],
              ),
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
                    // 跳转到创建旅行计划页面
                    Get.to(
                      () => CreateTravelPlanPage(
                        cityId: cityId,
                        cityName: cityName,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                            FontAwesomeIcons.wandMagicSparkles,
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
                          FontAwesomeIcons.arrowRight,
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
        ); // body: Obx 结束
      }), // Scaffold 的 body 结束
    );
  }

  // Scores 标签 (简化版 - 只显示5个基本评分)
  Widget _buildScoresTab(BuildContext context, CityDetailStateController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      // 显示加载状态
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final city = controller.currentCity.value;
      if (city == null) {
        return Center(child: Text(l10n.noData));
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadCityDetail(cityId),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 用户评分系统（极简风格）
            CityRatingsCard(cityId: city.id),
          ],
        ),
      );
    });
  }

  // Digital Nomad Guide 标签页
  Widget _buildGuideTab(AiStateController controller) {
    // 🔥 只在首次加载或城市变化时请求数据，防止滚动时重复请求
    if (!_hasInitializedGuide || _lastGuideLoadedCityId != cityId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentGuide = controller.currentGuide;

        // 如果是不同城市,先清空旧数据
        if (currentGuide != null && currentGuide.cityId != cityId) {
          print('🔄 [GuideTab] 城市切换: ${currentGuide.cityId} → $cityId, 清空旧数据');
          controller.resetGuideState();
        }

        // 只在未加载过且控制器空闲时才加载
        if (!controller.isGeneratingGuide && !controller.isLoadingGuide) {
          final shouldLoad = currentGuide == null || currentGuide.cityId != cityId;
          if (shouldLoad) {
            print('📖 [GuideTab] 加载城市指南: $cityName (ID: $cityId)');
            controller.loadCityGuide(
              cityId: cityId,
              cityName: cityName,
            );
          }
        }

        // 标记已初始化
        _hasInitializedGuide = true;
        _lastGuideLoadedCityId = cityId;
      });
    }

    return Obx(() {
      print(
          '🔍 [GuideTab] Rebuilding... cityId=$cityId, isLoading=${controller.isLoadingGuide}, isGenerating=${controller.isGeneratingGuide}, guide=${controller.currentGuide != null}, guideCity=${controller.currentGuide?.cityId}');

      // 优先显示指南内容(如果有且是当前城市的)
      final guide = controller.currentGuide;
      if (guide != null && guide.cityId == cityId) {
        print('✅ [GuideTab] Showing guide content for $cityName');
        return _buildGuideContent(context, guide, controller);
      }

      // 显示加载或生成状态
      if (controller.isLoadingGuide || controller.isGeneratingGuide) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                controller.isGeneratingGuide ? '🤖 AI 正在生成旅游指南...' : '📖 正在加载旅游指南...',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              if (controller.isGeneratingGuide) ...[
                const SizedBox(height: 12),
                Text(
                  controller.guideGenerationMessage,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${controller.guideGenerationProgress}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4458),
                  ),
                ),
              ],
            ],
          ),
        );
      }

      // 只有在确实没有数据且不在加载中时，才显示空状态
      print('⚠️ [GuideTab] Guide is null and not loading, showing empty state');
      // 显示空状态,带有"AI 生成"按钮
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔄 生成中的状态提示
              if (controller.isGeneratingGuide) ...[
                const CircularProgressIndicator(
                  color: Color(0xFFFF4458),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🤖 正在生成指南...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFF4458),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请稍候,生成完成后会自动显示',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
              ],
              const Icon(
                FontAwesomeIcons.map,
                size: 60,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.loadingGuide,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.isGeneratingGuide
                        ? null
                        : () async {
                            // 先检查权限
                            if (!await _checkGeneratePermission()) {
                              return;
                            }
                            _showAIGenerateProgressDialog(controller);
                          },
                    icon: const Icon(FontAwesomeIcons.wandMagicSparkles),
                    label: const Text('AI 生成指南'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4458),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300], // 禁用时的背景色
                      disabledForegroundColor: Colors.grey[500], // 禁用时的文字色
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      // 空状态结束，显示指南内容的逻辑已在前面处理
    });
  }

  Widget _buildGuideContent(BuildContext context, guide, AiStateController controller) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      children: [
        // AI 重新生成按钮
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                FontAwesomeIcons.cloudArrowUp,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '☁️ 从后端加载',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green[800],
                  ),
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: controller.isGeneratingGuide || controller.isLoadingGuide
                        ? null
                        : () {
                            // 重新从后端加载指南
                            controller.loadCityGuide(
                              cityId: cityId,
                              cityName: cityName,
                            );
                          },
                    icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18),
                    label: const Text('刷新'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF4458),
                      disabledForegroundColor: Colors.grey[400],
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: controller.isGeneratingGuide || controller.isLoadingGuide
                        ? null
                        : () async {
                            if (!await _checkGeneratePermission()) {
                              return;
                            }
                            _showAIGenerateProgressDialog(controller);
                          },
                    icon: const Icon(FontAwesomeIcons.wandMagicSparkles, size: 18),
                    label: const Text('AI 生成'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF4458),
                      disabledForegroundColor: Colors.grey[400],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                  const Text('💡', style: TextStyle(fontSize: 18, color: Color(0xFFFF4458))),
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
  Widget _buildProsConsTab(ProsConsStateController controller) {
    return Obx(() {
      // 显示加载状态
      final isLoading = controller.isLoadingPros.value || controller.isLoadingCons.value;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadCityProsCons(cityId),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
              children: [
                const Text(
                  '优点',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // 优点列表或空状态
                if (controller.prosList.isEmpty)
                  _buildEmptyProsConsState(
                    icon: FontAwesomeIcons.circleCheck,
                    iconColor: Colors.green,
                    title: '还没有优点',
                    subtitle: '分享你在这座城市的美好体验',
                    buttonText: '添加优点',
                    onTap: () => _showAddProsConsPage(initialTab: 0),
                  )
                else
                  ...controller.prosList.map((item) {
                    final hasVoted = controller.hasUserVoted(item.id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.circleCheck,
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
                            _buildProsConsVoteBadge(
                              hasVoted: hasVoted,
                              count: item.upvotes,
                              onTap: hasVoted ? null : () => _handleProsConsVote(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                const Text(
                  '挑战',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // 挑战列表或空状态
                if (controller.consList.isEmpty)
                  _buildEmptyProsConsState(
                    icon: FontAwesomeIcons.ban,
                    iconColor: Colors.red,
                    title: '还没有挑战',
                    subtitle: '分享你遇到的困难和需要改进的地方',
                    buttonText: '添加挑战',
                    onTap: () => _showAddProsConsPage(initialTab: 1),
                  )
                else
                  ...controller.consList.map((item) {
                    final hasVoted = controller.hasUserVoted(item.id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.ban,
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
                            _buildProsConsVoteBadge(
                              hasVoted: hasVoted,
                              count: item.upvotes,
                              onTap: hasVoted ? null : () => _handleProsConsVote(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
            // 添加按钮（仅 admin/moderator 可见）
            FutureBuilder<bool>(
              future: _canUserManageContent(),
              builder: (context, snapshot) {
                if (snapshot.data != true) return const SizedBox.shrink();
                return Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    heroTag: 'add_pros_cons',
                    onPressed: () => _showAddProsConsPage(),
                    backgroundColor: const Color(0xFFFF4458),
                    child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  // 空状态显示组件
  Widget _buildEmptyProsConsState({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: iconColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(FontAwesomeIcons.plus, size: 18),
            label: Text(buttonText),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF4458),
              side: const BorderSide(color: Color(0xFFFF4458)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProsConsVoteBadge({
    required bool hasVoted,
    required int count,
    required VoidCallback? onTap,
  }) {
    const accent = Color(0xFFFF4458);
    final Color color = hasVoted ? Colors.grey : accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasVoted ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: hasVoted ? Colors.grey.withOpacity(0.12) : const Color(0xFFFFEEF2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FontAwesomeIcons.thumbsUp, size: 18, color: color),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                hasVoted ? '已投' : '投票',
                style: TextStyle(fontSize: 10, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reviews 标签
  Widget _buildReviewsTab(UserCityContentStateController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final realUserReviews = controller.reviews; // ✅ 使用reviews属性

      // 首次加载时显示中间加载指示器
      if (controller.isLoadingReviews.value && realUserReviews.isEmpty && !_isRefreshingReviews) {
        return const Center(child: CircularProgressIndicator());
      }

      // 如果为空
      if (realUserReviews.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => _handleRefreshReviews(controller),
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
                        Icon(FontAwesomeIcons.commentDots, size: 64, color: Colors.grey[300]),
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
                  ),
                ),
              );
            },
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _handleRefreshReviews(controller), // ✅ 使用loadCityReviews方法
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
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
                          backgroundImage: review.userAvatar != null && review.userAvatar!.isNotEmpty
                              ? NetworkImage(review.userAvatar!)
                              : null,
                          child: review.userAvatar == null || review.userAvatar!.isEmpty
                              ? Text(
                                  review.username.isNotEmpty ? review.username.substring(0, 1).toUpperCase() : '?',
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
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (review.visitDate != null)
                                Text(
                                  '${l10n.visited} ${_formatDate(review.visitDate!, l10n)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.star, color: Colors.amber, size: 16),
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
                                      image: NetworkImage(review.photoUrls[photoIndex]),
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
                                  FontAwesomeIcons.imagePortrait,
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
  Widget _buildCostTab(UserCityContentStateController controller) {
    final l10n = AppLocalizations.of(context)!; // ✅ 添加国际化
    return Obx(() {
      final communityCost = controller.costSummary.value; // ✅ 使用costSummary属性

      // 如果数据还在加载中
      if (controller.isLoadingCostSummary.value && communityCost == null) {
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

      return RefreshIndicator(
        onRefresh: () => controller.loadCityCostSummary(cityId),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        l10n.basedOnRealExpenses(totalExpenseCount, totalExpenseCount != 1 ? 's' : ''),
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
                  icon: FontAwesomeIcons.hotel,
                  color: Colors.purple,
                ),
                _buildCostCategoryCard(
                  category: l10n.food,
                  amount: food,
                  icon: FontAwesomeIcons.utensils,
                  color: Colors.orange,
                ),
                _buildCostCategoryCard(
                  category: l10n.transportation,
                  amount: transportation,
                  icon: FontAwesomeIcons.car,
                  color: Colors.blue,
                ),
                _buildCostCategoryCard(
                  category: l10n.activity,
                  amount: activity,
                  icon: FontAwesomeIcons.ticket,
                  color: Colors.green,
                ),
                _buildCostCategoryCard(
                  category: l10n.shopping,
                  amount: shopping,
                  icon: FontAwesomeIcons.bagShopping,
                  color: Colors.pink,
                ),
                _buildCostCategoryCard(
                  category: 'Other',
                  amount: other,
                  icon: FontAwesomeIcons.ellipsis,
                  color: Colors.grey,
                ),
                const SizedBox(height: 32),
              ], // children 数组闭合
            ), // ListView 闭合
          ],
        ),
      );
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
  Widget _buildPhotosTab(UserCityContentStateController controller) {
    return Obx(() {
      final realUserPhotos = controller.photos; // ✅ 使用photos属性
      final l10n = AppLocalizations.of(context)!;

      // 首次加载时显示中间加载指示器
      if (controller.isLoadingPhotos.value && realUserPhotos.isEmpty && !_isRefreshingPhotos) {
        return const Center(child: CircularProgressIndicator());
      }

      // 如果为空
      if (realUserPhotos.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => _handleRefreshPhotos(controller),
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
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }

      final groupedMap = <String, _PhotoGroup>{};
      for (final photo in realUserPhotos) {
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

      final groupedList = groupedMap.values.toList()..sort((a, b) => b.latestUpload.compareTo(a.latestUpload));

      final slivers = <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.photos,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ];

      for (var i = 0; i < groupedList.length; i++) {
        final group = groupedList[i];
        final uploaderName = _resolveUploaderName(controller, group.uploaderId);
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
                  final globalIndex = realUserPhotos.indexWhere((element) => element.id == photo.id);
                  final initialIndex = globalIndex >= 0 ? globalIndex : 0;

                  return GestureDetector(
                    onTap: () => _showPhotoGallery(realUserPhotos, initialIndex),
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
                },
                childCount: group.photos.length,
              ),
            ),
          ),
        );

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
                '$uploaderName | ${l10n.uploaded} ${_formatDate(group.latestUpload, l10n)}',
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
        onRefresh: () => _handleRefreshPhotos(controller),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: slivers,
        ),
      );
    });
  }

  /// 全屏查看照片集合
  void _showPhotoGallery(List<UserCityPhoto> photos, int initialIndex) {
    if (photos.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final pageController = PageController(initialPage: initialIndex);
    int currentIndex = initialIndex;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            backgroundColor: Colors.black,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.xmark, color: Colors.white),
                        onPressed: Get.back,
                      ),
                      const Spacer(),
                      Text(
                        '${currentIndex + 1}/${photos.length}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (value) => setState(() {
                      currentIndex = value;
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (photos[currentIndex].caption?.trim().isNotEmpty ?? false)
                            ? photos[currentIndex].caption!.trim()
                            : l10n.photo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if ((photos[currentIndex].location?.isNotEmpty ?? false) ||
                          photos[currentIndex].placeName?.isNotEmpty == true)
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.locationDot, size: 16, color: Colors.white54),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                photos[currentIndex].placeName?.isNotEmpty == true
                                    ? photos[currentIndex].placeName!
                                    : (photos[currentIndex].location ?? ''),
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
                        '${l10n.uploaded} ${_formatDate(photos[currentIndex].createdAt, l10n)}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      barrierColor: Colors.black87,
    );
  }

  // Weather 标签
  Widget _buildWeatherTab(WeatherStateController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      // 显示加载状态
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final weather = controller.weather.value;
      if (weather == null) {
        return RefreshIndicator(
          onRefresh: () => controller.loadCityWeather(cityId, forceRefresh: true),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
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
                  ),
                ),
              );
            },
          ),
        );
      }

      final rawDescription = weather.weatherDescription.trim();
      final description =
          rawDescription.isEmpty ? weather.weather : rawDescription[0].toUpperCase() + rawDescription.substring(1);
      final timezone = _formatTimezone(weather.timezoneOffset);
      final sunrise = _formatWeatherTime(weather.sunrise, weather.timezoneOffset);
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

      return RefreshIndicator(
        onRefresh: () => controller.loadCityWeather(cityId, forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 96),
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
                            if (cityName.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.locationDot,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    cityName,
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
                        icon: FontAwesomeIcons.temperatureHalf,
                        label: l10n.feelsLike,
                        value: '${weather.feelsLike.toStringAsFixed(0)}°',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      _buildWeatherMiniInfo(
                        icon: FontAwesomeIcons.droplet,
                        label: l10n.humidity,
                        value: '${weather.humidity}%',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      _buildWeatherMiniInfo(
                        icon: FontAwesomeIcons.wind,
                        label: l10n.wind,
                        value: '${(weather.windSpeed * 3.6).toStringAsFixed(0)} km/h',
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
                      const Icon(FontAwesomeIcons.solidSun, color: Colors.orange, size: 20),
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
                      const Icon(FontAwesomeIcons.solidMoon, color: Color(0xFF5B6FD8), size: 20),
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
                    final dayName = isToday ? l10n.today : _formatDayName(day.date, l10n);

                    return Container(
                      width: 140,
                      margin: EdgeInsets.only(right: index < weather.forecast!.daily.length - 1 ? 16 : 0),
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
                                    : const Color(0xFFFF4458).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                dayName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isToday ? Colors.white : const Color(0xFFFF4458),
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
                              color: isToday ? Colors.white : Colors.orange.shade600,
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
                                        color: isToday ? Colors.white : Colors.grey.shade900,
                                        height: 1.0,
                                      ),
                                    ),
                                    Text(
                                      '°',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: isToday ? Colors.white.withValues(alpha: 0.9) : Colors.grey.shade700,
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
                                      FontAwesomeIcons.arrowDown,
                                      size: 12,
                                      color: isToday ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      day.tempMin.toStringAsFixed(0),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isToday ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      '°',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isToday ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade500,
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
        ),
      );
    });
  }

  // Neighborhoods 标签
  Widget _buildNeighborhoodsTab(CityDetailStateController controller) {
    return Obx(() {
      // 显示加载状态
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // TODO: City 实体暂时没有 neighborhoods/bestAreas，先显示空状态
      final neighborhoods = <dynamic>[];
      if (neighborhoods.isEmpty) {
        return const Center(child: Text('No neighborhoods available'));
      }

      return ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
        itemCount: neighborhoods.length,
        itemBuilder: (context, index) {
          final neighborhood = neighborhoods[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                          const Icon(FontAwesomeIcons.shieldHalved, size: 16, color: Color(0xFFFF4458)),
                          const SizedBox(width: 4),
                          Text('${AppLocalizations.of(context)!.safety}: ${neighborhood.safetyScore}'),
                          const SizedBox(width: 16),
                          const Icon(FontAwesomeIcons.dollarSign, size: 16, color: Color(0xFFFF4458)),
                          const SizedBox(width: 4),
                          Text('\$${neighborhood.rentPrice.toStringAsFixed(0)}/mo'),
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

  /// Coworking 标签页
  Widget _buildCoworkingTab(CoworkingStateController controller) {
    return Obx(() {
      // 显示加载状态
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // 显示空状态
      if (controller.coworkingSpaces.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.loadCoworkingSpacesByCity(cityName),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 120),
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
                                  color: const Color(0xFFFF4458).withValues(alpha: 0.1),
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
                                  color: const Color(0xFFFF4458).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // Main icon
                            Icon(
                              FontAwesomeIcons.building,
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
                                FontAwesomeIcons.plus,
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
            },
          ),
        );
      }

      // 显示共享办公空间列表
      return RefreshIndicator(
        onRefresh: () => controller.loadCoworkingSpacesByCity(cityName),
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
          itemCount: controller.coworkingSpaces.length,
          itemBuilder: (context, index) {
            final space = controller.coworkingSpaces[index];
            return _buildCoworkingSpaceCard(space);
          },
        ),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      space.spaceInfo.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(FontAwesomeIcons.building, size: 48),
                        );
                      },
                    ),
                  ),
                ),
                // Verification 徽章
                Positioned(
                  top: 12,
                  right: 12,
                  child: CoworkingVerificationBadge(
                    space: space,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
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
                  // 名称和评分
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
                              FontAwesomeIcons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              space.spaceInfo.rating.toStringAsFixed(1),
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
                      const Icon(FontAwesomeIcons.locationDot, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          space.location.address,
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
                        FontAwesomeIcons.wifi,
                        '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? '0'} Mbps',
                        Colors.blue,
                      ),
                      if (space.pricing.monthlyRate != null)
                        _buildCoworkingInfoChip(
                          FontAwesomeIcons.dollarSign,
                          '\$${space.pricing.monthlyRate!.toStringAsFixed(0)}/mo',
                          Colors.green,
                        ),
                      if (space.amenities.has24HourAccess)
                        _buildCoworkingInfoChip(
                          FontAwesomeIcons.clock,
                          '24/7',
                          Colors.orange,
                        ),
                      if (space.pricing.hasFreeTrial)
                        _buildCoworkingInfoChip(
                          FontAwesomeIcons.tag,
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
  Widget _buildHotelsTab(CityDetailStateController controller) {
    final parsedCityId = int.tryParse(cityId);
    print('🏨 Hotels Tab - cityId: $cityId, parsed: $parsedCityId, cityName: $cityName');

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

  // ========== 分享对话框方法 ==========

  /// 添加 Pros & Cons
  /// [initialTab] 初始显示的 tab (0=优点, 1=挑战)
  void _showAddProsConsPage({int initialTab = 0}) async {
    final result = await Get.to(() => ProsAndConsAddPage(
          cityId: cityId,
          cityName: cityName,
          initialTab: initialTab,
        ));

    // 如果有变更,刷新数据
    if (result == true) {
      final prosConsController = Get.find<ProsConsStateController>();
      // 重新加载优缺点数据
      await prosConsController.loadCityProsCons(cityId);
    }
  }

  Future<void> _handleProsConsVote(ProsCons item) async {
    final controller = Get.find<ProsConsStateController>();
    if (controller.hasUserVoted(item.id)) {
      AppToast.info('你已经为该条目投过票啦');
      return;
    }

    final success = await controller.upvote(item.id, item.isPro);
    if (success) {
      AppToast.success('感谢你的投票！');
    } else {
      final message = controller.error.value ?? '投票失败，请稍后再试';
      AppToast.error(message);
    }
  }

  /// 选择并上传图片
  Future<void> pickAndUploadImage(ImageSource source) async {
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
        final apiService = Get.find<IUserCityContentRepository>();
        final result = await apiService.addCityPhoto(
          cityId: cityId,
          imageUrl: 'https://via.placeholder.com/800x600.png?text=${Uri.encodeComponent(image.name)}',
          caption: null,
          location: null,
          takenAt: null,
        );

        switch (result) {
          case Success():
            // 刷新照片列表
            final userContentController = Get.find<UserCityContentStateController>();
            await userContentController.loadCityPhotos(cityId);

            AppToast.success(
              'Photo uploaded successfully!',
              title: 'Success',
            );
          case Failure(:final exception):
            AppToast.error(
              'Failed to upload photo: ${exception.message}',
              title: 'Error',
            );
        }
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
                  FontAwesomeIcons.locationDot,
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
            buildScoreDimension(
              icon: FontAwesomeIcons.champagneGlasses,
              label: '娱乐',
              score: area.entertainmentScore,
              description: area.entertainmentDescription,
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            buildScoreDimension(
              icon: FontAwesomeIcons.cameraRetro,
              label: '旅游',
              score: area.tourismScore,
              description: area.tourismDescription,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            buildScoreDimension(
              icon: FontAwesomeIcons.dollarSign,
              label: '经济',
              score: area.economyScore,
              description: area.economyDescription,
              color: Colors.green,
              isReversed: true, // 经济评分越低越好
            ),
            const SizedBox(height: 12),
            buildScoreDimension(
              icon: FontAwesomeIcons.palette,
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
  Widget buildScoreDimension({
    required IconData icon,
    required String label,
    required num score,
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
                isFilled ? FontAwesomeIcons.star : FontAwesomeIcons.star,
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

  /// 添加 Coworking Space
  void _showAddCoworkingPage() async {
    // 获取城市详情控制器，读取完整的城市信息
    final cityDetailController = Get.find<CityDetailStateController>();
    final city = cityDetailController.currentCity.value;

    print('🔍 [_showAddCoworkingPage] 城市数据检查:');
    print('   currentCity: ${city != null ? "已加载" : "null"}');
    print('   city.name: ${city?.name}');
    print('   city.country: ${city?.country}');
    print('   city.region: ${city?.region}');

    final result = await Get.to(() => AddCoworkingPage(
          cityName: cityName,
          cityId: cityId,
          countryName: city?.country, // 传递国家信息
        ));

    // 无论是否成功，返回时都重新加载数据
    final coworkingController = Get.find<CoworkingStateController>();
    coworkingController.loadCoworkingSpacesByCity(cityId);
    print('🔄 [AddCoworking] 返回页面，重新加载 coworking 数据');

    if (result != null && result == true) {
      AppToast.success(
        'Your coworking space will be reviewed and added soon!',
        title: 'Success',
      );
    }
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

  String _formatUploaderId(String userId) {
    if (userId.length <= 8) {
      return userId;
    }
    return '${userId.substring(0, 4)}...${userId.substring(userId.length - 4)}';
  }

  String _resolveUploaderName(
    UserCityContentStateController controller,
    String uploaderId,
  ) {
    final cachedName = controller.photoUploaderNames[uploaderId];
    if (cachedName != null && cachedName.trim().isNotEmpty) {
      return cachedName.trim();
    }
    return _formatUploaderId(uploaderId);
  }

  /// 添加 Coworking Space
  void showAddCoworkingPage() async {
    // 获取城市详情控制器，读取完整的城市信息
    final cityDetailController = Get.find<CityDetailStateController>();
    final city = cityDetailController.currentCity.value;

    print('🔍 [showAddCoworkingPage] 城市数据检查:');
    print('   currentCity: ${city != null ? "已加载" : "null"}');
    print('   city.name: ${city?.name}');
    print('   city.country: ${city?.country}');
    print('   city.region: ${city?.region}');

    final result = await Get.to(() => AddCoworkingPage(
          cityName: cityName,
          cityId: cityId,
          countryName: city?.country, // 传递国家信息
        ));
    if (result != null) {
      AppToast.success(
        'Your coworking space will be reviewed and added soon!',
        title: 'Success',
      );
    }
  }

  /// 分享社区信息
  void _shareCityInfo() {
    final cityDetailController = Get.find<CityDetailStateController>();
    final city = cityDetailController.currentCity.value;
    if (city == null) return;

    // 构建分享内容
    final String title = '${city.name} - 数字游民城市指南';
    final String description = '探索${city.name}的最佳Coworking空间、生活成本、气候信息和数字游民社区。';

    // 构建分享链接（可以根据实际情况调整）
    final String shareUrl = 'https://nomadcities.app/cities/${city.id}';

    // 显示分享底部抽屉
    ShareBottomSheet.show(
      context,
      title: title,
      description: description,
      imageUrl: city.imageUrl,
      shareUrl: shareUrl,
    );
  }
}

class _PhotoGroup {
  _PhotoGroup({required this.title, required this.uploaderId})
      : photos = [],
        latestUpload = DateTime.fromMillisecondsSinceEpoch(0);

  final String title;
  final String uploaderId;
  final List<UserCityPhoto> photos;
  DateTime latestUpload;
}

// SliverAppBarDelegate for pinned tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
