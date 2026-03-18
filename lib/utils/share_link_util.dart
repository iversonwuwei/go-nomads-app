enum ShareContentType {
  city,
  meetup,
  travelPlan,
}

class ShareLinkUtil {
  static const String _baseHost = 'go-nomads.com';
  static const String _appPathPrefix = '/app';

  static String cityDetail(String cityId) {
    return _buildShareUri(type: ShareContentType.city, id: cityId).toString();
  }

  static String meetupDetail(String meetupId) {
    return _buildShareUri(type: ShareContentType.meetup, id: meetupId).toString();
  }

  static String travelPlanDetail(String planId) {
    return _buildShareUri(type: ShareContentType.travelPlan, id: planId).toString();
  }

  static Uri _buildShareUri({required ShareContentType type, required String id}) {
    final normalizedId = id.trim();
    final routeSegment = switch (type) {
      ShareContentType.city => 'city-detail',
      ShareContentType.meetup => 'meetup-detail',
      ShareContentType.travelPlan => 'travel-plan',
    };

    return Uri.https(_baseHost, '$_appPathPrefix/$routeSegment', {'id': normalizedId});
  }
}
