import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_reorderable_grid_view/widgets/widgets.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/static/styles.dart";
import "package:helping_hand/view/page/overview/screens/tiles/tile.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class TilesScreen extends HookConsumerWidget {
  const TilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFolderId = ref.watch(currentFolderIdProvider);
    final tiles = ref.watch(tilesProvider(currentFolderId)).value;
    final scrollController = useScrollController();

    if (tiles == null) {
      return Center(
        child: CircularProgressIndicator(
          color: Styles.colorPrimary,
        ),
      );
    }

    // TODO empty case

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
        return Tile(
          key: UniqueKey(),
          tileId: t.id,
        );
      }).toList(),
    );
  }
}
