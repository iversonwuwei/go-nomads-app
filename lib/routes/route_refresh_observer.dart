import 'package:flutter/widgets.dart';

/// Global route observer that lets any page know when it becomes visible again
/// after navigating back from another page.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();

/// Mixin for pages that must refresh whenever the user returns to them by
/// popping a pushed route (e.g. after adding or editing data).
///
/// Usage:
///
/// ```dart
/// class _MyPageState extends State<MyPage>
///     with RouteAwareRefreshMixin<MyPage> {
///   @override
///   Future<void> onRouteResume() async {
///     await _reloadData();
///   }
/// }
/// ```
///
/// The mixin automatically subscribes the State to [appRouteObserver] and calls
/// [onRouteResume] inside `didPopNext` (i.e. when another page above the current
/// one is popped). This keeps each page's refresh logic self-contained.
mixin RouteAwareRefreshMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  PageRoute<dynamic>? _route;

  /// Called automatically when the page becomes visible again.
  Future<void> onRouteResume();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _route) {
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    if (_route != null) {
      appRouteObserver.unsubscribe(this);
      _route = null;
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    onRouteResume();
  }

  @override
  void didPush() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}
}
