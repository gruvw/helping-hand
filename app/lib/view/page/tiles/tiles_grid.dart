import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_reorderable_grid_view/widgets/widgets.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/current_tile_id_path_notifier.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/providers.dart";
import "package:helping_hand/state/remote_notifier.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/utils/language.dart";
import "package:helping_hand/view/component/structure/title_bar.dart";
import "package:helping_hand/view/page/tiles/tiles.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class TilesGrid extends HookConsumerWidget {
  const TilesGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTileId = ref.watch(currentTileIdProvider);
    final tiles = ref.watch(tilesProvider).value;
    final scrollController = useScrollController();

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

    final List<Widget> tilesDisplay =
        tiles?.map<Widget>((t) {
          final tileId = t.tileId;
          final key = ValueKey("p=${tileId.parentId};t=${tileId.id}");

          return switch (tileId) {
            FolderTileId() => FolderTile(key: key, id: tileId),
            RemoteTileId() => RemoteTile(key: key, id: tileId),
            RemoteActionTileId() => RemoteActionTile(key: key, id: tileId),
          };
        }).toList() ??
        [];

    // TODO (now) back button if the current tile is not null and in accessible mode
    // tilesDisplay.add(
    //   TileContent(
    //     key: ValueKey("ABC"),
    //     title: "back",
    //     color: Colors.green,
    //     child: Icon(Icons.backup),
    //     onClick: () {
    //       ref.read(currentTileIdPathProvider.notifier).pop();
    //     },
    //   ),
    // );

    final tilesGrid = ReorderableBuilder(
      scrollController: scrollController,
      onReorder: (ReorderedListFunction r) {
        // TODO grid reorder
      },
      lockedIndices: [0],
      builder: (children) {
        return GridView(
          controller: scrollController,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          children: children,
        );
      },
      children: tilesDisplay,
    );

    final content =
        tiles?.nmap(
          (tiles) => tiles.isEmpty
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
              : tilesGrid,
        ) ??
        Center(
          child: CircularProgressIndicator(
            color: Styles.colorPrimary,
          ),
        );

    if (currentTileId.isRootFolder) {
      return content;
    }

    return TitleScreen(
      title: title ?? "",
      child: content,
    );
  }
}
