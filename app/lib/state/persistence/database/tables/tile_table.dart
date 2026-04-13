import "package:drift/drift.dart";

// TODO tile modeling
// @UseRowClass(Score, constructor: "fromData")
class TileTable extends Table {
  @override
  String get tableName => "tile";

  @override
  Set<Column> get primaryKey => {key};

  TextColumn get key => text()();

  // @override
  // Set<Column> get primaryKey => {gameId, length};

  // TextColumn get gameId => text()();
  // IntColumn get length => integer()();

  // IntColumn get durationMs => integer()();
}
