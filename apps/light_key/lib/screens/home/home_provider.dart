import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/auth_session.dart';
import '../../services/home_reaction_stream_service.dart';
import 'home_particle_models.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({HomeReactionStreamService? reactionStreamService})
    : _reactionStreamService = reactionStreamService ?? HomeReactionStreamService();

  final Random _random = Random();
  final HomeReactionStreamService _reactionStreamService;
  final List<HomeReactionParticle> _particles = <HomeReactionParticle>[];

  int _particleSeed = 0;
  bool _isDisposed = false;

  List<HomeReactionParticle> get particles => List<HomeReactionParticle>.unmodifiable(_particles);

  void configureMainChannel({
    required AuthSession? session,
    required bool isParticleEnabledTab,
    required Future<void> Function(HomeReactionStreamEvent event) onReactionEvent,
  }) {
    _reactionStreamService.configure(
      session: session,
      isParticleEnabledTab: isParticleEnabledTab,
      onReactionEvent: onReactionEvent,
    );
  }

  Future<void> onHide() => _reactionStreamService.onHide();

  Future<void> onResume() => _reactionStreamService.onResume();

  List<HomeReactionParticle> emitParticles({
    required HomeParticleOrigin origin,
    required String reaction,
    String? avatarUrl,
    required Duration particleDuration,
    required int accentCount,
    required int maxActiveParticles,
    required double reactionRise,
    required List<Color> accentPalette,
  }) {
    final mainParticle = HomeReactionParticle(
      id: _particleSeed++,
      reaction: reaction,
      avatarUrl: avatarUrl,
      left: origin.left + ((_random.nextDouble() * 2 - 1) * 6),
      bottom: origin.bottom,
      fontSize: 22 + _random.nextDouble() * 6,
      driftX: (_random.nextDouble() - 0.5) * 14,
      rise: reactionRise,
    );

    final accents = List<HomeReactionParticle>.generate(accentCount, (_) {
      final driftX = (_random.nextDouble() - 0.5) * 120;
      final rise = reactionRise * (0.1 + _random.nextDouble() * 0.65);
      return HomeReactionParticle(
        id: _particleSeed++,
        reaction: reaction,
        iconData: Icons.favorite_rounded,
        iconColor: accentPalette[_random.nextInt(accentPalette.length)],
        left: origin.left + ((_random.nextDouble() * 2 - 1) * 20),
        bottom: origin.bottom,
        fontSize: 11 + _random.nextDouble() * 4,
        driftX: driftX,
        rise: rise,
        angle: atan2(driftX, rise),
        isAccent: true,
      );
    });

    final emitted = <HomeReactionParticle>[mainParticle, ...accents];

    _particles.addAll(emitted);
    if (_particles.length > maxActiveParticles) {
      _particles.removeRange(0, _particles.length - maxActiveParticles);
    }
    _notifyIfActive();

    for (final particle in emitted) {
      Future<void>.delayed(particleDuration, () {
        if (_isDisposed) return;
        _particles.removeWhere((item) => item.id == particle.id);
        _notifyIfActive();
      });
    }

    return emitted;
  }

  void _notifyIfActive() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_reactionStreamService.dispose());
    super.dispose();
  }
}
