import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 导航工具类
/// 统一处理页面返回逻辑，解决 iOS 上 Future.delayed + Get.back 不工作的问题
class NavigationUtil {
  NavigationUtil._();

  /// 安全地返回上一页并传递结果
  /// 
  /// 在 iOS 上，直接使用 `Future.delayed(() => Get.back(result:))` 可能不会正确执行。
  /// 此方法提供了一个统一的、跨平台的解决方案。
  /// 
  /// [result] - 要传递给上一页的结果
  /// [context] - 可选的 BuildContext，如果提供则优先使用 Navigator
  /// [delay] - 返回前的延迟时间，默认为 0（立即返回）
  static Future<void> goBack<T>({
    T? result,
    BuildContext? context,
    Duration delay = Duration.zero,
  }) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    // 在 iOS 上优先使用 Navigator.of(context).pop
    // 因为 GetX 的 Get.back 在某些 iOS 场景下可能不会正确传递 result
    if (Platform.isIOS && context != null && context.mounted) {
      Navigator.of(context).pop(result);
    } else if (Get.isOverlaysOpen) {
      // 如果有 overlay 打开（如 dialog, snackbar），先关闭它
      Get.back(closeOverlays: true);
      if (Get.isDialogOpen == true || Get.isSnackbarOpen) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      final navigatorState = Get.key.currentState;
      if (navigatorState != null && navigatorState.canPop()) {
        Get.back(result: result);
      }
    } else {
      Get.back(result: result);
    }
  }

  /// 创建成功后的统一返回逻辑
  /// 
  /// 专门用于创建/编辑页面在成功后返回上一页
  /// 
  /// [result] - 要传递给上一页的结果，通常为 true 或包含数据的 Map
  /// [context] - BuildContext，强烈建议提供以确保 iOS 上正确工作
  /// [successMessage] - 可选的成功提示消息
  static Future<void> popAfterSuccess<T>({
    required T result,
    BuildContext? context,
  }) async {
    // 给 UI 一点时间完成任何正在进行的动画或状态更新
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (context != null && context.mounted) {
      // 使用 Navigator 直接 pop，这在所有平台上都更可靠
      Navigator.of(context).pop(result);
    } else {
      // fallback 到 GetX
      Get.back(result: result);
    }
  }

  /// 打开一个页面并等待结果
  /// 
  /// [route] - 路由名称
  /// [arguments] - 传递给目标页面的参数
  /// [onResult] - 结果回调，当返回结果不为 null 且满足条件时调用
  static Future<T?> toNamedAndAwait<T>({
    required String route,
    dynamic arguments,
    bool Function(T?)? shouldRefresh,
    VoidCallback? onRefresh,
  }) async {
    final result = await Get.toNamed<T>(route, arguments: arguments);
    
    if (onRefresh != null) {
      final shouldCall = shouldRefresh?.call(result) ?? (result != null);
      if (shouldCall) {
        onRefresh();
      }
    }
    
    return result;
  }
}
