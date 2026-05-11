import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:helping_hand/logic/action_state.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/current_tile_id_path_notifier.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/remote_notifier.dart";
import "package:helping_hand/state/remote_request.dart";
import "package:helping_hand/static/styles.dart";
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
      orElse: () => TileContent.loading(
        title: "Loading...",
        color: Styles.colorOffline,
      ),
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
          color: Styles.colorOffline,
        );
      },
    );
  }
}

class RemoteActionTile extends HookConsumerWidget {
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
    final performState = useState(ActionState.nothing);
    final resetTimer = useRef<Timer?>(null);

    final title = remote.value?.name ?? "Loading...";
    final subtitle = id.actionName;

    final offlineAction = TileContent.icon(
      title: title,
      subtitle: subtitle,
      iconData: Styles.iconOffline,
      color: Styles.colorOffline,
      onClick: () {
        ref.invalidate(remoteConfigProvider(id.remoteId));
      },
    );

    return remote.unwrapPrevious().maybeWhen(
      data: (remote) {
        final remoteButtonActions = remote.actionConfigs;
        if (remoteButtonActions == null) {
          return offlineAction;
        }

        final action = remoteButtonActions
            .where((a) => a.name == id.actionName)
            .firstOrNull;

        Future<void> performAction() async {
          if (action == null) return;

          resetTimer.value?.cancel();
          performState.value = ActionState.pending;

          await ref
              .read(remoteRequestServiceProvider(remote.id))
              .perform(action)
              .then(
                (_) {
                  if (context.mounted) {
                    performState.value = ActionState.success;
                  }
                },
                onError: (_, _) {
                  if (context.mounted) {
                    performState.value = ActionState.error;
                  }
                },
              );

          if (context.mounted) {
            resetTimer.value = Timer(const Duration(milliseconds: 1500), () {
              if (context.mounted) {
                performState.value = ActionState.nothing;
              }
            });
          }
        }

        if (performState.value == ActionState.pending) {
          return TileContent.loading(
            key: key,
            title: title,
            subtitle: subtitle,
            color: Styles.colorButton,
          );
        }

        return TileContent.icon(
          key: key,
          title: title,
          subtitle: subtitle,
          iconData: switch (performState.value) {
            ActionState.nothing => Styles.iconButton,
            ActionState.success => Styles.iconSuccess,
            ActionState.error => Styles.iconError,
            ActionState.pending => throw StateError(
              "should be loading for pending state",
            ),
          },
          color: Styles.colorButton,
          onClick: performState.value != ActionState.pending
              ? performAction
              : null,
        );
      },
      orElse: () {
        return TileContent.loading(
          title: title,
          subtitle: subtitle,
          color: Styles.colorOffline,
        );
      },
    );
  }
}
