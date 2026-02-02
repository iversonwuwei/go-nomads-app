import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/hotel/domain/entities/hotel.dart';
import 'package:go_nomads_app/features/hotel/domain/repositories/i_hotel_repository.dart';

// ==================== Use Cases ====================

/// 获取酒店列表
class GetHotelsUseCase {
  final IHotelRepository _repository;

  GetHotelsUseCase(this._repository);

  Future<Result<List<Hotel>>> call() => _repository.getHotels();
}

/// 根据ID获取酒店详情
class GetHotelByIdUseCase {
  final IHotelRepository _repository;

  GetHotelByIdUseCase(this._repository);

  Future<Result<Hotel>> call(GetHotelByIdParams params) =>
      _repository.getHotelById(params.id);
}

class GetHotelByIdParams {
  final String id;

  GetHotelByIdParams(this.id);
}

/// 根据城市ID获取酒店
class GetHotelsByCityUseCase {
  final IHotelRepository _repository;

  GetHotelsByCityUseCase(this._repository);

  Future<Result<List<Hotel>>> call(GetHotelsByCityParams params) =>
      _repository.getHotelsByCity(params.cityId);
}

class GetHotelsByCityParams {
  final String cityId;

  GetHotelsByCityParams(this.cityId);
}

/// 搜索酒店
class SearchHotelsUseCase {
  final IHotelRepository _repository;

  SearchHotelsUseCase(this._repository);

  Future<Result<List<Hotel>>> call(SearchHotelsParams params) =>
      _repository.searchHotels(params.query);
}

class SearchHotelsParams {
  final String query;

  SearchHotelsParams(this.query);
}

/// 创建酒店
class CreateHotelUseCase {
  final IHotelRepository _repository;

  CreateHotelUseCase(this._repository);

  Future<Result<Hotel>> call(CreateHotelParams params) =>
      _repository.createHotel(params.data);
}

class CreateHotelParams {
  final Map<String, dynamic> data;

  CreateHotelParams(this.data);
}

/// 更新酒店
class UpdateHotelUseCase {
  final IHotelRepository _repository;

  UpdateHotelUseCase(this._repository);

  Future<Result<Hotel>> call(UpdateHotelParams params) =>
      _repository.updateHotel(params.id, params.data);
}

class UpdateHotelParams {
  final String id;
  final Map<String, dynamic> data;

  UpdateHotelParams(this.id, this.data);
}

/// 删除酒店
class DeleteHotelUseCase {
  final IHotelRepository _repository;

  DeleteHotelUseCase(this._repository);

  Future<Result<void>> call(DeleteHotelParams params) =>
      _repository.deleteHotel(params.id);
}

class DeleteHotelParams {
  final String id;

  DeleteHotelParams(this.id);
}

/// 获取精选酒店
class GetFeaturedHotelsUseCase {
  final IHotelRepository _repository;

  GetFeaturedHotelsUseCase(this._repository);

  Future<Result<List<Hotel>>> call() => _repository.getFeaturedHotels();
}

/// 根据分类获取酒店
class GetHotelsByCategoryUseCase {
  final IHotelRepository _repository;

  GetHotelsByCategoryUseCase(this._repository);

  Future<Result<List<Hotel>>> call(GetHotelsByCategoryParams params) =>
      _repository.getHotelsByCategory(params.category);
}

class GetHotelsByCategoryParams {
  final String category;

  GetHotelsByCategoryParams(this.category);
}

/// 获取酒店的房型列表
class GetRoomTypesUseCase {
  final IHotelRepository _repository;

  GetRoomTypesUseCase(this._repository);

  Future<Result<List<RoomType>>> call(GetRoomTypesParams params) =>
      _repository.getRoomTypes(params.hotelId);
}

class GetRoomTypesParams {
  final String hotelId;

  GetRoomTypesParams(this.hotelId);
}

/// 创建预订
class CreateBookingUseCase {
  final IHotelRepository _repository;

  CreateBookingUseCase(this._repository);

  Future<Result<HotelBooking>> call(CreateBookingParams params) =>
      _repository.createBooking(params.data);
}

class CreateBookingParams {
  final Map<String, dynamic> data;

  CreateBookingParams(this.data);
}

/// 获取用户的预订列表
class GetUserBookingsUseCase {
  final IHotelRepository _repository;

  GetUserBookingsUseCase(this._repository);

  Future<Result<List<HotelBooking>>> call(GetUserBookingsParams params) =>
      _repository.getUserBookings(params.userId);
}

class GetUserBookingsParams {
  final String userId;

  GetUserBookingsParams(this.userId);
}

/// 取消预订
class CancelBookingUseCase {
  final IHotelRepository _repository;

  CancelBookingUseCase(this._repository);

  Future<Result<void>> call(CancelBookingParams params) =>
      _repository.cancelBooking(params.bookingId);
}

class CancelBookingParams {
  final String bookingId;

  CancelBookingParams(this.bookingId);
}
