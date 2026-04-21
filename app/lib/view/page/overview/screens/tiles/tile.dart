import "package:flutter/material.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/remote_notifier.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/utils/language.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class Tile extends HookConsumerWidget {
  final String tileId;

  const Tile({
    super.key,
    required this.tileId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = ref.watch(folderProvider(tileId)).value;

    final remote = ref.watch(remoteNotifierProvider(tileId)).value;
    final remoteActions = remote?.actionConfigs;

    final (remoteIdButton, remoteButtonName) = tileId.splitOnce(
      TileData.idSeparator,
    );
    final remoteButton = ref
        .watch(remoteNotifierProvider(remoteIdButton))
        .value;
    final remoteButtonActions = remoteButton?.actionConfigs;

    if (remote != null) {
      if (remoteActions == null) {
        // TODO offline remote tile
        return SizedBox();
      }
      // TODO remote tile
      return SizedBox();
    }

    if (folder != null) {
      // TODO folder tile
      return SizedBox();
    }

    if (remoteButton != null) {
      if (remoteButtonActions == null) {
        // TODO offline button tile
        return SizedBox();
      }
      final action = remoteButtonActions
          .where(
            (a) => a.name == remoteButtonName,
          )
          .firstOrNull;
      if (action == null) {
        // TODO delete button tile, remote is online but does not have the button
        return SizedBox();
      }
      // TODO button tile for action
      return SizedBox();
    }

    return Center(
      child: CircularProgressIndicator(
        color: Styles.colorPrimary,
      ),
    );
  }
}

class TileContent extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Color color;

  const TileContent({
    super.key,
    required this.title,
    required this.iconData,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: null,
    );
  }
}
