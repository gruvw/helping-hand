// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:helping_hand/state/persistence/database/tables/tile_table.drift.dart'
    as i1;
import 'package:helping_hand/state/persistence/database/tables/kvs_table.drift.dart'
    as i2;
import 'package:helping_hand/state/persistence/database/tables/remote_table.drift.dart'
    as i3;

abstract class $Database extends i0.GeneratedDatabase {
  $Database(i0.QueryExecutor e) : super(e);
  late final i1.$TileTableTable tileTable = i1.$TileTableTable(this);
  late final i2.$KvsTableTable kvsTable = i2.$KvsTableTable(this);
  late final i3.$RemoteTableTable remoteTable = i3.$RemoteTableTable(this);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [
    tileTable,
    kvsTable,
    remoteTable,
  ];
  @override
  i0.DriftDatabaseOptions get options =>
      const i0.DriftDatabaseOptions(storeDateTimeAsText: true);
}
