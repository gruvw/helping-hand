import "package:flutter/material.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/current_tile_id_path_notifier.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/remote_notifier.dart";
import "package:helping_hand/state/remote_request.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/utils/language.dart";
import "package:helping_hand/utils/riverpod.dart";
import "package:helping_hand/view/page/tiles/tile_content.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class FolderTile extends ConsumerWidget {
  final FolderTileId id;

  const FolderTile({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = ref.watch(folderProvider(id.folderId!).whereNotNull());

    return folder.maybeWhen(
      data: (folder) => TileContent.icon(
        title: folder.name,
        iconData: Styles.iconFolder,
        color: Styles.colorFolder,
        onClick: () {
          ref.read(currentTileIdPathProvider.notifier).add(id);
        },
      ),
      orElse: () => TileContent.loading(title: "Loading..."),
    );
  }
}

class RemoteTile extends ConsumerWidget {
  final RemoteTileId id;

  const RemoteTile({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(
      remoteNotifierProvider(id.remoteId).whereNotNull(),
    );

    return remote.unwrapPrevious().maybeWhen(
      data: (remote) {
        if (remote.isOnline) {
          return TileContent.icon(
            title: remote.name,
            iconData: Styles.iconRemote,
            color: Styles.colorRemote,
            onClick: () {
              ref.read(currentTileIdPathProvider.notifier).add(id);
            },
          );
        }

        return TileContent.icon(
          title: remote.name,
          iconData: Styles.iconOffline,
          color: Styles.colorOffline,
          onClick: () {
            ref.invalidate(remoteConfigProvider(remote.id));
          },
        );
      },
      orElse: () {
        return TileContent.loading(
          title: remote.value?.name ?? "Loading...",
        );
      },
    );
  }
}

class RemoteActionTile extends ConsumerWidget {
  final RemoteActionTileId id;

  const RemoteActionTile({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(
      remoteNotifierProvider(id.remoteId).whereNotNull(),
    );

    final title = remote.value?.name ?? "Loading...";
    final subtitle = id.actionName;

    return remote.unwrapPrevious().maybeWhen(
      data: (remote) {
        final remoteButtonActions = remote.actionConfigs;
        if (remoteButtonActions == null) {
          return TileContent.icon(
            title: title,
            subtitle: subtitle,
            iconData: Styles.iconOffline,
            color: Styles.colorOffline,
            onClick: () {
              ref.invalidate(remoteConfigProvider(remote.id));
            },
          );
        }

        final action = remoteButtonActions
            .where((a) => a.name == id.actionName)
            .firstOrNull;

        return TileContent.icon(
          key: key,
          title: title,
          subtitle: subtitle,
          iconData: Styles.iconButton,
          color: Styles.colorButton,
          onClick: () {
            // TODO show perform state (loading, success / error)
            action?.nmap(
              (action) => ref
                  .read(remoteRequestServiceProvider(remote.id))
                  .perform(action),
            );
          },
        );
      },
      orElse: () {
        return TileContent.loading(
          title: title,
          subtitle: subtitle,
        );
      },
    );
  }
}
