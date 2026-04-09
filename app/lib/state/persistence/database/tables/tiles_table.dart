import "package:drift/drift.dart";

// TODO tiles modeling
// @UseRowClass(Score, constructor: "fromData")
class TilesTable extends Table {
  @override
  String get tableName => "high_score";

  @override
  Set<Column> get primaryKey => {key};

  TextColumn get key => text()();

  // @override
  // Set<Column> get primaryKey => {gameId, length};

  // TextColumn get gameId => text()();
  // IntColumn get length => integer()();

  // IntColumn get durationMs => integer()();
}
