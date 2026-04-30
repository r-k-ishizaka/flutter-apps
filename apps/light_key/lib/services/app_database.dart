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

  /// 画像バイナリ（取得済みの場合）。
  BlobColumn get imageBytes => blob().nullable()();

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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await customStatement(
          'ALTER TABLE emojis ADD COLUMN image_bytes BLOB',
        );
      }
    },
  );

  // -- Emoji CRUD -----------------------------------------------------------

  /// 全絵文字を取得する。
  Future<List<EmojiTableData>> getAllEmojis() =>
      select(emojiTable).get();

  /// リアクションピッカー向けに必要最小限の列のみ取得する。
  ///
  /// imageBytes(BLOB) を除外して初期表示時のI/Oコストを抑える。
  Future<List<EmojiPickerRow>> getEmojisForPicker() async {
    final rows = await (selectOnly(emojiTable)
          ..addColumns([
            emojiTable.name,
            emojiTable.category,
            emojiTable.url,
            emojiTable.aliases,
          ]))
        .get();

    return rows
        .map(
          (row) => EmojiPickerRow(
            name: row.read(emojiTable.name)!,
            category: row.read(emojiTable.category),
            url: row.read(emojiTable.url)!,
            aliases: row.read(emojiTable.aliases),
          ),
        )
        .toList(growable: false);
  }

  /// リアクションピッカー向けにカテゴリ列のみ取得する。
  ///
  /// 初期表示でカテゴリ一覧だけ必要なケース向けの軽量クエリ。
  Future<List<String?>> getEmojiCategoriesForPicker() async {
    final rows = await (selectOnly(emojiTable)
          ..addColumns([emojiTable.category]))
        .get();

    return rows
        .map((row) => row.read(emojiTable.category))
        .toList(growable: false);
  }

  /// 指定トップカテゴリに属する絵文字のみ取得する。
  ///
  /// カテゴリ文字列をプレフィックスで絞り込み、
  /// 上位カテゴリへの遷移時の読み込み量を減らす。
  Future<List<EmojiPickerRow>> getEmojisForPickerByTopCategory(
    String topCategory,
  ) async {
    final query = selectOnly(emojiTable)
      ..addColumns([
        emojiTable.name,
        emojiTable.category,
        emojiTable.url,
        emojiTable.aliases,
      ]);

    if (topCategory == 'その他') {
      query.where(
        emojiTable.category.isNull() |
            emojiTable.category.equals('') |
            emojiTable.category.equals('その他') |
            emojiTable.category.like('その他/%'),
      );
    } else {
      query.where(emojiTable.category.like('$topCategory%'));
    }

    final rows = await query.get();
    return rows
        .map(
          (row) => EmojiPickerRow(
            name: row.read(emojiTable.name)!,
            category: row.read(emojiTable.category),
            url: row.read(emojiTable.url)!,
            aliases: row.read(emojiTable.aliases),
          ),
        )
        .toList(growable: false);
  }

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

/// リアクションピッカーが必要とする最小列の読み取りモデル。
class EmojiPickerRow {
  const EmojiPickerRow({
    required this.name,
    required this.category,
    required this.url,
    required this.aliases,
  });

  final String name;
  final String? category;
  final String url;
  final String? aliases;
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
