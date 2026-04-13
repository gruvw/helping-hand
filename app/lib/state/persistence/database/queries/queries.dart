import "package:helping_hand/state/persistence/database/core/database.dart";

class Queries {
  final Database _db;

  Queries(this._db);

  Future<void> removeRemote(String remoteId) async {
    return _db.transaction(() async {
      final query = _db.delete(_db.remoteTable)
        ..where((t) => t.id.equals(remoteId));

      await query.go();

      // TODO delete other matches
    });
  }
}
