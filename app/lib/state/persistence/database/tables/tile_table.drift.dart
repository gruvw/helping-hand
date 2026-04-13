// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:helping_hand/state/persistence/database/tables/tile_table.drift.dart'
    as i1;
import 'package:helping_hand/state/persistence/database/tables/tile_table.dart'
    as i2;

class $TileTableTable extends i2.TileTable
    with i0.TableInfo<$TileTableTable, i1.TileTableData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TileTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _keyMeta = const i0.VerificationMeta('key');
  @override
  late final i0.GeneratedColumn<String> key = i0.GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<i0.GeneratedColumn> get $columns => [key];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tile';
  @override
  i0.VerificationContext validateIntegrity(
    i0.Insertable<i1.TileTableData> instance, {
    bool isInserting = false,
  }) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {key};
  @override
  i1.TileTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.TileTableData(
      key: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
    );
  }

  @override
  $TileTableTable createAlias(String alias) {
    return $TileTableTable(attachedDatabase, alias);
  }
}

class TileTableData extends i0.DataClass
    implements i0.Insertable<i1.TileTableData> {
  final String key;
  const TileTableData({required this.key});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['key'] = i0.Variable<String>(key);
    return map;
  }

  factory TileTableData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return TileTableData(key: serializer.fromJson<String>(json['key']));
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key)};
  }

  i1.TileTableData copyWith({String? key}) =>
      i1.TileTableData(key: key ?? this.key);
  TileTableData copyWithCompanion(i1.TileTableCompanion data) {
    return TileTableData(key: data.key.present ? data.key.value : this.key);
  }

  @override
  String toString() {
    return (StringBuffer('TileTableData(')
          ..write('key: $key')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => key.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.TileTableData && other.key == this.key);
}

class TileTableCompanion extends i0.UpdateCompanion<i1.TileTableData> {
  final i0.Value<String> key;
  final i0.Value<int> rowid;
  const TileTableCompanion({
    this.key = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  TileTableCompanion.insert({
    required String key,
    this.rowid = const i0.Value.absent(),
  }) : key = i0.Value(key);
  static i0.Insertable<i1.TileTableData> custom({
    i0.Expression<String>? key,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (key != null) 'key': key,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.TileTableCompanion copyWith({
    i0.Value<String>? key,
    i0.Value<int>? rowid,
  }) {
    return i1.TileTableCompanion(
      key: key ?? this.key,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (key.present) {
      map['key'] = i0.Variable<String>(key.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TileTableCompanion(')
          ..write('key: $key, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
