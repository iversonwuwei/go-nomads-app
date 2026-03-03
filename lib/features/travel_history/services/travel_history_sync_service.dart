import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../config/api_config.dart';
import '../../../core/core.dart';
import '../../../services/token_storage_service.dart';
import '../data/dao/travel_history_dao.dart';
import '../data/models/travel_history_api_dto.dart';
import '../data/repositories/travel_history_api_repository.dart';
import '../domain/entities/candidate_trip.dart';

/// 旅行历史同步服务
/// 负责在本地 SQLite 和后端服务之间同步旅行历史数据
class TravelHistorySyncService {
  final TravelHistoryDao _dao;
  final TravelHistoryApiRepository _apiRepository;

  /// 是否正在同步
  final RxBool isSyncing = false.obs;

  /// 上次同步时间
  DateTime? _lastSyncTime;

  TravelHistorySyncService({
    required TravelHistoryDao dao,
    required TravelHistoryApiRepository apiRepository,
  })  : _dao = dao,
        _apiRepository = apiRepository;

  /// 工厂方法创建实例
  static TravelHistorySyncService create({required TravelHistoryDao dao}) {
    final dio = Get.find<Dio>();
    final tokenService = Get.find<TokenStorageService>();

    final apiRepository = TravelHistoryApiRepository(
      dio: dio,
      tokenService: tokenService,
    );

    return TravelHistorySyncService(
      dao: dao,
      apiRepository: apiRepository,
    );
  }

  /// 同步已确认的旅行到后端
  Future<void> syncConfirmedTripsToBackend() async {
    if (isSyncing.value) return;
    
    // 检查是否有有效的 token
    final tokenService = Get.find<TokenStorageService>();
    final token = await tokenService.getAccessToken();
    
    if (token == null || token.isEmpty) {
      log('⚠️ 用户未登录，跳过同步旅行历史到后端');
      return;
    }
    
    isSyncing.value = true;

    try {
      // 获取本地已确认但未同步的旅行
      final localConfirmedTrips = await _dao.getConfirmedTrips();
      final unsyncedTrips = localConfirmedTrips.where((t) => !t.isSyncedToBackend).toList();

      if (unsyncedTrips.isEmpty) {
        log('✅ 没有需要同步的旅行历史');
        return;
      }

      log('📤 正在同步 ${unsyncedTrips.length} 条旅行历史到后端...');

      // 批量创建到后端
      final request = BatchCreateTravelHistoryRequest(
        items: unsyncedTrips.map((trip) {
          return CreateTravelHistoryRequest(
            city: trip.cityName ?? '未知城市',
            country: trip.countryName ?? '未知国家',
            countryCode: trip.countryCode,
            latitude: trip.latitude,
            longitude: trip.longitude,
            arrivalTime: trip.arrivalTime,
            departureTime: trip.departureTime,
            isConfirmed: true,
            cityId: trip.cityId,
          );
        }).toList(),
      );

      final result = await _apiRepository.createBatchTravelHistory(request);

      switch (result) {
        case Success(data: final createdTrips):
          log('✅ 成功同步 ${createdTrips.length} 条旅行历史到后端');

          // 更新本地记录的同步状态
          for (final trip in unsyncedTrips) {
            if (trip.id != null) {
              await _dao.markAsSynced(trip.id!);
            }
          }

          _lastSyncTime = DateTime.now();
        case Failure(exception: final exception):
          log('❌ 同步旅行历史失败: ${exception.message}');
      }
    } catch (e) {
      log('❌ 同步旅行历史异常: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  /// 从后端拉取旅行历史
  Future<List<CandidateTrip>> fetchFromBackend() async {
    try {
      // 检查是否有有效的 token
      final tokenService = Get.find<TokenStorageService>();
      final token = await tokenService.getAccessToken();
      
      if (token == null || token.isEmpty) {
        log('⚠️ 用户未登录，跳过从后端获取旅行历史');
        return <CandidateTrip>[];
      }
      
      log('📥 正在从后端获取旅行历史...');
      log('🔗 API URL: ${ApiConfig.currentApiBaseUrl}${ApiConfig.travelHistoryConfirmedEndpoint}');

      final result = await _apiRepository.getConfirmedTravelHistory();

      return switch (result) {
        Success(data: final apiTrips) => () {
            log('✅ 从后端获取到 ${apiTrips.length} 条旅行历史');
            if (apiTrips.isNotEmpty) {
              log('📋 第一条数据: ${apiTrips.first.city}, ${apiTrips.first.country}');
            }
            return apiTrips.map(_apiDtoToLocalTrip).toList();
          }(),
        Failure(exception: final exception) => () {
            log('❌ 从后端获取旅行历史失败: ${exception.message}');
            log('📍 错误代码: ${exception.code}');
            return <CandidateTrip>[];
          }(),
      };
    } catch (e, stackTrace) {
      log('❌ 从后端获取旅行历史异常: $e');
      log('📍 堆栈: $stackTrace');
      return [];
    }
  }

  /// 完整同步（双向）
  Future<void> fullSync() async {
    if (isSyncing.value) return;
    isSyncing.value = true;

    try {
      log('🔄 开始完整同步旅行历史...');

      // 1. 先从后端获取最新数据
      final backendTrips = await fetchFromBackend();
      log('📥 从后端获取到 ${backendTrips.length} 条旅行历史');

      // 2. 获取本地已确认的旅行
      final localTrips = await _dao.getConfirmedTrips();
      log('📂 本地已有 ${localTrips.length} 条已确认旅行历史');

      // 3. 合并数据（以后端为准，补充本地未同步的）
      final mergedTrips = _mergeTrips(localTrips, backendTrips);
      log('🔀 合并后共 ${mergedTrips.length} 条旅行历史');

      // 4. 将合并后的数据保存到本地
      int insertedCount = 0;
      int updatedCount = 0;
      for (final trip in mergedTrips) {
        if (trip.id != null) {
          // 更新现有记录
          await _dao.updateCandidateTrip(trip);
          updatedCount++;
        } else {
          // 检查是否已存在相似记录，避免重复插入
          final exists = await _dao.existsSimilarTrip(trip);
          if (!exists) {
            // 插入新记录
            await _dao.insertCandidateTrip(trip);
            insertedCount++;
            log('➕ 插入新旅行: ${trip.cityName}, ${trip.countryName}');
          } else {
            log('⏭️ 跳过重复旅行: ${trip.cityName}, ${trip.countryName}');
          }
        }
      }
      log('📊 同步结果: 插入 $insertedCount 条, 更新 $updatedCount 条');

      // 5. 上传本地未同步的数据到后端
      await syncConfirmedTripsToBackend();

      _lastSyncTime = DateTime.now();
      log('✅ 完整同步完成');
    } catch (e, stackTrace) {
      log('❌ 完整同步失败: $e');
      log('📍 堆栈: $stackTrace');
    } finally {
      isSyncing.value = false;
    }
  }

  /// 确认旅行并同步到后端
  Future<bool> confirmAndSync(CandidateTrip trip) async {
    try {
      // 1. 本地确认
      if (trip.id != null) {
        await _dao.confirmTrip(trip.id!);
      }

      // 2. 同步到后端
      final request = CreateTravelHistoryRequest(
        city: trip.cityName ?? '未知城市',
        country: trip.countryName ?? '未知国家',
        countryCode: trip.countryCode,
        latitude: trip.latitude,
        longitude: trip.longitude,
        arrivalTime: trip.arrivalTime,
        departureTime: trip.departureTime,
        isConfirmed: true,
        cityId: trip.cityId,
      );

      final result = await _apiRepository.createTravelHistory(request);

      return switch (result) {
        Success(data: final created) => () async {
            log('✅ 旅行历史已同步到后端: ${created.id}');
            if (trip.id != null) {
              await _dao.markAsSynced(trip.id!);
            }
            return true;
          }(),
        Failure(exception: final exception) => () {
            log('⚠️ 同步到后端失败，稍后重试: ${exception.message}');
            return false;
          }(),
      };
    } catch (e) {
      log('❌ 确认并同步旅行失败: $e');
      return false;
    }
  }

  /// 合并本地和后端的旅行数据
  List<CandidateTrip> _mergeTrips(
    List<CandidateTrip> localTrips,
    List<CandidateTrip> backendTrips,
  ) {
    final merged = <CandidateTrip>[];
    final processedIds = <String>{};

    // 先添加后端数据
    for (final backendTrip in backendTrips) {
      merged.add(backendTrip);
      if (backendTrip.backendId != null) {
        processedIds.add(backendTrip.backendId!);
      }
    }

    // 添加本地未同步的数据
    for (final localTrip in localTrips) {
      // 检查是否已经在后端数据中
      final isDuplicate = merged.any((t) => _isSameTrip(t, localTrip));
      if (!isDuplicate && !localTrip.isSyncedToBackend) {
        merged.add(localTrip);
      }
    }

    // 按到达时间排序
    merged.sort((a, b) => b.arrivalTime.compareTo(a.arrivalTime));

    return merged;
  }

  /// 判断两个旅行是否相同
  bool _isSameTrip(CandidateTrip a, CandidateTrip b) {
    // 如果城市和国家相同，且到达时间在24小时内，认为是同一次旅行
    if (a.cityName != b.cityName || a.countryName != b.countryName) {
      return false;
    }

    final timeDiff = a.arrivalTime.difference(b.arrivalTime).abs();
    return timeDiff.inHours < 24;
  }

  /// 将后端 DTO 转换为本地实体
  CandidateTrip _apiDtoToLocalTrip(TravelHistoryApiDto dto) {
    return CandidateTrip(
      id: null, // 本地 ID 需要在插入时生成
      userId: dto.userId, // 保存用户 ID，用于区分不同用户的数据
      backendId: dto.id,
      latitude: dto.latitude ?? 0.0,
      longitude: dto.longitude ?? 0.0,
      arrivalTime: dto.arrivalTime,
      departureTime: dto.departureTime ?? dto.arrivalTime, // 如果没有离开时间，使用到达时间
      cityName: dto.city,
      countryName: dto.country,
      cityId: dto.cityId, // 关联城市 ID，用于跳转到城市详情
      status: dto.isConfirmed ? CandidateTripStatus.confirmed : CandidateTripStatus.pending,
      isSyncedToBackend: true,
    );
  }

  /// 获取上次同步时间
  DateTime? get lastSyncTime => _lastSyncTime;
}
