import 'dart:developer';

import 'package:get/get.dart';

/// Binding 工具类 - 确保页面控制器全新创建
///
/// 提供统一的控制器注册模式：
/// 1. 删除已存在的同类型控制器
/// 2. 注册全新的控制器实例
/// 3. 控制器的 onInit 会重新从服务端加载数据
///
/// 使用方式:
/// ```dart
/// class MyBinding extends Bindings {
///   @override
///   void dependencies() {
///     BindingHelper.putFresh<MyController>(() => MyController());
///   }
/// }
/// ```
class BindingHelper {
  /// 注册全新的控制器实例
  ///
  /// 如果同类型控制器已存在，先删除旧实例再注册新实例。
  /// 这确保了每次进入页面时控制器状态都是全新的。
  ///
  /// [builder] 控制器构造函数
  /// [tag] 可选的 tag，用于同类型多实例场景
  /// [permanent] 是否为永久控制器（默认 false）
  static T putFresh<T extends GetxController>(
    T Function() builder, {
    String? tag,
    bool permanent = false,
  }) {
    // 先删除旧实例
    if (Get.isRegistered<T>(tag: tag)) {
      Get.delete<T>(tag: tag, force: true);
      log('🧹 [BindingHelper] 删除旧控制器: ${T.toString()}${tag != null ? ' (tag: $tag)' : ''}');
    }

    // 注册全新实例
    final controller = Get.put<T>(builder(), tag: tag, permanent: permanent);
    log('✨ [BindingHelper] 注册新控制器: ${T.toString()}${tag != null ? ' (tag: $tag)' : ''}');
    return controller;
  }

  /// 延迟注册全新的控制器实例（fenix 模式）
  ///
  /// 使用 Get.lazyPut + fenix: true，确保控制器被删除后能重新创建。
  /// 首次 Get.find 时才真正创建实例。
  ///
  /// [builder] 控制器构造函数
  /// [tag] 可选的 tag
  static void lazyPutFresh<T extends GetxController>(
    T Function() builder, {
    String? tag,
  }) {
    // 先删除旧实例
    if (Get.isRegistered<T>(tag: tag)) {
      Get.delete<T>(tag: tag, force: true);
      log('🧹 [BindingHelper] 删除旧控制器(lazy): ${T.toString()}${tag != null ? ' (tag: $tag)' : ''}');
    }

    // 使用 fenix: true 注册，控制器被删除后可自动重建
    Get.lazyPut<T>(builder, tag: tag, fenix: true);
    log('✨ [BindingHelper] 延迟注册新控制器: ${T.toString()}${tag != null ? ' (tag: $tag)' : ''}');
  }

  /// 确保共享状态控制器存在
  ///
  /// 对于全局共享的状态控制器（如 CityStateController），
  /// 只需确保它们存在即可，不需要删除重建。
  /// 这些控制器在 DependencyInjection 中注册，生命周期与 app 一致。
  static T ensureExists<T extends GetxController>({String? tag}) {
    if (!Get.isRegistered<T>(tag: tag)) {
      log('⚠️ [BindingHelper] 共享控制器未注册: ${T.toString()}，依赖 fenix 重建');
    }
    return Get.find<T>(tag: tag);
  }
}
