import 'dart:developer';

import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/hotel/domain/entities/hotel.dart';
import 'package:go_nomads_app/features/hotel/domain/repositories/i_hotel_repository.dart';
import 'package:go_nomads_app/features/hotel/infrastructure/models/hotel_dto.dart';
import 'package:go_nomads_app/services/http_service.dart';

/// Hotel Repository - 酒店数据仓储
/// 对接后端 AccommodationService API
class HotelRepository implements IHotelRepository {
  final HttpService _httpService;
  final Map<String, Hotel> _hotelCache = <String, Hotel>{};
  String _lastExternalDataStatus = 'not_requested';
  bool _lastPartialExternalData = false;
  String? _lastExternalDataMessage;

  /// API 基础路径（通过 Gateway 路由到 AccommodationService）
  static const String _basePath = '/hotels';

  HotelRepository(this._httpService);

  String get lastExternalDataStatus => _lastExternalDataStatus;
  bool get lastPartialExternalData => _lastPartialExternalData;
  String? get lastExternalDataMessage => _lastExternalDataMessage;

  Future<Result<List<Hotel>>> getHotelsForDiscovery({
    String? cityId,
    String? cityName,
    String? countryName,
    double? latitude,
    double? longitude,
    DateTime? checkInDate,
    int? stayNights,
    int? adultCount,
    int? roomCount,
    String? search,
  }) async {
    final result = await getHotels(
      cityId: cityId,
      cityName: cityName,
      countryName: countryName,
      latitude: latitude,
      longitude: longitude,
      checkInDate: checkInDate,
      stayNights: stayNights,
      adultCount: adultCount,
      roomCount: roomCount,
      search: search,
    );

    result.onSuccess((hotels) {
      for (final hotel in hotels) {
        _hotelCache[hotel.id] = hotel;
      }
    });

    if (result is Success<List<Hotel>>) {
      log('🏨 [HotelRepository] 服务端返回 ${result.data.length} 个酒店');
    }

    return result;
  }

  @override
  Future<Result<List<Hotel>>> getHotels({
    int page = 1,
    int pageSize = 20,
    String? cityId,
    String? cityName,
    String? countryName,
    double? latitude,
    double? longitude,
    DateTime? checkInDate,
    int? stayNights,
    int? adultCount,
    int? roomCount,
    String? search,
    bool? hasWifi,
    bool? hasCoworkingSpace,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      // 构建查询参数
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (cityId != null) queryParams['cityId'] = cityId;
      if (cityName != null && cityName.isNotEmpty) {
        queryParams['cityName'] = cityName;
      }
      if (countryName != null && countryName.isNotEmpty) {
        queryParams['countryName'] = countryName;
      }
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (checkInDate != null) {
        queryParams['checkInDate'] = _formatDate(checkInDate);
      }
      if (stayNights != null) queryParams['stayNights'] = stayNights.toString();
      if (adultCount != null) queryParams['adultCount'] = adultCount.toString();
      if (roomCount != null) queryParams['roomCount'] = roomCount.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (hasWifi != null) queryParams['hasWifi'] = hasWifi.toString();
      if (hasCoworkingSpace != null) {
        queryParams['hasCoworkingSpace'] = hasCoworkingSpace.toString();
      }
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();

      final queryString = queryParams.entries
          .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      final url = queryString.isNotEmpty ? '$_basePath?$queryString' : _basePath;

      log('🏨 HotelRepository.getHotels: $url');

      final response = await _httpService.get(url);
      final externalDataStatus = response.data['externalDataStatus']?.toString();
      final partialExternalData = response.data['partialExternalData'] == true;
      final externalDataMessage = response.data['externalDataMessage']?.toString();

      _lastExternalDataStatus = externalDataStatus?.isNotEmpty == true ? externalDataStatus! : 'not_requested';
      _lastPartialExternalData = partialExternalData;
      _lastExternalDataMessage = externalDataMessage;

      // 后端返回 { hotels: [...], totalCount, page, pageSize, totalPages }
      final List<dynamic> hotelsData = response.data['hotels'] ?? [];
      final hotels = hotelsData.map((json) => HotelDto.fromMap(json).toDomain()).toList();

      if (externalDataStatus != null && externalDataStatus.isNotEmpty) {
        log('🏨 [HotelRepository] 外部酒店状态: $externalDataStatus, partial=$partialExternalData');
      }
      if (externalDataMessage != null && externalDataMessage.isNotEmpty) {
        log('🏨 [HotelRepository] 外部酒店说明: $externalDataMessage');
      }

      for (final hotel in hotels) {
        _hotelCache[hotel.id] = hotel;
      }

      log('🏨 获取到 ${hotels.length} 个酒店');
      return Success(hotels);
    } on HttpException catch (e) {
      _lastExternalDataStatus = 'unavailable';
      _lastPartialExternalData = false;
      _lastExternalDataMessage = null;
      log('❌ HotelRepository.getHotels 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      _lastExternalDataStatus = 'unavailable';
      _lastPartialExternalData = false;
      _lastExternalDataMessage = null;
      log('❌ HotelRepository.getHotels 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Future<Result<Hotel>> getHotelById(String id) async {
    try {
      final cachedHotel = _hotelCache[id];
      if (cachedHotel != null) {
        return Success(cachedHotel);
      }

      log('🏨 HotelRepository.getHotelById: $id');
      final response = await _httpService.get('$_basePath/$id');
      final hotel = HotelDto.fromMap(response.data).toDomain();
      _hotelCache[hotel.id] = hotel;
      return Success(hotel);
    } on HttpException catch (e) {
      log('❌ HotelRepository.getHotelById 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelRepository.getHotelById 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<List<Hotel>>> getHotelsByCity(String cityId) async {
    try {
      log('🏨 HotelRepository.getHotelsByCity: $cityId');
      final response = await _httpService.get('$_basePath/city/$cityId');

      // 后端直接返回数组 List<HotelDto>
      final List<dynamic> hotelsData = response.data is List ? response.data : [];
      final hotels = hotelsData.map((json) => HotelDto.fromMap(json).toDomain()).toList();

      log('🏨 城市 $cityId 有 ${hotels.length} 个酒店');
      return Success(hotels);
    } on HttpException catch (e) {
      log('❌ HotelRepository.getHotelsByCity 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelRepository.getHotelsByCity 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<List<Hotel>>> searchHotels(String query) async {
    try {
      log('🏨 HotelRepository.searchHotels: $query');
      final response = await _httpService.get('$_basePath?search=$query');

      final List<dynamic> hotelsData = response.data['hotels'] ?? [];
      final hotels = hotelsData.map((json) => HotelDto.fromMap(json).toDomain()).toList();

      return Success(hotels);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<Hotel>> createHotel(Map<String, dynamic> data) async {
    try {
      log('🏨 HotelRepository.createHotel: $data');
      final response = await _httpService.post(_basePath, data: data);
      final hotel = HotelDto.fromMap(response.data).toDomain();
      log('✅ 酒店创建成功: ${hotel.id}');
      return Success(hotel);
    } on HttpException catch (e) {
      log('❌ HotelRepository.createHotel 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelRepository.createHotel 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<Hotel>> updateHotel(String id, Map<String, dynamic> data) async {
    try {
      log('🏨 HotelRepository.updateHotel: $id');
      final response = await _httpService.put('$_basePath/$id', data: data);
      final hotel = HotelDto.fromMap(response.data).toDomain();
      log('✅ 酒店更新成功: ${hotel.id}');
      return Success(hotel);
    } on HttpException catch (e) {
      log('❌ HotelRepository.updateHotel 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelRepository.updateHotel 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteHotel(String id) async {
    try {
      log('🏨 HotelRepository.deleteHotel: $id');
      await _httpService.delete('$_basePath/$id');
      log('✅ 酒店删除成功: $id');
      return const Success(null);
    } on HttpException catch (e) {
      log('❌ HotelRepository.deleteHotel 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelRepository.deleteHotel 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  /// 获取当前用户创建的酒店列表
  Future<Result<List<Hotel>>> getMyHotels() async {
    try {
      log('🏨 HotelRepository.getMyHotels');
      final response = await _httpService.get('$_basePath/my');

      final List<dynamic> hotelsData = response.data is List ? response.data : (response.data['hotels'] ?? []);
      final hotels = hotelsData.map((json) => HotelDto.fromMap(json).toDomain()).toList();

      log('🏨 我的酒店: ${hotels.length} 个');
      return Success(hotels);
    } on HttpException catch (e) {
      log('❌ HotelRepository.getMyHotels 失败: ${e.message}');
      return Failure(_convertHttpException(e));
    } catch (e) {
      log('❌ HotelRepository.getMyHotels 异常: $e');
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<List<Hotel>>> getFeaturedHotels() async {
    try {
      // 暂时使用普通列表，后端可以添加 featured 过滤
      return getHotels();
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<List<Hotel>>> getHotelsByCategory(String category) async {
    try {
      // 暂时使用普通列表，后端可以添加 category 过滤
      return getHotels();
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<List<RoomType>>> getRoomTypes(String hotelId) async {
    try {
      final response = await _httpService.get('$_basePath/$hotelId/rooms');
      final List<dynamic> data = response.data;
      final rooms = data.map((json) => RoomTypeDto.fromMap(json).toDomain()).toList();
      return Success(rooms);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<HotelBooking>> createBooking(Map<String, dynamic> data) async {
    try {
      final response = await _httpService.post('/hotel-bookings', data: data);
      final booking = HotelBookingDto.fromMap(response.data).toDomain();
      return Success(booking);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<List<HotelBooking>>> getUserBookings(String userId) async {
    try {
      final response = await _httpService.get('/hotel-bookings/user/$userId');
      final List<dynamic> data = response.data;
      final bookings = data.map((json) => HotelBookingDto.fromMap(json).toDomain()).toList();
      return Success(bookings);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<void>> cancelBooking(String bookingId) async {
    try {
      await _httpService.put('/hotel-bookings/$bookingId/cancel', data: {});
      return const Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  DomainException _convertHttpException(HttpException e) {
    if (e.statusCode == null) {
      return NetworkException(e.message);
    }

    switch (e.statusCode!) {
      case 400:
        return ValidationException(e.message, details: e.errors);
      case 401:
      case 403:
        return UnauthorizedException(e.message);
      case 404:
        return NotFoundException(e.message);
      case >= 500:
        return ServerException(e.message);
      default:
        return NetworkException(e.message, code: e.statusCode.toString());
    }
  }
}
