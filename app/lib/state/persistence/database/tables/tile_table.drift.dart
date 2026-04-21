// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:helping_hand/model/data/tile_data.dart' as i1;
import 'package:helping_hand/state/persistence/database/tables/tile_table.drift.dart'
    as i2;
import 'package:helping_hand/state/persistence/database/tables/tile_table.dart'
    as i3;

class $TileTableTable extends i3.TileTable
    with i0.TableInfo<$TileTableTable, i1.TileData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TileTableTable(this.attachedDatabase, [this._alias]);
  static const i0.VerificationMeta _parentIdMeta = const i0.VerificationMeta(
    'parentId',
  );
  @override
  late final i0.GeneratedColumn<String> parentId = i0.GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const i0.VerificationMeta _idMeta = const i0.VerificationMeta('id');
  @override
  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const i0.VerificationMeta _positionMeta = const i0.VerificationMeta(
    'position',
  );
  @override
  late final i0.GeneratedColumn<int> position = i0.GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<i0.GeneratedColumn> get $columns => [parentId, id, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tile';
  @override
  i0.VerificationContext validateIntegrity(
    i0.Insertable<i1.TileData> instance, {
    bool isInserting = false,
  }) {
    final context = i0.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<i0.GeneratedColumn> get $primaryKey => {parentId, id};
  @override
  i1.TileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.TileData.fromData(
      parentId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $TileTableTable createAlias(String alias) {
    return $TileTableTable(attachedDatabase, alias);
  }
}

class TileTableCompanion extends i0.UpdateCompanion<i1.TileData> {
  final i0.Value<String?> parentId;
  final i0.Value<String> id;
  final i0.Value<int> position;
  final i0.Value<int> rowid;
  const TileTableCompanion({
    this.parentId = const i0.Value.absent(),
    this.id = const i0.Value.absent(),
    this.position = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  TileTableCompanion.insert({
    this.parentId = const i0.Value.absent(),
    required String id,
    required int position,
    this.rowid = const i0.Value.absent(),
  }) : id = i0.Value(id),
       position = i0.Value(position);
  static i0.Insertable<i1.TileData> custom({
    i0.Expression<String>? parentId,
    i0.Expression<String>? id,
    i0.Expression<int>? position,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (parentId != null) 'parent_id': parentId,
      if (id != null) 'id': id,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i2.TileTableCompanion copyWith({
    i0.Value<String?>? parentId,
    i0.Value<String>? id,
    i0.Value<int>? position,
    i0.Value<int>? rowid,
  }) {
    return i2.TileTableCompanion(
      parentId: parentId ?? this.parentId,
      id: id ?? this.id,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (parentId.present) {
      map['parent_id'] = i0.Variable<String>(parentId.value);
    }
    if (id.present) {
      map['id'] = i0.Variable<String>(id.value);
    }
    if (position.present) {
      map['position'] = i0.Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TileTableCompanion(')
          ..write('parentId: $parentId, ')
          ..write('id: $id, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
