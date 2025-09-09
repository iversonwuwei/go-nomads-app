import 'package:df_admin_mobile/utils/token_util.dart';
import 'package:dio/dio.dart';

class HttpUtil {
  static final HttpUtil _instance = HttpUtil._internal();
  factory HttpUtil() => _instance;
  late final Dio dio;
  String? _encryptedToken;

  HttpUtil._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com', // 可根据实际情况修改
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 自动解密并附加 Token
        if (_encryptedToken != null && _encryptedToken!.isNotEmpty) {
          try {
            final tokens = TokenUtil.decryptToken(_encryptedToken!);
            options.headers['Authorization'] = 'Bearer ${tokens[0]}';
            options.headers['X-Refresh-Token'] = tokens[1];
          } catch (e) {
            print('Token 解密失败: $e');
          }
        }
        // 可添加日志、统一参数等
        print('请求: [${options.method}] ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        // 响应拦截，可统一处理业务错误码
        print('响应: ${response.statusCode} ${response.data}');
        handler.next(response);
      },
      onError: (DioException e, handler) {
        // 错误拦截
        print('请求错误: ${e.message}');
        handler.next(e);
      },
    ));
  }

  // 设置并加密 token
  void setToken(String token, String refreshToken) {
    _encryptedToken = TokenUtil.encryptToken(token, refreshToken);
  }

  Future<dynamic> get(String url, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response = await dio.get(url, queryParameters: queryParameters, options: options);
      return response.data;
    } catch (e) {
      throw Exception('GET请求失败: $e');
    }
  }

  Future<dynamic> post(String url, {dynamic data, Options? options}) async {
    try {
      final response = await dio.post(url, data: data, options: options);
      return response.data;
    } catch (e) {
      throw Exception('POST请求失败: $e');
    }
  }
// ...existing code...
}
