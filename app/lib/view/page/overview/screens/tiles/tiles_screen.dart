import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_reorderable_grid_view/widgets/widgets.dart";
import "package:helping_hand/model/data/tile_data.dart";
import "package:helping_hand/state/providers.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/page/overview/screens/tiles/tiles.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class TilesScreen extends HookConsumerWidget {
  const TilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final currentTileId = ref.watch(currentTileIdProvider);
    final tiles = ref.watch(tilesProvider).value;
    final scrollController = useScrollController();

    if (tiles == null) {
      return Center(
        child: CircularProgressIndicator(
          color: Styles.colorPrimary,
        ),
      );
    }

    // TODO back button if the current tile is not null

    if (tiles.isEmpty) {
      return Center(
        child: Text("No tiles.\nAdd new tiles using the context menu."),
      );
    }

    return ReorderableBuilder(
      scrollController: scrollController,
      onReorder: (ReorderedListFunction r) {
        // TODO grid reorder
      },
      builder: (children) {
        return GridView(
          controller: scrollController,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 100,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          children: children,
        );
      },
      children: tiles.map((t) {
        return switch (t.id) {
          FolderTileId id => FolderTile(id: id),
          RemoteTileId id => RemoteTile(id: id),
          RemoteActionTileId id => RemoteActionTile(id: id),
        };
      }).toList(),
    );
  }
}
