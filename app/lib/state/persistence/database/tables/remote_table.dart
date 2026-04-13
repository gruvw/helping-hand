import "package:drift/drift.dart";

class RemoteTable extends Table {
  @override
  String get tableName => "remote";

  @override
  Set<Column> get primaryKey => {name};

  TextColumn get name => text()();
}
