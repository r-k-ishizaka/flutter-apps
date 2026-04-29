import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../di/di.dart';
import '../../repositories/emoji_repository.dart';
import '../../route/app_routes.dart';
import '../../services/emoji_cache.dart';
import '../auth/auth_provider.dart';

class SplashScreen extends HookWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final syncProgress = useState<double?>(null);
    final syncMessage = useState<String>('初期化中...');

    useEffect(() {
      var disposed = false;

      void updateProgress(double progress, String message) {
        if (disposed) return;
        syncProgress.value = progress.clamp(0, 1);
        syncMessage.value = message;
      }

      Future<void> bootstrap() async {
        developer.log('Bootstrap started', name: 'SplashScreen');
        syncMessage.value = 'セッションを復元中...';

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
          final emojiCache = getIt<EmojiCache>();

          // まずDBキャッシュを復元。空なら初回起動扱いで同期完了まで待機する。
          developer.log('Loading emojis from DB...', name: 'SplashScreen');
          await emojiRepo.loadToCache().catchError((Object err) {
            developer.log(
              'Failed to load emojis from DB: $err',
              name: 'SplashScreen',
              error: err,
            );
          });

          if (emojiCache.isEmpty) {
            developer.log('Emoji cache is empty. Running blocking sync...', name: 'SplashScreen');
            syncProgress.value = 0;
            syncMessage.value = '絵文字を同期中...';
            await emojiRepo.syncEmojis(
              session,
              onProgress: updateProgress,
            ).catchError((Object e) {
              developer.log(
                'Blocking emoji sync failed: $e',
                name: 'SplashScreen',
                error: e,
              );
            });
            syncProgress.value = 1;
            syncMessage.value = '同期完了';
          } else {
            developer.log('Starting background emoji sync...', name: 'SplashScreen');
            syncProgress.value = null;
            syncMessage.value = '起動中...';
            unawaited(
              emojiRepo.syncEmojis(session).catchError((Object e) {
                developer.log(
                  'Background emoji sync failed: $e',
                  name: 'SplashScreen',
                  error: e,
                );
              }),
            );
          }

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

    final progress = syncProgress.value;
    final percent = progress == null ? null : (progress * 100).round();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (progress == null)
                const CircularProgressIndicator()
              else
                LinearProgressIndicator(value: progress),
              const SizedBox(height: 12),
              Text(syncMessage.value),
              if (percent != null) ...[
                const SizedBox(height: 4),
                Text('$percent%'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
