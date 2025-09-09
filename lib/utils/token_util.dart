import 'dart:convert';

class TokenUtil {
  // 加密 token 和 refreshToken，返回加密后的字符串
  static String encryptToken(String token, String refreshToken) {
    final combined = '$token:$refreshToken';
    // 这里用 base64 加密，也可以用 AES/自定义算法
    return base64Url.encode(utf8.encode(combined));
  }

  // 解密，返回 [token, refreshToken]
  static List<String> decryptToken(String encrypted) {
    final decoded = utf8.decode(base64Url.decode(encrypted));
    final parts = decoded.split(':');
    if (parts.length == 2) {
      return parts;
    } else {
      throw Exception('Token 解密失败');
    }
  }
}
