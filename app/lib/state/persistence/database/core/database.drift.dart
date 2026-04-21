// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:helping_hand/state/persistence/database/tables/kvs_table.drift.dart'
    as i1;
import 'package:helping_hand/state/persistence/database/tables/remote_table.drift.dart'
    as i2;
import 'package:helping_hand/state/persistence/database/tables/folder_table.drift.dart'
    as i3;
import 'package:helping_hand/state/persistence/database/tables/tile_table.drift.dart'
    as i4;

abstract class $Database extends i0.GeneratedDatabase {
  $Database(i0.QueryExecutor e) : super(e);
  late final i1.$KvsTableTable kvsTable = i1.$KvsTableTable(this);
  late final i2.$RemoteTableTable remoteTable = i2.$RemoteTableTable(this);
  late final i3.$FolderTableTable folderTable = i3.$FolderTableTable(this);
  late final i4.$TileTableTable tileTable = i4.$TileTableTable(this);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [
    kvsTable,
    remoteTable,
    folderTable,
    tileTable,
  ];
  @override
  i0.DriftDatabaseOptions get options =>
      const i0.DriftDatabaseOptions(storeDateTimeAsText: true);
}
