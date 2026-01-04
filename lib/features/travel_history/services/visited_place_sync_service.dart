import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../core/core.dart';
import '../../../services/token_storage_service.dart';
import '../data/dao/travel_history_dao.dart';
import '../data/models/visited_place_api_dto.dart';
import '../data/repositories/visited_place_api_repository.dart';
import '../domain/entities/visited_place.dart';

/// 访问地点同步服务
/// 负责在本地 SQLite 和后端服务之间同步访问地点数据
class VisitedPlaceSyncService {
  final TravelHistoryDao _dao;
  final VisitedPlaceApiRepository _apiRepository;

  /// 是否正在同步
  final RxBool isSyncing = false.obs;

  /// UUID 生成器
  static const _uuid = Uuid();

  VisitedPlaceSyncService({
    required TravelHistoryDao dao,
    required VisitedPlaceApiRepository apiRepository,
  })  : _dao = dao,
        _apiRepository = apiRepository;

  /// 工厂方法创建实例
  static VisitedPlaceSyncService create({required TravelHistoryDao dao}) {
    final dio = Get.find<Dio>();
    final tokenService = Get.find<TokenStorageService>();

    final apiRepository = VisitedPlaceApiRepository(
      dio: dio,
      tokenService: tokenService,
    );

    return VisitedPlaceSyncService(
      dao: dao,
      apiRepository: apiRepository,
    );
  }

  /// 生成唯一的 client_id
  static String generateClientId() {
    return _uuid.v4();
  }

  /// 同步未上传的访问地点到后端
  Future<void> syncUnsyncedToBackend() async {
    if (isSyncing.value) return;

    // 检查是否有有效的 token
    final tokenService = Get.find<TokenStorageService>();
    final token = await tokenService.getAccessToken();

    if (token == null || token.isEmpty) {
      log('⚠️ 用户未登录，跳过同步访问地点到后端');
      return;
    }

    isSyncing.value = true;

    try {
      // 获取本地未同步的访问地点
      final unsyncedPlaces = await _dao.getUnsyncedVisitedPlaces();

      if (unsyncedPlaces.isEmpty) {
        log('✅ 没有需要同步的访问地点');
        return;
      }

      log('📤 正在同步 ${unsyncedPlaces.length} 个访问地点到后端...');

      // 按旅行 ID 分组
      final groupedPlaces = <String, List<VisitedPlace>>{};
      for (final place in unsyncedPlaces) {
        groupedPlaces.putIfAbsent(place.tripId, () => []).add(place);
      }

      // 逐个旅行批量上传
      for (final entry in groupedPlaces.entries) {
        final travelHistoryId = entry.key;
        final places = entry.value;

        final request = BatchCreateVisitedPlaceRequest(
          travelHistoryId: travelHistoryId,
          items: places
              .map((place) => CreateVisitedPlaceRequest(
                    travelHistoryId: travelHistoryId,
                    latitude: place.latitude,
                    longitude: place.longitude,
                    placeName: place.placeName,
                    placeType: place.placeType,
                    address: place.address,
                    arrivalTime: place.arrivalTime,
                    departureTime: place.departureTime,
                    photoUrl: place.photoUrl,
                    notes: place.notes,
                    isHighlight: place.isHighlight,
                    clientId: place.toMap()['client_id'] as String?,
                  ))
              .toList(),
        );

        final result = await _apiRepository.createBatch(request);

        switch (result) {
          case Success(data: final createdPlaces):
            log('✅ 成功同步 ${createdPlaces.length} 个访问地点 (旅行: $travelHistoryId)');

            // 更新本地记录的同步状态
            for (final place in places) {
              if (place.id != null) {
                // 查找对应的后端记录
                final backendPlace = createdPlaces.firstWhereOrNull(
                  (p) => p.clientId == place.toMap()['client_id'],
                );
                await _dao.markVisitedPlaceAsSynced(
                  place.id!,
                  backendId: backendPlace?.id,
                );
              }
            }
          case Failure(exception: final exception):
            log('❌ 同步访问地点失败 (旅行: $travelHistoryId): ${exception.message}');
        }
      }
    } catch (e) {
      log('❌ 同步访问地点异常: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  /// 从后端拉取旅行的访问地点
  Future<List<VisitedPlace>> fetchFromBackend(String travelHistoryId) async {
    try {
      // 检查是否有有效的 token
      final tokenService = Get.find<TokenStorageService>();
      final token = await tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        log('⚠️ 用户未登录，跳过从后端获取访问地点');
        return <VisitedPlace>[];
      }

      log('📥 正在从后端获取访问地点 (旅行: $travelHistoryId)...');

      final result = await _apiRepository.getByTravelHistoryId(travelHistoryId);

      return switch (result) {
        Success(data: final apiPlaces) => () {
            log('✅ 从后端获取到 ${apiPlaces.length} 个访问地点');
            return apiPlaces.map(_apiDtoToLocal).toList();
          }(),
        Failure(exception: final exception) => () {
            log('❌ 从后端获取访问地点失败: ${exception.message}');
            return <VisitedPlace>[];
          }(),
      };
    } catch (e, stackTrace) {
      log('❌ 从后端获取访问地点异常: $e');
      log('📍 堆栈: $stackTrace');
      return [];
    }
  }

  /// 获取旅行的访问地点（优先使用本地缓存）
  Future<List<VisitedPlace>> getVisitedPlaces(String travelHistoryId) async {
    // 先从本地获取
    var localPlaces = await _dao.getVisitedPlacesByTripId(travelHistoryId);

    // 如果本地没有数据，从后端获取
    if (localPlaces.isEmpty) {
      final backendPlaces = await fetchFromBackend(travelHistoryId);
      if (backendPlaces.isNotEmpty) {
        // 保存到本地
        await _dao.saveVisitedPlaces(backendPlaces);
        localPlaces = backendPlaces;
      }
    }

    return localPlaces;
  }

  /// 添加访问地点（本地保存并准备同步）
  Future<VisitedPlace> addVisitedPlace(VisitedPlace place) async {
    // 检查是否已存在相似的地点
    final exists = await _dao.existsSimilarVisitedPlace(
      tripId: place.tripId,
      latitude: place.latitude,
      longitude: place.longitude,
      arrivalTime: place.arrivalTime,
    );

    if (exists) {
      log('⚠️ 已存在相似的访问地点，跳过添加');
      final existing = await _dao.getVisitedPlacesByTripId(place.tripId);
      return existing.firstWhere(
        (p) =>
            (p.latitude - place.latitude).abs() < 0.001 &&
            (p.longitude - place.longitude).abs() < 0.001,
        orElse: () => place,
      );
    }

    // 生成 client_id
    final placeMap = place.toMap();
    if (placeMap['client_id'] == null) {
      placeMap['client_id'] = generateClientId();
    }

    // 保存到本地
    final id = await _dao.saveVisitedPlace(VisitedPlace.fromMap(placeMap));

    log('✅ 添加访问地点成功 - id: $id, placeName: ${place.placeName}');

    return place.copyWith(id: id);
  }

  /// 批量添加访问地点
  Future<void> addVisitedPlaces(List<VisitedPlace> places) async {
    final placesToAdd = <VisitedPlace>[];

    for (final place in places) {
      // 检查是否已存在相似的地点
      final exists = await _dao.existsSimilarVisitedPlace(
        tripId: place.tripId,
        latitude: place.latitude,
        longitude: place.longitude,
        arrivalTime: place.arrivalTime,
      );

      if (!exists) {
        // 生成 client_id
        final placeMap = place.toMap();
        if (placeMap['client_id'] == null) {
          placeMap['client_id'] = generateClientId();
        }
        placesToAdd.add(VisitedPlace.fromMap(placeMap));
      }
    }

    if (placesToAdd.isNotEmpty) {
      await _dao.saveVisitedPlaces(placesToAdd);
      log('✅ 批量添加 ${placesToAdd.length} 个访问地点成功');
    }
  }

  /// 将 API DTO 转换为本地实体
  VisitedPlace _apiDtoToLocal(VisitedPlaceApiDto dto) {
    return VisitedPlace(
      tripId: dto.travelHistoryId,
      latitude: dto.latitude,
      longitude: dto.longitude,
      placeName: dto.placeName,
      placeType: dto.placeType,
      address: dto.address,
      arrivalTime: dto.arrivalTime,
      departureTime: dto.departureTime,
      photoUrl: dto.photoUrl,
      notes: dto.notes,
      isHighlight: dto.isHighlight,
    );
  }
}
