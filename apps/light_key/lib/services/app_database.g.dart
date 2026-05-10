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
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [
    name,
    category,
    url,
    width,
    height,
    aliases,
  ];
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
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
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
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
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

  /// 画像の元幅（px）。未取得の場合は null。
  final int? width;

  /// 画像の元高さ（px）。未取得の場合は null。
  final int? height;

  /// エイリアスを JSON 文字列として保存。例: '["ai","acid"]'
  final String? aliases;
  const EmojiTableData({
    required this.name,
    this.category,
    required this.url,
    this.width,
    this.height,
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
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
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
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
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
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
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
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'aliases': serializer.toJson<String?>(aliases),
    };
  }

  EmojiTableData copyWith({
    String? name,
    Value<String?> category = const Value.absent(),
    String? url,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<String?> aliases = const Value.absent(),
  }) => EmojiTableData(
    name: name ?? this.name,
    category: category.present ? category.value : this.category,
    url: url ?? this.url,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    aliases: aliases.present ? aliases.value : this.aliases,
  );
  EmojiTableData copyWithCompanion(EmojiTableCompanion data) {
    return EmojiTableData(
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      url: data.url.present ? data.url.value : this.url,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmojiTableData(')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('url: $url, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('aliases: $aliases')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, category, url, width, height, aliases);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmojiTableData &&
          other.name == this.name &&
          other.category == this.category &&
          other.url == this.url &&
          other.width == this.width &&
          other.height == this.height &&
          other.aliases == this.aliases);
}

class EmojiTableCompanion extends UpdateCompanion<EmojiTableData> {
  final Value<String> name;
  final Value<String?> category;
  final Value<String> url;
  final Value<int?> width;
  final Value<int?> height;
  final Value<String?> aliases;
  final Value<int> rowid;
  const EmojiTableCompanion({
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.url = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.aliases = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmojiTableCompanion.insert({
    required String name,
    this.category = const Value.absent(),
    required String url,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.aliases = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       url = Value(url);
  static Insertable<EmojiTableData> custom({
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? url,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? aliases,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (url != null) 'url': url,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (aliases != null) 'aliases': aliases,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmojiTableCompanion copyWith({
    Value<String>? name,
    Value<String?>? category,
    Value<String>? url,
    Value<int?>? width,
    Value<int?>? height,
    Value<String?>? aliases,
    Value<int>? rowid,
  }) {
    return EmojiTableCompanion(
      name: name ?? this.name,
      category: category ?? this.category,
      url: url ?? this.url,
      width: width ?? this.width,
      height: height ?? this.height,
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
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
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
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('aliases: $aliases, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmojiUsageTableTable extends EmojiUsageTable
    with TableInfo<$EmojiUsageTableTable, EmojiUsageTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmojiUsageTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usedCountMeta = const VerificationMeta(
    'usedCount',
  );
  @override
  late final GeneratedColumn<int> usedCount = GeneratedColumn<int>(
    'used_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<int> lastUsedAt = GeneratedColumn<int>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [emoji, usedCount, lastUsedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emoji_usages';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmojiUsageTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('used_count')) {
      context.handle(
        _usedCountMeta,
        usedCount.isAcceptableOrUnknown(data['used_count']!, _usedCountMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {emoji};
  @override
  EmojiUsageTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmojiUsageTableData(
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      usedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}used_count'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_used_at'],
      )!,
    );
  }

  @override
  $EmojiUsageTableTable createAlias(String alias) {
    return $EmojiUsageTableTable(attachedDatabase, alias);
  }
}

class EmojiUsageTableData extends DataClass
    implements Insertable<EmojiUsageTableData> {
  /// 選択された絵文字文字列。
  final String emoji;

  /// 累計利用回数。
  final int usedCount;

  /// 最終利用時刻（epoch milliseconds）。
  final int lastUsedAt;
  const EmojiUsageTableData({
    required this.emoji,
    required this.usedCount,
    required this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['emoji'] = Variable<String>(emoji);
    map['used_count'] = Variable<int>(usedCount);
    map['last_used_at'] = Variable<int>(lastUsedAt);
    return map;
  }

  EmojiUsageTableCompanion toCompanion(bool nullToAbsent) {
    return EmojiUsageTableCompanion(
      emoji: Value(emoji),
      usedCount: Value(usedCount),
      lastUsedAt: Value(lastUsedAt),
    );
  }

  factory EmojiUsageTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmojiUsageTableData(
      emoji: serializer.fromJson<String>(json['emoji']),
      usedCount: serializer.fromJson<int>(json['usedCount']),
      lastUsedAt: serializer.fromJson<int>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'emoji': serializer.toJson<String>(emoji),
      'usedCount': serializer.toJson<int>(usedCount),
      'lastUsedAt': serializer.toJson<int>(lastUsedAt),
    };
  }

  EmojiUsageTableData copyWith({
    String? emoji,
    int? usedCount,
    int? lastUsedAt,
  }) => EmojiUsageTableData(
    emoji: emoji ?? this.emoji,
    usedCount: usedCount ?? this.usedCount,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
  );
  EmojiUsageTableData copyWithCompanion(EmojiUsageTableCompanion data) {
    return EmojiUsageTableData(
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      usedCount: data.usedCount.present ? data.usedCount.value : this.usedCount,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmojiUsageTableData(')
          ..write('emoji: $emoji, ')
          ..write('usedCount: $usedCount, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(emoji, usedCount, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmojiUsageTableData &&
          other.emoji == this.emoji &&
          other.usedCount == this.usedCount &&
          other.lastUsedAt == this.lastUsedAt);
}

class EmojiUsageTableCompanion extends UpdateCompanion<EmojiUsageTableData> {
  final Value<String> emoji;
  final Value<int> usedCount;
  final Value<int> lastUsedAt;
  final Value<int> rowid;
  const EmojiUsageTableCompanion({
    this.emoji = const Value.absent(),
    this.usedCount = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmojiUsageTableCompanion.insert({
    required String emoji,
    this.usedCount = const Value.absent(),
    required int lastUsedAt,
    this.rowid = const Value.absent(),
  }) : emoji = Value(emoji),
       lastUsedAt = Value(lastUsedAt);
  static Insertable<EmojiUsageTableData> custom({
    Expression<String>? emoji,
    Expression<int>? usedCount,
    Expression<int>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (emoji != null) 'emoji': emoji,
      if (usedCount != null) 'used_count': usedCount,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmojiUsageTableCompanion copyWith({
    Value<String>? emoji,
    Value<int>? usedCount,
    Value<int>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return EmojiUsageTableCompanion(
      emoji: emoji ?? this.emoji,
      usedCount: usedCount ?? this.usedCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (usedCount.present) {
      map['used_count'] = Variable<int>(usedCount.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<int>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmojiUsageTableCompanion(')
          ..write('emoji: $emoji, ')
          ..write('usedCount: $usedCount, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EmojiTableTable emojiTable = $EmojiTableTable(this);
  late final $EmojiUsageTableTable emojiUsageTable = $EmojiUsageTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    emojiTable,
    emojiUsageTable,
  ];
}

typedef $$EmojiTableTableCreateCompanionBuilder =
    EmojiTableCompanion Function({
      required String name,
      Value<String?> category,
      required String url,
      Value<int?> width,
      Value<int?> height,
      Value<String?> aliases,
      Value<int> rowid,
    });
typedef $$EmojiTableTableUpdateCompanionBuilder =
    EmojiTableCompanion Function({
      Value<String> name,
      Value<String?> category,
      Value<String> url,
      Value<int?> width,
      Value<int?> height,
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

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
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

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
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

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

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
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String?> aliases = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmojiTableCompanion(
                name: name,
                category: category,
                url: url,
                width: width,
                height: height,
                aliases: aliases,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                Value<String?> category = const Value.absent(),
                required String url,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String?> aliases = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmojiTableCompanion.insert(
                name: name,
                category: category,
                url: url,
                width: width,
                height: height,
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
typedef $$EmojiUsageTableTableCreateCompanionBuilder =
    EmojiUsageTableCompanion Function({
      required String emoji,
      Value<int> usedCount,
      required int lastUsedAt,
      Value<int> rowid,
    });
typedef $$EmojiUsageTableTableUpdateCompanionBuilder =
    EmojiUsageTableCompanion Function({
      Value<String> emoji,
      Value<int> usedCount,
      Value<int> lastUsedAt,
      Value<int> rowid,
    });

class $$EmojiUsageTableTableFilterComposer
    extends Composer<_$AppDatabase, $EmojiUsageTableTable> {
  $$EmojiUsageTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usedCount => $composableBuilder(
    column: $table.usedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmojiUsageTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EmojiUsageTableTable> {
  $$EmojiUsageTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usedCount => $composableBuilder(
    column: $table.usedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmojiUsageTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmojiUsageTableTable> {
  $$EmojiUsageTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get usedCount =>
      $composableBuilder(column: $table.usedCount, builder: (column) => column);

  GeneratedColumn<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$EmojiUsageTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmojiUsageTableTable,
          EmojiUsageTableData,
          $$EmojiUsageTableTableFilterComposer,
          $$EmojiUsageTableTableOrderingComposer,
          $$EmojiUsageTableTableAnnotationComposer,
          $$EmojiUsageTableTableCreateCompanionBuilder,
          $$EmojiUsageTableTableUpdateCompanionBuilder,
          (
            EmojiUsageTableData,
            BaseReferences<
              _$AppDatabase,
              $EmojiUsageTableTable,
              EmojiUsageTableData
            >,
          ),
          EmojiUsageTableData,
          PrefetchHooks Function()
        > {
  $$EmojiUsageTableTableTableManager(
    _$AppDatabase db,
    $EmojiUsageTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmojiUsageTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmojiUsageTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmojiUsageTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> emoji = const Value.absent(),
                Value<int> usedCount = const Value.absent(),
                Value<int> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmojiUsageTableCompanion(
                emoji: emoji,
                usedCount: usedCount,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String emoji,
                Value<int> usedCount = const Value.absent(),
                required int lastUsedAt,
                Value<int> rowid = const Value.absent(),
              }) => EmojiUsageTableCompanion.insert(
                emoji: emoji,
                usedCount: usedCount,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmojiUsageTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmojiUsageTableTable,
      EmojiUsageTableData,
      $$EmojiUsageTableTableFilterComposer,
      $$EmojiUsageTableTableOrderingComposer,
      $$EmojiUsageTableTableAnnotationComposer,
      $$EmojiUsageTableTableCreateCompanionBuilder,
      $$EmojiUsageTableTableUpdateCompanionBuilder,
      (
        EmojiUsageTableData,
        BaseReferences<
          _$AppDatabase,
          $EmojiUsageTableTable,
          EmojiUsageTableData
        >,
      ),
      EmojiUsageTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EmojiTableTableTableManager get emojiTable =>
      $$EmojiTableTableTableManager(_db, _db.emojiTable);
  $$EmojiUsageTableTableTableManager get emojiUsageTable =>
      $$EmojiUsageTableTableTableManager(_db, _db.emojiUsageTable);
}
