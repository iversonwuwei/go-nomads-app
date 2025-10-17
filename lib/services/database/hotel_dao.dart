import 'package:sqflite/sqflite.dart';

import '../database_service.dart';

/// 酒店数据访问对象
class HotelDao {
  final DatabaseService _dbService = DatabaseService();

  /// 插入酒店
  Future<int> insertHotel(Map<String, dynamic> hotel) async {
    final db = await _dbService.database;
    hotel['created_at'] = DateTime.now().toIso8601String();
    hotel['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('hotels', hotel,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 插入房型
  Future<int> insertRoomType(Map<String, dynamic> roomType) async {
    final db = await _dbService.database;
    roomType['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('room_types', roomType,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 插入预订
  Future<int> insertBooking(Map<String, dynamic> booking) async {
    final db = await _dbService.database;
    booking['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('hotel_bookings', booking,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 根据ID查询酒店
  Future<Map<String, dynamic>?> getHotelById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT h.*, c.name as city_name
      FROM hotels h
      LEFT JOIN cities c ON h.city_id = c.id
      WHERE h.id = ?
      LIMIT 1
    ''', [id]);
    return maps.isNotEmpty ? maps.first : null;
  }

  /// 获取酒店的所有房型
  Future<List<Map<String, dynamic>>> getRoomTypesByHotelId(int hotelId) async {
    final db = await _dbService.database;
    return await db.query(
      'room_types',
      where: 'hotel_id = ? AND is_available = 1',
      whereArgs: [hotelId],
      orderBy: 'price_per_night ASC',
    );
  }

  /// 根据城市ID查询酒店
  Future<List<Map<String, dynamic>>> getHotelsByCity(int cityId) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT h.*, c.name as city_name
      FROM hotels h
      LEFT JOIN cities c ON h.city_id = c.id
      WHERE h.city_id = ?
      ORDER BY h.is_featured DESC, h.rating DESC
    ''', [cityId]);
  }

  /// 根据城市名称查询酒店
  Future<List<Map<String, dynamic>>> getHotelsByCityName(
      String cityName) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT h.*, c.name as city_name
      FROM hotels h
      LEFT JOIN cities c ON h.city_id = c.id
      WHERE c.name = ?
      ORDER BY h.is_featured DESC, h.rating DESC
    ''', [cityName]);
  }

  /// 获取所有酒店
  Future<List<Map<String, dynamic>>> getAllHotels() async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT h.*, c.name as city_name
      FROM hotels h
      LEFT JOIN cities c ON h.city_id = c.id
      ORDER BY h.is_featured DESC, h.rating DESC
    ''');
  }

  /// 根据分类获取酒店
  Future<List<Map<String, dynamic>>> getHotelsByCategory(
      String category) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT h.*, c.name as city_name
      FROM hotels h
      LEFT JOIN cities c ON h.city_id = c.id
      WHERE h.category = ?
      ORDER BY h.rating DESC
    ''', [category]);
  }

  /// 搜索酒店
  Future<List<Map<String, dynamic>>> searchHotels(String keyword) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT h.*, c.name as city_name
      FROM hotels h
      LEFT JOIN cities c ON h.city_id = c.id
      WHERE h.name LIKE ? OR h.address LIKE ? OR c.name LIKE ?
      ORDER BY h.rating DESC
    ''', ['%$keyword%', '%$keyword%', '%$keyword%']);
  }

  /// 获取特色酒店
  Future<List<Map<String, dynamic>>> getFeaturedHotels() async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT h.*, c.name as city_name
      FROM hotels h
      LEFT JOIN cities c ON h.city_id = c.id
      WHERE h.is_featured = 1
      ORDER BY h.rating DESC
      LIMIT 10
    ''');
  }

  /// 更新酒店信息
  Future<int> updateHotel(int id, Map<String, dynamic> hotel) async {
    final db = await _dbService.database;
    hotel['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'hotels',
      hotel,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 更新房型信息
  Future<int> updateRoomType(int id, Map<String, dynamic> roomType) async {
    final db = await _dbService.database;
    return await db.update(
      'room_types',
      roomType,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 更新预订状态
  Future<int> updateBookingStatus(int id, String status) async {
    final db = await _dbService.database;
    return await db.update(
      'hotel_bookings',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除酒店
  Future<int> deleteHotel(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'hotels',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取用户的预订记录
  Future<List<Map<String, dynamic>>> getUserBookings(int userId) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT 
        b.*,
        h.name as hotel_name,
        h.address as hotel_address,
        h.images as hotel_images,
        r.name as room_type_name
      FROM hotel_bookings b
      LEFT JOIN hotels h ON b.hotel_id = h.id
      LEFT JOIN room_types r ON b.room_type_id = r.id
      WHERE b.user_id = ?
      ORDER BY b.created_at DESC
    ''', [userId]);
  }

  /// 检查房间可用性
  Future<bool> checkRoomAvailability(
    int roomTypeId,
    DateTime checkIn,
    DateTime checkOut,
    int numberOfRooms,
  ) async {
    final db = await _dbService.database;

    // 获取房型的总房间数
    final roomType = await db.query(
      'room_types',
      columns: ['available_rooms'],
      where: 'id = ?',
      whereArgs: [roomTypeId],
      limit: 1,
    );

    if (roomType.isEmpty) return false;
    final totalRooms = roomType.first['available_rooms'] as int;

    // 查询该时间段内已预订的房间数
    final bookings = await db.rawQuery('''
      SELECT SUM(number_of_rooms) as booked_rooms
      FROM hotel_bookings
      WHERE room_type_id = ?
      AND status IN ('confirmed', 'pending')
      AND (
        (check_in_date >= ? AND check_in_date < ?)
        OR (check_out_date > ? AND check_out_date <= ?)
        OR (check_in_date <= ? AND check_out_date >= ?)
      )
    ''', [
      roomTypeId,
      checkIn.toIso8601String(),
      checkOut.toIso8601String(),
      checkIn.toIso8601String(),
      checkOut.toIso8601String(),
      checkIn.toIso8601String(),
      checkOut.toIso8601String(),
    ]);

    final bookedRooms = (bookings.first['booked_rooms'] as int?) ?? 0;
    final availableRooms = totalRooms - bookedRooms;

    return availableRooms >= numberOfRooms;
  }
}
