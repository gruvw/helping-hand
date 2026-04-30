import "package:drift/drift.dart";
import "package:helping_hand/model/config/remote.dart";
import "package:helping_hand/model/data/folder.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/persistence/database/core/database.dart";
import "package:helping_hand/utils/language.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

final dbProvider = Provider<Database>(
  (ref) => Database.native(),
);

final remoteIdsProvider = StreamProvider<List<String>>((ref) {
  final db = ref.watch(dbProvider);

  return db
      .select(db.remoteTable)
      .map((remote) => remote.id)
      .watch()
      .distinct();
});

final localRemoteProvider = StreamProvider.family<Remote?, String>((
  ref,
  remoteId,
) {
  final db = ref.watch(dbProvider);

  return (db.select(
    db.remoteTable,
  )..where((r) => r.id.equals(remoteId))).watchSingle().distinct();
});

final folderProvider = StreamProvider.family<Folder?, String>((
  ref,
  folderId,
) {
  final db = ref.watch(dbProvider);

  return (db.select(
    db.folderTable,
  )..where((f) => f.id.equals(folderId))).watchSingleOrNull();
});

final folderTilesProvider = StreamProvider.family<List<TileData>, String?>((
  ref,
  folderId,
) {
  final db = ref.watch(dbProvider);

  return (db.select(db.tileTable)
        ..where(
          (t) =>
              folderId?.nmap((folderId) => t.parentId.equals(folderId)) ??
              t.parentId.isNull(),
        )
        ..orderBy([(t) => OrderingTerm.asc(t.position)]))
      .watch();
});

final tileProvider = StreamProvider.family<TileData?, String>((ref, tileId) {
  final db = ref.watch(dbProvider);

  return (db.select(
    db.tileTable,
  )..where((t) => t.id.equals(tileId))).watchSingle();
});
