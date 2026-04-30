import "package:helping_hand/utils/language.dart";

class TileData {
  final String? parentId;
  final TileId id;
  final int position;

  TileData({
    required this.parentId,
    required this.id,
    required this.position,
  });

  TileData.fromData({
    required this.parentId,
    required String id,
    required this.position,
  }) : id = TileId.parse(id);
}

sealed class TileId {
  static final folderPrefix = "\$";
  static final actionSeparator = ":";

  static TileId parse(String? tileId) {
    if (tileId == null || tileId.startsWith(folderPrefix)) {
      return FolderTileId(tileId);
    }

    final (remoteId, actionName) = tileId.splitOnce(actionSeparator);
    if (actionName != null) {
      return RemoteActionTileId(remoteId, actionName);
    }

    return RemoteTileId(remoteId);
  }

  const TileId();
}

class FolderTileId extends TileId {
  final String? folderId;

  const FolderTileId(this.folderId);
}

class RemoteTileId extends TileId {
  final String remoteId;

  const RemoteTileId(this.remoteId);
}

class RemoteActionTileId extends TileId {
  final String remoteId;
  final String actionName;

  late final String id = "$remoteId${TileId.actionSeparator}$actionName";

  RemoteActionTileId(this.remoteId, this.actionName);
}
