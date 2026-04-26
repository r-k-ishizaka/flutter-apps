import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../route/app_routes.dart';
import '../../services/oauth_service.dart';
import 'auth_provider.dart';
import 'auth_screen_state.dart';

// IndieAuthのクライアント識別子（client_idとして使うURL）
const String _indieAuthClientId = 'https://indieauth.mayonicle.com/light-key';

class AuthScreen extends HookWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final baseUrlController = useTextEditingController(text: 'https://misskey.io');
    final oauthService = useMemoized(() => OAuthService());
    final state = context.watch<AuthProvider>().state;

    useEffect(() {
      if (state.status != AuthStatus.authenticated) return null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        const SplashRoute().go(context);
      });

      return null;
    }, [state.status]);

    useEffect(() {
      StreamSubscription<OAuthCallbackData>? callbackSubscription;

      void initializeOAuthListener() async {
        await oauthService.initializeDeepLinkListener();

        callbackSubscription = oauthService.callbackStream.listen(
          (callbackData) {
            if (!context.mounted) return;
            final baseUrl = baseUrlController.text;

            context.read<AuthProvider>().signInWithOAuth(
              baseUrl: baseUrl,
              clientId: _indieAuthClientId,
              code: callbackData.code,
              redirectUri: OAuthService.redirectUri,
              codeVerifier: oauthService.codeVerifier,
            );
          },
          onError: (error) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('OAuth エラー: $error')),
            );
          },
        );
      }

      initializeOAuthListener();

      return () {
        unawaited(callbackSubscription?.cancel());
        unawaited(oauthService.dispose());
      };
    }, []);

    return DefaultScaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: baseUrlController,
            decoration: const InputDecoration(
              labelText: 'Misskey サーバーURL',
              hintText: 'https://example.tld',
            ),
          ),
          const SizedBox(height: 20),
          // OAuth セクション
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'OAuth 2.0 でログイン',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Misskey の認可画面を通じてログインします',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: state.status == AuthStatus.loading
                ? null
                : () async {
                    await oauthService.startOAuthFlow(
                      baseUrl: baseUrlController.text,
                      clientId: _indieAuthClientId,
                    );
                  },
            child: const Text('Misskey でログイン'),
          ),
          if (state.status == AuthStatus.authenticated) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.read<AuthProvider>().signOut(),
              child: const Text('ログアウト'),
            ),
          ],
          const SizedBox(height: 20),
          if (state.session != null)
            Text('接続先: ${state.session!.baseUrl}'),
          if (state.user != null)
            Text('ユーザー: @${state.user!.username} (${state.user!.name})'),
          if (state.message != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(state.message!),
            ),
        ],
      ),
    );
  }
}
