import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/hotel/domain/entities/hotel.dart';

/// Hotel Repository Interface
abstract class IHotelRepository {
  /// 获取酒店列表
  Future<Result<List<Hotel>>> getHotels();

  /// 根据ID获取酒店详情
  Future<Result<Hotel>> getHotelById(String id);

  /// 根据城市ID获取酒店
  Future<Result<List<Hotel>>> getHotelsByCity(String cityId);

  /// 搜索酒店
  Future<Result<List<Hotel>>> searchHotels(String query);

  /// 创建酒店
  Future<Result<Hotel>> createHotel(Map<String, dynamic> data);

  /// 更新酒店
  Future<Result<Hotel>> updateHotel(String id, Map<String, dynamic> data);

  /// 删除酒店
  Future<Result<void>> deleteHotel(String id);

  /// 获取精选酒店
  Future<Result<List<Hotel>>> getFeaturedHotels();

  /// 根据分类获取酒店
  Future<Result<List<Hotel>>> getHotelsByCategory(String category);

  /// 获取酒店的房型列表
  Future<Result<List<RoomType>>> getRoomTypes(String hotelId);

  /// 创建预订
  Future<Result<HotelBooking>> createBooking(Map<String, dynamic> data);

  /// 获取用户的预订列表
  Future<Result<List<HotelBooking>>> getUserBookings(String userId);

  /// 取消预订
  Future<Result<void>> cancelBooking(String bookingId);
}
