import 'dart:async';

import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/ai/domain/repositories/iai_repository.dart';
import 'package:df_admin_mobile/features/async_task/domain/entities/async_task.dart';
import 'package:df_admin_mobile/features/city/domain/entities/digital_nomad_guide.dart';
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan.dart'
    as entity;
import 'package:df_admin_mobile/services/database/digital_nomad_guide_dao.dart';
import 'package:df_admin_mobile/services/database_service.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/signalr_service.dart';
import 'package:get/get.dart';

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
      print('🤖 正在生成AI旅行计划...');
      print('   城市: $cityName, 天数: $duration');

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
            finalBudget =
                amount < 3000 ? 'low' : (amount < 10000 ? 'medium' : 'high');
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
          if (finalCustomBudget != null)
            'customBudget': finalCustomBudget.toString(),
          if (finalCurrency != null) 'currency': finalCurrency,
          if (selectedAttractions != null)
            'selectedAttractions': selectedAttractions,
        },
      );

      // 使用响应数据 (TODO: 实现完整的转换逻辑)
      print('✅ API响应: ${response.statusCode}');

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
    double? customBudget,
    String? currency,
    List<String>? selectedAttractions,
    required Function(String message, int progress) onProgress,
    required Function(entity.TravelPlan plan) onData,
    required Function(String error) onError,
  }) async {
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
  Future<Result<DigitalNomadGuide>> generateDigitalNomadGuide({
    required String cityId,
    required String cityName,
  }) async {
    try {
      final response = await _httpService.post(
        '/ai/digital-nomad-guide',
        data: {'cityId': cityId, 'cityName': cityName},
      );

      final guideData = response.data as Map<String, dynamic>;
      final guide = DigitalNomadGuide.fromMap(guideData);

      return Result.success(guide);
    } catch (e) {
      return Result.failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<void>> generateDigitalNomadGuideStream({
    required String cityId,
    required String cityName,
    required Function(String message, int progress) onProgress,
    required Function(DigitalNomadGuide guide) onData,
    required Function(String error) onError,
  }) async {
    try {
      print('🤖 开始异步生成数字游民指南...');
      print('   城市: $cityName (ID: $cityId)');
      print('   API Base URL: ${ApiConfig.currentApiBaseUrl}');

      // 1. 创建异步任务
      onProgress('正在创建生成任务...', 0);

      print('📤 发送请求到: ${ApiConfig.currentApiBaseUrl}/ai/guide/async');

      final createResponse = await _httpService.post(
        '/ai/guide/async',
        data: {
          'cityId': cityId,
          'cityName': cityName,
        },
      );

      print('✅ API 响应成功！');
      print('   Response data: ${createResponse.data}');

      final taskId = createResponse.data['taskId'] as String;
      print('✅ 任务已创建: $taskId');

      onProgress('任务已创建，等待处理...', 10);

      // 2. 连接 SignalR 监听任务完成
      final signalRService = SignalRService();
      
      // SignalR Hub 在 AIService 上（端口 8009），直接连接
      const aiServiceBaseUrl = 'http://127.0.0.1:8009';
      print('🔌 连接到 AIService SignalR Hub: $aiServiceBaseUrl/hubs/notifications');

      if (!signalRService.isConnected) {
        await signalRService.connect(aiServiceBaseUrl);
      }

      // 订阅任务通知
      await signalRService.subscribeToTask(taskId);

      // 3. 监听任务事件
      final completer = Completer<void>();
      late StreamSubscription<AsyncTask> progressSub;
      late StreamSubscription<AsyncTask> completedSub;
      late StreamSubscription<AsyncTask> failedSub;

      progressSub = signalRService.taskProgressStream.listen((task) {
        if (task.taskId == taskId) {
          final message = task.progress.message ?? '处理中...';
          final percent = task.progress.percentage;
          print('📊 任务进度: $percent% - $message');
          onProgress(message, percent);
        }
      });

      completedSub = signalRService.taskCompletedStream.listen((task) async {
        if (task.taskId == taskId) {
          print('✅ 任务完成！');

          try {
            // 从 task.result.rawData 中直接获取指南数据
            if (task.result?.rawData != null) {
              print('📦 解析指南数据...');
              final rawData = task.result!.rawData!;

              // 从 Map 创建实体
              final guide = DigitalNomadGuide.fromMap(rawData);

              // 保存到数据库
              await _saveGuideToDatabase(guide);

              onProgress('指南生成完成！', 100);
              onData(guide);
            } else {
              throw Exception('任务完成但没有返回指南数据');
            }
          } catch (e, stackTrace) {
            print('❌ 处理指南数据失败: $e');
            print('   StackTrace: $stackTrace');
            onError('处理指南数据失败: ${e.toString()}');
          } finally {
            await progressSub.cancel();
            await completedSub.cancel();
            await failedSub.cancel();
            await signalRService.unsubscribeFromTask(taskId);
            completer.complete();
          }
        }
      });

      failedSub = signalRService.taskFailedStream.listen((task) async {
        if (task.taskId == taskId) {
          print('❌ 任务失败: ${task.error}');
          onError(task.error ?? '生成失败');

          await progressSub.cancel();
          await completedSub.cancel();
          await failedSub.cancel();
          await signalRService.unsubscribeFromTask(taskId);
          completer.complete();
        }
      });

      // 等待任务完成
      await completer.future;

      return Result.success(null);
    } catch (e, stackTrace) {
      print('❌ 异步任务失败: $e');
      print('   类型: ${e.runtimeType}');
      print('   StackTrace: $stackTrace');
      onError('异步任务失败: ${e.toString()}');
      return Result.failure(
        UnknownException('异步任务失败: ${e.toString()}'),
      );
    }
  }

  /// 保存指南到数据库
  Future<void> _saveGuideToDatabase(DigitalNomadGuide guide) async {
    try {
      print('💾 保存指南到 SQLite...');
      final db = await DatabaseService().database;
      final dao = DigitalNomadGuideDao(db);
      await dao.saveGuide(guide);
      print('✅ 指南已保存到 SQLite');
    } catch (e) {
      print('⚠️ 保存指南到数据库失败: $e');
      // 不抛出异常，允许继续执行
    }
  }
}
