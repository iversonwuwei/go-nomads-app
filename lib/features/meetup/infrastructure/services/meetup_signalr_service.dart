import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// Meetup SignalR 事件类型
class MeetupSignalREvents {
  static const String meetupCreated = 'MeetupCreated';
  static const String meetupUpdated = 'MeetupUpdated';
  static const String meetupDeleted = 'MeetupDeleted';
  static const String meetupCancelled = 'MeetupCancelled';
  static const String participantJoined = 'ParticipantJoined';
  static const String participantLeft = 'ParticipantLeft';
}

/// 参与者变更事件数据
class ParticipantChangeEvent {
  final String meetupId;
  final String userId;
  final int newParticipantCount;

  ParticipantChangeEvent({
    required this.meetupId,
    required this.userId,
    required this.newParticipantCount,
  });
}

/// Meetup SignalR 服务
/// 用于接收 Meetup 相关的实时更新推送
/// 支持单点更新：推送完整的 Meetup 数据，避免额外 API 调用
class MeetupSignalRService extends GetxService {
  HubConnection? _hubConnection;

  // 事件流控制器 - 推送完整的 Meetup JSON 数据
  final _meetupCreatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _meetupUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _meetupDeletedController = StreamController<String>.broadcast();
  final _meetupCancelledController = StreamController<Map<String, dynamic>>.broadcast();
  final _participantJoinedController = StreamController<ParticipantChangeEvent>.broadcast();
  final _participantLeftController = StreamController<ParticipantChangeEvent>.broadcast();

  // 公开的事件流 - 推送完整数据，支持单点更新
  Stream<Map<String, dynamic>> get onMeetupCreated => _meetupCreatedController.stream;
  Stream<Map<String, dynamic>> get onMeetupUpdated => _meetupUpdatedController.stream;
  Stream<String> get onMeetupDeleted => _meetupDeletedController.stream;
  Stream<Map<String, dynamic>> get onMeetupCancelled => _meetupCancelledController.stream;
  Stream<ParticipantChangeEvent> get onParticipantJoined => _participantJoinedController.stream;
  Stream<ParticipantChangeEvent> get onParticipantLeft => _participantLeftController.stream;

  /// 连接状态
  final isConnected = false.obs;

  /// 当前订阅的城市ID
  String? _subscribedCityId;

  // 重连控制
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  DateTime? _lastReconnectTime;

  @override
  void onInit() {
    super.onInit();
    log('🎬 MeetupSignalRService 初始化');
  }

  @override
  void onClose() {
    log('👋 MeetupSignalRService 关闭');
    dispose();
    super.onClose();
  }

  /// 连接到 Meetup Hub
  Future<void> connect() async {
    if (_hubConnection != null && isConnected.value) {
      log('📡 [MeetupSignalR] Already connected');
      return;
    }

    // 如果已经有连接但没有 connected，先停止旧连接
    if (_hubConnection != null) {
      log('🔄 [MeetupSignalR] 停止旧连接...');
      try {
        await _hubConnection?.stop();
      } catch (e) {
        log('⚠️ [MeetupSignalR] 停止旧连接时出错: $e');
      }
      _hubConnection = null;
    }

    try {
      // 获取认证 token
      final tokenService = TokenStorageService();
      final token = await tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        log('⚠️ [MeetupSignalR] No auth token, skipping connection');
        return;
      }

      // 使用 ApiConfig 中配置的 Hub URL
      final hubUrl = ApiConfig.meetupHubUrl;
      log('📡 [MeetupSignalR] Connecting to: $hubUrl');

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              skipNegotiation: false,
              transport: HttpTransportType.WebSockets,
              accessTokenFactory: () async => token,
              requestTimeout: 60000,
            ),
          )
          .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000])
          .build();

      // 设置超时
      _hubConnection!.serverTimeoutInMilliseconds = 60000;
      _hubConnection!.keepAliveIntervalInMilliseconds = 15000;

      // 注册事件处理器
      _registerEventHandlers();

      // 监听连接状态变化
      _hubConnection!.onclose(({error}) {
        log('📡 [MeetupSignalR] Connection closed: $error');
        isConnected.value = false;
      });

      _hubConnection!.onreconnecting(({error}) {
        _reconnectAttempts++;
        final now = DateTime.now();

        if (_lastReconnectTime != null &&
            now.difference(_lastReconnectTime!).inSeconds < 10 &&
            _reconnectAttempts > _maxReconnectAttempts) {
          log('⚠️ [MeetupSignalR] 重连次数过多，暂停重连');
          _hubConnection?.stop();
          return;
        }

        _lastReconnectTime = now;
        log('📡 [MeetupSignalR] Reconnecting (第 $_reconnectAttempts 次): $error');
        isConnected.value = false;
      });

      _hubConnection!.onreconnected(({connectionId}) {
        log('📡 [MeetupSignalR] Reconnected: $connectionId');
        isConnected.value = true;
        _reconnectAttempts = 0;
        // 重新订阅之前的城市
        if (_subscribedCityId != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (isConnected.value && _subscribedCityId != null) {
              subscribeToCityMeetups(_subscribedCityId!);
            }
          });
        }
      });

      await _hubConnection!.start();
      log('✅ [MeetupSignalR] Connected successfully');
      isConnected.value = true;
      _reconnectAttempts = 0;
    } catch (e) {
      log('❌ [MeetupSignalR] Connection failed: $e');
      isConnected.value = false;
    }
  }

  /// 注册事件处理器
  void _registerEventHandlers() {
    if (_hubConnection == null) return;

    // Meetup 创建事件 - 接收完整的 Meetup JSON 数据
    _hubConnection!.on(MeetupSignalREvents.meetupCreated, (arguments) {
      log('📨 [MeetupSignalR] Raw MeetupCreated: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final meetupData = arguments.first;
        if (meetupData is Map<String, dynamic>) {
          log('📨 [MeetupSignalR] Meetup created with full data: ${meetupData['id']}');
          _meetupCreatedController.add(meetupData);
        } else {
          log('⚠️ [MeetupSignalR] MeetupCreated data is not a Map: $meetupData');
        }
      }
    });

    // Meetup 更新事件 - 接收完整的 Meetup JSON 数据
    _hubConnection!.on(MeetupSignalREvents.meetupUpdated, (arguments) {
      log('📨 [MeetupSignalR] Raw MeetupUpdated: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final meetupData = arguments.first;
        if (meetupData is Map<String, dynamic>) {
          log('📨 [MeetupSignalR] Meetup updated with full data: ${meetupData['id']}');
          _meetupUpdatedController.add(meetupData);
        } else {
          log('⚠️ [MeetupSignalR] MeetupUpdated data is not a Map: $meetupData');
        }
      }
    });

    // Meetup 删除事件 - 只需要 meetupId
    _hubConnection!.on(MeetupSignalREvents.meetupDeleted, (arguments) {
      final meetupId = arguments?.firstOrNull?.toString() ?? '';
      log('📨 [MeetupSignalR] Meetup deleted: $meetupId');
      _meetupDeletedController.add(meetupId);
    });

    // Meetup 取消事件 - 接收完整的 Meetup JSON 数据
    _hubConnection!.on(MeetupSignalREvents.meetupCancelled, (arguments) {
      log('📨 [MeetupSignalR] Raw MeetupCancelled: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final meetupData = arguments.first;
        if (meetupData is Map<String, dynamic>) {
          log('📨 [MeetupSignalR] Meetup cancelled with full data: ${meetupData['id']}');
          _meetupCancelledController.add(meetupData);
        } else {
          log('⚠️ [MeetupSignalR] MeetupCancelled data is not a Map: $meetupData');
        }
      }
    });

    // 参与者加入事件 - 接收 meetupId, userId, newParticipantCount
    _hubConnection!.on(MeetupSignalREvents.participantJoined, (arguments) {
      log('📨 [MeetupSignalR] Raw ParticipantJoined: $arguments');
      if (arguments != null && arguments.length >= 3) {
        final event = ParticipantChangeEvent(
          meetupId: arguments[0]?.toString() ?? '',
          userId: arguments[1]?.toString() ?? '',
          newParticipantCount: int.tryParse(arguments[2]?.toString() ?? '0') ?? 0,
        );
        log('📨 [MeetupSignalR] Participant joined: meetup=${event.meetupId}, user=${event.userId}, count=${event.newParticipantCount}');
        _participantJoinedController.add(event);
      }
    });

    // 参与者离开事件 - 接收 meetupId, userId, newParticipantCount
    _hubConnection!.on(MeetupSignalREvents.participantLeft, (arguments) {
      log('📨 [MeetupSignalR] Raw ParticipantLeft: $arguments');
      if (arguments != null && arguments.length >= 3) {
        final event = ParticipantChangeEvent(
          meetupId: arguments[0]?.toString() ?? '',
          userId: arguments[1]?.toString() ?? '',
          newParticipantCount: int.tryParse(arguments[2]?.toString() ?? '0') ?? 0,
        );
        log('📨 [MeetupSignalR] Participant left: meetup=${event.meetupId}, user=${event.userId}, count=${event.newParticipantCount}');
        _participantLeftController.add(event);
      }
    });
  }

  /// 订阅特定城市的 Meetup 更新
  Future<void> subscribeToCityMeetups(String cityId) async {
    if (!isConnected.value) {
      log('⚠️ [MeetupSignalR] Not connected, cannot subscribe to city');
      return;
    }
    try {
      // 先取消之前的订阅
      if (_subscribedCityId != null && _subscribedCityId != cityId) {
        await unsubscribeFromCityMeetups(_subscribedCityId!);
      }

      await _hubConnection!.invoke('SubscribeToCityMeetups', args: [cityId]);
      _subscribedCityId = cityId;
      log('✅ [MeetupSignalR] Subscribed to city: $cityId');
    } catch (e) {
      log('❌ [MeetupSignalR] Subscribe to city failed: $e');
    }
  }

  /// 取消订阅特定城市的 Meetup 更新
  Future<void> unsubscribeFromCityMeetups(String cityId) async {
    if (!isConnected.value) return;
    try {
      await _hubConnection!.invoke('UnsubscribeFromCityMeetups', args: [cityId]);
      if (_subscribedCityId == cityId) {
        _subscribedCityId = null;
      }
      log('✅ [MeetupSignalR] Unsubscribed from city: $cityId');
    } catch (e) {
      log('❌ [MeetupSignalR] Unsubscribe from city failed: $e');
    }
  }

  /// 订阅特定 Meetup 的更新（用于详情页）
  Future<void> subscribeToMeetup(String meetupId) async {
    if (!isConnected.value) {
      log('⚠️ [MeetupSignalR] Not connected, cannot subscribe to meetup');
      return;
    }
    try {
      await _hubConnection!.invoke('SubscribeToMeetup', args: [meetupId]);
      log('✅ [MeetupSignalR] Subscribed to meetup: $meetupId');
    } catch (e) {
      log('❌ [MeetupSignalR] Subscribe to meetup failed: $e');
    }
  }

  /// 取消订阅特定 Meetup 的更新
  Future<void> unsubscribeFromMeetup(String meetupId) async {
    if (!isConnected.value) return;
    try {
      await _hubConnection!.invoke('UnsubscribeFromMeetup', args: [meetupId]);
      log('✅ [MeetupSignalR] Unsubscribed from meetup: $meetupId');
    } catch (e) {
      log('❌ [MeetupSignalR] Unsubscribe from meetup failed: $e');
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        await _hubConnection!.stop();
      } catch (e) {
        log('⚠️ [MeetupSignalR] Error stopping connection: $e');
      }
      _hubConnection = null;
      _subscribedCityId = null;
      isConnected.value = false;
      log('📡 [MeetupSignalR] Disconnected');
    }
  }

  /// 释放资源
  void dispose() {
    disconnect();
    _meetupCreatedController.close();
    _meetupUpdatedController.close();
    _meetupDeletedController.close();
    _meetupCancelledController.close();
    _participantJoinedController.close();
    _participantLeftController.close();
  }
}

