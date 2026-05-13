import "package:collection/collection.dart";
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

      // delete the folder if it is a folder
      await (_db.delete(_db.folderTable)..where(
            (r) => r.id.equals(tileId),
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

  Future<List<(String? id, String path)>> getPaths(
    String exceptId,
    String? parentFolderId,
  ) async {
    final allTiles = await _db.select(_db.tileTable).get();
    final allFolders = await _db.select(_db.folderTable).get();

    final folderNamesById = {
      for (final f in allFolders) f.id: f.name,
    };
    final parentById = {
      for (final t in allTiles)
        if (folderNamesById.containsKey(t.tileId.id))
          t.tileId.id!: t.tileId.parentId,
    };

    String? buildPath(String folderId) {
      final parentId = parentById[folderId];
      final name = folderNamesById[folderId];

      if (folderId == exceptId) return null;

      if (parentId == null || parentId == TileId.rootFolderId) {
        return "${TileId.folderPathSeparator}$name";
      }

      final parentPath = buildPath(parentId);

      if (parentPath == null) {
        return null;
      }

      return "$parentPath${TileId.folderPathSeparator}$name";
    }

    return [
      (null, TileId.folderPathSeparator),
      ...allFolders.map((folder) {
        final path = buildPath(folder.id);
        if (path == null) return null;
        return (folder.id, path);
      }).nonNulls,
    ].where((a) => a.$1 != parentFolderId).sortedBy((a) => a.$2).toList();
  }

  Future<void> moveFolderTo({
    required String folderId,
    required String? newParentFolderId,
  }) async {
    return _db.transaction(() async {
      final nextPosition =
          (await (_db.select(
                    _db.tileTable,
                  )..where(
                    (r) => r.parentId.equals(
                      newParentFolderId ?? TileId.rootFolderId,
                    ),
                  ))
                  .get())
              .length;

      await (_db.update(
        _db.tileTable,
      )..where((r) => r.id.equals(folderId))).write(
        TileTableCompanion.insert(
          parentId: newParentFolderId ?? TileId.rootFolderId,
          id: folderId,
          position: nextPosition,
        ),
      );
    });
  }

  Future<void> reorderTiles({
    required String? folderId,
    required Map<String, int> idToNewPos,
  }) async {
    final parentId = folderId ?? TileId.rootFolderId;

    return _db.batch((batch) {
      for (final MapEntry(key: id, value: newPos) in idToNewPos.entries) {
        batch.update(
          _db.tileTable,
          TileTableCompanion(
            position: Value(newPos),
          ),
          where: (r) => r.parentId.equals(parentId) & r.id.equals(id),
        );
      }
    });
  }
}
