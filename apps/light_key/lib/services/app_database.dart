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

  /// 画像の元幅（px）。未取得の場合は null。
  IntColumn get width => integer().nullable()();

  /// 画像の元高さ（px）。未取得の場合は null。
  IntColumn get height => integer().nullable()();

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
  int get schemaVersion => 3;

  // -- Emoji CRUD -----------------------------------------------------------

  /// 全絵文字を取得する。
  Future<List<EmojiTableData>> getAllEmojis() => select(emojiTable).get();

  /// リアクションピッカー向けに必要最小限の列のみ取得する。
  Future<List<EmojiPickerRow>> getEmojisForPicker() async {
    final rows =
        await (selectOnly(emojiTable)..addColumns([
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
    final rows = await (selectOnly(
      emojiTable,
    )..addColumns([emojiTable.category])).get();

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
  Future<EmojiTableData?> getEmojiByName(String emojiName) => (select(
    emojiTable,
  )..where((t) => t.name.equals(emojiName))).getSingleOrNull();

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

  /// 絵文字を差分反映する。
  ///
  /// [upserts] は insert/update 対象、[keepNames] に含まれない既存行は削除する。
  Future<void> applyEmojiDiff({
    required List<EmojiTableCompanion> upserts,
    required Set<String> keepNames,
  }) async {
    await transaction(() async {
      if (upserts.isNotEmpty) {
        await batch((b) {
          b.insertAllOnConflictUpdate(emojiTable, upserts);
        });
      }

      if (keepNames.isEmpty) {
        await delete(emojiTable).go();
        return;
      }

      final existingNames =
          await (selectOnly(emojiTable)..addColumns([emojiTable.name])).get();
      final toDelete = <String>[];
      for (final row in existingNames) {
        final name = row.read(emojiTable.name);
        if (name != null && !keepNames.contains(name)) {
          toDelete.add(name);
        }
      }

      if (toDelete.isEmpty) {
        return;
      }

      const chunkSize = 400;
      for (var i = 0; i < toDelete.length; i += chunkSize) {
        final end = (i + chunkSize < toDelete.length)
            ? i + chunkSize
            : toDelete.length;
        final chunk = toDelete.sublist(i, end);
        await (delete(emojiTable)..where((t) => t.name.isIn(chunk))).go();
      }
    });
  }

  /// 絵文字のサイズ情報を upsert する。
  ///
  /// - 行が存在しない場合: [companion] の内容でそのまま挿入する。
  /// - 行が既に存在する場合（name が一致）: width / height **のみ**を更新し、
  ///   category・aliases などの既存データは保持する。
  Future<void> upsertEmojiSizes(List<EmojiTableCompanion> companions) async {
    await batch((b) {
      for (final c in companions) {
        b.insert(
          emojiTable,
          c,
          onConflict: DoUpdate(
            (_) => EmojiTableCompanion(width: c.width, height: c.height),
            target: [emojiTable.name],
          ),
        );
      }
    });
  }

  /// 指定した絵文字の width / height のみを一括更新する。
  ///
  /// [companions] の各エントリの [EmojiTableCompanion.name] をキーとして
  /// 対応する行の幅・高さを上書きする。
  Future<void> updateEmojiSizes(
    List<EmojiTableCompanion> companions,
  ) async {
    await transaction(() async {
      for (final c in companions) {
        await (update(emojiTable)..where((t) => t.name.equals(c.name.value)))
            .write(
              EmojiTableCompanion(width: c.width, height: c.height),
            );
      }
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
