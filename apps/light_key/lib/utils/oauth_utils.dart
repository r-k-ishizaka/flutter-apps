import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class OAuthUtils {
  /// ランダムな文字列を生成
  static String generateRandomString(int length) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(
      length,
      (index) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// State パラメータを生成
  static String generateState() {
    return generateRandomString(32);
  }

  /// PKCE用の code_verifier を生成
  static String generateCodeVerifier() {
    return generateRandomString(128);
  }

  /// PKCE用の code_challenge を生成
  static String generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// OAuth 認可 URL を生成
  static String generateAuthorizationUrl({
    required String baseUrl,
    required String clientId,
    required String redirectUri,
    String? state,
    String? codeChallenge,
    String scope = 'read:account write:notes',
  }) {
    final uri = Uri.parse('$baseUrl/oauth/authorize');
    final queryParameters = <String, String>{
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'scope': scope,
    };

    if (state != null) {
      queryParameters['state'] = state;
    }

    if (codeChallenge != null) {
      queryParameters['code_challenge'] = codeChallenge;
      queryParameters['code_challenge_method'] = 'S256';
    }

    return uri.replace(queryParameters: queryParameters).toString();
  }
}
