import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/services/http_service.dart';

import '../../domain/entities/hotel.dart';
import '../../domain/repositories/i_hotel_repository.dart';
import '../models/hotel_dto.dart';

class HotelRepository implements IHotelRepository {
  final HttpService _httpService;

  HotelRepository(this._httpService);

  @override
  Future<Result<List<Hotel>>> getHotels() async {
    try {
      final response = await _httpService.get('/hotels');
      final List<dynamic> data = response.data;
      final hotels =
          data.map((json) => HotelDto.fromMap(json).toDomain()).toList();
      return Success(hotels);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<Hotel>> getHotelById(String id) async {
    try {
      final response = await _httpService.get('/hotels/$id');
      final hotel = HotelDto.fromMap(response.data).toDomain();
      return Success(hotel);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<List<Hotel>>> getHotelsByCity(String cityId) async {
    try {
      final response = await _httpService.get('/hotels/city/$cityId');
      final List<dynamic> data = response.data;
      final hotels =
          data.map((json) => HotelDto.fromMap(json).toDomain()).toList();
      return Success(hotels);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<List<Hotel>>> searchHotels(String query) async {
    try {
      final response = await _httpService.get('/hotels/search?q=$query');
      final List<dynamic> data = response.data;
      final hotels =
          data.map((json) => HotelDto.fromMap(json).toDomain()).toList();
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
      final response = await _httpService.post('/hotels', data: data);
      final hotel = HotelDto.fromMap(response.data).toDomain();
      return Success(hotel);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<Hotel>> updateHotel(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _httpService.put('/hotels/$id', data: data);
      final hotel = HotelDto.fromMap(response.data).toDomain();
      return Success(hotel);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteHotel(String id) async {
    try {
      await _httpService.delete('/hotels/$id');
      return const Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<List<Hotel>>> getFeaturedHotels() async {
    try {
      final response = await _httpService.get('/hotels/featured');
      final List<dynamic> data = response.data;
      final hotels =
          data.map((json) => HotelDto.fromMap(json).toDomain()).toList();
      return Success(hotels);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<List<Hotel>>> getHotelsByCategory(String category) async {
    try {
      final response = await _httpService.get('/hotels/category/$category');
      final List<dynamic> data = response.data;
      final hotels =
          data.map((json) => HotelDto.fromMap(json).toDomain()).toList();
      return Success(hotels);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<List<RoomType>>> getRoomTypes(String hotelId) async {
    try {
      final response = await _httpService.get('/hotels/$hotelId/rooms');
      final List<dynamic> data = response.data;
      final rooms =
          data.map((json) => RoomTypeDto.fromMap(json).toDomain()).toList();
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
      final bookings =
          data.map((json) => HotelBookingDto.fromMap(json).toDomain()).toList();
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
