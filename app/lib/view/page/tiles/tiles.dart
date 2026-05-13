import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:helping_hand/logic/action_state.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/current_tile_id_path_notifier.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/remote_notifier.dart";
import "package:helping_hand/state/remote_request_provider.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/utils/riverpod.dart";
import "package:helping_hand/view/page/tiles/tile_content.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

void useScrollToVisibleWhenSelected(BuildContext context, bool selected) {
  useEffect(() {
    if (selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        }
      });
    }
    return null;
  }, [selected]);
}

class BackTile extends HookConsumerWidget {
  final bool selected;
  final Listenable accessibleEvent;

  const BackTile({
    super.key,
    required this.selected,
    required this.accessibleEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onTap() {
      ref.read(currentTileIdPathProvider.notifier).pop();
    }

    useOnListenableChange(accessibleEvent, () {
      if (selected) {
        onTap();
      }
    });

    useScrollToVisibleWhenSelected(context, selected);

    return TileContent.icon(
      title: "Back",
      color: Styles.colorBack,
      selected: selected,
      iconData: Styles.iconPrevious,
      onTap: onTap,
    );
  }
}

class FolderTile extends HookConsumerWidget {
  final FolderTileId id;
  final bool selected;
  final Listenable accessibleEvent;

  const FolderTile({
    super.key,
    required this.id,
    required this.selected,
    required this.accessibleEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = ref.watch(folderProvider(id.folderId!).whereNotNull());

    void onTap() {
      folder.maybeWhen(
        data: (_) {
          ref.read(currentTileIdPathProvider.notifier).add(id);
        },
        orElse: () {},
      );
    }

    useOnListenableChange(accessibleEvent, () {
      if (selected) {
        onTap();
      }
    });

    useScrollToVisibleWhenSelected(context, selected);

    return folder.maybeWhen(
      data: (folder) => TileContent.icon(
        title: folder.name,
        iconData: Styles.iconFolder,
        color: Styles.colorFolder,
        selected: selected,
        onTap: onTap,
      ),
      orElse: () => TileContent.loading(
        title: "Loading...",
        color: Styles.colorFolder,
        selected: selected,
      ),
    );
  }
}

class RemoteTile extends HookConsumerWidget {
  final RemoteTileId id;
  final bool selected;
  final Listenable accessibleEvent;

  const RemoteTile({
    super.key,
    required this.id,
    required this.selected,
    required this.accessibleEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(
      remoteNotifierProvider(id.remoteId).whereNotNull(),
    );

    void onTap() {
      remote.unwrapPrevious().maybeWhen(
        data: (remote) {
          if (remote.isOnline) {
            ref.read(currentTileIdPathProvider.notifier).add(id);
            return;
          }

          ref.invalidate(remoteConfigProvider(remote.id));
        },
        orElse: () {},
      );
    }

    useOnListenableChange(accessibleEvent, () {
      if (selected) {
        onTap();
      }
    });

    useScrollToVisibleWhenSelected(context, selected);

    return remote.unwrapPrevious().maybeWhen(
      data: (remote) {
        if (remote.isOnline) {
          return TileContent.icon(
            title: remote.name,
            iconData: Styles.iconRemote,
            color: Styles.colorRemote,
            selected: selected,
            onTap: onTap,
          );
        }

        return TileContent.icon(
          title: remote.name,
          iconData: Styles.iconOffline,
          color: Styles.colorOffline,
          selected: selected,
          onTap: onTap,
        );
      },
      orElse: () {
        return TileContent.loading(
          title: remote.value?.name ?? "Loading...",
          color: Styles.colorOffline,
          selected: selected,
        );
      },
    );
  }
}

class RemoteActionTile extends HookConsumerWidget {
  final RemoteActionTileId id;
  final bool selected;
  final Listenable accessibleEvent;

  const RemoteActionTile({
    super.key,
    required this.id,
    required this.selected,
    required this.accessibleEvent,
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

    void onTap() {
      remote.unwrapPrevious().maybeWhen(
        data: (remote) {
          final remoteButtonActions = remote.actionConfigs;
          if (remoteButtonActions == null) {
            ref.invalidate(remoteConfigProvider(id.remoteId));
            return;
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

          if (performState.value != ActionState.pending) {
            performAction();
          }
        },
        orElse: () {},
      );
    }

    useOnListenableChange(accessibleEvent, () {
      if (selected) {
        onTap();
      }
    });

    useScrollToVisibleWhenSelected(context, selected);

    return remote.unwrapPrevious().maybeWhen(
      data: (remote) {
        final remoteButtonActions = remote.actionConfigs;
        if (remoteButtonActions == null) {
          return TileContent.icon(
            title: title,
            subtitle: subtitle,
            iconData: Styles.iconOffline,
            color: Styles.colorOffline,
            selected: selected,
            onTap: onTap,
          );
        }

        if (performState.value == ActionState.pending) {
          return TileContent.loading(
            key: key,
            title: title,
            subtitle: subtitle,
            color: Styles.colorButton,
            selected: selected,
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
          selected: selected,
          onTap: onTap,
        );
      },
      orElse: () {
        return TileContent.loading(
          title: title,
          subtitle: subtitle,
          color: Styles.colorOffline,
          selected: selected,
        );
      },
    );
  }
}
