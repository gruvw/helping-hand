import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_reorderable_grid_view/widgets/widgets.dart";
import "package:helping_hand/state/persistence/providers.dart";
import "package:helping_hand/state/providers.dart";
import "package:helping_hand/static/styles.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class TilesScreen extends HookConsumerWidget {
  const TilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTileId = ref.watch(currentTileIdProvider);
    final folderTiles = ref.watch(folderTilesProvider(currentTileId)).value;
    final scrollController = useScrollController();

    final remote = ref.watch(remoteNotifierProvider(tileId)).value;
    final actions = remote?.actionConfigs;
    if (remote != null) {}

    // TODO back button if the current tile is not null

    if (folderTiles == null) {
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
      children: folderTiles.map((t) {
        return TileFromId(
          key: UniqueKey(),
          tileId: t.id,
        );
      }).toList(),
    );
  }
}
