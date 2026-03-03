import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/hotel/domain/entities/hotel.dart';
import 'package:go_nomads_app/features/hotel/infrastructure/repositories/hotel_repository.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:get/get.dart';

/// RoomTypeListPage 控制器
class RoomTypeListPageController extends GetxController {
  final String hotelId;
  final String hotelName;

  RoomTypeListPageController({
    required this.hotelId,
    required this.hotelName,
  });

  final RxBool isLoading = false.obs;
  final RxList<RoomType> roomTypes = <RoomType>[].obs;

  final HotelRepository _hotelRepository = HotelRepository(HttpService());

  @override
  void onInit() {
    super.onInit();
    loadRoomTypes();
  }

  // 加载房型数据
  Future<void> loadRoomTypes() async {
    isLoading.value = true;
    try {
      final result = await _hotelRepository.getRoomTypes(hotelId);

      result.fold(
        onSuccess: (types) {
          roomTypes.value = types;
        },
        onFailure: (exception) {
          AppToast.error('加载房型失败: ${exception.message}');
        },
      );
    } catch (e) {
      AppToast.error('加载房型失败: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
