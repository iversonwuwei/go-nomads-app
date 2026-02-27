import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/core/core.dart';
import 'package:go_nomads_app/features/ai/domain/repositories/iai_repository.dart';
import 'package:go_nomads_app/features/async_task/domain/entities/async_task.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/digital_nomad_guide.dart';
import 'package:go_nomads_app/features/city/infrastructure/models/city_detail_dto.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart' as entity;
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:go_nomads_app/features/travel_plan/infrastructure/models/travel_plan_dto.dart';
import 'package:go_nomads_app/services/database/digital_nomad_guide_dao.dart';
import 'package:go_nomads_app/services/database_service.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/services/signalr_service.dart';

/// AI服务Repository实现
///
/// 使用HttpService调用后端AI API
class AiRepository implements IAiRepository {
  final HttpService _httpService = Get.find();

  @override
  Future<Result<entity.TravelPlan>> generateTravelPlan({
    required String cityId,
    required String cityName,
    required String cityImage,
    required int duration,
    required String budget,
    required String travelStyle,
    required List<String> interests,
    String? departureLocation,
    double? customBudget,
    String? currency,
    List<String>? selectedAttractions,
  }) async {
    try {
      log('🤖 正在生成AI旅行计划...');
      log('   城市: $cityName, 天数: $duration');

      // 处理自定义预算格式
      String finalBudget = budget;
      String? finalCurrency = currency;
      double? finalCustomBudget = customBudget;

      if (budget.contains(':')) {
        final parts = budget.split(':');
        if (parts.length == 2) {
          finalCurrency = parts[0];
          final amount = double.tryParse(parts[1]);
          if (amount != null) {
            finalCustomBudget = amount;
            finalBudget = amount < 3000 ? 'low' : (amount < 10000 ? 'medium' : 'high');
          }
        }
      }

      final response = await _httpService.post(
        '/ai/travel-plan',
        data: {
          'cityId': cityId,
          'cityName': cityName,
          'cityImage': cityImage,
          'duration': duration,
          'budget': finalBudget,
          'travelStyle': travelStyle,
          'interests': interests,
          if (departureLocation != null) 'departureLocation': departureLocation,
          if (finalCustomBudget != null) 'customBudget': finalCustomBudget.toString(),
          if (finalCurrency != null) 'currency': finalCurrency,
          if (selectedAttractions != null) 'selectedAttractions': selectedAttractions,
        },
      );

      // 使用响应数据 (TODO: 实现完整的转换逻辑)
      log('✅ API响应: ${response.statusCode}');

      // TODO: 实现从响应到 entity.TravelPlan 的转换
      // 暂时返回错误，等待完整的 DTO 迁移
      return Result.failure(
        UnknownException('TravelPlan DTO conversion not yet implemented'),
      );
    } catch (e) {
      return Result.failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<void>> generateTravelPlanStream({
    required String cityId,
    required String cityName,
    required String cityImage,
    required int duration,
    required String budget,
    required String travelStyle,
    required List<String> interests,
    String? departureLocation,
    DateTime? departureDate,
    double? customBudget,
    String? currency,
    List<String>? selectedAttractions,
    required Function(String message, int progress) onProgress,
    required Function(entity.TravelPlan plan) onData,
    required Function(String error) onError,
  }) async {
    try {
      log('🤖 开始异步生成旅行计划...');
      log('   城市: $cityName (ID: $cityId)');
      log('   天数: $duration, 预算: $budget, 风格: $travelStyle');
      log('   API Base URL: ${ApiConfig.currentApiBaseUrl}');

      // 处理自定义预算格式
      String finalBudget = budget;
      String? finalCurrency = currency;
      double? finalCustomBudget = customBudget;

      if (budget.contains(':')) {
        final parts = budget.split(':');
        if (parts.length == 2) {
          finalCurrency = parts[0];
          final amount = double.tryParse(parts[1]);
          if (amount != null) {
            finalCustomBudget = amount;
            finalBudget = amount < 3000 ? 'low' : (amount < 10000 ? 'medium' : 'high');
          }
        }
      }

      // 1. 先设置 SignalR 连接和监听器
      final signalRService = SignalRService();

      // SignalR Hub 连接到 MessageService 的 ai-progress hub
      // 生产环境通过 Gateway 路由，开发环境也通过 Gateway 路由
      final messageServiceUrl = ApiConfig.messageServiceBaseUrl;
      log('🔌 连接到 MessageService SignalR Hub: $messageServiceUrl/hubs/ai-progress');

      // 使用 ensureConnected 替代直接 connect，带重试机制
      final connected = await signalRService.ensureConnected(maxRetries: 2);
      if (connected) {
        log('✅ SignalR 连接已建立');
      } else {
        log('⚠️ SignalR 连接失败，将依赖轮询回退');
      }

      // 等待连接稳定
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. 创建异步任务
      log('📤 发送请求到: ${ApiConfig.currentApiBaseUrl}/ai/travel-plan/async');

      final createResponse = await _httpService.post(
        '/ai/travel-plan/async',
        data: {
          'cityId': cityId,
          'cityName': cityName,
          'cityImage': cityImage,
          'duration': duration,
          'budget': finalBudget,
          'travelStyle': travelStyle,
          'interests': interests,
          if (departureLocation != null) 'departureLocation': departureLocation,
          if (departureDate != null) 'departureDate': departureDate.toIso8601String(),
          if (finalCustomBudget != null) 'customBudget': finalCustomBudget.toString(),
          if (finalCurrency != null) 'currency': finalCurrency,
          if (selectedAttractions != null) 'selectedAttractions': selectedAttractions,
        },
      );

      log('✅ API 响应成功！');
      log('   Response data: ${createResponse.data}');

      final taskId = createResponse.data['taskId'] as String;
      log('✅ 任务已创建: $taskId');

      // 3. 订阅任务通知
      await signalRService.subscribeToTask(taskId);
      log('📢 客户端订阅任务: $taskId');

      // 4. 监听任务事件
      final completer = Completer<void>();
      late StreamSubscription<AsyncTask> progressSub;
      late StreamSubscription<AsyncTask> completedSub;
      late StreamSubscription<AsyncTask> failedSub;
      Timer? pollingTimer;

      // 清理所有资源的辅助方法
      Future<void> cleanup() async {
        pollingTimer?.cancel();
        await progressSub.cancel();
        await completedSub.cancel();
        await failedSub.cancel();
        await signalRService.unsubscribeFromTask(taskId);
      }

      log('📡 开始监听 SignalR 事件流...');

      progressSub = signalRService.taskProgressStream.listen((task) {
        if (task.taskId == taskId) {
          final message = task.progress.message ?? '处理中...';
          final percent = task.progress.percentage;
          final status = task.progress.status;
          log('📊 旅行计划任务进度: $percent% - $message - status: $status');
          onProgress(message, percent);
        }
      });

      completedSub = signalRService.taskCompletedStream.listen((task) async {
        if (task.taskId == taskId) {
          log('✅ [SignalR] 旅行计划任务完成！');

          try {
            if (task.result?.rawData != null) {
              log('📦 解析旅行计划数据...');
              final rawData = task.result!.rawData!;
              final dto = TravelPlanDto.fromJson(rawData);
              final plan = dto.toDomain();
              onData(plan);
            } else {
              throw Exception('任务完成但没有返回旅行计划数据');
            }
          } catch (e, stackTrace) {
            log('❌ 处理旅行计划数据失败: $e');
            log('   StackTrace: $stackTrace');
            onError('处理旅行计划数据失败: ${e.toString()}');
          } finally {
            log('🧹 清理资源...');
            await cleanup();
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        }
      });

      failedSub = signalRService.taskFailedStream.listen((task) async {
        if (task.taskId == taskId) {
          log('❌ [SignalR] 旅行计划任务失败: ${task.error}');
          onError(task.error ?? '生成失败');

          log('🧹 清理资源（失败）...');
          await cleanup();
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

      // 5. 启动轮询回退机制（与 SignalR 并行，谁先到用谁）
      log('🔄 启动任务状态轮询回退...');
      int pollCount = 0;
      const maxPolls = 120; // 10分钟 / 5秒

      pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (completer.isCompleted) {
          timer.cancel();
          return;
        }

        pollCount++;
        if (pollCount > maxPolls) {
          timer.cancel();
          return;
        }

        final statusData = await _checkTaskStatus(taskId);
        if (statusData == null || completer.isCompleted) return;

        final status = statusData['status'] as String?;
        final progress = statusData['progress'] as int? ?? 0;
        final message = statusData['progressMessage'] as String? ?? '处理中...';

        // 报告进度
        if (status == 'processing') {
          onProgress(message, progress);
        }

        if (status == 'completed') {
          log('✅ [轮询] 旅行计划任务已完成！');
          timer.cancel();

          if (!completer.isCompleted) {
            try {
              final result = statusData['result'];
              if (result != null && result is Map<String, dynamic>) {
                final dto = TravelPlanDto.fromJson(result);
                final plan = dto.toDomain();
                onData(plan);
              } else {
                // result 为空，尝试通过 planId 获取
                final planId = statusData['planId'] as String?;
                if (planId != null) {
                  log('📥 通过 planId 获取旅行计划: $planId');
                  final planResult = await getTravelPlanDetail(planId);
                  planResult.fold(
                    onSuccess: (plan) => onData(plan),
                    onFailure: (e) => onError('获取旅行计划数据失败: ${e.toString()}'),
                  );
                } else {
                  onError('任务完成但无法获取旅行计划数据');
                }
              }
            } catch (e) {
              log('❌ [轮询] 处理旅行计划数据失败: $e');
              onError('处理旅行计划数据失败: ${e.toString()}');
            }
            await cleanup();
            completer.complete();
          }
        } else if (status == 'failed') {
          log('❌ [轮询] 旅行计划任务失败');
          timer.cancel();

          if (!completer.isCompleted) {
            onError(statusData['error'] as String? ?? '生成失败');
            await cleanup();
            completer.complete();
          }
        }
      });

      log('⏳ 等待旅行计划任务完成（最长 10 分钟）...');

      // 等待任务完成，最多 10 分钟
      await completer.future.timeout(
        const Duration(minutes: 10),
        onTimeout: () async {
          log('⏱️ 旅行计划任务超时！');
          onError('任务超时，请稍后重试');
          await cleanup();
        },
      );

      log('✅ generateTravelPlanStream 执行完成');
      return Result.success(null);
    } catch (e, stackTrace) {
      log('❌ 旅行计划异步任务失败: $e');
      log('   类型: ${e.runtimeType}');
      log('   StackTrace: $stackTrace');
      onError('异步任务失败: ${e.toString()}');
      return Result.failure(
        UnknownException('异步任务失败: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<entity.TravelPlan>> getTravelPlanById(String planId) async {
    try {
      // TODO: 需要实现从 legacy model 到 DTO 的转换
      // 暂时直接返回错误，等待 AI service 迁移到 DDD
      return Result.failure(
        UnknownException('Legacy model conversion not implemented'),
      );
    } catch (e) {
      return Result.failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<DigitalNomadGuide?>> getDigitalNomadGuideFromBackend(String cityId) async {
    try {
      log('🔍 正在从后端获取数字游民指南...');
      log('   城市ID: $cityId');
      log('   API: ${ApiConfig.currentApiBaseUrl}/cities/$cityId/guide');

      final response = await _httpService.get('/cities/$cityId/guide');

      if (response.statusCode == 200) {
        // HttpService 的拦截器会自动解包 API 响应，response.data 就是内层的 data 字段
        // 如果 data 为 null，表示该城市尚未生成指南，这是正常状态
        final guideData = response.data;

        if (guideData != null && guideData is Map<String, dynamic>) {
          final guide = DigitalNomadGuide.fromMap(guideData);
          log('✅ 成功获取指南数据');
          return Result.success(guide);
        } else {
          log('ℹ️ 后端没有该城市的指南数据');
          return Result.success(null);
        }
      }

      log('⚠️ 意外的响应状态: ${response.statusCode}');
      return Result.failure(UnknownException('Unexpected status: ${response.statusCode}'));
    } on DioException catch (e) {
      // 特殊处理 404 - 表示该城市尚未生成指南
      if (e.response?.statusCode == 404) {
        log('ℹ️ 该城市暂无指南数据（404）');
        return Result.success(null);
      }

      log('❌ 获取指南失败: $e');
      return Result.failure(UnknownException(e.toString()));
    } catch (e) {
      log('❌ 获取指南失败: $e');
      return Result.failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<void>> generateDigitalNomadGuideStream({
    required String cityId,
    required String cityName,
    required Function(AsyncTask task) onProgress,
    required Function(DigitalNomadGuide guide) onData,
    required Function(String error) onError,
  }) async {
    try {
      log('🤖 开始异步生成数字游民指南...');
      log('   城市: $cityName (ID: $cityId)');
      log('   API Base URL: ${ApiConfig.currentApiBaseUrl}');

      // 1. 先设置 SignalR 连接和监听器
      final signalRService = SignalRService();

      // SignalR Hub 连接到 MessageService 的 ai-progress hub
      // 生产环境通过 Gateway 路由，开发环境也通过 Gateway 路由
      final messageServiceUrl = ApiConfig.messageServiceBaseUrl;
      log('🔌 连接到 MessageService SignalR Hub: $messageServiceUrl/hubs/ai-progress');

      // 使用 ensureConnected 替代直接 connect，带重试机制
      final connected = await signalRService.ensureConnected(maxRetries: 2);
      if (connected) {
        log('✅ SignalR 连接已建立');
      } else {
        log('⚠️ SignalR 连接失败，将依赖轮询回退');
      }

      // 等待连接稳定
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. 创建异步任务
      log('📤 发送请求到: ${ApiConfig.currentApiBaseUrl}/ai/guide/async');

      final createResponse = await _httpService.post(
        '/ai/guide/async',
        data: {
          'cityId': cityId,
          'cityName': cityName,
        },
      );

      log('✅ API 响应成功！');
      log('   Response data: ${createResponse.data}');

      final taskId = createResponse.data['taskId'] as String;
      log('✅ 任务已创建: $taskId');

      // 3. 订阅任务通知
      await signalRService.subscribeToTask(taskId);
      log('📢 客户端订阅任务: $taskId');

      // 4. 监听任务事件
      final completer = Completer<void>();
      late StreamSubscription<AsyncTask> progressSub;
      late StreamSubscription<AsyncTask> completedSub;
      late StreamSubscription<AsyncTask> failedSub;
      Timer? pollingTimer;

      // 清理所有资源的辅助方法
      Future<void> cleanup() async {
        pollingTimer?.cancel();
        await progressSub.cancel();
        await completedSub.cancel();
        await failedSub.cancel();
        await signalRService.unsubscribeFromTask(taskId);
      }

      log('📡 开始监听 SignalR 事件流...');

      progressSub = signalRService.taskProgressStream.listen((task) {
        if (task.taskId == taskId) {
          final message = task.progress.message ?? '处理中...';
          final percent = task.progress.percentage;
          final status = task.progress.status;
          log('📊 任务进度: $percent% - $message - status: $status');
          onProgress(task);
        }
      });

      completedSub = signalRService.taskCompletedStream.listen((task) async {
        if (task.taskId == taskId) {
          log('✅ [SignalR] 指南任务完成！');

          try {
            if (task.result?.rawData != null) {
              log('📦 解析指南数据...');
              final rawData = task.result!.rawData!;
              final guide = DigitalNomadGuide.fromMap(rawData);
              await _saveGuideToDatabase(guide);
              onData(guide);
            } else {
              throw Exception('任务完成但没有返回指南数据');
            }
          } catch (e, stackTrace) {
            log('❌ 处理指南数据失败: $e');
            log('   StackTrace: $stackTrace');
            onError('处理指南数据失败: ${e.toString()}');
          } finally {
            log('🧹 清理资源...');
            await cleanup();
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        }
      });

      failedSub = signalRService.taskFailedStream.listen((task) async {
        if (task.taskId == taskId) {
          log('❌ [SignalR] 指南任务失败: ${task.error}');
          onError(task.error ?? '生成失败');

          log('🧹 清理资源（失败）...');
          await cleanup();
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

      // 5. 启动轮询回退机制（与 SignalR 并行，谁先到用谁）
      log('🔄 启动指南任务状态轮询回退...');
      int pollCount = 0;
      const maxPolls = 120; // 10分钟 / 5秒

      pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (completer.isCompleted) {
          timer.cancel();
          return;
        }

        pollCount++;
        if (pollCount > maxPolls) {
          timer.cancel();
          return;
        }

        final statusData = await _checkTaskStatus(taskId);
        if (statusData == null || completer.isCompleted) return;

        final status = statusData['status'] as String?;

        if (status == 'completed') {
          log('✅ [轮询] 指南任务已完成！');
          timer.cancel();

          if (!completer.isCompleted) {
            try {
              final result = statusData['result'];
              if (result != null && result is Map<String, dynamic>) {
                final guide = DigitalNomadGuide.fromMap(result);
                await _saveGuideToDatabase(guide);
                onData(guide);
              } else {
                // 通过后端 API 获取指南
                final guideResult = await getDigitalNomadGuideFromBackend(cityId);
                guideResult.fold(
                  onSuccess: (guide) {
                    if (guide != null) {
                      onData(guide);
                    } else {
                      onError('任务完成但无法获取指南数据');
                    }
                  },
                  onFailure: (e) => onError('获取指南数据失败: ${e.toString()}'),
                );
              }
            } catch (e) {
              log('❌ [轮询] 处理指南数据失败: $e');
              onError('处理指南数据失败: ${e.toString()}');
            }
            await cleanup();
            completer.complete();
          }
        } else if (status == 'failed') {
          log('❌ [轮询] 指南任务失败');
          timer.cancel();

          if (!completer.isCompleted) {
            onError(statusData['error'] as String? ?? '生成失败');
            await cleanup();
            completer.complete();
          }
        }
      });

      log('⏳ 等待指南任务完成（最长 10 分钟）...');

      // 等待任务完成，最多 10 分钟
      await completer.future.timeout(
        const Duration(minutes: 10),
        onTimeout: () async {
          log('⏱️ 指南任务超时！');
          onError('任务超时，请稍后重试');
          await cleanup();
        },
      );

      log('✅ generateDigitalNomadGuideStream 执行完成');
      return Result.success(null);
    } catch (e, stackTrace) {
      log('❌ 异步任务失败: $e');
      log('   类型: ${e.runtimeType}');
      log('   StackTrace: $stackTrace');
      onError('异步任务失败: ${e.toString()}');
      return Result.failure(
        UnknownException('异步任务失败: ${e.toString()}'),
      );
    }
  }

  /// 保存指南到数据库
  Future<void> _saveGuideToDatabase(DigitalNomadGuide guide) async {
    try {
      log('💾 保存指南到 SQLite...');
      final db = await DatabaseService().database;
      final dao = DigitalNomadGuideDao(db);
      final userId = _getCurrentUserId();
      await dao.saveGuide(guide, userId: userId);
      log('✅ 指南已保存到 SQLite (userId=$userId)');
    } catch (e) {
      log('⚠️ 保存指南到数据库失败: $e');
      // 不抛出异常，允许继续执行
    }
  }

  /// 获取当前登录用户ID
  String _getCurrentUserId() {
    try {
      final authController = Get.find<AuthStateController>();
      return authController.currentUser.value?.id ?? '00000000-0000-0000-0000-000000000001';
    } catch (e) {
      return '00000000-0000-0000-0000-000000000001';
    }
  }

  @override
  Future<Result<List<TravelPlanSummary>>> getUserTravelPlans({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      log('📋 获取用户旅行计划列表: page=$page, pageSize=$pageSize');

      final response = await _httpService.get(
        '/ai/travel-plans',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        // HttpService 会自动解包 API 响应，response.data 已经是内层的 data 字段
        final data = response.data;

        if (data != null && data is List) {
          final plans = data.map((json) => TravelPlanSummary.fromJson(json as Map<String, dynamic>)).toList();
          log('✅ 获取到 ${plans.length} 个旅行计划');
          return Result.success(plans);
        } else {
          // data 为 null 或不是列表，返回空列表
          log('ℹ️ 没有旅行计划数据');
          return Result.success([]);
        }
      }

      return Result.failure(
        ServerException('获取旅行计划列表失败'),
      );
    } on DioException catch (e) {
      log('❌ 获取旅行计划列表网络错误: ${e.message}');
      if (e.response?.statusCode == 401) {
        return Result.failure(
          UnauthorizedException('请先登录'),
        );
      }
      return Result.failure(
        NetworkException('网络连接失败: ${e.message}'),
      );
    } catch (e) {
      log('❌ 获取旅行计划列表失败: $e');
      return Result.failure(
        UnknownException('获取失败: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<entity.TravelPlan>> getTravelPlanDetail(String planId) async {
    try {
      log('📋 获取旅行计划详情: planId=$planId');

      final response = await _httpService.get(
        '/ai/travel-plans/$planId/detail',
      );

      if (response.statusCode == 200) {
        // HttpService 会自动解包 API 响应，response.data 已经是内层的 data 字段
        final data = response.data;

        if (data != null && data is Map<String, dynamic>) {
          final dto = TravelPlanDto.fromJson(data);
          final plan = dto.toDomain();
          log('✅ 获取旅行计划详情成功');
          return Result.success(plan);
        } else {
          log('ℹ️ 旅行计划数据为空');
          return Result.failure(
            ServerException('旅行计划数据为空'),
          );
        }
      }

      return Result.failure(
        ServerException('获取旅行计划详情失败'),
      );
    } on DioException catch (e) {
      log('❌ 获取旅行计划详情网络错误: ${e.message}');
      if (e.response?.statusCode == 401) {
        return Result.failure(
          UnauthorizedException('请先登录'),
        );
      }
      if (e.response?.statusCode == 404) {
        return Result.failure(
          ServerException('旅行计划不存在'),
        );
      }
      if (e.response?.statusCode == 403) {
        return Result.failure(
          UnauthorizedException('无权访问该旅行计划'),
        );
      }
      return Result.failure(
        NetworkException('网络连接失败: ${e.message}'),
      );
    } catch (e) {
      log('❌ 获取旅行计划详情失败: $e');
      return Result.failure(
        UnknownException('获取失败: ${e.toString()}'),
      );
    }
  }

  // ==================== 附近城市 ====================

  @override
  Future<Result<List<NearbyCityDto>>> getNearbyCitiesFromBackend(String cityId) async {
    try {
      log('🌍 从后端获取附近城市: cityId=$cityId');

      final response = await _httpService.get(
        '/cities/$cityId/nearby',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data is List) {
          final cities = data.map((e) => NearbyCityDto.fromJson(e as Map<String, dynamic>)).toList();
          log('✅ 获取到 ${cities.length} 个附近城市');
          return Result.success(cities);
        } else {
          log('ℹ️ 附近城市数据为空');
          return Result.success([]);
        }
      }

      return Result.failure(
        ServerException('获取附近城市失败'),
      );
    } on DioException catch (e) {
      log('❌ 获取附近城市网络错误: ${e.message}');
      return Result.failure(
        NetworkException('网络连接失败: ${e.message}'),
      );
    } catch (e) {
      log('❌ 获取附近城市失败: $e');
      return Result.failure(
        UnknownException('获取失败: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> generateNearbyCitiesStream({
    required String cityId,
    required String cityName,
    String? country,
    int radiusKm = 100,
    int count = 4,
    required Function(AsyncTask task) onProgress,
    required Function(List<NearbyCityDto> cities) onData,
    required Function(String error) onError,
  }) async {
    try {
      log('🌍 开始生成附近城市 (异步任务模式)');
      log('   城市: $cityName (ID: $cityId)');
      log('   半径: ${radiusKm}km, 数量: $count');

      // 1. 先设置 SignalR 连接和监听器
      final signalRService = SignalRService();

      // SignalR Hub 连接到 MessageService 的 ai-progress hub
      // 生产环境通过 Gateway 路由，开发环境也通过 Gateway 路由
      final messageServiceUrl = ApiConfig.messageServiceBaseUrl;
      log('🔌 连接到 MessageService SignalR Hub: $messageServiceUrl/hubs/ai-progress');

      // 使用 ensureConnected 替代直接 connect，带重试机制
      final connected = await signalRService.ensureConnected(maxRetries: 2);
      if (connected) {
        log('✅ SignalR 连接已建立');
      } else {
        log('⚠️ SignalR 连接失败，将依赖轮询回退');
      }

      // 等待连接稳定
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. 创建异步任务
      log('📤 发送请求到: ${ApiConfig.currentApiBaseUrl}/ai/nearby-cities/async');

      final response = await _httpService.post(
        '/ai/nearby-cities/async',
        data: {
          'cityId': cityId,
          'cityName': cityName,
          if (country != null) 'country': country,
          'radiusKm': radiusKm,
          'count': count,
        },
      );

      log('✅ API 响应成功！');
      log('   Response data: ${response.data}');

      final taskId = response.data['taskId'] as String?;
      if (taskId == null) {
        onError('创建附近城市生成任务失败: 未返回任务ID');
        return Result.failure(ServerException('未返回任务ID'));
      }

      log('✅ 附近城市任务已创建: taskId=$taskId');

      // 3. 订阅任务通知
      await signalRService.subscribeToTask(taskId);
      log('📢 客户端订阅任务: $taskId');

      // 4. 监听任务事件
      final completer = Completer<void>();
      late StreamSubscription<AsyncTask> progressSub;
      late StreamSubscription<AsyncTask> completedSub;
      late StreamSubscription<AsyncTask> failedSub;
      Timer? pollingTimer;

      // 清理所有资源的辅助方法
      Future<void> cleanup() async {
        pollingTimer?.cancel();
        await progressSub.cancel();
        await completedSub.cancel();
        await failedSub.cancel();
        await signalRService.unsubscribeFromTask(taskId);
      }

      log('📡 开始监听 SignalR 事件流...');

      progressSub = signalRService.taskProgressStream.listen((task) {
        if (task.taskId == taskId) {
          final message = task.progress.message ?? '处理中...';
          final percent = task.progress.percentage;
          final status = task.progress.status;
          log('📊 附近城市任务进度: $percent% - $message - status: $status');
          onProgress(task);
        }
      });

      completedSub = signalRService.taskCompletedStream.listen((task) async {
        if (task.taskId == taskId) {
          log('✅ [SignalR] 附近城市任务完成！');

          try {
            final cities = await _fetchNearbyCitiesResult(cityId);
            log('📦 获取到 ${cities.length} 个附近城市');
            onData(cities);
          } catch (e, stackTrace) {
            log('❌ 获取附近城市数据失败: $e');
            log('   StackTrace: $stackTrace');
            onError('获取附近城市数据失败: ${e.toString()}');
          } finally {
            log('🧹 清理资源...');
            await cleanup();
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        }
      });

      failedSub = signalRService.taskFailedStream.listen((task) async {
        if (task.taskId == taskId) {
          log('❌ [SignalR] 附近城市任务失败: ${task.error}');
          onError(task.error ?? '生成失败');

          log('🧹 清理资源（失败）...');
          await cleanup();
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

      // 5. 启动轮询回退机制（与 SignalR 并行，谁先到用谁）
      log('🔄 启动附近城市任务状态轮询回退...');
      int pollCount = 0;
      const maxPolls = 60; // 5分钟 / 5秒

      pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (completer.isCompleted) {
          timer.cancel();
          return;
        }

        pollCount++;
        if (pollCount > maxPolls) {
          timer.cancel();
          return;
        }

        final statusData = await _checkTaskStatus(taskId);
        if (statusData == null || completer.isCompleted) return;

        final status = statusData['status'] as String?;

        if (status == 'completed') {
          log('✅ [轮询] 附近城市任务已完成！');
          timer.cancel();

          if (!completer.isCompleted) {
            try {
              final cities = await _fetchNearbyCitiesResult(cityId);
              log('📦 [轮询] 获取到 ${cities.length} 个附近城市');
              onData(cities);
            } catch (e) {
              log('❌ [轮询] 获取附近城市数据失败: $e');
              onError('获取附近城市数据失败: ${e.toString()}');
            }
            await cleanup();
            completer.complete();
          }
        } else if (status == 'failed') {
          log('❌ [轮询] 附近城市任务失败');
          timer.cancel();

          if (!completer.isCompleted) {
            onError(statusData['error'] as String? ?? '生成失败');
            await cleanup();
            completer.complete();
          }
        }
      });

      log('⏳ 等待附近城市任务完成（最长 5 分钟）...');

      // 等待任务完成，最多 5 分钟
      await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () async {
          log('⏱️ 附近城市任务超时！');
          onError('任务超时，请稍后重试');
          await cleanup();
        },
      );

      log('✅ generateNearbyCitiesStream 执行完成');
      return Result.success(null);
    } on DioException catch (e) {
      log('❌ 生成附近城市网络错误: ${e.message}');
      onError('网络连接失败: ${e.message}');
      return Result.failure(NetworkException('网络连接失败'));
    } catch (e, stackTrace) {
      log('❌ 生成附近城市失败: $e');
      log('   StackTrace: $stackTrace');
      onError('生成失败: ${e.toString()}');
      return Result.failure(UnknownException('生成失败'));
    }
  }

  /// 从 CityService 获取附近城市结果
  Future<List<NearbyCityDto>> _fetchNearbyCitiesResult(String cityId) async {
    try {
      final response = await _httpService.get('/cities/$cityId/nearby');

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => NearbyCityDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      log('❌ 获取附近城市结果失败: $e');
      return [];
    }
  }

  /// 通用任务状态轮询方法
  /// 调用 GET /ai/travel-plan/tasks/{taskId} (通用任务状态端点)
  Future<Map<String, dynamic>?> _checkTaskStatus(String taskId) async {
    try {
      final response = await _httpService.get(
        '/ai/travel-plan/tasks/$taskId',
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : null;
      }
      return null;
    } catch (e) {
      log('⚠️ 轮询任务状态失败: $e');
      return null;
    }
  }
}
