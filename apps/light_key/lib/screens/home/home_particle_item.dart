import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../services/emoji_cache.dart';
import '../../widgets/emoji_text.dart';
import '../../widgets/user_avatar.dart';
import 'home_particle_models.dart';

class HomeReactionParticleItem extends HookWidget {
  const HomeReactionParticleItem({
    required this.particle,
    required this.emojis,
    required this.duration,
    super.key,
  });

  final HomeReactionParticle particle;
  final Map<String, EmojiCacheEntry> emojis;
  final Duration duration;

  static const _avatarInset = 8.0;

  @override
  Widget build(BuildContext context) {
    final contentKey = useMemoized(GlobalKey.new);
    final measuredWidth = useState<double?>(null);

    // リアクション表示が変わると実測幅を取り直す。
    useEffect(() {
      measuredWidth.value = null;
      return null;
    }, [
      particle.id,
      particle.reaction,
      particle.avatarUrl,
      particle.fontSize,
      particle.iconData,
    ]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final renderObject = contentKey.currentContext?.findRenderObject();
        if (renderObject is! RenderBox || !renderObject.hasSize) return;
        final width = renderObject.size.width;
        if (measuredWidth.value != null &&
            (width - measuredWidth.value!).abs() < 0.1) {
          return;
        }
        measuredWidth.value = width;
      });
      return null;
    });

    final avatarInset = particle.avatarUrl != null ? _avatarInset : 0.0;
    final effectiveWidth = measuredWidth.value ?? particle.fontSize;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      builder: (context, value, _) {
        final motion = Curves.easeOutCubic.transform(value);
        final fadeStart = particle.isAccent ? 0.45 : 0.60;
        final fadeProgress = ((value - fadeStart) / (1 - fadeStart)).clamp(
          0.0,
          1.0,
        );
        final baseOpacity = particle.isAccent ? 0.55 : 0.60;
        final opacity = (baseOpacity - fadeProgress * baseOpacity).clamp(
          0.0,
          1.0,
        );
        final rise = particle.rise * motion;

        final body = particle.iconData != null
            ? Transform.rotate(
                angle: particle.angle,
                child: Icon(
                  particle.iconData,
                  size: particle.fontSize,
                  color: particle.iconColor ?? Colors.redAccent,
                ),
              )
            : EmojiText(
                particle.reaction,
                emojis: emojis,
                emojiSize: particle.fontSize,
                style: TextStyle(
                  fontSize: particle.fontSize,
                  shadows: [
                    const Shadow(color: Colors.black45, blurRadius: 3),
                    Shadow(
                      color: Colors.white.withValues(alpha: 0.20),
                      blurRadius: 8,
                    ),
                  ],
                ),
              );

        final content = Stack(
          key: contentKey,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(left: avatarInset, bottom: avatarInset),
              child: body,
            ),
            if (particle.avatarUrl != null)
              Positioned(
                bottom: 0,
                left: 0,
                child: UserAvatar(avatarUrl: particle.avatarUrl, size: 18),
              ),
          ],
        );

        return Positioned(
          left: particle.left + (particle.driftX * motion) - (effectiveWidth / 2),
          bottom: particle.bottom + rise - avatarInset,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              alignment: Alignment.bottomCenter,
              scale: motion,
              child: content,
            ),
          ),
        );
      },
    );
  }
}
