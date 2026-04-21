// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:helping_hand/model/data/folder.dart' as i1;
import 'package:helping_hand/state/persistence/database/tables/folder_table.drift.dart'
    as i2;
import 'package:helping_hand/state/persistence/database/tables/folder_table.dart'
    as i3;

class $FolderTableTable extends i3.FolderTable
    with i0.TableInfo<$FolderTableTable, i1.Folder> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FolderTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _idMeta = const i0.VerificationMeta('id');
  @override
  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  List<i0.GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folder';
  @override
  i0.VerificationContext validateIntegrity(
    i0.Insertable<i1.Folder> instance, {
    bool isInserting = false,
  }) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
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
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i1.Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.Folder.fromData(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $FolderTableTable createAlias(String alias) {
    return $FolderTableTable(attachedDatabase, alias);
  }
}

class FolderTableCompanion extends i0.UpdateCompanion<i1.Folder> {
  final i0.Value<String> id;
  final i0.Value<String> name;
  final i0.Value<int> rowid;
  const FolderTableCompanion({
    this.id = const i0.Value.absent(),
    this.name = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  FolderTableCompanion.insert({
    required String id,
    required String name,
    this.rowid = const i0.Value.absent(),
  }) : id = i0.Value(id),
       name = i0.Value(name);
  static i0.Insertable<i1.Folder> custom({
    i0.Expression<String>? id,
    i0.Expression<String>? name,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i2.FolderTableCompanion copyWith({
    i0.Value<String>? id,
    i0.Value<String>? name,
    i0.Value<int>? rowid,
  }) {
    return i2.FolderTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<String>(id.value);
    }
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
    return (StringBuffer('FolderTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
