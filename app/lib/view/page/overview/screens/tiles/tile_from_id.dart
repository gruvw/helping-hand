import "package:flutter/material.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/providers.dart";
import "package:helping_hand/state/remote_notifier.dart";
import "package:helping_hand/state/remote_request.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/utils/language.dart";
import "package:helping_hand/view/page/overview/screens/tiles/tile_content.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class TileFromId extends HookConsumerWidget {
  final String tileId;

  const TileFromId({
    super.key,
    required this.tileId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = ref.watch(folderProvider(tileId)).value;

    final remote = ref.watch(remoteNotifierProvider(tileId));
    final remoteValue = remote.value;

    final (remoteIdButton, remoteButtonName) = tileId.splitOnce(
      TileData.idSeparator,
    );
    final remoteButton = ref.watch(remoteNotifierProvider(remoteIdButton));
    final remoteButtonValue = remoteButton.value;

    if (remoteValue != null) {
      return remote.maybeWhen(
        data: (remote) {
          if (remote.isOnline) {
            return TileContent.icon(
              title: remote.name,
              iconData: Styles.iconRemote,
              color: Styles.colorRemote,
              onClick: () {
                ref.read(currentTileIdProvider.notifier).state = remote.id;
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
            title: remoteValue.name,
          );
        },
      );
    }

    if (folder != null) {
      return TileContent.icon(
        title: folder.name,
        iconData: Styles.iconFolder,
        color: Styles.colorFolder,
        onClick: () {
          ref.read(currentTileIdProvider.notifier).state = folder.id;
        },
      );
    }

    if (remoteButtonName != null && remoteButtonValue != null) {
      final buttonDisplay = "${remoteButtonValue.name}\n$remoteButtonName";

      return remoteButton.maybeWhen(
        data: (remoteButton) {
          final remoteButtonActions = remoteButton.actionConfigs;
          if (remoteButtonActions == null) {
            return TileContent.icon(
              title: buttonDisplay,
              iconData: Styles.iconOffline,
              color: Styles.colorOffline,
              onClick: () {
                ref.invalidate(remoteConfigProvider(remoteButton.id));
              },
            );
          }

          final action = remoteButtonActions
              .where((a) => a.name == remoteButtonName)
              .firstOrNull;

          if (action == null) {
            // TODO handle externally removed action
          }

          return TileContent.icon(
            title: buttonDisplay,
            iconData: Styles.iconButton,
            color: Styles.colorButton,
            onClick: () {
              // TODO perform action
            },
          );
        },
        orElse: () {
          return TileContent.loading(
            title: buttonDisplay,
          );
        },
      );
    }

    return TileContent.loading(title: "Loading...");
  }
}
