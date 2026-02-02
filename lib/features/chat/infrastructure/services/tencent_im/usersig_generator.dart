import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// UserSig生成器 - 仅用于开发测试
///
/// ⚠️ 警告: 生产环境请通过后端服务生成UserSig
class UserSigGenerator {
  /// 生成UserSig
  static String generate({
    required int sdkAppId,
    required String secretKey,
    required String userId,
    int expireTime = 604800,
  }) {
    final currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final sigDoc = {
      'TLS.ver': '2.0',
      'TLS.identifier': userId,
      'TLS.sdkappid': sdkAppId,
      'TLS.expire': expireTime,
      'TLS.time': currTime,
    };

    final sig = _hmacsha256(
      sdkAppId: sdkAppId,
      secretKey: secretKey,
      userId: userId,
      currTime: currTime,
      expireTime: expireTime,
    );
    sigDoc['TLS.sig'] = sig;

    final jsonStr = jsonEncode(sigDoc);
    final compressed = zlib.encode(utf8.encode(jsonStr));
    return _base64UrlEncode(Uint8List.fromList(compressed));
  }

  static String _hmacsha256({
    required int sdkAppId,
    required String secretKey,
    required String userId,
    required int currTime,
    required int expireTime,
  }) {
    final content = 'TLS.identifier:$userId\n'
        'TLS.sdkappid:$sdkAppId\n'
        'TLS.time:$currTime\n'
        'TLS.expire:$expireTime\n';
    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final digest = hmac.convert(utf8.encode(content));
    return base64Encode(digest.bytes);
  }

  static String _base64UrlEncode(Uint8List data) {
    return base64Encode(data).replaceAll('+', '*').replaceAll('/', '-').replaceAll('=', '_');
  }
}
