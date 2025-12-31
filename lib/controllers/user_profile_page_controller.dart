import 'package:df_admin_mobile/features/user/domain/entities/user.dart';
import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller_v2.dart';
import 'package:get/get.dart';

class UserProfilePageController extends GetxController {
  UserProfilePageController({this.args});

  final dynamic args;

  late final UserStateControllerV2 _profileController = Get.find<UserStateControllerV2>();
  Worker? _currentUserWorker;

  final RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs;
  final Rxn<User> routeUser = Rxn<User>();
  String? requestedUserId;

  final RxBool isRemoteProfileLoading = false.obs;
  final RxnString remoteProfileError = RxnString();

  @override
  void onInit() {
    super.onInit();
    _initializeProfileData();
    _listenForCurrentUserUpdates();
  }

  @override
  void onClose() {
    _currentUserWorker?.dispose();
    super.onClose();
  }

  bool get shouldBlockForRemoteProfile {
    if (requestedUserId == null) return false;
    if (routeUser.value != null) return false;
    return isRemoteProfileLoading.value;
  }

  User? get displayUser {
    if (routeUser.value != null) {
      return routeUser.value;
    }
    if (requestedUserId != null && requestedUserId!.isNotEmpty) {
      return null;
    }
    return _profileController.currentUser.value;
  }

  User? get chatTargetUser => displayUser;

  Future<void> fetchUserProfile(String userId) async {
    if (userId.isEmpty) return;
    isRemoteProfileLoading.value = true;
    remoteProfileError.value = null;

    final user = await _profileController.getUserById(userId);

    if (user == null) {
      isRemoteProfileLoading.value = false;
      remoteProfileError.value = '无法加载用户信息';
      return;
    }

    routeUser.value = user;
    userInfo.assignAll(_mapUserToInfo(user));
    isRemoteProfileLoading.value = false;
    remoteProfileError.value = null;
  }

  // Helpers
  String getCountryFlag(String country) {
    const Map<String, String> countryFlags = {
      'Thailand': '🇹🇭',
      'Indonesia': '🇮🇩',
      'Vietnam': '🇻🇳',
      'Portugal': '🇵🇹',
      'Mexico': '🇲🇽',
      'Japan': '🇯🇵',
      'China': '🇨🇳',
      'USA': '🇺🇸',
      'UK': '🇬🇧',
      'Spain': '🇪🇸',
      'France': '🇫🇷',
      'Germany': '🇩🇪',
      'Italy': '🇮🇹',
      'Brazil': '🇧🇷',
      'Australia': '🇦🇺',
    };
    return countryFlags[country] ?? '🌍';
  }

  String formatTravelDates(DateTime arrival, DateTime? departure, int? durationDays) {
    final arrivalStr = '${arrival.month}/${arrival.day}/${arrival.year}';
    if (departure != null) {
      final departureStr = '${departure.month}/${departure.day}/${departure.year}';
      final days = durationDays ?? departure.difference(arrival).inDays;
      return '$arrivalStr - $departureStr ($days days)';
    }
    return arrivalStr;
  }

  // initialization helpers
  void _initializeProfileData() {
    requestedUserId = _extractUserId(args);
    routeUser.value = _parseRouteUser(args);

    if (requestedUserId != null && routeUser.value != null && routeUser.value!.id != requestedUserId) {
      routeUser.value = null;
    }

    final currentUser = _profileController.currentUser.value;
    if (requestedUserId != null && currentUser?.id == requestedUserId) {
      routeUser.value = currentUser;
    }

    if (routeUser.value != null) {
      userInfo.assignAll(_mapUserToInfo(routeUser.value!));
    } else if (requestedUserId == null) {
      if (currentUser != null) {
        userInfo.assignAll(_mapUserToInfo(currentUser));
      }
    } else {
      userInfo.assignAll(_buildLoadingUserInfo(requestedUserId!));
    }

    if (requestedUserId != null) {
      fetchUserProfile(requestedUserId!);
    }
  }

  void _listenForCurrentUserUpdates() {
    _currentUserWorker = ever<User?>(_profileController.currentUser, (user) {
      if (user == null) return;
      if (routeUser.value != null) return;
      if (requestedUserId != null && requestedUserId!.isNotEmpty) return;
      userInfo.assignAll(_mapUserToInfo(user));
    });
  }

  String? _extractUserId(dynamic args) {
    if (args == null) return null;
    if (args is User) return args.id;
    if (args is String && args.isNotEmpty) return args;
    if (args is Map<String, dynamic>) {
      final nestedUser = args['user'];
      if (nestedUser is User) return nestedUser.id;
      final id = args['userId'] ?? args['id'];
      if (id is String && id.isNotEmpty) return id;
    }
    return null;
  }

  Map<String, dynamic> _buildLoadingUserInfo(String userId) {
    return {
      'id': userId,
      'username': userId,
      'name': '加载中...',
      'email': '加载中...',
      'memberSince': '--',
      'favoritesCount': 0,
      'visitedCount': 0,
      'countriesCount': 0,
      'citiesCount': 0,
      'avatar': 'https://ui-avatars.com/api/?name=User&background=374151&color=fff&size=200',
    };
  }

  User? _parseRouteUser(dynamic args) {
    if (args == null) return null;
    if (args is User) return args;
    if (args is Map<String, dynamic>) {
      final id = args['userId'] ?? args['id'];
      final username = args['username'] ?? args['name'];
      if (id == null || username == null) return null;
      final statsArgument = args['stats'];
      return User(
        id: id.toString(),
        name: (args['name'] ?? username).toString(),
        username: username.toString(),
        email: args['email'] as String?,
        bio: args['bio'] as String?,
        avatarUrl: args['avatarUrl'] as String?,
        currentCity: args['currentCity'] as String?,
        currentCountry: args['currentCountry'] as String?,
        skills: const [],
        interests: const [],
        socialLinks: const {},
        badges: const [],
        stats: _parseStats(statsArgument, args),
        travelHistory: const [],
        joinedDate: _parseDate(args['joinedDate']?.toString()) ?? DateTime.now(),
        isVerified: args['isVerified'] == true,
      );
    }
    return null;
  }

  TravelStats _parseStats(dynamic stats, Map<String, dynamic> fallback) {
    if (stats is TravelStats) return stats;
    if (stats is Map<String, dynamic>) {
      return TravelStats(
        citiesVisited: _parseInt(stats['citiesVisited']),
        countriesVisited: _parseInt(stats['countriesVisited']),
        reviewsWritten: _parseInt(stats['reviewsWritten']),
        photosShared: _parseInt(stats['photosShared']),
        totalDistanceTraveled: _parseDouble(stats['totalDistanceTraveled']),
      );
    }
    return TravelStats(
      citiesVisited: _parseInt(fallback['visitedCount']),
      countriesVisited: _parseInt(fallback['countriesVisited']),
      reviewsWritten: _parseInt(fallback['favoritesCount']),
      photosShared: 0,
      totalDistanceTraveled: 0,
    );
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> _mapUserToInfo(User user) {
    return {
      'id': user.id,
      'username': user.username,
      'name': user.name,
      'email': user.email ?? 'Email not provided',
      'memberSince': _formatMemberSince(user.joinedDate),
      'favoritesCount': user.stats.reviewsWritten,
      'visitedCount': user.stats.citiesVisited,
      'countriesCount': user.stats.countriesVisited,
      'citiesCount': user.stats.citiesVisited,
      'avatar': user.avatarUrl ?? 'https://ui-avatars.com/api/?name=${user.name}&background=FF9800&color=fff&size=200',
    };
  }

  String _formatMemberSince(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '${dateTime.year}-$month-$day';
  }
}
