import 'dart:developer';

import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/services/http_service.dart';

/// 搜索服务 - 通过Elasticsearch提供统一搜索功能
class SearchService {
  final HttpService _httpService;
  final String _baseUrl = '/search';

  SearchService(this._httpService);

  /// 统一搜索 - 同时搜索城市和共享办公空间
  Future<Result<UnifiedSearchResult>> search({
    String? query,
    String? type,
    int page = 1,
    int pageSize = 20,
    String? country,
    String? cityId,
    double? minRating,
    String? sortBy,
    String sortOrder = 'desc',
    double? lat,
    double? lon,
    double? radiusKm,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'sortOrder': sortOrder,
      };

      if (query != null && query.isNotEmpty) {
        queryParameters['query'] = query;
      }
      if (type != null && type.isNotEmpty) {
        queryParameters['type'] = type;
      }
      if (country != null && country.isNotEmpty) {
        queryParameters['country'] = country;
      }
      if (cityId != null && cityId.isNotEmpty) {
        queryParameters['cityId'] = cityId;
      }
      if (minRating != null) {
        queryParameters['minRating'] = minRating;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParameters['sortBy'] = sortBy;
      }
      if (lat != null) {
        queryParameters['lat'] = lat;
      }
      if (lon != null) {
        queryParameters['lon'] = lon;
      }
      if (radiusKm != null) {
        queryParameters['radiusKm'] = radiusKm;
      }

      final response = await _httpService.get(
        _baseUrl,
        queryParameters: queryParameters,
      );

      final data = response.data as Map<String, dynamic>;
      final result = UnifiedSearchResult.fromJson(data['data'] ?? data);

      return Success(result);
    } on HttpException catch (e) {
      log('❌ 搜索失败: ${e.message}');
      return Failure(NetworkException(e.message));
    } catch (e) {
      log('❌ 搜索异常: $e');
      return Failure(UnknownException('搜索失败: ${e.toString()}'));
    }
  }

  /// 搜索城市
  Future<Result<SearchResult<CitySearchDocument>>> searchCities({
    String? query,
    int page = 1,
    int pageSize = 20,
    String? country,
    double? minRating,
    String? sortBy,
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'sortOrder': sortOrder,
      };

      if (query != null && query.isNotEmpty) {
        queryParameters['query'] = query;
      }
      if (country != null && country.isNotEmpty) {
        queryParameters['country'] = country;
      }
      if (minRating != null) {
        queryParameters['minRating'] = minRating;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParameters['sortBy'] = sortBy;
      }

      final requestPath = '$_baseUrl/cities';
      log('🔍 [SearchService] 搜索城市请求路径: $requestPath, 参数: $queryParameters');

      final response = await _httpService.get(
        requestPath,
        queryParameters: queryParameters,
      );

      log('✅ [SearchService] 搜索城市响应: ${response.statusCode}');

      final data = response.data as Map<String, dynamic>;
      final result = SearchResult<CitySearchDocument>.fromJson(
        data['data'] ?? data,
        (json) => CitySearchDocument.fromJson(json as Map<String, dynamic>),
      );

      return Success(result);
    } on HttpException catch (e) {
      log('❌ 搜索城市失败: ${e.message}');
      return Failure(NetworkException(e.message));
    } catch (e) {
      log('❌ 搜索城市异常: $e');
      return Failure(UnknownException('搜索城市失败: ${e.toString()}'));
    }
  }

  /// 搜索共享办公空间
  Future<Result<SearchResult<CoworkingSearchDocument>>> searchCoworkings({
    String? query,
    int page = 1,
    int pageSize = 20,
    String? cityId,
    String? country,
    double? minRating,
    String? sortBy,
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'sortOrder': sortOrder,
      };

      if (query != null && query.isNotEmpty) {
        queryParameters['query'] = query;
      }
      if (cityId != null && cityId.isNotEmpty) {
        queryParameters['cityId'] = cityId;
      }
      if (country != null && country.isNotEmpty) {
        queryParameters['country'] = country;
      }
      if (minRating != null) {
        queryParameters['minRating'] = minRating;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParameters['sortBy'] = sortBy;
      }

      final response = await _httpService.get(
        '$_baseUrl/coworkings',
        queryParameters: queryParameters,
      );

      final data = response.data as Map<String, dynamic>;
      final result = SearchResult<CoworkingSearchDocument>.fromJson(
        data['data'] ?? data,
        (json) => CoworkingSearchDocument.fromJson(json as Map<String, dynamic>),
      );

      return Success(result);
    } on HttpException catch (e) {
      log('❌ 搜索共享办公空间失败: ${e.message}');
      return Failure(NetworkException(e.message));
    } catch (e) {
      log('❌ 搜索共享办公空间异常: $e');
      return Failure(UnknownException('搜索共享办公空间失败: ${e.toString()}'));
    }
  }

  /// 获取搜索建议
  Future<Result<SuggestResponse>> getSuggestions({
    required String prefix,
    String? type,
    int size = 10,
  }) async {
    try {
      if (prefix.isEmpty) {
        return Success(SuggestResponse(suggestions: []));
      }

      final queryParameters = <String, dynamic>{
        'prefix': prefix,
        'size': size,
      };

      if (type != null && type.isNotEmpty) {
        queryParameters['type'] = type;
      }

      final response = await _httpService.get(
        '$_baseUrl/suggest',
        queryParameters: queryParameters,
      );

      final data = response.data as Map<String, dynamic>;
      final result = SuggestResponse.fromJson(data['data'] ?? data);

      return Success(result);
    } on HttpException catch (e) {
      log('❌ 获取搜索建议失败: ${e.message}');
      return Failure(NetworkException(e.message));
    } catch (e) {
      log('❌ 获取搜索建议异常: $e');
      return Failure(UnknownException('获取搜索建议失败: ${e.toString()}'));
    }
  }
}

/// 统一搜索结果
class UnifiedSearchResult {
  final SearchResult<CitySearchDocument> cities;
  final SearchResult<CoworkingSearchDocument> coworkings;
  final int totalTook;
  final int totalCount;

  UnifiedSearchResult({
    required this.cities,
    required this.coworkings,
    required this.totalTook,
    required this.totalCount,
  });

  factory UnifiedSearchResult.fromJson(Map<String, dynamic> json) {
    return UnifiedSearchResult(
      cities: SearchResult<CitySearchDocument>.fromJson(
        json['cities'] ?? {'items': [], 'totalCount': 0},
        (j) => CitySearchDocument.fromJson(j as Map<String, dynamic>),
      ),
      coworkings: SearchResult<CoworkingSearchDocument>.fromJson(
        json['coworkings'] ?? {'items': [], 'totalCount': 0},
        (j) => CoworkingSearchDocument.fromJson(j as Map<String, dynamic>),
      ),
      totalTook: json['totalTook'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

/// 搜索结果
class SearchResult<T> {
  final List<SearchResultItem<T>> items;
  final int totalCount;
  final int took;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasMore;

  SearchResult({
    required this.items,
    required this.totalCount,
    this.took = 0,
    this.page = 1,
    this.pageSize = 20,
    this.totalPages = 0,
    this.hasMore = false,
  });

  factory SearchResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return SearchResult<T>(
      items: itemsList.map((item) {
        final itemMap = item as Map<String, dynamic>;
        return SearchResultItem<T>.fromJson(itemMap, fromJsonT);
      }).toList(),
      totalCount: json['totalCount'] ?? 0,
      took: json['took'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }
}

/// 搜索结果项
class SearchResultItem<T> {
  final T document;
  final double? score;
  final Map<String, List<String>>? highlights;

  SearchResultItem({
    required this.document,
    this.score,
    this.highlights,
  });

  factory SearchResultItem.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    Map<String, List<String>>? highlightsMap;
    if (json['highlights'] != null) {
      highlightsMap = (json['highlights'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as List<dynamic>).cast<String>()),
      );
    }

    return SearchResultItem<T>(
      document: fromJsonT(json['document']),
      score: (json['score'] as num?)?.toDouble(),
      highlights: highlightsMap,
    );
  }
}

/// 城市搜索文档
class CitySearchDocument {
  final String id;
  final String name;
  final String? nameEn;
  final String country;
  final String? countryId;
  final String? provinceId;
  final String? region;
  final String? description;
  final double? latitude;
  final double? longitude;
  final int? population;
  final String? climate;
  final String? timeZone;
  final String? currency;
  final String? imageUrl;
  final String? portraitImageUrl;
  final double? overallScore;
  final double? internetQualityScore;
  final double? safetyScore;
  final double? costScore;
  final double? communityScore;
  final double? weatherScore;
  final List<String> tags;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // 扩展字段 - 用于列表展示
  final double? averageCost;
  final int userCount;
  final String? moderatorId;
  final String? moderatorName;
  final int moderatorCount;
  final int coworkingCount;
  final int meetupCount;
  final int reviewCount;

  CitySearchDocument({
    required this.id,
    required this.name,
    this.nameEn,
    required this.country,
    this.countryId,
    this.provinceId,
    this.region,
    this.description,
    this.latitude,
    this.longitude,
    this.population,
    this.climate,
    this.timeZone,
    this.currency,
    this.imageUrl,
    this.portraitImageUrl,
    this.overallScore,
    this.internetQualityScore,
    this.safetyScore,
    this.costScore,
    this.communityScore,
    this.weatherScore,
    this.tags = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    // 扩展字段
    this.averageCost,
    this.userCount = 0,
    this.moderatorId,
    this.moderatorName,
    this.moderatorCount = 0,
    this.coworkingCount = 0,
    this.meetupCount = 0,
    this.reviewCount = 0,
  });

  factory CitySearchDocument.fromJson(Map<String, dynamic> json) {
    return CitySearchDocument(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      nameEn: json['nameEn'],
      country: json['country'] ?? '',
      countryId: json['countryId']?.toString(),
      provinceId: json['provinceId']?.toString(),
      region: json['region'],
      description: json['description'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      population: json['population'],
      climate: json['climate'],
      timeZone: json['timeZone'],
      currency: json['currency'],
      imageUrl: json['imageUrl'],
      portraitImageUrl: json['portraitImageUrl'],
      overallScore: (json['overallScore'] as num?)?.toDouble(),
      internetQualityScore: (json['internetQualityScore'] as num?)?.toDouble(),
      safetyScore: (json['safetyScore'] as num?)?.toDouble(),
      costScore: (json['costScore'] as num?)?.toDouble(),
      communityScore: (json['communityScore'] as num?)?.toDouble(),
      weatherScore: (json['weatherScore'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      // 扩展字段
      averageCost: (json['averageCost'] as num?)?.toDouble(),
      userCount: json['userCount'] ?? 0,
      moderatorId: json['moderatorId']?.toString(),
      moderatorName: json['moderatorName'],
      moderatorCount: json['moderatorCount'] ?? 0,
      coworkingCount: json['coworkingCount'] ?? 0,
      meetupCount: json['meetupCount'] ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}

/// 共享办公空间搜索文档
class CoworkingSearchDocument {
  final String id;
  final String name;
  final String? cityId;
  final String? cityName;
  final String? countryName;
  final String address;
  final String? description;
  final String? imageUrl;
  final double? pricePerDay;
  final double? pricePerMonth;
  final double? pricePerHour;
  final String currency;
  final double rating;
  final int reviewCount;
  final double? wifiSpeed;
  final int? desks;
  final int? meetingRooms;
  final bool hasMeetingRoom;
  final bool hasCoffee;
  final bool hasParking;
  final bool has247Access;
  final List<String>? amenities;
  final int? capacity;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? website;
  final String? openingHours;
  final bool isActive;
  final String verificationStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CoworkingSearchDocument({
    required this.id,
    required this.name,
    this.cityId,
    this.cityName,
    this.countryName,
    required this.address,
    this.description,
    this.imageUrl,
    this.pricePerDay,
    this.pricePerMonth,
    this.pricePerHour,
    this.currency = 'USD',
    this.rating = 0,
    this.reviewCount = 0,
    this.wifiSpeed,
    this.desks,
    this.meetingRooms,
    this.hasMeetingRoom = false,
    this.hasCoffee = false,
    this.hasParking = false,
    this.has247Access = false,
    this.amenities,
    this.capacity,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.openingHours,
    this.isActive = true,
    this.verificationStatus = 'unverified',
    this.createdAt,
    this.updatedAt,
  });

  factory CoworkingSearchDocument.fromJson(Map<String, dynamic> json) {
    return CoworkingSearchDocument(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      cityId: json['cityId']?.toString(),
      cityName: json['cityName'],
      countryName: json['countryName'],
      address: json['address'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble(),
      pricePerMonth: (json['pricePerMonth'] as num?)?.toDouble(),
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble(),
      currency: json['currency'] ?? 'USD',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      wifiSpeed: (json['wifiSpeed'] as num?)?.toDouble(),
      desks: json['desks'],
      meetingRooms: json['meetingRooms'],
      hasMeetingRoom: json['hasMeetingRoom'] ?? false,
      hasCoffee: json['hasCoffee'] ?? false,
      hasParking: json['hasParking'] ?? false,
      has247Access: json['has247Access'] ?? false,
      amenities: (json['amenities'] as List<dynamic>?)?.cast<String>(),
      capacity: json['capacity'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      openingHours: json['openingHours'],
      isActive: json['isActive'] ?? true,
      verificationStatus: json['verificationStatus'] ?? 'unverified',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

/// 搜索建议响应
class SuggestResponse {
  final List<SuggestItem> suggestions;

  SuggestResponse({required this.suggestions});

  factory SuggestResponse.fromJson(Map<String, dynamic> json) {
    return SuggestResponse(
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((item) => SuggestItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 搜索建议项
class SuggestItem {
  final String text;
  final String id;
  final String type;
  final double score;
  final Map<String, dynamic>? metadata;

  SuggestItem({
    required this.text,
    required this.id,
    required this.type,
    this.score = 0,
    this.metadata,
  });

  factory SuggestItem.fromJson(Map<String, dynamic> json) {
    return SuggestItem(
      text: json['text'] ?? '',
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      metadata: json['metadata'],
    );
  }
}
