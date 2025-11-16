import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:get/get.dart';

import '../../application/use_cases/hotel_use_cases.dart';
import '../../domain/entities/hotel.dart';

/// Hotel State Controller
/// 使用 GetX 进行响应式状态管理
class HotelStateController extends GetxController {
  // Use Cases
  final GetHotelsUseCase _getHotelsUseCase;
  final GetHotelByIdUseCase _getHotelByIdUseCase;
  final GetHotelsByCityUseCase _getHotelsByCityUseCase;
  final SearchHotelsUseCase _searchHotelsUseCase;
  final CreateHotelUseCase _createHotelUseCase;
  final UpdateHotelUseCase _updateHotelUseCase;
  final DeleteHotelUseCase _deleteHotelUseCase;
  final GetFeaturedHotelsUseCase _getFeaturedHotelsUseCase;
  final GetHotelsByCategoryUseCase _getHotelsByCategoryUseCase;
  final GetRoomTypesUseCase _getRoomTypesUseCase;
  final CreateBookingUseCase _createBookingUseCase;
  final GetUserBookingsUseCase _getUserBookingsUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;

  HotelStateController({
    required GetHotelsUseCase getHotelsUseCase,
    required GetHotelByIdUseCase getHotelByIdUseCase,
    required GetHotelsByCityUseCase getHotelsByCityUseCase,
    required SearchHotelsUseCase searchHotelsUseCase,
    required CreateHotelUseCase createHotelUseCase,
    required UpdateHotelUseCase updateHotelUseCase,
    required DeleteHotelUseCase deleteHotelUseCase,
    required GetFeaturedHotelsUseCase getFeaturedHotelsUseCase,
    required GetHotelsByCategoryUseCase getHotelsByCategoryUseCase,
    required GetRoomTypesUseCase getRoomTypesUseCase,
    required CreateBookingUseCase createBookingUseCase,
    required GetUserBookingsUseCase getUserBookingsUseCase,
    required CancelBookingUseCase cancelBookingUseCase,
  })  : _getHotelsUseCase = getHotelsUseCase,
        _getHotelByIdUseCase = getHotelByIdUseCase,
        _getHotelsByCityUseCase = getHotelsByCityUseCase,
        _searchHotelsUseCase = searchHotelsUseCase,
        _createHotelUseCase = createHotelUseCase,
        _updateHotelUseCase = updateHotelUseCase,
        _deleteHotelUseCase = deleteHotelUseCase,
        _getFeaturedHotelsUseCase = getFeaturedHotelsUseCase,
        _getHotelsByCategoryUseCase = getHotelsByCategoryUseCase,
        _getRoomTypesUseCase = getRoomTypesUseCase,
        _createBookingUseCase = createBookingUseCase,
        _getUserBookingsUseCase = getUserBookingsUseCase,
        _cancelBookingUseCase = cancelBookingUseCase;

  // State
  final hotels = <Hotel>[].obs;
  final currentHotel = Rx<Hotel?>(null);
  final roomTypes = <RoomType>[].obs;
  final bookings = <HotelBooking>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  // ==================== Public Methods ====================

  /// 获取酒店列表
  Future<void> getHotels() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getHotelsUseCase();
    result.fold(
      onSuccess: (hotels) {
        this.hotels.value = hotels;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 根据ID获取酒店详情
  Future<void> getHotelById(String id) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getHotelByIdUseCase(GetHotelByIdParams(id));
    result.fold(
      onSuccess: (hotel) {
        currentHotel.value = hotel;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 根据城市ID获取酒店
  Future<void> getHotelsByCity(String cityId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getHotelsByCityUseCase(GetHotelsByCityParams(cityId));
    result.fold(
      onSuccess: (hotels) {
        this.hotels.value = hotels;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 搜索酒店
  Future<void> searchHotels(String query) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _searchHotelsUseCase(SearchHotelsParams(query));
    result.fold(
      onSuccess: (hotels) {
        this.hotels.value = hotels;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 创建酒店
  Future<bool> createHotel(Map<String, dynamic> data) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _createHotelUseCase(CreateHotelParams(data));
    return result.fold<bool>(
      onSuccess: (hotel) {
        hotels.add(hotel);
        isLoading.value = false;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
        return false;
      },
    );
  }

  /// 更新酒店
  Future<bool> updateHotel(String id, Map<String, dynamic> data) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _updateHotelUseCase(UpdateHotelParams(id, data));
    return result.fold<bool>(
      onSuccess: (hotel) {
        final index = hotels.indexWhere((h) => h.id == id);
        if (index != -1) {
          hotels[index] = hotel;
        }
        if (currentHotel.value?.id == id) {
          currentHotel.value = hotel;
        }
        isLoading.value = false;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
        return false;
      },
    );
  }

  /// 删除酒店
  Future<bool> deleteHotel(String id) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _deleteHotelUseCase(DeleteHotelParams(id));
    return result.fold<bool>(
      onSuccess: (_) {
        hotels.removeWhere((h) => h.id == id);
        if (currentHotel.value?.id == id) {
          currentHotel.value = null;
        }
        isLoading.value = false;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
        return false;
      },
    );
  }

  /// 获取精选酒店
  Future<void> getFeaturedHotels() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getFeaturedHotelsUseCase();
    result.fold(
      onSuccess: (hotels) {
        this.hotels.value = hotels;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 根据分类获取酒店
  Future<void> getHotelsByCategory(String category) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result =
        await _getHotelsByCategoryUseCase(GetHotelsByCategoryParams(category));
    result.fold(
      onSuccess: (hotels) {
        this.hotels.value = hotels;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 获取酒店的房型列表
  Future<void> getRoomTypes(String hotelId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getRoomTypesUseCase(GetRoomTypesParams(hotelId));
    result.fold(
      onSuccess: (rooms) {
        roomTypes.value = rooms;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 创建预订
  Future<bool> createBooking(Map<String, dynamic> data) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _createBookingUseCase(CreateBookingParams(data));
    return result.fold<bool>(
      onSuccess: (booking) {
        bookings.add(booking);
        isLoading.value = false;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
        return false;
      },
    );
  }

  /// 获取用户的预订列表
  Future<void> getUserBookings(String userId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getUserBookingsUseCase(GetUserBookingsParams(userId));
    result.fold(
      onSuccess: (bookings) {
        this.bookings.value = bookings;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 取消预订
  Future<bool> cancelBooking(String bookingId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _cancelBookingUseCase(CancelBookingParams(bookingId));
    return result.fold<bool>(
      onSuccess: (_) {
        bookings.removeWhere((b) => b.id == bookingId);
        isLoading.value = false;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
        return false;
      },
    );
  }

  @override
  void onClose() {
    // 清空所有响应式变量
    hotels.clear();
    currentHotel.value = null;
    roomTypes.clear();
    bookings.clear();
    
    // 重置加载状态
    isLoading.value = false;
    errorMessage.value = null;
    
    super.onClose();
  }
}
