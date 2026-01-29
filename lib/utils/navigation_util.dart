import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/core/navigation/navigation_result.dart';

// 导出核心类型
export 'package:go_nomads_app/core/navigation/navigation_result.dart';

/// 导航工具类
///
/// 提供统一的页面导航和数据刷新机制
///
/// ## 核心特性
/// - 自动处理 NavigationResult 和旧式返回值
/// - 与 IRefreshableList 接口集成，自动处理列表刷新
/// - 跨平台兼容（解决 iOS 上的返回问题）
///
/// ## 使用示例
///
/// ### 1. 跳转并自动刷新（推荐）
/// ```dart
/// await NavigationUtil.toAndRefresh<Meetup>(
///   page: () => CreateMeetupPage(),
///   refresher: controller,  // 实现了 IRefreshableList<Meetup>
/// );
/// ```
///
/// ### 2. 详情页返回
/// ```dart
/// NavigationUtil.backFromDetail<Meetup>(
///   entity: meetup.value,
///   hasChanged: hasDataChanged.value,
///   context: context,
/// );
/// ```
///
/// ### 3. 创建/编辑页返回
/// ```dart
/// NavigationUtil.backAfterSave(newMeetup, context: context);
/// ```
class NavigationUtil {
  NavigationUtil._();

  // ==================== 核心跳转方法（使用接口） ====================

  /// 跳转到页面并自动处理刷新逻辑
  ///
  /// 泛型 `T` 为实体类型
  ///
  /// - [page] - 目标页面构建函数
  /// - [refresher] - 实现了 `IRefreshableList<T>` 的 controller
  /// - [binding] - GetX Binding（可选）
  ///
  /// 自动处理：
  /// - NavigationResult 返回值
  /// - 旧式 bool/entity/'deleted' 返回值
  static Future<void> toAndRefresh<T>({
    required Widget Function() page,
    required IRefreshableList<T> refresher,
    Bindings? binding,
  }) async {
    final rawResult = await Get.to<dynamic>(page, binding: binding);
    _handleResultForRefresher<T>(rawResult, refresher);
  }

  /// 跳转到命名路由并自动处理刷新逻辑
  static Future<void> toNamedAndRefresh<T>({
    required String route,
    required IRefreshableList<T> refresher,
    dynamic arguments,
  }) async {
    final rawResult = await Get.toNamed<dynamic>(route, arguments: arguments);
    _handleResultForRefresher<T>(rawResult, refresher);
  }

  /// 统一处理返回结果并刷新列表
  static void _handleResultForRefresher<T>(dynamic rawResult, IRefreshableList<T> refresher) {
    log('🔄 [NavigationUtil] Received result: $rawResult');

    // 1. 处理 NavigationResult<T>
    if (rawResult is NavigationResult<T>) {
      _applyNavigationResult<T>(rawResult, refresher);
      return;
    }

    // 2. 处理 NavigationResult<dynamic>（泛型不匹配时）
    if (rawResult is NavigationResult) {
      if (rawResult.needsRefresh) {
        if (rawResult.hasData && rawResult.data is T) {
          final typedResult = NavigationResult.internal<T>(
            action: rawResult.action,
            data: rawResult.data as T,
            entityId: rawResult.entityId,
          );
          _applyNavigationResult<T>(typedResult, refresher);
        } else if (rawResult.isDeleted && rawResult.entityId != null) {
          refresher.removeItemById(rawResult.entityId!);
        } else {
          refresher.refreshList();
        }
      }
      return;
    }

    // 3. 处理旧式返回值（向后兼容）
    if (rawResult == true || rawResult == 'deleted') {
      refresher.refreshList();
    } else if (rawResult is T) {
      refresher.updateItem(rawResult);
    }
  }

  /// 应用 NavigationResult 到 refresher
  static void _applyNavigationResult<T>(NavigationResult<T> result, IRefreshableList<T> refresher) {
    switch (result.action) {
      case NavigationAction.created:
        if (result.hasData) {
          refresher.addItem(result.data as T);
        } else {
          refresher.refreshList();
        }
        break;

      case NavigationAction.updated:
        if (result.hasData) {
          refresher.updateItem(result.data as T);
        } else {
          refresher.refreshList();
        }
        break;

      case NavigationAction.deleted:
        if (result.entityId != null) {
          refresher.removeItemById(result.entityId!);
        } else {
          refresher.refreshList();
        }
        break;

      case NavigationAction.forceRefresh:
        refresher.refreshList();
        break;

      case NavigationAction.unchanged:
        // 不需要处理
        break;
    }
  }

  // ==================== 简化的返回方法 ====================

  /// 从详情页返回（自动判断是否有数据变更）
  ///
  /// [entity] - 当前实体数据
  /// [hasChanged] - 数据是否有变更
  /// [context] - BuildContext（推荐提供，确保 iOS 兼容）
  static Future<void> backFromDetail<T>({
    required T? entity,
    required bool hasChanged,
    BuildContext? context,
  }) async {
    if (hasChanged && entity != null) {
      await _doBack(NavigationResult<T>.updated(entity), context);
    } else {
      await _doBack(NavigationResult<T>.unchanged(), context);
    }
  }

  /// 保存成功后返回（创建或更新）
  ///
  /// [entity] - 保存后的实体
  /// [isNew] - 是否为新建（true=created, false=updated）
  /// [context] - BuildContext
  static Future<void> backAfterSave<T>(
    T entity, {
    bool isNew = true,
    BuildContext? context,
  }) async {
    final result = isNew ? NavigationResult<T>.created(entity) : NavigationResult<T>.updated(entity);
    await _doBack(result, context);
  }

  /// 删除成功后返回
  static Future<void> backAfterDelete({
    String? entityId,
    BuildContext? context,
  }) async {
    await _doBack(
      NavigationResult<void>.deleted(entityId: entityId),
      context,
    );
  }

  /// 强制刷新后返回
  static Future<void> backWithRefresh<T>({
    T? data,
    BuildContext? context,
  }) async {
    await _doBack(NavigationResult<T>.forceRefresh(data: data), context);
  }

  /// 未变更直接返回
  static Future<void> backUnchanged<T>({BuildContext? context}) async {
    await _doBack(NavigationResult<T>.unchanged(), context);
  }

  // ==================== 底层返回实现 ====================

  /// 执行返回操作
  static Future<void> _doBack<T>(NavigationResult<T> result, BuildContext? context) async {
    log('🔙 [NavigationUtil] Back with: ${result.action.name}');

    // 给 UI 一点时间完成动画
    await Future.delayed(const Duration(milliseconds: 50));

    if (context != null && context.mounted) {
      Navigator.of(context).pop(result);
    } else {
      Get.back(result: result);
    }
  }

  /// 使用 NavigationResult 返回（底层方法）
  static Future<void> backWithResult<T>(
    NavigationResult<T> result, {
    BuildContext? context,
  }) async {
    await _doBack(result, context);
  }

  // ==================== 带回调的跳转方法 ====================

  /// 跳转到页面并手动处理结果
  ///
  /// 用于不使用 IRefreshableList 接口的场景
  static Future<NavigationResult<T>?> toWithCallback<T>({
    required Widget Function() page,
    Bindings? binding,
    void Function(NavigationResult<T> result)? onResult,
  }) async {
    final rawResult = await Get.to<dynamic>(page, binding: binding);
    return _processAndCallback<T>(rawResult, onResult);
  }

  /// 跳转到命名路由并手动处理结果
  static Future<NavigationResult<T>?> toNamedWithCallback<T>({
    required String route,
    dynamic arguments,
    void Function(NavigationResult<T> result)? onResult,
  }) async {
    final rawResult = await Get.toNamed<dynamic>(route, arguments: arguments);
    return _processAndCallback<T>(rawResult, onResult);
  }

  /// 处理结果并调用回调
  static NavigationResult<T>? _processAndCallback<T>(
    dynamic rawResult,
    void Function(NavigationResult<T> result)? onResult,
  ) {
    log('🔄 [NavigationUtil] Processing result: $rawResult');

    NavigationResult<T>? navResult;

    if (rawResult is NavigationResult<T>) {
      navResult = rawResult;
    } else if (rawResult is NavigationResult && rawResult.hasData && rawResult.data is T) {
      navResult = NavigationResult.internal<T>(
        action: rawResult.action,
        data: rawResult.data as T,
        entityId: rawResult.entityId,
      );
    } else if (rawResult == true) {
      navResult = NavigationResult<T>.forceRefresh();
    } else if (rawResult is T) {
      navResult = NavigationResult<T>.updated(rawResult);
    } else if (rawResult == 'deleted') {
      navResult = NavigationResult<T>.deleted();
    } else if (rawResult == null) {
      navResult = NavigationResult<T>.unchanged();
    }

    if (navResult != null && navResult.needsRefresh && onResult != null) {
      onResult(navResult);
    }

    return navResult;
  }

  // ==================== 兼容旧 API ====================

  /// 安全地返回上一页（兼容旧代码）
  @Deprecated('Use backFromDetail, backAfterSave, or backWithResult instead')
  static Future<void> goBack<T>({
    T? result,
    BuildContext? context,
    Duration delay = Duration.zero,
  }) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    if (Platform.isIOS && context != null && context.mounted) {
      Navigator.of(context).pop(result);
    } else if (Get.isOverlaysOpen) {
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

  /// 创建成功后返回（兼容旧代码）
  @Deprecated('Use backAfterSave instead')
  static Future<void> popAfterSuccess<T>({
    required T result,
    BuildContext? context,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (context != null && context.mounted) {
      Navigator.of(context).pop(result);
    } else {
      Get.back(result: result);
    }
  }

  /// 跳转并等待结果（兼容旧代码）
  @Deprecated('Use toAndRefresh or toWithCallback instead')
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

  // 以下方法标记为废弃，建议使用新方法

  @Deprecated('Use toAndRefresh instead')
  static Future<NavigationResult<T>?> toWithRefresh<T>({
    required Widget Function() page,
    Bindings? binding,
    void Function(NavigationResult<T> result)? onResult,
    void Function(dynamic legacyResult)? onLegacyResult,
  }) async {
    return toWithCallback<T>(page: page, binding: binding, onResult: onResult);
  }

  @Deprecated('Use toNamedAndRefresh instead')
  static Future<NavigationResult<T>?> toNamedWithRefresh<T>({
    required String route,
    dynamic arguments,
    void Function(NavigationResult<T> result)? onResult,
    void Function(dynamic legacyResult)? onLegacyResult,
  }) async {
    return toNamedWithCallback<T>(route: route, arguments: arguments, onResult: onResult);
  }
}
