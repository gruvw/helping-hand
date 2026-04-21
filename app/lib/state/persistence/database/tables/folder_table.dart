import "package:drift/drift.dart";
import "package:helping_hand/model/data/folder.dart";

@UseRowClass(Folder, constructor: "fromData")
class FolderTable extends Table {
  @override
  String get tableName => "folder";

  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get name => text()();
}
