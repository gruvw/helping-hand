import "package:helping_hand/model/data/tile_data.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class CurrentTileIdPathNotifier extends Notifier<List<TileId>> {
  CurrentTileIdPathNotifier();

  @override
  List<TileId> build() {
    return [];
  }

  bool pop() {
    if (state.isEmpty) return false;

    state = [...state]..removeLast();
    return true;
  }

  void add(TileId next) {
    state = [...state, next];
  }
}

final currentTileIdPathProvider =
    NotifierProvider<CurrentTileIdPathNotifier, List<TileId>>(
      CurrentTileIdPathNotifier.new,
    );

final currentTileIdProvider = Provider<TileId>(
  (ref) {
    final path = ref.watch(currentTileIdPathProvider);
    return path.isEmpty ? TileId.rootFolder : path.last;
  },
);
