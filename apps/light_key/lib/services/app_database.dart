import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// テーブル定義
// ---------------------------------------------------------------------------

/// カスタム絵文字テーブル。
/// name が主キー（:shortcode: のコード部分）。
class EmojiTable extends Table {
  @override
  String get tableName => 'emojis';

  /// 絵文字名（shortcode）。例: "ai_acid_misskeyio"
  TextColumn get name => text()();

  /// カテゴリ。例: "000 Misskey.io Original"
  TextColumn get category => text().nullable()();

  /// 画像 URL。
  TextColumn get url => text()();

  /// エイリアスを JSON 文字列として保存。例: '["ai","acid"]'
  TextColumn get aliases => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

// ---------------------------------------------------------------------------
// データベース
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [EmojiTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // -- Emoji CRUD -----------------------------------------------------------

  /// 全絵文字を取得する。
  Future<List<EmojiTableData>> getAllEmojis() =>
      select(emojiTable).get();

  /// 絵文字を名前で1件取得する。
  Future<EmojiTableData?> getEmojiByName(String emojiName) =>
      (select(emojiTable)..where((t) => t.name.equals(emojiName)))
          .getSingleOrNull();

  /// 絵文字を一括 upsert する（存在すれば上書き）。
  Future<void> upsertEmojis(List<EmojiTableCompanion> emojis) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(emojiTable, emojis);
    });
  }

  /// 全絵文字を削除し、新しいリストを挿入する。
  Future<void> replaceAllEmojis(List<EmojiTableCompanion> emojis) async {
    await transaction(() async {
      await delete(emojiTable).go();
      await batch((b) {
        b.insertAll(emojiTable, emojis);
      });
    });
  }
}

// ---------------------------------------------------------------------------
// DB ファイルのオープン
// ---------------------------------------------------------------------------

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'light_key.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
