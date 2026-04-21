import "package:drift/drift.dart";
import "package:helping_hand/model/data/tile_data.dart";

@UseRowClass(TileData, constructor: "fromData")
class TileTable extends Table {
  @override
  String get tableName => "tile";

  @override
  Set<Column> get primaryKey => {parentId, id};

  TextColumn get parentId => text().nullable()();
  TextColumn get id => text()();
  IntColumn get position => integer()();
}
