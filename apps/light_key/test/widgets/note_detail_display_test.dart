import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/models/note_file.dart';
import 'package:light_key/services/emoji_cache.dart';
import 'package:light_key/widgets/note_media_list.dart';
import 'package:light_key/widgets/note_reaction_list.dart';

void main() {
  group('Detail display mode', () {
    testWidgets('NoteReactionList(showAll: true) は全リアクションを表示する', (
      tester,
    ) async {
      final reactions = <String, int>{
        for (var i = 0; i < 18; i++) ':e$i:': 100 - i,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteReactionList(
              reactions: reactions,
              emojis: const <String, EmojiCacheEntry>{},
              showAll: true,
            ),
          ),
        ),
      );

      for (var i = 0; i < 18; i++) {
        expect(find.byKey(ValueKey('reaction-chip-:e$i:')), findsOneWidget);
      }
      expect(find.text('もっと見る'), findsNothing);
    });

    testWidgets('NoteMediaList(showAll: true) は5件以上の画像も省略しない', (tester) async {
      final files = List<NoteFile>.generate(
        5,
        (index) => NoteFile(id: '$index', type: 'image/png'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NoteMediaList(files: files, showAll: true)),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView.semanticChildCount, 5);
      expect(find.text('+1'), findsNothing);
    });
  });
}
