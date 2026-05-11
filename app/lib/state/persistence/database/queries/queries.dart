import "package:drift/drift.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/persistence/database/core/database.dart";
import "package:helping_hand/state/persistence/database/tables/folder_table.drift.dart";
import "package:helping_hand/state/persistence/database/tables/tile_table.drift.dart";
import "package:nanoid/nanoid.dart";

class Queries {
  final Database _db;

  Queries(this._db);

  Future<void> removeRemote(String remoteId) async {
    return _db.transaction(() async {
      final query = _db.delete(_db.remoteTable)
        ..where((t) => t.id.equals(remoteId));

      await query.go();

      // delete remote action tiles
      await removeStaleActionsFor(remoteId: remoteId, remoteActionNames: {});

      // delete remote tiles
      final remoteTiles = await (_db.select(
        _db.tileTable,
      )..where((r) => r.id.equals(remoteId))).get();

      for (final remoteTile in remoteTiles) {
        await removeTile(
          parentId: remoteTile.tileId.parentId,
          tileId: remoteTile.tileId.id!,
        );
      }
    });
  }

  Future<void> createTile({
    required String? parentFolderId,
    required String id,
  }) {
    return _db.transaction(() async {
      final nextPosition =
          (await (_db.select(
                    _db.tileTable,
                  )..where(
                    (r) => r.parentId.equals(
                      parentFolderId ?? TileId.rootFolderId,
                    ),
                  ))
                  .get())
              .length;

      await _db
          .into(_db.tileTable)
          .insert(
            TileTableCompanion.insert(
              parentId: parentFolderId ?? TileId.rootFolderId,
              id: id,
              position: nextPosition,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    });
  }

  Future<void> createFolder({
    required String name,
    required String? parentFolderId,
  }) {
    return _db.transaction(() async {
      final id = TileId.folderIdPrefix + nanoid();

      await _db
          .into(_db.folderTable)
          .insert(
            FolderTableCompanion.insert(id: id, name: name),
            mode: InsertMode.insertOrIgnore,
          );

      await createTile(id: id, parentFolderId: parentFolderId);
    });
  }

  Future<void> removeTile({
    required String? parentId,
    required String tileId,
  }) {
    return _db.transaction(() async {
      final children = await (_db.select(
        _db.tileTable,
      )..where((r) => r.parentId.equals(tileId))).get();

      // recursively delete children
      for (final child in children) {
        await removeTile(parentId: tileId, tileId: child.tileId.id!);
      }

      await (_db.delete(_db.tileTable)..where(
            (r) =>
                r.parentId.equals(parentId ?? TileId.rootFolderId) &
                r.id.equals(tileId),
          ))
          .go();
    });
  }

  Future<void> removeStaleActionsFor({
    required String remoteId,
    required Set<String> remoteActionNames,
  }) async {
    return _db.transaction(() async {
      final localRemoteActionTiles = await (_db.select(
        _db.tileTable,
      )..where((r) => r.id.contains(remoteId + TileId.actionSeparator))).get();

      for (final localRemoteActionTile in localRemoteActionTiles) {
        final localRemoteActionName =
            (localRemoteActionTile.tileId as RemoteActionTileId).actionName;
        if (!remoteActionNames.contains(localRemoteActionName)) {
          await removeTile(
            parentId: localRemoteActionTile.tileId.parentId,
            tileId: localRemoteActionTile.tileId.id!,
          );
        }
      }
    });
  }
}
