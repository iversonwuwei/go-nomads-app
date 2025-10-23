import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/home_data_service.dart';
import '../services/http_service.dart';

/// HTTP 服务使用示例
/// 
/// 这个文件展示了如何使用 HttpService, AuthService 和 HomeDataService
class HttpServiceExample {
  final AuthService _authService = AuthService();
  final HomeDataService _homeDataService = HomeDataService();
  
  /// 示例 1: 用户登录
  Future<void> exampleLogin(BuildContext context) async {
    try {
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // 调用登录接口
      final result = await _authService.login(
        username: 'test@example.com',
        password: 'password123',
      );
      
      // 关闭加载指示器
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // 登录成功
      print('登录成功: ${result['user']}');
      print('Token: ${result['token']}');
      
      // 显示成功提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('登录成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on HttpException catch (e) {
      // 关闭加载指示器
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // 显示错误提示
      print('登录失败: ${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登录失败: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 关闭加载指示器
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      print('未知错误: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('未知错误: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// 示例 2: 获取首页数据
  Future<void> exampleGetHomeData(BuildContext context) async {
    try {
      // 获取首页数据
      final homeData = await _homeDataService.getHomeData();
      
      print('首页数据:');
      print('- 轮播图: ${homeData['banners']?.length ?? 0} 个');
      print('- 推荐城市: ${homeData['recommendedCities']?.length ?? 0} 个');
      print('- 最近 Meetup: ${homeData['recentMeetups']?.length ?? 0} 个');
      print('- 精选项目: ${homeData['featuredProjects']?.length ?? 0} 个');
      
      // 使用数据更新 UI
      // setState(() {
      //   _banners = homeData['banners'];
      //   _cities = homeData['recommendedCities'];
      //   ...
      // });
      
    } on HttpException catch (e) {
      print('获取首页数据失败: ${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// 示例 3: 获取城市列表 (带分页)
  Future<void> exampleGetCities() async {
    try {
      // 第一页数据
      final result = await _homeDataService.getCities(
        page: 1,
        pageSize: 20,
        search: '清迈',
      );
      
      final cities = result['cities'] as List?;
      final total = result['total'] as int?;
      final hasMore = result['hasMore'] as bool?;
      
      print('找到 $total 个城市，当前页 ${cities?.length ?? 0} 个');
      print('是否有更多数据: $hasMore');
      
    } on HttpException catch (e) {
      print('获取城市列表失败: ${e.message}');
    }
  }
  
  /// 示例 4: 用户注册
  Future<void> exampleRegister(BuildContext context) async {
    try {
      final result = await _authService.register(
        username: 'newuser',
        email: 'newuser@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );
      
      print('注册成功: ${result['user']}');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('注册成功，请登录'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } on HttpException catch (e) {
      print('注册失败: ${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('注册失败: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// 示例 5: 获取用户信息
  Future<void> exampleGetUserProfile() async {
    try {
      // 确保已登录
      if (!_authService.isLoggedIn()) {
        print('请先登录');
        return;
      }
      
      final userProfile = await _authService.getCurrentUser();
      
      print('用户信息:');
      print('- ID: ${userProfile['id']}');
      print('- 用户名: ${userProfile['username']}');
      print('- 邮箱: ${userProfile['email']}');
      print('- 头像: ${userProfile['avatar']}');
      
    } on HttpException catch (e) {
      print('获取用户信息失败: ${e.message}');
    }
  }
  
  /// 示例 6: 获取 Meetup 列表
  Future<void> exampleGetMeetups() async {
    try {
      final result = await _homeDataService.getMeetups(
        cityId: 'chiang-mai',
        upcoming: true, // 只获取即将到来的活动
        page: 1,
        pageSize: 10,
      );
      
      final meetups = result['meetups'] as List?;
      print('找到 ${meetups?.length ?? 0} 个即将到来的 Meetup');
      
    } on HttpException catch (e) {
      print('获取 Meetup 列表失败: ${e.message}');
    }
  }
  
  /// 示例 7: 获取创意项目列表
  Future<void> exampleGetInnovationProjects() async {
    try {
      final result = await _homeDataService.getInnovationProjects(
        page: 1,
        pageSize: 20,
        category: 'tech',
      );
      
      final projects = result['projects'] as List?;
      print('找到 ${projects?.length ?? 0} 个创意项目');
      
    } on HttpException catch (e) {
      print('获取创意项目失败: ${e.message}');
    }
  }
  
  /// 示例 8: 用户登出
  Future<void> exampleLogout(BuildContext context) async {
    try {
      await _authService.logout();
      
      print('登出成功');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已退出登录'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 跳转到登录页
        // Navigator.pushReplacementNamed(context, '/login');
      }
      
    } on HttpException catch (e) {
      print('登出失败: ${e.message}');
    }
  }
}

/// 在 Widget 中使用的完整示例
class HomePageWithApi extends StatefulWidget {
  const HomePageWithApi({super.key});

  @override
  State<HomePageWithApi> createState() => _HomePageWithApiState();
}

class _HomePageWithApiState extends State<HomePageWithApi> {
  final HomeDataService _homeDataService = HomeDataService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _homeData;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }
  
  /// 加载首页数据
  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final data = await _homeDataService.getHomeData();
      
      setState(() {
        _homeData = data;
        _isLoading = false;
      });
      
    } on HttpException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '未知错误: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页数据示例'),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHomeData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    
    // 显示数据
    return RefreshIndicator(
      onRefresh: _loadHomeData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('轮播图: ${_homeData?['banners']?.length ?? 0} 个'),
          Text('推荐城市: ${_homeData?['recommendedCities']?.length ?? 0} 个'),
          Text('最近 Meetup: ${_homeData?['recentMeetups']?.length ?? 0} 个'),
          Text('精选项目: ${_homeData?['featuredProjects']?.length ?? 0} 个'),
          // 添加更多 UI 组件...
        ],
      ),
    );
  }
}
