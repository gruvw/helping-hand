import "package:helping_hand/utils/language.dart";

class TileData {
  final String? parentId;
  final TileId tileId;
  final int position;

  TileData({
    required this.parentId,
    required this.tileId,
    required this.position,
  });

  TileData.fromData({
    required this.parentId,
    required String id,
    required this.position,
  }) : tileId = TileId.parse(parentId, id);
}

sealed class TileId {
  static final rootFolder = TileId.parse(null, null);

  static final folderPrefix = "\$";
  static final folderPathSeparator = "/";
  static final actionSeparator = ":";

  static TileId parse(String? parentId, String? id) {
    if (id == null || id.startsWith(folderPrefix)) {
      return FolderTileId(parentId: parentId, folderId: id);
    }

    final (remoteId, actionName) = id.splitOnce(actionSeparator);
    if (actionName != null) {
      return RemoteActionTileId(
        parentId: parentId,
        remoteId: remoteId,
        actionName: actionName,
      );
    }

    return RemoteTileId(parentId: parentId, remoteId: remoteId);
  }

  final String? parentId;

  const TileId({required this.parentId});

  String? get id;

  bool get isRootFolder => id == null;
}

class FolderTileId extends TileId {
  final String? folderId;

  const FolderTileId({required super.parentId, required this.folderId});

  @override
  String? get id => folderId;
}

class RemoteTileId extends TileId {
  final String remoteId;

  const RemoteTileId({required super.parentId, required this.remoteId});

  @override
  String? get id => remoteId;
}

class RemoteActionTileId extends TileId {
  final String remoteId;
  final String actionName;

  @override
  final String id;

  RemoteActionTileId({
    required super.parentId,
    required this.remoteId,
    required this.actionName,
  }) : id = "$remoteId${TileId.actionSeparator}$actionName";
}
