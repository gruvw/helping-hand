import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart";
import "package:flutter_reorderable_grid_view/widgets/widgets.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/current_tile_id_path_notifier.dart";
import "package:helping_hand/state/persistence/kvs/providers.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/providers.dart";
import "package:helping_hand/state/remote_notifier.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/utils/language.dart";
import "package:helping_hand/view/component/structure/title_bar.dart";
import "package:helping_hand/view/page/tiles/tile_content.dart";
import "package:helping_hand/view/page/tiles/tiles.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class TilesGrid extends HookConsumerWidget {
  const TilesGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTileId = ref.watch(currentTileIdProvider);
    final tiles = ref.watch(tilesProvider).value ?? [];
    final accessibleUi = ref.watch(kvsAccessibleUiProvider).value ?? false;
    final scrollController = useScrollController();

    final displayBack = accessibleUi && !currentTileId.isRootFolder;

    final title = currentTileId.id?.nmap(
      (_) => switch (currentTileId) {
        FolderTileId id => ref.watch(folderProvider(id.folderId!)).value?.name,
        RemoteTileId id =>
          ref.watch(remoteNotifierProvider(id.remoteId)).value?.name,
        RemoteActionTileId() => throw StateError(
          "should never have a remote action parent tile",
        ),
      },
    );
    final emptyMessage = switch (currentTileId) {
      FolderTileId() =>
        "There are currently no tiles on this page.\nAdd new tiles using the top right context menu.",
      RemoteTileId() =>
        "There are currently no action for this remote.\nConfigure a new action using the remote manager.",
      RemoteActionTileId() => throw StateError(
        "should never have a remote action parent tile",
      ),
    };

    final totalTiles = tiles.length + (displayBack ? 1 : 0);

    final tilesDisplay = List.generate(
      totalTiles,
      (index) {
        if (index == 0 && displayBack) {
          return TileContent.icon(
            key: ValueKey("back$currentTileId"),
            title: "Back",
            color: Styles.colorBack,
            selected: false,
            iconData: Styles.iconPrevious,
            onClick: () {
              ref.read(currentTileIdPathProvider.notifier).pop();
            },
          );
        }

        final tileId = tiles[index + (displayBack ? -1 : 0)].tileId;
        final key = ValueKey(tileId.toString());

        return switch (tileId) {
          FolderTileId() => FolderTile(key: key, id: tileId),
          RemoteTileId() => RemoteTile(key: key, id: tileId),
          RemoteActionTileId() => RemoteActionTile(key: key, id: tileId),
        };
      },
      growable: false,
    );

    // TODO accessible mode tile select rotation

    final tilesGrid = ReorderableBuilder(
      key: ValueKey(currentTileId.toString()),
      animationConfig: ReorderableAnimationConfig(
        fadeInDuration: Duration(milliseconds: 200),
      ),
      scrollController: scrollController,
      enableDraggable: true,
      onReorderPositions: (newPositions) {
        // TODO grid reorder
      },
      lockedIndices: displayBack ? [0] : [],
      builder: (children) {
        const spacing = 4.0;

        return GridView(
          controller: scrollController,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
          ),
          children: children,
        );
      },
      children: tilesDisplay,
    );

    final content = tiles.isEmpty
        ? Stack(
            children: [
              tilesGrid,
              Center(
                child: Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        : tilesGrid;

    if (currentTileId.isRootFolder) {
      return content;
    }

    return TitleScreen(
      title: title ?? "",
      child: content,
    );
  }
}
