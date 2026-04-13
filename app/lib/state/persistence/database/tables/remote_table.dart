import "package:drift/drift.dart";
import "package:helping_hand/model/config/remote.dart";

@UseRowClass(Remote, constructor: "fromData")
class RemoteTable extends Table {
  @override
  String get tableName => "remote";

  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get name => text()();
}
