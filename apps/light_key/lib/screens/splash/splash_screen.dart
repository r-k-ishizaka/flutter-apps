import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../di/di.dart';
import '../../repositories/emoji_repository.dart';
import '../../route/app_routes.dart';
import '../auth/auth_provider.dart';

class SplashScreen extends HookWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      var disposed = false;

      Future<void> bootstrap() async {
        developer.log('Bootstrap started', name: 'SplashScreen');

        final authProvider = context.read<AuthProvider>();
        await Future.wait<void>([
          Future<void>.delayed(const Duration(milliseconds: 500)),
          authProvider.restoreSession(),
        ]);
        if (!context.mounted || disposed) return;

        developer.log(
          'Session restored: ${authProvider.state.session != null}',
          name: 'SplashScreen',
        );

        final session = authProvider.state.session;
        if (session != null) {
          final emojiRepo = getIt<EmojiRepository>();

          // DB から既存の絵文字をロード（高速・ブロッキング開始直後）
          developer.log('Loading emojis from DB...', name: 'SplashScreen');
          await emojiRepo.loadToCache().catchError((Object err) {
            developer.log(
              'Failed to load emojis from DB: $err',
              name: 'SplashScreen',
              error: err,
            );
            // DB が空の場合もここで catch（初回起動時など）
          });

          // バックグラウンドで最新の絵文字を同期（非ブロッキング）
          // スプラッシュ画面は即座に遷移し、タイムライン表示後に非同期で更新される
          developer.log('Starting background emoji sync...', name: 'SplashScreen');
          unawaited(
            emojiRepo.syncEmojis(session).catchError((Object e) {
              developer.log(
                'Background emoji sync failed: $e',
                name: 'SplashScreen',
                error: e,
              );
            }),
          );

          if (!context.mounted || disposed) return;
          const TimelineRoute().go(context);
          return;
        }
        const AuthRoute().go(context);
      }

      unawaited(bootstrap());
      return () {
        disposed = true;
      };
    }, const []);

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
