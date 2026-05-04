import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../services/emoji_cache.dart';

/// Misskey のノート本文を絵文字付きでレンダリングするウィジェット。
///
/// テキスト中の `:shortcode:` を検出し、[emojis] にある URL を使って
/// インライン表示する。キャッシュに該当エントリがない場合は
/// `:shortcode:` をそのままテキスト表示。
class EmojiText extends StatelessWidget {
  const EmojiText(
    this.text, {
    required this.emojis,
    super.key,
    this.style,
    this.emojiSize = 25.0,
    this.maxLines,
    this.overflow,
    this.host,
    this.showCrossServerCacheMissAsError = false,
  });

  final String text;
  final Map<String, EmojiCacheEntry> emojis;
  final TextStyle? style;

  /// 絵文字画像の表示高さ。
  final double emojiSize;

  final int? maxLines;
  final TextOverflow? overflow;

  /// `:name:` の解決時に使う既定ホスト。指定時は `name@host` を優先して参照する。
  final String? host;

  /// `:name@host:` がキャッシュ未登録のとき、shortcode文字列ではなくエラー画像を表示する。
  final bool showCrossServerCacheMissAsError;

  // :shortcode: に加えて :shortcode@host: / :shortcode@.: 形式も許可する。
  static final _emojiPattern = RegExp(
    r':([a-zA-Z0-9_.-]+)(?:@([a-zA-Z0-9.-]+|\.))?:',
  );

  @override
  Widget build(BuildContext context) {
    final spans = _buildSpans(text, emojis, context);

    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  List<InlineSpan> _buildSpans(
    String source,
    Map<String, EmojiCacheEntry> cache,
    BuildContext context,
  ) {
    final spans = <InlineSpan>[];
    var lastEnd = 0;

    for (final match in _emojiPattern.allMatches(source)) {
      // マッチ前の通常テキスト
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: source.substring(lastEnd, match.start)));
      }

      final name = match.group(1)!;
      final explicitHost = match.group(2);
      final entry = _resolveEmojiEntry(
        cache: cache,
        name: name,
        explicitHost: explicitHost,
      );

      if (entry != null && entry.url.isNotEmpty) {
        // アスペクト比から表示幅を計算（最大 emojiSize * 11 に制限）
        final displayWidth = (emojiSize * entry.aspectRatio).clamp(
          0.0,
          emojiSize * 11,
        );
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: CachedNetworkImage(
                imageUrl: entry.url,
                width: displayWidth,
                height: emojiSize,
                fit: BoxFit.fill,
                placeholder: (_, _) =>
                    SizedBox(width: displayWidth, height: emojiSize),
                errorWidget: (_, _, _) => Text(':$name:'),
              ),
            ),
          ),
        );
      } else {
        final isCrossServer =
            explicitHost != null &&
            explicitHost.isNotEmpty &&
            explicitHost != '.';

        if (showCrossServerCacheMissAsError && isCrossServer) {
          spans.add(_buildErrorSpan(context));
        } else {
          // 未登録の shortcode はそのまま表示
          spans.add(TextSpan(text: match.group(0)));
        }
      }

      lastEnd = match.end;
    }

    // 末尾の残りテキスト
    if (lastEnd < source.length) {
      spans.add(TextSpan(text: source.substring(lastEnd)));
    }

    return spans;
  }

  InlineSpan _buildErrorSpan(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: SizedBox.square(
          dimension: emojiSize,
          child: Icon(
            Icons.broken_image_outlined,
            size: emojiSize,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  EmojiCacheEntry? _resolveEmojiEntry({
    required Map<String, EmojiCacheEntry> cache,
    required String name,
    String? explicitHost,
  }) {
    // 明示的な host がある場合（:name@host:）は最優先。
    if (explicitHost != null && explicitHost.isNotEmpty && explicitHost != '.') {
      final keyWithHost = '$name@$explicitHost';
      final entryWithHost = cache[keyWithHost];
      if (entryWithHost != null) {
        return entryWithHost;
      }

      // host指定でも見つからないので bare name で再検索
      final entryBare = cache[name];
      if (entryBare != null) {
        return entryBare;
      }
      return null;
    }

    // host 引数が与えられている場合、:name: は name@host を優先。
    final defaultHost = host;
    if (defaultHost != null && defaultHost.isNotEmpty) {
      final keyWithDefaultHost = '$name@$defaultHost';
      final entryWithDefaultHost = cache[keyWithDefaultHost];
      if (entryWithDefaultHost != null) {
        return entryWithDefaultHost;
      }

      // host指定でも見つからないので bare name で再検索
      final entryBare = cache[name];
      if (entryBare != null) {
        return entryBare;
      }
      return null;
    }

    // host 指定なし → bare name で検索
    final bareEntry = cache[name];
    if (bareEntry != null) {
      return bareEntry;
    }

    // bare name でもヒットしない場合、`name@host` 形式でキャッシュされた
    // 他鯖ユーザーのプロフィール絵文字をスキャンして返す
    final prefix = '$name@';
    for (final entry in cache.entries) {
      if (entry.key.startsWith(prefix)) {
        return entry.value;
      }
    }
    return null;
  }
}
