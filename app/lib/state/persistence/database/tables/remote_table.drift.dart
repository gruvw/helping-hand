// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:helping_hand/state/persistence/database/tables/remote_table.drift.dart'
    as i1;
import 'package:helping_hand/state/persistence/database/tables/remote_table.dart'
    as i2;

class $RemoteTableTable extends i2.RemoteTable
    with i0.TableInfo<$RemoteTableTable, i1.RemoteTableData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _nameMeta = const i0.VerificationMeta(
    'name',
  );
  @override
  late final i0.GeneratedColumn<String> name = i0.GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<i0.GeneratedColumn> get $columns => [name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote';
  @override
  i0.VerificationContext validateIntegrity(
    i0.Insertable<i1.RemoteTableData> instance, {
    bool isInserting = false,
  }) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {name};
  @override
  i1.RemoteTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.RemoteTableData(
      name: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $RemoteTableTable createAlias(String alias) {
    return $RemoteTableTable(attachedDatabase, alias);
  }
}

class RemoteTableData extends i0.DataClass
    implements i0.Insertable<i1.RemoteTableData> {
  final String name;
  const RemoteTableData({required this.name});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['name'] = i0.Variable<String>(name);
    return map;
  }

  factory RemoteTableData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return RemoteTableData(name: serializer.fromJson<String>(json['name']));
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'name': serializer.toJson<String>(name)};
  }

  i1.RemoteTableData copyWith({String? name}) =>
      i1.RemoteTableData(name: name ?? this.name);
  RemoteTableData copyWithCompanion(i1.RemoteTableCompanion data) {
    return RemoteTableData(
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteTableData(')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => name.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.RemoteTableData && other.name == this.name);
}

class RemoteTableCompanion extends i0.UpdateCompanion<i1.RemoteTableData> {
  final i0.Value<String> name;
  final i0.Value<int> rowid;
  const RemoteTableCompanion({
    this.name = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  RemoteTableCompanion.insert({
    required String name,
    this.rowid = const i0.Value.absent(),
  }) : name = i0.Value(name);
  static i0.Insertable<i1.RemoteTableData> custom({
    i0.Expression<String>? name,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.RemoteTableCompanion copyWith({
    i0.Value<String>? name,
    i0.Value<int>? rowid,
  }) {
    return i1.RemoteTableCompanion(
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (name.present) {
      map['name'] = i0.Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteTableCompanion(')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
