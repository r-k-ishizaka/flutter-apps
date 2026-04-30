import 'dart:async';

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
    final syncMessage = useState<String>('初期化中...');

    useEffect(() {
      var disposed = false;

      Future<void> bootstrap() async {
        syncMessage.value = 'セッションを復元中...';

        final authProvider = context.read<AuthProvider>();
        await Future.wait<void>([
          Future<void>.delayed(const Duration(milliseconds: 500)),
          authProvider.restoreSession(),
        ]);
        if (!context.mounted || disposed) return;

        final session = authProvider.state.session;
        if (session != null) {
          final emojiRepo = getIt<EmojiRepository>();

          // 起動体感を優先し、絵文字のDB復元/同期は非同期で進める。
          unawaited(
            () async {
              try {
                await emojiRepo.loadToCache();
              } catch (_) {
              }

              try {
                await emojiRepo.syncEmojis(session);
              } catch (_) {
              }
            }(),
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

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(syncMessage.value),
            ],
          ),
        ),
      ),
    );
  }
}
