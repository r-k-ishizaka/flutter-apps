// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $EmojiTableTable extends EmojiTable
    with TableInfo<$EmojiTableTable, EmojiTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmojiTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasesMeta = const VerificationMeta(
    'aliases',
  );
  @override
  late final GeneratedColumn<String> aliases = GeneratedColumn<String>(
    'aliases',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [name, category, url, aliases];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emojis';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmojiTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('aliases')) {
      context.handle(
        _aliasesMeta,
        aliases.isAcceptableOrUnknown(data['aliases']!, _aliasesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  EmojiTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmojiTableData(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      aliases: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aliases'],
      ),
    );
  }

  @override
  $EmojiTableTable createAlias(String alias) {
    return $EmojiTableTable(attachedDatabase, alias);
  }
}

class EmojiTableData extends DataClass implements Insertable<EmojiTableData> {
  /// 絵文字名（shortcode）。例: "ai_acid_misskeyio"
  final String name;

  /// カテゴリ。例: "000 Misskey.io Original"
  final String? category;

  /// 画像 URL。
  final String url;

  /// エイリアスを JSON 文字列として保存。例: '["ai","acid"]'
  final String? aliases;
  const EmojiTableData({
    required this.name,
    this.category,
    required this.url,
    this.aliases,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || aliases != null) {
      map['aliases'] = Variable<String>(aliases);
    }
    return map;
  }

  EmojiTableCompanion toCompanion(bool nullToAbsent) {
    return EmojiTableCompanion(
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      url: Value(url),
      aliases: aliases == null && nullToAbsent
          ? const Value.absent()
          : Value(aliases),
    );
  }

  factory EmojiTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmojiTableData(
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String?>(json['category']),
      url: serializer.fromJson<String>(json['url']),
      aliases: serializer.fromJson<String?>(json['aliases']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String?>(category),
      'url': serializer.toJson<String>(url),
      'aliases': serializer.toJson<String?>(aliases),
    };
  }

  EmojiTableData copyWith({
    String? name,
    Value<String?> category = const Value.absent(),
    String? url,
    Value<String?> aliases = const Value.absent(),
  }) => EmojiTableData(
    name: name ?? this.name,
    category: category.present ? category.value : this.category,
    url: url ?? this.url,
    aliases: aliases.present ? aliases.value : this.aliases,
  );
  EmojiTableData copyWithCompanion(EmojiTableCompanion data) {
    return EmojiTableData(
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      url: data.url.present ? data.url.value : this.url,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmojiTableData(')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('url: $url, ')
          ..write('aliases: $aliases')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, category, url, aliases);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmojiTableData &&
          other.name == this.name &&
          other.category == this.category &&
          other.url == this.url &&
          other.aliases == this.aliases);
}

class EmojiTableCompanion extends UpdateCompanion<EmojiTableData> {
  final Value<String> name;
  final Value<String?> category;
  final Value<String> url;
  final Value<String?> aliases;
  final Value<int> rowid;
  const EmojiTableCompanion({
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.url = const Value.absent(),
    this.aliases = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmojiTableCompanion.insert({
    required String name,
    this.category = const Value.absent(),
    required String url,
    this.aliases = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       url = Value(url);
  static Insertable<EmojiTableData> custom({
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? url,
    Expression<String>? aliases,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (url != null) 'url': url,
      if (aliases != null) 'aliases': aliases,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmojiTableCompanion copyWith({
    Value<String>? name,
    Value<String?>? category,
    Value<String>? url,
    Value<String?>? aliases,
    Value<int>? rowid,
  }) {
    return EmojiTableCompanion(
      name: name ?? this.name,
      category: category ?? this.category,
      url: url ?? this.url,
      aliases: aliases ?? this.aliases,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(aliases.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmojiTableCompanion(')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('url: $url, ')
          ..write('aliases: $aliases, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EmojiTableTable emojiTable = $EmojiTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [emojiTable];
}

typedef $$EmojiTableTableCreateCompanionBuilder =
    EmojiTableCompanion Function({
      required String name,
      Value<String?> category,
      required String url,
      Value<String?> aliases,
      Value<int> rowid,
    });
typedef $$EmojiTableTableUpdateCompanionBuilder =
    EmojiTableCompanion Function({
      Value<String> name,
      Value<String?> category,
      Value<String> url,
      Value<String?> aliases,
      Value<int> rowid,
    });

class $$EmojiTableTableFilterComposer
    extends Composer<_$AppDatabase, $EmojiTableTable> {
  $$EmojiTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmojiTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EmojiTableTable> {
  $$EmojiTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmojiTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmojiTableTable> {
  $$EmojiTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);
}

class $$EmojiTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmojiTableTable,
          EmojiTableData,
          $$EmojiTableTableFilterComposer,
          $$EmojiTableTableOrderingComposer,
          $$EmojiTableTableAnnotationComposer,
          $$EmojiTableTableCreateCompanionBuilder,
          $$EmojiTableTableUpdateCompanionBuilder,
          (
            EmojiTableData,
            BaseReferences<_$AppDatabase, $EmojiTableTable, EmojiTableData>,
          ),
          EmojiTableData,
          PrefetchHooks Function()
        > {
  $$EmojiTableTableTableManager(_$AppDatabase db, $EmojiTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmojiTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmojiTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmojiTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> aliases = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmojiTableCompanion(
                name: name,
                category: category,
                url: url,
                aliases: aliases,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                Value<String?> category = const Value.absent(),
                required String url,
                Value<String?> aliases = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmojiTableCompanion.insert(
                name: name,
                category: category,
                url: url,
                aliases: aliases,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmojiTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmojiTableTable,
      EmojiTableData,
      $$EmojiTableTableFilterComposer,
      $$EmojiTableTableOrderingComposer,
      $$EmojiTableTableAnnotationComposer,
      $$EmojiTableTableCreateCompanionBuilder,
      $$EmojiTableTableUpdateCompanionBuilder,
      (
        EmojiTableData,
        BaseReferences<_$AppDatabase, $EmojiTableTable, EmojiTableData>,
      ),
      EmojiTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EmojiTableTableTableManager get emojiTable =>
      $$EmojiTableTableTableManager(_db, _db.emojiTable);
}
