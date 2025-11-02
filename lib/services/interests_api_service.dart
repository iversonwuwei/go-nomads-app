import '../models/interest_model.dart';
import 'http_service.dart';

/// 兴趣爱好 API 服务
class InterestsApiService {
  final HttpService _httpService = HttpService();

  /// 获取所有兴趣
  Future<List<Interest>> getAllInterests() async {
    try {
      final response = await _httpService.get('/interests');
      
      // HttpService 已经解包了 ApiResponse，response.data 直接是数据数组
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List;
        return data.map((json) => Interest.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw Exception('Failed to get interests');
    } catch (e) {
      print('❌ Error getting interests: $e');
      rethrow;
    }
  }

  /// 获取按类别分组的兴趣
  Future<List<InterestsByCategory>> getInterestsByCategory() async {
    try {
      final response = await _httpService.get('/interests/by-category');
      
      // HttpService 已经解包了 ApiResponse，response.data 直接是数据数组
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List;
        return data.map((json) => InterestsByCategory.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw Exception('Failed to get interests by category');
    } catch (e) {
      print('❌ Error getting interests by category: $e');
      rethrow;
    }
  }

  /// 根据类别获取兴趣
  Future<List<Interest>> getInterestsBySpecificCategory(String category) async {
    try {
      final response = await _httpService.get('/interests/category/$category');
      
      // HttpService 已经解包了 ApiResponse，response.data 直接是数据数组
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List;
        return data.map((json) => Interest.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw Exception('Failed to get interests for category');
    } catch (e) {
      print('❌ Error getting interests for category $category: $e');
      rethrow;
    }
  }

  /// 获取单个兴趣详情
  Future<Interest> getInterest(String id) async {
    try {
      final response = await _httpService.get('/interests/$id');
      
      // HttpService 已经解包了 ApiResponse，response.data 直接是数据对象
      if (response.statusCode == 200 && response.data != null) {
        return Interest.fromJson(response.data as Map<String, dynamic>);
      }
      
      throw Exception('Failed to get interest');
    } catch (e) {
      print('❌ Error getting interest $id: $e');
      rethrow;
    }
  }

  /// 获取当前用户的兴趣
  Future<List<UserInterest>> getCurrentUserInterests() async {
    try {
      final response = await _httpService.get('/interests/me');
      
      // HttpService 已经解包了 ApiResponse，response.data 直接是数据数组
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List;
        return data.map((json) => UserInterest.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw Exception('Failed to get user interests');
    } catch (e) {
      print('❌ Error getting current user interests: $e');
      rethrow;
    }
  }

  /// 获取指定用户的兴趣
  Future<List<UserInterest>> getUserInterests(String userId) async {
    try {
      final response = await _httpService.get('/interests/users/$userId');
      
      // HttpService 已经解包了 ApiResponse，response.data 直接是数据数组
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List;
        return data.map((json) => UserInterest.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw Exception('Failed to get user interests');
    } catch (e) {
      print('❌ Error getting user interests for $userId: $e');
      rethrow;
    }
  }

  /// 添加当前用户兴趣
  Future<UserInterest> addCurrentUserInterest(AddUserInterestRequest request) async {
    try {
      final response = await _httpService.post('/interests/me', data: request.toJson());
      
      // HttpService 已经解包了 ApiResponse，response.data 直接是数据对象
      if (response.statusCode == 200 && response.data != null) {
        return UserInterest.fromJson(response.data as Map<String, dynamic>);
      }
      
      throw Exception('Failed to add user interest');
    } catch (e) {
      print('❌ Error adding user interest: $e');
      rethrow;
    }
  }

  /// 批量添加用户兴趣
  Future<List<UserInterest>> addUserInterestsBatch(List<AddUserInterestRequest> interests) async {
    try {
      final data = interests.map((i) => i.toJson()).toList();
      final response = await _httpService.post('/interests/users/me/batch', data: data);
      
      // HttpService 已经解包了 ApiResponse，response.data 直接是数据数组
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> resultData = response.data as List;
        return resultData.map((json) => UserInterest.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw Exception('Failed to add user interests');
    } catch (e) {
      print('❌ Error adding user interests batch: $e');
      rethrow;
    }
  }

  /// 删除用户兴趣
  Future<bool> removeUserInterest(String userId, String interestId) async {
    try {
      final response = await _httpService.delete('/interests/users/$userId/$interestId');
      
      if (response.statusCode == 200) {
        return true;
      }
      
      throw Exception('Failed to remove user interest');
    } catch (e) {
      print('❌ Error removing user interest: $e');
      return false;
    }
  }

  /// 更新用户兴趣
  Future<UserInterest> updateUserInterest(
    String userId, 
    String interestId, 
    AddUserInterestRequest request
  ) async {
    try {
      final response = await _httpService.put(
        '/interests/users/$userId/$interestId',
        data: request.toJson(),
      );
      
      // HttpService 已经解包了 ApiResponse，response.data 直接是数据对象
      if (response.statusCode == 200 && response.data != null) {
        return UserInterest.fromJson(response.data as Map<String, dynamic>);
      }
      
      throw Exception('Failed to update user interest');
    } catch (e) {
      print('❌ Error updating user interest: $e');
      rethrow;
    }
  }
}
