import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

/// 深链跳转服务
/// 监听 app_links 事件，根据 URL 路由跳转到对应页面
class DeepLinkService extends GetxService {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void onInit() {
    super.onInit();
    _appLinks = AppLinks();
    _initDeepLinkListener();
  }

  Future<void> _initDeepLinkListener() async {
    // 冷启动时获取初始链接
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }
    // 监听后续链接
    _linkSubscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    // 例如: gonomads://city/detail?id=123
    // 或 https://gonomads.app/city/detail?id=123
    final path = uri.path;
    final params = uri.queryParameters;

    // 根据 path 路由跳转
    if (path.startsWith('/city/detail')) {
      final cityId = params['id'];
      if (cityId != null) {
        Get.toNamed('/city/detail', arguments: {'cityId': int.tryParse(cityId)});
      }
    } else if (path.startsWith('/meetup/detail')) {
      final meetupId = params['id'];
      if (meetupId != null) {
        Get.toNamed('/meetup/detail', arguments: {'meetupId': int.tryParse(meetupId)});
      }
    } else if (path.startsWith('/coworking/detail')) {
      final coworkingId = params['id'];
      if (coworkingId != null) {
        Get.toNamed('/coworking/detail', arguments: {'coworkingId': int.tryParse(coworkingId)});
      }
    }
    // 可扩展更多页面...
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
