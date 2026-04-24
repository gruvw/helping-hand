import "package:hooks_riverpod/legacy.dart";

/// Can be a remote id or a folder id, if null it is the root folder.
final currentTileIdProvider = StateProvider<String?>((ref) => null);
