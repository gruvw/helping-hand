// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:helping_hand/state/persistence/database/tables/tiles_table.drift.dart'
    as i1;
import 'package:helping_hand/state/persistence/database/tables/kvs_table.drift.dart'
    as i2;

abstract class $Database extends i0.GeneratedDatabase {
  $Database(i0.QueryExecutor e) : super(e);
  late final i1.$TilesTableTable tilesTable = i1.$TilesTableTable(this);
  late final i2.$KvsTableTable kvsTable = i2.$KvsTableTable(this);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [tilesTable, kvsTable];
  @override
  i0.DriftDatabaseOptions get options =>
      const i0.DriftDatabaseOptions(storeDateTimeAsText: true);
}
