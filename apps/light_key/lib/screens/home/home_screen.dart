import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../models/auth_session.dart';
import '../../services/emoji_cache.dart';
import '../../services/home_reaction_stream_service.dart';
import '../auth/auth_provider.dart';
import 'home_particle_item.dart';
import 'home_particle_models.dart';
import 'home_provider.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({
    super.key,
    required this.child,
    required this.actions,
    required this.onDestinationSelected,
    required this.onPostTap,
    required this.currentPath,
    this.selectedIndex = 0,
  });

  final Widget child;
  final List<Widget> actions;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onPostTap;
  final String currentPath;
  final int selectedIndex;

  static const _particleDuration = Duration(milliseconds: 900);
  static const _accentCount = 5;
  static const _maxActiveParticles = 12;
  static const _reactionRise = 70.0;
  static const _fallbackParticleBottom = 34.0;
  static const _particleLogPrefix = '[BellParticle]';
  static const _accentPalette = <Color>[
    Colors.redAccent,
    Colors.greenAccent,
    Colors.amberAccent,
    Colors.lightBlueAccent,
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeProvider>(
      child: _HomeScreenBody(
        actions: actions,
        onDestinationSelected: onDestinationSelected,
        onPostTap: onPostTap,
        currentPath: currentPath,
        selectedIndex: selectedIndex,
        child: child,
      ),
      create: (_) => HomeProvider(),
    );
  }

  static final _emojiNamePattern = RegExp(
    r'^:([a-zA-Z0-9_.-]+)(?:@[a-zA-Z0-9.-]+)?:$',
  );

  static Future<void> _precacheReactionEmoji(
    BuildContext context,
    String reaction,
  ) async {
    if (!context.mounted) return;
    final match = _emojiNamePattern.firstMatch(reaction);
    if (match == null) return;
    final name = match.group(1)!;
    final cache = Provider.of<EmojiCache?>(context, listen: false);
    if (cache == null) return;
    final entry =
        cache.getEntry(name) ??
        cache.entries.entries
            .where((e) => e.key.startsWith('$name@'))
            .map((e) => e.value)
            .firstOrNull;
    final url = entry?.url;
    if (url == null || url.isEmpty) return;
    try {
      await precacheImage(
        CachedNetworkImageProvider(url),
        context,
      ).timeout(const Duration(milliseconds: 600));
    } catch (_) {
      // タイムアウト・エラー時はそのままパーティクルを出す
    }
  }

  static void _debugLogParticleEmission({
    required String reaction,
    required HomeParticleOrigin origin,
    required List<HomeReactionParticle> particles,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer(
      'emit reaction=$reaction '
      'origin=(${origin.left.toStringAsFixed(1)}, ${origin.bottom.toStringAsFixed(1)})',
    );
    for (final particle in particles) {
      buffer.write(
        '\n  id=${particle.id} '
        'accent=${particle.isAccent} '
        'left=${particle.left.toStringAsFixed(1)} '
        'bottom=${particle.bottom.toStringAsFixed(1)} '
        'driftX=${particle.driftX.toStringAsFixed(1)} '
        'rise=${particle.rise.toStringAsFixed(1)} '
        'font=${particle.fontSize.toStringAsFixed(1)}',
      );
    }
    debugPrint('$_particleLogPrefix $buffer');
  }

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint('$_particleLogPrefix $message');
  }
}

class _HomeScreenBody extends HookWidget {
  const _HomeScreenBody({
    required this.child,
    required this.actions,
    required this.onDestinationSelected,
    required this.onPostTap,
    required this.currentPath,
    required this.selectedIndex,
  });

  final Widget child;
  final List<Widget> actions;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onPostTap;
  final String currentPath;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final currentIndex = currentPath.startsWith('/home/notifications')
        ? 1
        : selectedIndex;
    final title = switch (currentIndex) {
      1 => '通知',
      _ => 'ホーム',
    };
    final isParticleEnabledTab = currentIndex == 0 || currentIndex == 1;

    final particles = context.select<HomeProvider, List<HomeReactionParticle>>(
      (provider) => provider.particles,
    );
    final homeProvider = context.read<HomeProvider>();

    final particleLayerKey = useMemoized(GlobalKey.new);
    final notificationsTabKey = useMemoized(GlobalKey.new);
    final lastNotificationParticleOrigin = useRef<HomeParticleOrigin?>(null);

    final session = context.select<AuthProvider, AuthSession?>(
      (provider) => provider.state.session,
    );
    final emojiCache =
        Provider.of<EmojiCache?>(context)?.entries ??
        const <String, EmojiCacheEntry>{};

    HomeParticleOrigin notificationParticleOrigin() {
      final fallback = HomeParticleOrigin(
        left: MediaQuery.sizeOf(context).width * 0.75,
        bottom:
            MediaQuery.paddingOf(context).bottom + HomeScreen._fallbackParticleBottom,
      );

      final particleLayerContext = particleLayerKey.currentContext;
      final notificationsTabContext = notificationsTabKey.currentContext;
      final particleLayerBox = particleLayerContext?.findRenderObject();
      final notificationsTabBox = notificationsTabContext?.findRenderObject();

      if (particleLayerBox is! RenderBox ||
          notificationsTabBox is! RenderBox ||
          !particleLayerBox.hasSize ||
          !notificationsTabBox.hasSize) {
        HomeScreen._debugLog(
          'origin=fallback left=${fallback.left.toStringAsFixed(1)} '
          'bottom=${fallback.bottom.toStringAsFixed(1)} '
          'hasLayer=${particleLayerBox is RenderBox && particleLayerBox.hasSize} '
          'hasBell=${notificationsTabBox is RenderBox && notificationsTabBox.hasSize}',
        );
        return lastNotificationParticleOrigin.value ?? fallback;
      }

      final tabTopLeftInParticleLayer = particleLayerBox.globalToLocal(
        notificationsTabBox.localToGlobal(Offset.zero),
      );
      final tabBottomRightInParticleLayer = particleLayerBox.globalToLocal(
        notificationsTabBox.localToGlobal(
          notificationsTabBox.size.bottomRight(Offset.zero),
        ),
      );
      final tabRect = Rect.fromPoints(
        tabTopLeftInParticleLayer,
        tabBottomRightInParticleLayer,
      );
      final origin = HomeParticleOrigin(
        left: tabRect.center.dx,
        bottom: particleLayerBox.size.height - tabRect.top,
      );
      HomeScreen._debugLog(
        'bellRect='
        '(${tabRect.left.toStringAsFixed(1)}, ${tabRect.top.toStringAsFixed(1)}) '
        '${tabRect.width.toStringAsFixed(1)}x${tabRect.height.toStringAsFixed(1)} '
        'origin=(${origin.left.toStringAsFixed(1)}, ${origin.bottom.toStringAsFixed(1)}) '
        'layer=${particleLayerBox.size.width.toStringAsFixed(1)}x${particleLayerBox.size.height.toStringAsFixed(1)}',
      );
      lastNotificationParticleOrigin.value = origin;
      return origin;
    }

    void emitParticle(String reaction, {String? avatarUrl}) {
      final origin = notificationParticleOrigin();
      final emitted = homeProvider.emitParticles(
        origin: origin,
        reaction: reaction,
        avatarUrl: avatarUrl,
        particleDuration: HomeScreen._particleDuration,
        accentCount: HomeScreen._accentCount,
        maxActiveParticles: HomeScreen._maxActiveParticles,
        reactionRise: HomeScreen._reactionRise,
        accentPalette: HomeScreen._accentPalette,
      );
      HomeScreen._debugLogParticleEmission(
        reaction: reaction,
        origin: origin,
        particles: emitted,
      );
    }

    Future<void> precacheAndEmit(HomeReactionStreamEvent event) async {
      await HomeScreen._precacheReactionEmoji(context, event.reaction);
      if (!context.mounted || !isParticleEnabledTab) return;
      emitParticle(event.reaction, avatarUrl: event.avatarUrl);
    }

    useEffect(() {
      homeProvider.configureMainChannel(
        session: session,
        isParticleEnabledTab: isParticleEnabledTab,
        onReactionEvent: precacheAndEmit,
      );
      return null;
    }, [session?.baseUrl, session?.accessToken, isParticleEnabledTab]);

    useEffect(() {
      final lifecycleListener = AppLifecycleListener(
        onHide: () => unawaited(homeProvider.onHide()),
        onResume: () => unawaited(homeProvider.onResume()),
      );
      return lifecycleListener.dispose;
    }, [homeProvider]);

    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          appBar: AppBar(title: Text(title), actions: actions),
          floatingActionButton: FloatingActionButton(
            onPressed: onPostTap,
            child: const Icon(Icons.edit_note),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dynamic_feed),
                label: 'Timeline',
              ),
              NavigationDestination(
                icon: KeyedSubtree(
                  key: notificationsTabKey,
                  child: const Icon(Icons.notifications_none),
                ),
                label: 'Notifications',
              ),
            ],
          ),
          body: child,
        ),
        IgnorePointer(
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
            key: particleLayerKey,
            fit: StackFit.expand,
            children: particles
                .map(
                  (particle) => HomeReactionParticleItem(
                    key: ValueKey<int>(particle.id),
                    particle: particle,
                    emojis: emojiCache,
                    duration: HomeScreen._particleDuration,
                  ),
                )
                .toList(growable: false),
            ),
          ),
        ),
      ],
    );
  }
}
