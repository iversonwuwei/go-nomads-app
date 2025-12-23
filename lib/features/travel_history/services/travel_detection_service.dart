import 'dart:async';
import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../domain/entities/entities.dart';
import '../data/dao/travel_history_dao.dart';

/// 旅行检测服务
/// 负责：
/// 1. 后台低频位置采集
/// 2. 停留点聚类检测
/// 3. 旅行目的地判断
/// 4. 候选旅行管理
class TravelDetectionService extends GetxService {
  final TravelHistoryDao _dao;
  final TravelDetectionConfig _config;

  /// 后台定位定时器
  Timer? _locationTimer;

  /// 位置流订阅
  StreamSubscription<Position>? _positionSubscription;

  /// 是否启用旅行检测
  final RxBool isEnabled = false.obs;

  /// 是否正在运行
  final RxBool isRunning = false.obs;

  /// 常住地
  final Rx<HomeLocation?> homeLocation = Rx<HomeLocation?>(null);

  /// 待确认的候选旅行
  final RxList<CandidateTrip> pendingTrips = <CandidateTrip>[].obs;

  TravelDetectionService({
    TravelHistoryDao? dao,
    TravelDetectionConfig config = TravelDetectionConfig.defaultConfig,
  })  : _dao = dao ?? TravelHistoryDao(),
        _config = config;

  /// 初始化服务
  Future<TravelDetectionService> init() async {
    // 确保数据库表存在
    await _dao.ensureTables();

    // 加载常住地
    homeLocation.value = await _dao.getHomeLocation();

    // 加载待确认的旅行
    pendingTrips.value = await _dao.getPendingCandidateTrips();

    // 过期旧的候选旅行
    await _dao.expireOldCandidateTrips(
      expirationDays: _config.candidateTripExpirationDays,
    );

    // 注意：自动检测状态从后端 UserPreferences 加载
    // 在 profile_edit_page._loadUserPreferences() 中同步启动/停止服务

    log('✅ TravelDetectionService 初始化完成');
    return this;
  }

  /// 启动旅行检测
  Future<void> start() async {
    if (isRunning.value) return;

    // 检查位置权限
    final permission = await _checkLocationPermission();
    if (!permission) {
      log('⚠️ 位置权限不足，无法启动旅行检测');
      return;
    }

    isEnabled.value = true;
    isRunning.value = true;

    // 启动后台定位采集
    _startBackgroundLocationCollection();

    log('🚀 旅行检测服务已启动');
  }

  /// 停止旅行检测
  Future<void> stop() async {
    isEnabled.value = false;
    isRunning.value = false;

    _locationTimer?.cancel();
    _locationTimer = null;

    await _positionSubscription?.cancel();
    _positionSubscription = null;

    log('⏹️ 旅行检测服务已停止');
  }

  /// 检查位置权限
  Future<bool> _checkLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 对于后台定位，最好有 always 权限，但 whileInUse 也可以工作
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// 启动后台位置采集
  void _startBackgroundLocationCollection() {
    // 使用定时器定期获取位置（低功耗模式）
    _locationTimer = Timer.periodic(
      Duration(minutes: _config.locationIntervalMinutes),
      (_) => _collectLocation(),
    );

    // 立即获取一次位置
    _collectLocation();
  }

  /// 采集当前位置
  Future<void> _collectLocation() async {
    if (!isRunning.value) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium, // 使用中等精度以节省电量
          distanceFilter: 100, // 100米过滤
        ),
      );

      final point = LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: DateTime.now(),
      );

      await _dao.saveLocationPoint(point);
      log('📍 位置已记录: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}');

      // 触发停留点检测
      await _processLocationPoints();
    } catch (e) {
      log('⚠️ 获取位置失败: $e');
    }
  }

  /// 处理位置点，检测停留点
  Future<void> _processLocationPoints() async {
    // 获取未处理的位置点
    final unprocessedPoints = await _dao.getUnprocessedLocationPoints();
    if (unprocessedPoints.length < 2) return;

    // 检测停留点
    final stayPoints = StayPointFactory.detectStayPoints(unprocessedPoints);

    if (stayPoints.isNotEmpty) {
      log('🏠 检测到 ${stayPoints.length} 个停留点');

      // 保存停留点
      await _dao.saveStayPoints(stayPoints);

      // 标记位置点为已处理
      final processedIds = unprocessedPoints
          .where((p) => p.id != null)
          .map((p) => p.id as int)
          .toList();
      if (processedIds.isNotEmpty) {
        await _dao.markLocationPointsAsProcessed(processedIds);
      }

      // 分析停留点，判断是否为旅行
      await _analyzeStayPoints(stayPoints);
    }
  }

  /// 分析停留点，判断是否为旅行目的地
  Future<void> _analyzeStayPoints(List<StayPoint> stayPoints) async {
    final home = homeLocation.value;

    for (final stayPoint in stayPoints) {
      // 如果没有设置常住地，将第一个长时间停留点设为常住地
      if (home == null && stayPoint.isOvernightStay) {
        await _setHomeLocation(stayPoint);
        continue;
      }

      // 如果有常住地，检查是否为旅行目的地
      if (home != null) {
        final distanceKm = stayPoint.distanceToCoordinates(
          home.latitude,
          home.longitude,
        ) / 1000;

        log('📏 停留点距离常住地: ${distanceKm.toStringAsFixed(1)} km');

        // 判断是否满足旅行条件
        if (_isTravelDestination(stayPoint, distanceKm)) {
          await _createCandidateTrip(stayPoint, distanceKm);
        } else if (_shouldUpdateHome(stayPoint, distanceKm)) {
          // 如果在常住地附近频繁停留，可能需要更新常住地
          await _updateHomeConfidence(stayPoint);
        }
      }
    }
  }

  /// 判断是否为旅行目的地
  bool _isTravelDestination(StayPoint stayPoint, double distanceKm) {
    // 条件1: 距离常住地足够远
    if (distanceKm < _config.minTravelDistanceKm) return false;

    // 条件2: 停留时间足够长
    if (stayPoint.durationHours < _config.minStayHours) return false;

    // 条件3: 过夜（可选）
    if (_config.minOvernightStays > 0 && !stayPoint.isOvernightStay) {
      return false;
    }

    // 条件4: 检查是否在周末或节假日（可选增强）
    // final isWeekend = _isWeekend(stayPoint.arrivalTime);

    return true;
  }

  /// 判断是否应该更新常住地（在常住地附近频繁停留）
  bool _shouldUpdateHome(StayPoint stayPoint, double distanceKm) {
    return distanceKm < 5 && stayPoint.isOvernightStay;
  }

  /// 设置常住地
  Future<void> _setHomeLocation(StayPoint stayPoint) async {
    final home = HomeLocation(
      latitude: stayPoint.latitude,
      longitude: stayPoint.longitude,
      confidence: 50, // 初始置信度
    );

    await _dao.saveHomeLocation(home);
    homeLocation.value = home;

    log('🏠 已设置常住地: ${stayPoint.latitude.toStringAsFixed(4)}, ${stayPoint.longitude.toStringAsFixed(4)}');
  }

  /// 更新常住地置信度
  Future<void> _updateHomeConfidence(StayPoint stayPoint) async {
    final home = homeLocation.value;
    if (home == null || home.id == null) return;

    // 增加置信度（最高100）
    final newConfidence = (home.confidence + 5).clamp(0, 100);
    await _dao.updateHomeConfidence(home.id!, newConfidence);

    // 可选：如果新位置比当前常住地更可能是真正的常住地，更新位置
    // 这里简化处理，只更新置信度
    homeLocation.value = home.copyWith(confidence: newConfidence);
  }

  /// 创建候选旅行
  Future<void> _createCandidateTrip(
    StayPoint stayPoint,
    double distanceKm,
  ) async {
    // 检查是否已存在相似的候选旅行（避免重复）
    final existingTrips = await _dao.getPendingCandidateTrips();
    for (final trip in existingTrips) {
      final distance = stayPoint.distanceToCoordinates(
        trip.latitude,
        trip.longitude,
      );
      // 如果在 5km 内已有候选旅行，跳过
      if (distance < 5000) {
        log('ℹ️ 已存在相似的候选旅行，跳过');
        return;
      }
    }

    final candidateTrip = CandidateTrip.fromStayPoint(
      stayPoint,
      distanceFromHome: distanceKm,
    );

    final id = await _dao.saveCandidateTrip(candidateTrip);
    final savedTrip = candidateTrip.copyWith(id: id);

    pendingTrips.add(savedTrip);

    log('✈️ 发现新的旅行目的地！距离常住地 ${distanceKm.toStringAsFixed(0)} km');

    // TODO: 触发反向地理编码获取城市名称
    // TODO: 发送本地通知提醒用户确认
  }

  /// 确认旅行
  Future<void> confirmTrip(int tripId) async {
    await _dao.confirmTrip(tripId);

    // 更新本地列表
    final index = pendingTrips.indexWhere((t) => t.id == tripId);
    if (index >= 0) {
      pendingTrips.removeAt(index);
    }

    log('✅ 旅行已确认: ID=$tripId');
  }

  /// 忽略旅行
  Future<void> dismissTrip(int tripId) async {
    await _dao.dismissTrip(tripId);

    // 更新本地列表
    final index = pendingTrips.indexWhere((t) => t.id == tripId);
    if (index >= 0) {
      pendingTrips.removeAt(index);
    }

    log('❌ 旅行已忽略: ID=$tripId');
  }

  /// 手动刷新候选旅行列表
  Future<void> refreshPendingTrips() async {
    pendingTrips.value = await _dao.getPendingCandidateTrips();
  }

  /// 获取已确认的旅行历史
  Future<List<CandidateTrip>> getConfirmedTrips() async {
    return await _dao.getConfirmedTrips();
  }

  /// 手动设置常住地（用户主动设置）
  Future<void> setHomeLocationManually(double latitude, double longitude) async {
    final home = HomeLocation(
      latitude: latitude,
      longitude: longitude,
      confidence: 100, // 用户手动设置，置信度最高
    );

    await _dao.saveHomeLocation(home);
    homeLocation.value = home;

    log('🏠 用户手动设置常住地: $latitude, $longitude');
  }

  /// 获取统计信息
  Future<Map<String, dynamic>> getStatistics() async {
    return {
      'locationPointCount': await _dao.getLocationPointCount(),
      'stayPointCount': await _dao.getStayPointCount(),
      'tripCounts': await _dao.getCandidateTripCounts(),
      'hasHomeLocation': homeLocation.value != null,
      'pendingTripsCount': pendingTrips.length,
    };
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    await _dao.clearAllData();
    homeLocation.value = null;
    pendingTrips.clear();
    log('🗑️ 所有旅行检测数据已清除');
  }

  @override
  void onClose() {
    stop();
    super.onClose();
  }
}
