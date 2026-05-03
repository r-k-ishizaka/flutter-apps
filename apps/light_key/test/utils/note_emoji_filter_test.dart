import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/models/note.dart';
import 'package:light_key/models/response_with_cache_hints.dart';
import 'package:light_key/models/user.dart';
import 'package:light_key/models/user_profile.dart';
import 'package:light_key/utils/note_emoji_filter.dart';

void main() {
  User user({String name = 'alice'}) => User(id: 'u1', username: 'alice', name: name);

  Note note({
    String text = '',
    String? cw,
    Map<String, int> reactions = const <String, int>{},
    Note? renote,
    String userName = 'alice',
  }) =>
      Note(
        id: 'n1',
        text: text,
        cw: cw,
        createdAt: DateTime(2026, 1, 1),
        user: user(name: userName),
        reactions: reactions,
        renote: renote,
      );

  List<EmojiToCache> candidates(Iterable<String> names) =>
      names
          .map((name) => EmojiToCache(name: name, url: 'https://example.com/$name.png'))
          .toList(growable: false);

  group('NoteEmojiFilter', () {
    test('filterForNotes: テキスト絵文字 + リアクション上位16件だけを残す', () {
      final reactions = <String, int>{
        for (var i = 0; i < 20; i++) ':e$i:': 100 - i,
      }
        ..[':local@.:'] = 90;

      final notes = [
        note(
          text: 'hello :txt:',
          cw: 'cw :cw_emoji:',
          userName: ':user_name:',
          reactions: reactions,
        ),
      ];

      final pool = candidates([
        'txt',
        'cw_emoji',
        'user_name',
        'local',
        for (var i = 0; i < 20; i++) 'e$i',
        'unused',
      ]);

      final filtered = NoteEmojiFilter.filterForNotes(notes, pool);
      final names = filtered.map((e) => e.name).toSet();

      expect(names, containsAll({'txt', 'cw_emoji', 'user_name'}));
      expect(names, contains('local'));
      expect(names, isNot(contains('unused')));
      expect(names, isNot(contains('e16')));
      expect(names, isNot(contains('e19')));
      expect(names.length, lessThanOrEqualTo(20));
    });

    test('filterForProfile: 名前/説明/ピン留めノート由来だけを残す', () {
      final profile = UserProfile(
        id: 'p1',
        username: 'alice',
        name: ':name_emoji:',
        description: 'desc :desc_emoji@remote.com:',
        pinnedNotes: [
          note(
            text: 'pin :pin_emoji:',
            reactions: const <String, int>{':pin_reaction:': 5},
          ),
        ],
      );

      final pool = candidates([
        'name_emoji',
        'desc_emoji@remote.com',
        'pin_emoji',
        'pin_reaction',
        'other',
      ]);

      final filtered = NoteEmojiFilter.filterForProfile(profile, pool);
      final names = filtered.map((e) => e.name).toSet();

      expect(names, containsAll({
        'name_emoji',
        'desc_emoji@remote.com',
        'pin_emoji',
        'pin_reaction',
      }));
      expect(names, isNot(contains('other')));
    });
  });
}
