import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../di/di.dart';
import '../services/emoji_cache.dart';

/// Misskey のノート本文を絵文字付きでレンダリングするウィジェット。
///
/// テキスト中の `:shortcode:` を検出し、[EmojiCache] から URL を引いて
/// [CachedNetworkImage] でインライン表示する。
/// キャッシュに該当エントリがない場合は `:shortcode:` をそのままテキスト表示。
class EmojiText extends StatelessWidget {
  const EmojiText(
    this.text, {
    super.key,
    this.style,
    this.emojiSize = 25.0,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;

  /// 絵文字画像の表示高さ。
  final double emojiSize;

  final int? maxLines;
  final TextOverflow? overflow;

  static final _emojiPattern = RegExp(r':([a-zA-Z0-9_]+):');

  @override
  Widget build(BuildContext context) {
    final cache = getIt<EmojiCache>();
    developer.log(
      'EmojiText.build() - Cache size: ${cache.length}, Text: "$text"',
      name: 'EmojiText',
    );

    final spans = _buildSpans(text, cache, context);

    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  List<InlineSpan> _buildSpans(
    String source,
    EmojiCache cache,
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
      final url = cache.getUrl(name);

      developer.log(
        'Emoji code: $name -> ${url != null ? "Found: $url" : "Not found in cache"}',
        name: 'EmojiText',
      );

      if (url != null && url.isNotEmpty) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: emojiSize * 11,
              ),
              child: CachedNetworkImage(
                imageUrl: url,
                height: emojiSize,
                fit: BoxFit.fitHeight,
                placeholder: (_, _) => SizedBox(
                  width: emojiSize,
                  height: emojiSize,
                ),
                errorWidget: (_, _, _) => Text(':$name:'),
              ),
            ),
          ),
        );
      } else {
        // 未登録の shortcode はそのまま表示
        spans.add(TextSpan(text: match.group(0)));
      }

      lastEnd = match.end;
    }

    // 末尾の残りテキスト
    if (lastEnd < source.length) {
      spans.add(TextSpan(text: source.substring(lastEnd)));
    }

    return spans;
  }
}
