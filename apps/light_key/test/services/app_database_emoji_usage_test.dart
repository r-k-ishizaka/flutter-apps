import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/services/app_database.dart';

void main() {
  group('AppDatabase emoji usage', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('incrementEmojiUsage increments usage count', () async {
      await database.incrementEmojiUsage(':smile:');
      await database.incrementEmojiUsage(':smile:');

      final top = await database.getTopUsedEmojis(limit: 10);
      expect(top, [':smile:']);
    });

    test('getTopUsedEmojis returns at most limit in descending count order', () async {
      await database.incrementEmojiUsage(':high:');
      await database.incrementEmojiUsage(':high:');
      await database.incrementEmojiUsage(':high:');

      await database.incrementEmojiUsage(':medium:');
      await database.incrementEmojiUsage(':medium:');

      await database.incrementEmojiUsage(':low:');

      final top2 = await database.getTopUsedEmojis(limit: 2);
      expect(top2, [':high:', ':medium:']);
    });
  });
}
