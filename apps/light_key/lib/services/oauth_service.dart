import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/oauth_utils.dart';

class OAuthCallbackData {
  OAuthCallbackData({required this.code, required this.state});

  final String code;
  final String state;
}

class OAuthService {
  static const String _callbackScheme = 'light-key';
  static const String _callbackHost = 'oauth-callback';

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _deepLinkSubscription;

  String? _expectedState;
  final _callbackController = StreamController<OAuthCallbackData>.broadcast();

  Stream<OAuthCallbackData> get callbackStream => _callbackController.stream;

  OAuthService() {
    _appLinks = AppLinks();
  }

  /// ディープリンク監視を開始
  Future<void> initializeDeepLinkListener() async {
    final initialUri = await _appLinks.getInitialAppLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) {
        _callbackController.addError(err);
      },
    );
  }

  /// ディープリンクを処理
  void _handleDeepLink(Uri uri) {
    if (uri.scheme == _callbackScheme && uri.host == _callbackHost) {
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];

      if (code == null) {
        _callbackController.addError(OAuthException('認可コードが見つかりません'));
        return;
      }

      // State パラメータの検証
      if (_expectedState != null && state != _expectedState) {
        _callbackController.addError(OAuthException('State パラメータが一致しません'));
        return;
      }

      _callbackController.add(
        OAuthCallbackData(code: code, state: state ?? ''),
      );
    }
  }

  /// OAuth 認可フローの初期化とユーザーをブラウザへリダイレクト
  Future<void> startOAuthFlow({
    required String baseUrl,
    required String clientId,
    String? scope,
  }) async {
    try {
      // PKCE パラメータを生成
      final state = OAuthUtils.generateState();
      final codeVerifier = OAuthUtils.generateCodeVerifier();
      final codeChallenge = OAuthUtils.generateCodeChallenge(codeVerifier);

      // State を保存（後で検証用に使用）
      _expectedState = state;

      // 認可 URL を生成
      final redirectUri = '$_callbackScheme://$_callbackHost/callback';
      final authorizationUrl = OAuthUtils.generateAuthorizationUrl(
        baseUrl: baseUrl,
        clientId: clientId,
        redirectUri: redirectUri,
        state: state,
        codeChallenge: codeChallenge,
      );

      // Code verifier を保存（トークンをリクエストする際に必要）
      _codeVerifier = codeVerifier;

      debugPrint('OAuth Authorization URL: $authorizationUrl');

      // ブラウザを開く
      final uri = Uri.parse(authorizationUrl);
      final canLaunch = await canLaunchUrl(uri);
      debugPrint('canLaunchUrl result: $canLaunch');

      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('launchUrl result: $launched');
        if (!launched) {
          throw OAuthException('ブラウザの起動に失敗しました');
        }
      } else {
        throw OAuthException('URLを開くことができません。生成されたURL: $authorizationUrl');
      }
    } catch (e) {
      debugPrint('OAuth Error: $e');
      _callbackController.addError(e);
    }
  }

  /// 保存されたコード検証子を取得
  String? get codeVerifier => _codeVerifier;
  String? _codeVerifier;

  /// クリーンアップ
  Future<void> dispose() async {
    await _deepLinkSubscription?.cancel();
    _expectedState = null;
    _codeVerifier = null;
    await _callbackController.close();
  }

  /// コールバック URL スキーム
  static String get redirectUri => '$_callbackScheme://$_callbackHost/callback';
}

class OAuthException implements Exception {
  OAuthException(this.message);

  final String message;

  @override
  String toString() => 'OAuthException: $message';
}
