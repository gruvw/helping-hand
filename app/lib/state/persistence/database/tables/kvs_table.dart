import "package:drift/drift.dart";

class KvsTable extends Table {
  @override
  String get tableName => "kvs";

  @override
  Set<Column> get primaryKey => {key};

  TextColumn get key => text()();
  TextColumn get value => text()();
}
