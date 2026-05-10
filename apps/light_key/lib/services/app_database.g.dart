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

class $ReactionDeckTableTable extends ReactionDeckTable
    with TableInfo<$ReactionDeckTableTable, ReactionDeckTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReactionDeckTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [deckId, name, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reaction_decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReactionDeckTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deckId};
  @override
  ReactionDeckTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReactionDeckTableData(
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReactionDeckTableTable createAlias(String alias) {
    return $ReactionDeckTableTable(attachedDatabase, alias);
  }
}

class ReactionDeckTableData extends DataClass
    implements Insertable<ReactionDeckTableData> {
  final int deckId;
  final String name;
  final int updatedAt;
  const ReactionDeckTableData({
    required this.deckId,
    required this.name,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['deck_id'] = Variable<int>(deckId);
    map['name'] = Variable<String>(name);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ReactionDeckTableCompanion toCompanion(bool nullToAbsent) {
    return ReactionDeckTableCompanion(
      deckId: Value(deckId),
      name: Value(name),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReactionDeckTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReactionDeckTableData(
      deckId: serializer.fromJson<int>(json['deckId']),
      name: serializer.fromJson<String>(json['name']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deckId': serializer.toJson<int>(deckId),
      'name': serializer.toJson<String>(name),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ReactionDeckTableData copyWith({int? deckId, String? name, int? updatedAt}) =>
      ReactionDeckTableData(
        deckId: deckId ?? this.deckId,
        name: name ?? this.name,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ReactionDeckTableData copyWithCompanion(ReactionDeckTableCompanion data) {
    return ReactionDeckTableData(
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      name: data.name.present ? data.name.value : this.name,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReactionDeckTableData(')
          ..write('deckId: $deckId, ')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deckId, name, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReactionDeckTableData &&
          other.deckId == this.deckId &&
          other.name == this.name &&
          other.updatedAt == this.updatedAt);
}

class ReactionDeckTableCompanion
    extends UpdateCompanion<ReactionDeckTableData> {
  final Value<int> deckId;
  final Value<String> name;
  final Value<int> updatedAt;
  const ReactionDeckTableCompanion({
    this.deckId = const Value.absent(),
    this.name = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReactionDeckTableCompanion.insert({
    this.deckId = const Value.absent(),
    this.name = const Value.absent(),
    required int updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<ReactionDeckTableData> custom({
    Expression<int>? deckId,
    Expression<String>? name,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (deckId != null) 'deck_id': deckId,
      if (name != null) 'name': name,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReactionDeckTableCompanion copyWith({
    Value<int>? deckId,
    Value<String>? name,
    Value<int>? updatedAt,
  }) {
    return ReactionDeckTableCompanion(
      deckId: deckId ?? this.deckId,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReactionDeckTableCompanion(')
          ..write('deckId: $deckId, ')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ReactionDeckItemTableTable extends ReactionDeckItemTable
    with TableInfo<$ReactionDeckItemTableTable, ReactionDeckItemTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReactionDeckItemTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [deckId, position, emoji, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reaction_deck_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReactionDeckItemTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deckId, position};
  @override
  ReactionDeckItemTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReactionDeckItemTableData(
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReactionDeckItemTableTable createAlias(String alias) {
    return $ReactionDeckItemTableTable(attachedDatabase, alias);
  }
}

class ReactionDeckItemTableData extends DataClass
    implements Insertable<ReactionDeckItemTableData> {
  final int deckId;
  final int position;
  final String emoji;
  final int updatedAt;
  const ReactionDeckItemTableData({
    required this.deckId,
    required this.position,
    required this.emoji,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['deck_id'] = Variable<int>(deckId);
    map['position'] = Variable<int>(position);
    map['emoji'] = Variable<String>(emoji);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ReactionDeckItemTableCompanion toCompanion(bool nullToAbsent) {
    return ReactionDeckItemTableCompanion(
      deckId: Value(deckId),
      position: Value(position),
      emoji: Value(emoji),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReactionDeckItemTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReactionDeckItemTableData(
      deckId: serializer.fromJson<int>(json['deckId']),
      position: serializer.fromJson<int>(json['position']),
      emoji: serializer.fromJson<String>(json['emoji']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deckId': serializer.toJson<int>(deckId),
      'position': serializer.toJson<int>(position),
      'emoji': serializer.toJson<String>(emoji),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ReactionDeckItemTableData copyWith({
    int? deckId,
    int? position,
    String? emoji,
    int? updatedAt,
  }) => ReactionDeckItemTableData(
    deckId: deckId ?? this.deckId,
    position: position ?? this.position,
    emoji: emoji ?? this.emoji,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReactionDeckItemTableData copyWithCompanion(
    ReactionDeckItemTableCompanion data,
  ) {
    return ReactionDeckItemTableData(
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      position: data.position.present ? data.position.value : this.position,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReactionDeckItemTableData(')
          ..write('deckId: $deckId, ')
          ..write('position: $position, ')
          ..write('emoji: $emoji, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deckId, position, emoji, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReactionDeckItemTableData &&
          other.deckId == this.deckId &&
          other.position == this.position &&
          other.emoji == this.emoji &&
          other.updatedAt == this.updatedAt);
}

class ReactionDeckItemTableCompanion
    extends UpdateCompanion<ReactionDeckItemTableData> {
  final Value<int> deckId;
  final Value<int> position;
  final Value<String> emoji;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ReactionDeckItemTableCompanion({
    this.deckId = const Value.absent(),
    this.position = const Value.absent(),
    this.emoji = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReactionDeckItemTableCompanion.insert({
    required int deckId,
    required int position,
    required String emoji,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : deckId = Value(deckId),
       position = Value(position),
       emoji = Value(emoji),
       updatedAt = Value(updatedAt);
  static Insertable<ReactionDeckItemTableData> custom({
    Expression<int>? deckId,
    Expression<int>? position,
    Expression<String>? emoji,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deckId != null) 'deck_id': deckId,
      if (position != null) 'position': position,
      if (emoji != null) 'emoji': emoji,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReactionDeckItemTableCompanion copyWith({
    Value<int>? deckId,
    Value<int>? position,
    Value<String>? emoji,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ReactionDeckItemTableCompanion(
      deckId: deckId ?? this.deckId,
      position: position ?? this.position,
      emoji: emoji ?? this.emoji,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReactionDeckItemTableCompanion(')
          ..write('deckId: $deckId, ')
          ..write('position: $position, ')
          ..write('emoji: $emoji, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $ReactionDeckTableTable reactionDeckTable =
      $ReactionDeckTableTable(this);
  late final $ReactionDeckItemTableTable reactionDeckItemTable =
      $ReactionDeckItemTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    emojiTable,
    emojiUsageTable,
    reactionDeckTable,
    reactionDeckItemTable,
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
typedef $$ReactionDeckTableTableCreateCompanionBuilder =
    ReactionDeckTableCompanion Function({
      Value<int> deckId,
      Value<String> name,
      required int updatedAt,
    });
typedef $$ReactionDeckTableTableUpdateCompanionBuilder =
    ReactionDeckTableCompanion Function({
      Value<int> deckId,
      Value<String> name,
      Value<int> updatedAt,
    });

class $$ReactionDeckTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReactionDeckTableTable> {
  $$ReactionDeckTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReactionDeckTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReactionDeckTableTable> {
  $$ReactionDeckTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReactionDeckTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReactionDeckTableTable> {
  $$ReactionDeckTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReactionDeckTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReactionDeckTableTable,
          ReactionDeckTableData,
          $$ReactionDeckTableTableFilterComposer,
          $$ReactionDeckTableTableOrderingComposer,
          $$ReactionDeckTableTableAnnotationComposer,
          $$ReactionDeckTableTableCreateCompanionBuilder,
          $$ReactionDeckTableTableUpdateCompanionBuilder,
          (
            ReactionDeckTableData,
            BaseReferences<
              _$AppDatabase,
              $ReactionDeckTableTable,
              ReactionDeckTableData
            >,
          ),
          ReactionDeckTableData,
          PrefetchHooks Function()
        > {
  $$ReactionDeckTableTableTableManager(
    _$AppDatabase db,
    $ReactionDeckTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReactionDeckTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReactionDeckTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReactionDeckTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> deckId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => ReactionDeckTableCompanion(
                deckId: deckId,
                name: name,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> deckId = const Value.absent(),
                Value<String> name = const Value.absent(),
                required int updatedAt,
              }) => ReactionDeckTableCompanion.insert(
                deckId: deckId,
                name: name,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReactionDeckTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReactionDeckTableTable,
      ReactionDeckTableData,
      $$ReactionDeckTableTableFilterComposer,
      $$ReactionDeckTableTableOrderingComposer,
      $$ReactionDeckTableTableAnnotationComposer,
      $$ReactionDeckTableTableCreateCompanionBuilder,
      $$ReactionDeckTableTableUpdateCompanionBuilder,
      (
        ReactionDeckTableData,
        BaseReferences<
          _$AppDatabase,
          $ReactionDeckTableTable,
          ReactionDeckTableData
        >,
      ),
      ReactionDeckTableData,
      PrefetchHooks Function()
    >;
typedef $$ReactionDeckItemTableTableCreateCompanionBuilder =
    ReactionDeckItemTableCompanion Function({
      required int deckId,
      required int position,
      required String emoji,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ReactionDeckItemTableTableUpdateCompanionBuilder =
    ReactionDeckItemTableCompanion Function({
      Value<int> deckId,
      Value<int> position,
      Value<String> emoji,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$ReactionDeckItemTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReactionDeckItemTableTable> {
  $$ReactionDeckItemTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReactionDeckItemTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReactionDeckItemTableTable> {
  $$ReactionDeckItemTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReactionDeckItemTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReactionDeckItemTableTable> {
  $$ReactionDeckItemTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReactionDeckItemTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReactionDeckItemTableTable,
          ReactionDeckItemTableData,
          $$ReactionDeckItemTableTableFilterComposer,
          $$ReactionDeckItemTableTableOrderingComposer,
          $$ReactionDeckItemTableTableAnnotationComposer,
          $$ReactionDeckItemTableTableCreateCompanionBuilder,
          $$ReactionDeckItemTableTableUpdateCompanionBuilder,
          (
            ReactionDeckItemTableData,
            BaseReferences<
              _$AppDatabase,
              $ReactionDeckItemTableTable,
              ReactionDeckItemTableData
            >,
          ),
          ReactionDeckItemTableData,
          PrefetchHooks Function()
        > {
  $$ReactionDeckItemTableTableTableManager(
    _$AppDatabase db,
    $ReactionDeckItemTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReactionDeckItemTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ReactionDeckItemTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReactionDeckItemTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> deckId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReactionDeckItemTableCompanion(
                deckId: deckId,
                position: position,
                emoji: emoji,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int deckId,
                required int position,
                required String emoji,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ReactionDeckItemTableCompanion.insert(
                deckId: deckId,
                position: position,
                emoji: emoji,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReactionDeckItemTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReactionDeckItemTableTable,
      ReactionDeckItemTableData,
      $$ReactionDeckItemTableTableFilterComposer,
      $$ReactionDeckItemTableTableOrderingComposer,
      $$ReactionDeckItemTableTableAnnotationComposer,
      $$ReactionDeckItemTableTableCreateCompanionBuilder,
      $$ReactionDeckItemTableTableUpdateCompanionBuilder,
      (
        ReactionDeckItemTableData,
        BaseReferences<
          _$AppDatabase,
          $ReactionDeckItemTableTable,
          ReactionDeckItemTableData
        >,
      ),
      ReactionDeckItemTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EmojiTableTableTableManager get emojiTable =>
      $$EmojiTableTableTableManager(_db, _db.emojiTable);
  $$EmojiUsageTableTableTableManager get emojiUsageTable =>
      $$EmojiUsageTableTableTableManager(_db, _db.emojiUsageTable);
  $$ReactionDeckTableTableTableManager get reactionDeckTable =>
      $$ReactionDeckTableTableTableManager(_db, _db.reactionDeckTable);
  $$ReactionDeckItemTableTableTableManager get reactionDeckItemTable =>
      $$ReactionDeckItemTableTableTableManager(_db, _db.reactionDeckItemTable);
}
