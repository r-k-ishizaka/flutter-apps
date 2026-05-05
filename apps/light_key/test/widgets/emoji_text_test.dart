import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/widgets/emoji_text.dart';

void main() {
  testWidgets('onEmojiTap指定時にshortcodeタップでコールバックが呼ばれる', (tester) async {
    String? tapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmojiText(
            'hello :custom@example.com: world',
            emojis: const {},
            onEmojiTap: (emoji) => tapped = emoji,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(
        const ValueKey('${EmojiText.emojiTapKeyPrefix}:custom@example.com:'),
      ),
    );
    await tester.pump();

    expect(tapped, ':custom@example.com:');
  });
}
