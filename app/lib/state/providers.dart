import "package:collection/collection.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/current_tile_id_path_notifier.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/remote_notifier.dart";
import "package:helping_hand/utils/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

final tilesProvider = FutureProvider<List<TileData>?>((ref) async {
  final currentTileId = ref.watch(currentTileIdProvider);

  switch (currentTileId) {
    case FolderTileId():
      return ref
          .watch(folderTilesProvider(currentTileId.folderId))
          .requireValue;
    case RemoteTileId():
      final actions = ref
          .watch(remoteNotifierProvider(currentTileId.remoteId).whereNotNull())
          .requireValue
          .actionConfigs;

      return actions
          ?.sortedBy((action) => action.name)
          .mapIndexed(
            (i, action) => TileData(
              tileId: RemoteActionTileId(
                parentId: currentTileId.remoteId,
                remoteId: currentTileId.remoteId,
                actionName: action.name,
              ),
              position: i,
            ),
          )
          .toList();
    case RemoteActionTileId():
      return []; // an action has no children tiles
  }
});
